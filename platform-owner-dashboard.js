const SUPABASE_URL='https://gxsrajtqzdjvmceqcpgv.supabase.co';
const KEY='sb_publishable_Y8NRuGXqHNTu9oaolrpprw_wysMNLuz';
const SESSION_KEY='tradeflow_platform_owner_session';
let session=null;

const $=id=>document.getElementById(id);
try{session=JSON.parse(localStorage.getItem(SESSION_KEY)||'null')}catch{}

function save(){if(session?.access_token)localStorage.setItem(SESSION_KEY,JSON.stringify(session));else localStorage.removeItem(SESSION_KEY)}

async function request(path,options={},retry=true){
  const headers=new Headers(options.headers||{});
  headers.set('apikey',KEY);
  if(session?.access_token)headers.set('Authorization',`Bearer ${session.access_token}`);
  if(options.body)headers.set('Content-Type','application/json');
  const controller=new AbortController();const timeout=setTimeout(()=>controller.abort(),12000);let response;try{response=await fetch(`${SUPABASE_URL}${path}`,{...options,headers,signal:controller.signal})}catch(err){if(err?.name==='AbortError')throw Error(`Request timed out: ${path}`);throw err}finally{clearTimeout(timeout)}
  const text=await response.text();
  let body=null;try{body=text?JSON.parse(text):null}catch{body=text}
  if(!response.ok){
    if(response.status===401&&retry&&session?.refresh_token){
      const refreshed=await fetch(`${SUPABASE_URL}/auth/v1/token?grant_type=refresh_token`,{method:'POST',headers:{apikey:KEY,'Content-Type':'application/json'},body:JSON.stringify({refresh_token:session.refresh_token})});
      const rb=await refreshed.json();
      if(refreshed.ok&&rb?.access_token){session={...rb,user:session.user};save();return request(path,options,false)}
    }
    throw Error(body?.message||body?.msg||body?.error_description||body?.error||text||`HTTP ${response.status}`);
  }
  return body;
}

function showAuth(message=''){
  let overlay=document.getElementById('owner-auth');
  if(!overlay){
    overlay=document.createElement('div');
    overlay.id='owner-auth';
    overlay.style.cssText='position:fixed;inset:0;background:rgba(0,0,0,.55);display:flex;align-items:center;justify-content:center;padding:24px;z-index:999';
    overlay.innerHTML='<div style="width:min(430px,100%);background:#fff;border-radius:12px;padding:28px;box-shadow:0 20px 70px rgba(0,0,0,.3)"><div style="font-size:.72rem;text-transform:uppercase;letter-spacing:.12em;font-weight:800;color:#c46a2b">TradeFlow platform</div><h2>Owner sign in</h2><p>Sign in with your platform owner account.</p><label>Email<input id="owner-email-input" type="email" autocomplete="username" style="display:block;width:100%;box-sizing:border-box;padding:10px;margin-top:6px"></label><label style="display:block;margin-top:14px">Password<input id="owner-password-input" type="password" autocomplete="current-password" style="display:block;width:100%;box-sizing:border-box;padding:10px;margin-top:6px"></label><button id="owner-signin" type="button" style="margin-top:16px;padding:10px 16px">Sign in</button><button id="owner-forgot" type="button" style="margin:10px 0 0;padding:8px 0;border:0;background:none;color:#1f5f9d;text-decoration:underline;cursor:pointer">Forgot your password?</button><div id="owner-reset-box" style="display:none;margin-top:14px;padding-top:14px;border-top:1px solid #e5e7eb"><label>Owner email<input id="owner-reset-email" type="email" autocomplete="email" style="display:block;width:100%;box-sizing:border-box;padding:10px;margin-top:6px"></label><button id="owner-reset" type="button" style="margin-top:10px;padding:9px 14px">Send reset email</button><div id="owner-reset-status" style="margin-top:10px;color:#596774"></div></div><div id="owner-auth-error" style="color:#a32929;margin-top:12px"></div></div>';
    document.body.appendChild(overlay);
    $('owner-signin').onclick=signIn;
    $('owner-forgot').onclick=toggleOwnerReset;
    $('owner-reset').onclick=requestOwnerPasswordReset;
    $('owner-password-input').onkeydown=e=>{if(e.key==='Enter')signIn()};
  }
  overlay.hidden=false;overlay.style.display='flex';$('owner-auth-error').textContent=message;
}

function hideAuth(){const el=$('owner-auth');if(el){el.hidden=true;el.style.display='none'}}
function toggleOwnerReset(){
  const box=$('owner-reset-box');
  if(!box)return;
  box.style.display=box.style.display==='none'?'block':'none';
  const email=$('owner-email-input')?.value.trim();
  if(email&&!$('owner-reset-email').value)$('owner-reset-email').value=email;
  $('owner-reset-status').textContent='';
}
async function requestOwnerPasswordReset(){
  const email=$('owner-reset-email').value.trim();
  const status=$('owner-reset-status'),button=$('owner-reset');
  if(!email){status.textContent='Enter the owner email address.';return}
  button.disabled=true;status.textContent='Sending reset email…';
  try{
    const redirectTo=new URL('/owner-reset-password',location.origin).href;
    const response=await fetch(`${SUPABASE_URL}/auth/v1/recover`,{
      method:'POST',
      headers:{apikey:KEY,'Content-Type':'application/json'},
      body:JSON.stringify({email,redirect_to:redirectTo})
    });
    const body=await response.text();
    let data=null;try{data=body?JSON.parse(body):null}catch{}
    if(!response.ok)throw Error(data?.msg||data?.message||data?.error_description||body||`HTTP ${response.status}`);
    status.textContent='If that email belongs to the TradeFlow platform owner, a password reset email has been sent.';
  }catch(e){status.textContent=e.message||String(e)}
  finally{button.disabled=false}
}

async function establish(){
  const user=await request('/auth/v1/user');
  session.user=user;save();
  const memberships=await request(`/rest/v1/platform_memberships?select=id,status&user_id=eq.${encodeURIComponent(user.id)}&status=eq.active&limit=1`);
  if(!Array.isArray(memberships)||!memberships.length)throw Error('This account is not an active TradeFlow platform owner.');
  $('owner-email').textContent=user.email||'Platform Owner';
}

async function signIn(){
  const button=$('owner-signin'),error=$('owner-auth-error');
  const email=$('owner-email-input').value.trim(),password=$('owner-password-input').value;
  if(!email||!password){error.textContent='Enter your email and password.';return}
  button.disabled=true;button.textContent='Signing in…';error.textContent='';
  try{
    session=await request('/auth/v1/token?grant_type=password',{method:'POST',body:JSON.stringify({email,password})});
    save();await establish();hideAuth();await loadTenants();await loadPlans();await loadPlatformEmail();await loadDomainActions();await loadProductPages();await loadCloudAiProviders();await loadCloudAiJobs();await loadCloudAiReviewQueue();await loadManualAiResearchBatches();await window.loadPublicPages?.();
  }catch(e){session=null;save();error.textContent=e.message||String(e)}
  finally{button.disabled=false;button.textContent='Sign in'}
}


async function prepareCloudflareConnection(actionId){
  const out=document.querySelector('[data-domain-status="'+actionId+'"]');
  const buttons=[...document.querySelectorAll('[data-domain-phase="'+actionId+'"]')];
  buttons.forEach(b=>b.disabled=true);
  if(out)out.textContent='Preparing Cloudflare connection…';
  try{
    // Explicitly require the authenticated Platform Owner JWT for this
    // protected Edge Function. Do not rely on an implicit browser header.
    if(!session?.access_token) throw Error('Your Platform Owner session has expired. Please sign in again.');
    if(out)out.textContent='Sending authenticated request to Supabase…';
    console.debug('[TradeFlow custom-domain] Step 2 request', {
      endpoint:'/functions/v1/platform-prepare-custom-domain',
      action_id:actionId,
      has_access_token:!!session?.access_token
    });
    const result=await request('/functions/v1/platform-prepare-custom-domain',{
      method:'POST',
      headers:{
        Authorization:`Bearer ${session.access_token}`
      },
      body:JSON.stringify({action_id:actionId})
    });
    console.debug('[TradeFlow custom-domain] Step 2 response', result);
    if(out)out.textContent='Connection prepared automatically.';
    await loadDomainActions();
    return result;
  }catch(e){
    console.error('[TradeFlow custom-domain] Step 2 failed', e);
    if(out)out.textContent='Supabase/Cloudflare error: '+(e.message||String(e));
    buttons.forEach(b=>b.disabled=false);
    throw e;
  }
}

async function loadDomainActions(){
  const root=$('domain-actions-list'),error=$('domain-actions-error');
  if(!root)return;
  error.textContent='';
  root.innerHTML='<p class="muted">Loading domain requests…</p>';

  const phases=[
    {key:'reviewed',title:'Step 1 — Review the request',text:'Confirm the subscriber, hostname and tenant match. Check that the hostname is not already in use.',button:'Confirm request reviewed'},
    {key:'connection_prepared',title:'Step 2 — Prepare the TradeFlow connection',text:'Prepare the approved Cloudflare custom-hostname connection for this subscriber. Do not invent a DNS target. Record the exact DNS instruction returned by the approved connection setup.',button:'Mark connection prepared'},
    {key:'customer_instructions_sent',title:'Step 3 — Give the customer the DNS instructions',text:'Give the customer the exact DNS record(s) they must add at their registrar. Never request their registrar password.',button:'Mark instructions issued'},
    {key:'dns_verified',title:'Step 4 — Verify DNS',text:'Wait for the customer to make the DNS change, then verify that the hostname resolves to the approved TradeFlow connection.',button:'DNS verified'},
    {key:'ssl_verified',title:'Step 5 — Verify SSL / HTTPS',text:'Confirm the customer hostname has a valid HTTPS connection before activation.',button:'SSL verified'},
    {key:'routing_verified',title:'Step 6 — Verify tenant routing',text:'Confirm the hostname serves the correct subscriber website and cannot resolve to another tenant.',button:'Routing verified'},
    {key:'activated',title:'Step 7 — Activate the domain',text:'Only activate after DNS, SSL and tenant routing have all been verified.',button:'Activate domain'}
  ];

  function phaseIndex(meta){
    if(meta.activated)return 7;
    if(meta.routing_verified)return 6;
    if(meta.ssl_verified)return 5;
    if(meta.dns_verified)return 4;
    if(meta.customer_instructions_sent)return 3;
    if(meta.connection_prepared)return 2;
    if(meta.reviewed)return 1;
    return 0;
  }

  try{
    const rows=await request('/rest/v1/rpc/platform_owner_list_domain_actions',{method:'POST',body:'{}'});
    if(!Array.isArray(rows)||!rows.length){
      root.innerHTML='<p class="muted">No open subscriber domain connection requests.</p>';
      return;
    }

    root.innerHTML=rows.map(row=>{
      const m=row.metadata||{};
      const current=phaseIndex(m);
      const completed=(key)=>!!m[key];
      const disabled=(i)=>i>current+1||row.action_status==='active';
      const dns=String(m.dns_instructions||'');
      const notes=String(row.notes||'');
      const statusLabel=row.action_status==='dns_ready'?'DNS ready':row.action_status==='verified'?'Verified':row.action_status==='verification_failed'?'Verification failed':row.action_status==='active'?'Active':'Requested';

      return '<article class="note" style="margin-top:12px;padding:18px">'+
        '<div style="display:flex;justify-content:space-between;gap:16px;align-items:flex-start">'+
          '<div><strong>'+escapeHtml(row.tenant_name||'Subscriber')+'</strong><div style="margin-top:4px"><strong>'+escapeHtml(row.hostname)+'</strong></div><div class="muted">Requested '+formatDate(row.created_at)+' · '+escapeHtml(statusLabel)+'</div></div>'+
          '<span class="eyebrow">Phase '+Math.min(current+1,7)+' of 7</span>'+
        '</div>'+
        '<div style="margin-top:16px;display:grid;gap:10px">'+
          phases.map((p,i)=>{
            const done=completed(p.key);
            const isNext=!done&&i===current;
            return '<div style="border:1px solid '+(done?'#b7d7bd':isNext?'#d9b27c':'#e5e7eb')+';border-radius:8px;padding:12px;background:'+(done?'#f4faf5':isNext?'#fffaf2':'#fff')+'">'+
              '<div style="display:flex;justify-content:space-between;gap:12px;align-items:flex-start"><div><strong>'+(done?'✓ ':'')+escapeHtml(p.title)+'</strong><p class="muted" style="margin:5px 0 0">'+escapeHtml(p.text)+'</p></div>'+
              (done?'<span class="muted">Completed</span>':isNext?(p.key==='connection_prepared'?'<button type="button" data-domain-phase="'+escapeAttr(row.action_id)+'" data-phase="'+p.key+'">Prepare connection automatically</button>':'<button type="button" data-domain-phase="'+escapeAttr(row.action_id)+'" data-phase="'+p.key+'">'+escapeHtml(p.button)+'</button>'):'<span class="muted">Waiting</span>')+
              '</div>'+
              (p.key==='connection_prepared'&&isNext?'<div class="note" style="margin-top:10px"><strong>Preparation checklist</strong><ol style="margin:8px 0 0 20px"><li>Confirm the hostname belongs to this subscriber.</li><li>Prepare the approved Cloudflare custom-hostname connection.</li><li>Use the actual DNS target supplied by that connection.</li><li>Do not activate the TradeFlow domain yet.</li></ol></div>':'')+
              '</div>';
          }).join('')+
        '</div>'+
        '<label style="display:block;margin-top:14px"><strong>Exact DNS instructions for customer</strong><textarea data-domain-dns="'+escapeAttr(row.action_id)+'" rows="4" placeholder="Enter the exact DNS record(s) returned by the approved connection setup.">'+escapeHtml(dns)+'</textarea></label>'+
        '<label style="display:block;margin-top:12px"><strong>Owner notes</strong><textarea data-domain-notes="'+escapeAttr(row.action_id)+'" rows="3" placeholder="Record verification notes, customer corrections or other owner information.">'+escapeHtml(notes)+'</textarea></label>'+
        '<div style="display:flex;gap:12px;align-items:center;margin-top:12px"><button type="button" data-domain-save="'+escapeAttr(row.action_id)+'">Save notes / DNS instructions</button><span class="muted" data-domain-status="'+escapeAttr(row.action_id)+'"></span></div>'+
      '</article>';
    }).join('');

    root.querySelectorAll('[data-domain-phase]').forEach(btn=>btn.onclick=async()=>{
      const id=btn.dataset.domainPhase,key=btn.dataset.phase;
      if(key==='connection_prepared'){try{await prepareCloudflareConnection(id)}catch(e){console.error('[TradeFlow custom-domain] click handler failed',e)}return;}
      const status=root.querySelector('[data-domain-action-status="'+id+'"]');
      const out=root.querySelector('[data-domain-status="'+id+'"]');
      btn.disabled=true;
      if(out)out.textContent='Saving…';
      try{
        const dns=root.querySelector('[data-domain-dns="'+id+'"]').value.trim();
        const notes=root.querySelector('[data-domain-notes="'+id+'"]').value.trim();
        if(key==='connection_prepared'&&!dns)throw Error('Enter the exact DNS instructions before marking the connection prepared.');
        if(key==='customer_instructions_sent'&&!dns)throw Error('Enter the exact DNS instructions before issuing them to the customer.');
        const meta={};
        meta[key]=true;
        if(dns)meta.dns_instructions=dns;
        if(key==='dns_verified')meta.dns_verified=true;
        if(key==='ssl_verified')meta.ssl_verified=true;
        if(key==='routing_verified')meta.routing_verified=true;
        if(key==='activated'){
          const currentRow=rows.find(r=>r.action_id===id);
          const currentMetadata=currentRow?.metadata||{};
          if(currentMetadata.dns_verified!==true || currentMetadata.ssl_verified!==true || currentMetadata.routing_verified!==true)throw Error('DNS, SSL and tenant routing must all be verified before activation.');
          meta.activated=true;meta.dns_verified=true;meta.ssl_verified=true;meta.routing_verified=true;
        }
        let actionStatus='requested';
        if(key==='connection_prepared'||key==='customer_instructions_sent')actionStatus='dns_ready';
        if(key==='dns_verified'||key==='ssl_verified'||key==='routing_verified')actionStatus='dns_ready';
        if(key==='activated')actionStatus='active';
        await request('/rest/v1/rpc/platform_owner_update_domain_action',{method:'POST',body:JSON.stringify({p_action_id:id,p_status:actionStatus,p_notes:notes,p_metadata:meta})});
        if(out)out.textContent='Saved';
        await loadDomainActions();
      }catch(e){
        if(out)out.textContent=e.message||String(e);
        btn.disabled=false;
      }
    });

    root.querySelectorAll('[data-domain-save]').forEach(btn=>btn.onclick=async()=>{
      const id=btn.dataset.domainSave,out=root.querySelector('[data-domain-status="'+id+'"]');
      const dns=root.querySelector('[data-domain-dns="'+id+'"]').value.trim();
      const notes=root.querySelector('[data-domain-notes="'+id+'"]').value.trim();
      btn.disabled=true;if(out)out.textContent='Saving…';
      try{
        await request('/rest/v1/rpc/platform_owner_update_domain_action',{method:'POST',body:JSON.stringify({p_action_id:id,p_status:rows.find(r=>r.action_id===id)?.action_status||'requested',p_notes:notes,p_metadata:{dns_instructions:dns}})});
        if(out)out.textContent='Saved';await loadDomainActions();
      }catch(e){if(out)out.textContent=e.message||String(e);btn.disabled=false}
    });
  }catch(e){
    error.textContent=e.message||String(e);
    root.innerHTML='';
  }
}
async function loadPlatformEmail(){
 const status=$('platform-email-status'),input=$('platform-email-input');if(!status||!input)return;
 try{
  const data=await request('/rest/v1/rpc/platform_owner_get_email',{method:'POST',body:'{}'});
  input.value=data?.sender_email||'';
  const s=data?.sender_verification_status||'not_configured';
  status.textContent=s==='verified'?'Status: Ready — TradeFlow can send platform emails.':s==='pending'?'Status: Saved — sender/domain verification is still required.':'Status: Not configured.';
 }catch(e){status.textContent=e.message||String(e)}
}
async function savePlatformEmail(e){
 e.preventDefault();const input=$('platform-email-input'),status=$('platform-email-status'),email=input.value.trim().toLowerCase();
 if(!email){status.textContent='Enter the TradeFlow email address.';return}
 try{
  status.textContent='Saving…';
  const data=await request('/rest/v1/rpc/platform_owner_save_email',{method:'POST',body:JSON.stringify({p_email:email})});
  status.textContent='Status: '+(data?.sender_verification_status==='verified'?'Ready — TradeFlow can send platform emails.':'Saved — sender/domain verification is still required.');
 }catch(e){status.textContent=e.message||String(e)}
}
function nextPlan(code){return null}
function setActionMessage(text,isError=false){const el=$('action-message');if(el){el.textContent=text;el.className=isError?'action-message error':'action-message'}}
async function manageSubscription(tenantId,action,planCode,name){if(action==='close'&&!confirm('Close the TradeFlow account for "'+name+'"? The tenant will be archived and its subscription cancelled. This does not delete its stored business data.'))return;if(action==='upgrade'&&!confirm('Upgrade "'+name+'" to '+planCode+'?'))return;setActionMessage(action==='close'?'Closing account…':'Updating subscription…');try{await request('/rest/v1/rpc/platform_admin_manage_subscription',{method:'POST',body:JSON.stringify({p_tenant_id:tenantId,p_action:action,p_plan_code:planCode})});setActionMessage(action==='close'?'Account closed.':'Subscription upgraded.');await loadTenants()}catch(e){setActionMessage(e.message||String(e),true)}}
async function loadTenants(){const error=$('error');error.textContent='';$('tenant-rows').innerHTML='<tr><td colspan="9">Loading…</td></tr>';try{const [rows,accounts]=await Promise.all([request('/rest/v1/rpc/platform_admin_list_tenants',{method:'POST',body:'{}'}),request('/rest/v1/rpc/platform_admin_list_subscriber_accounts',{method:'POST',body:'{}'})]);const tenants=Array.isArray(rows)?rows:[],subscriberAccounts=Array.isArray(accounts)?accounts:[],subscriberIds=new Set(subscriberAccounts.map(x=>x.tenant_id)),subscriberTenants=tenants.filter(x=>subscriberIds.has(x.tenant_id));$('tenant-count').textContent=subscriberAccounts.length;$('active-count').textContent=subscriberAccounts.filter(x=>x.business_status==='active').length;$('tradeflow-count').textContent=subscriberTenants.filter(x=>x.plan_code==='enhanced').length;if(!subscriberAccounts.length){$('tenant-rows').innerHTML='<tr><td colspan="9">No subscriber businesses found.</td></tr>';return}const tenantMap=new Map(subscriberTenants.map(x=>[x.tenant_id,x]));$('tenant-rows').innerHTML=subscriberAccounts.map(t=>{const d=tenantMap.get(t.tenant_id)||{},current=d.plan_code||'—',next=nextPlan(current);let actions='';if(t.business_status==='archived'){actions='<span class="muted">Closed</span>'}else{actions+='<button class="table-action danger" data-action="close" data-tenant="'+t.tenant_id+'" data-name="'+escapeAttr(t.business_name)+'">Close account</button>'}return '<tr><td><strong>'+escapeHtml(t.business_name||'—')+'</strong></td><td>'+escapeHtml(t.owner_name||'—')+'</td><td>'+escapeHtml(t.owner_email||'—')+'</td><td>'+escapeHtml(current)+'</td><td>'+escapeHtml(d.subscription_status||'—')+'</td><td>'+escapeHtml(t.business_status||'—')+'</td><td>'+formatDate(t.joined_at)+'</td><td><a class="table-action" href="public-site.html?tenant_id='+encodeURIComponent(t.tenant_id)+'" target="_blank" rel="noopener">View website</a></td><td class="actions-cell">'+actions+'</td></tr>'}).join('');document.querySelectorAll('[data-action]').forEach(b=>b.onclick=()=>manageSubscription(b.dataset.tenant,b.dataset.action,b.dataset.plan,b.dataset.name))}catch(e){error.textContent=e.message||String(e);$('tenant-rows').innerHTML='<tr><td colspan="9">Unable to load platform data.</td></tr>'}}
async function loadProductPages(){
 const host=$('product-pages-list'),error=$('product-pages-error');if(!host)return;
 error.textContent='';host.innerHTML='<p class="muted">Loading product pages…</p>';
 try{
  const rows=await request('/rest/v1/rpc/platform_owner_get_product_pages',{method:'POST',body:'{}'});
  if(!Array.isArray(rows)||!rows.length){host.innerHTML='<p class="muted">No product pages are configured.</p>';return}
  host.innerHTML=rows.map(p=>'<form class="plan-editor product-page-editor" data-product-slug="'+escapeAttr(p.slug)+'">'+
   '<div class="plan-editor-head"><div><div class="eyebrow">'+escapeHtml(p.slug)+'</div><h3>'+escapeHtml(p.product_name)+'</h3></div>'+
   '<label class="plan-live">Page status<select name="status"><option value="published" '+(p.status==='published'?'selected':'')+'>Published</option><option value="coming_soon" '+(p.status==='coming_soon'?'selected':'')+'>Coming soon</option><option value="hidden" '+(p.status==='hidden'?'selected':'')+'>Hidden</option></select></label></div>'+
   '<label>Product name<input name="product_name" maxlength="80" required value="'+escapeAttr(p.product_name)+'"></label>'+
   '<label>Headline<input name="headline" maxlength="180" required value="'+escapeAttr(p.headline)+'"></label>'+
   '<label>Tagline<input name="tagline" maxlength="300" value="'+escapeAttr(p.tagline||'')+'"></label>'+
   '<label>Description<textarea name="description" maxlength="2000" rows="4">'+escapeHtml(p.description||'')+'</textarea></label>'+
   '<div class="plan-fields"><label>Link label<input name="button_label" maxlength="80" value="'+escapeAttr(p.button_label||'')+'"></label><label>Link destination<input name="button_url" maxlength="500" value="'+escapeAttr(p.button_url||'')+'" placeholder="https://… or /studioflow"></label></div>'+
   '<div class="plan-editor-foot"><span class="plan-status" aria-live="polite"></span><button class="table-action" type="submit">Save '+escapeHtml(p.product_name)+' page</button></div></form>').join('');
  host.querySelectorAll('.product-page-editor').forEach(form=>form.onsubmit=saveProductPage);
 }catch(e){error.textContent=e.message||String(e);host.innerHTML='<p class="muted">Unable to load product pages. The product-page database migration may not have been applied yet.</p>'}
}
async function saveProductPage(e){
 e.preventDefault();const form=e.currentTarget,status=form.querySelector('.plan-status'),button=form.querySelector('button[type="submit"]'),data=new FormData(form);
 const slug=form.dataset.productSlug;
 const payload={p_slug:slug,p_product_name:String(data.get('product_name')||''),p_status:String(data.get('status')||'coming_soon'),p_headline:String(data.get('headline')||''),p_tagline:String(data.get('tagline')||''),p_description:String(data.get('description')||''),p_button_label:String(data.get('button_label')||''),p_button_url:String(data.get('button_url')||'')};
 button.disabled=true;status.textContent='Saving…';
 try{await request('/rest/v1/rpc/platform_owner_update_product_page',{method:'POST',body:JSON.stringify(payload)});status.textContent='Saved. Public page content will update on refresh.';await loadProductPages()}
 catch(err){status.textContent=err.message||String(err)}
 finally{button.disabled=false}
}
function planPrice(value,currency='GBP'){if(value===null||value===undefined||value==='')return'';try{return new Intl.NumberFormat('en-GB',{style:'currency',currency}).format(Number(value))}catch{return String(value)}}
function renderPlanAdmin(plans){
 const host=$('plan-admin-list');if(!host)return;
 if(!plans.length){host.innerHTML='<p class="muted">No commercial plans configured.</p>';return}
 host.innerHTML=plans.map(p=>'<form class="plan-editor" data-plan-id="'+p.id+'">'+
 '<div class="plan-editor-head"><div><div class="eyebrow">'+escapeHtml(p.code)+'</div><h3>'+escapeHtml(p.name)+'</h3></div><label class="plan-live"><input name="website_visible" type="checkbox" '+(p.website_visible?'checked':'')+'> Live on website</label></div>'+
 '<label>Plan name<input name="name" value="'+escapeAttr(p.name)+'" required></label>'+
 '<label>Description<textarea name="description" rows="3">'+escapeHtml(p.description||'')+'</textarea></label>'+
 '<div class="plan-fields"><label>Monthly price<input name="monthly_price" type="number" min="0" step="0.01" value="'+(p.monthly_price??'')+'" placeholder="59.99"></label>'+
 '<label>Annual price<input name="annual_price" type="number" min="0" step="0.01" value="'+(p.annual_price??'')+'" placeholder="Optional"></label>'+
 '<label>Currency<input name="currency" maxlength="3" value="'+escapeAttr(p.currency||'GBP')+'"></label>'+
 '<label>Free trial (days)<input name="trial_days" type="number" min="0" max="3650" step="1" value="'+(p.trial_days??30)+'"></label></div>'+
 '<div class="stripe-box"><strong>Stripe</strong><span class="muted">LIVE subscriber billing identifiers.</span>'+
 '<label>Stripe Product ID<input name="stripe_product_id" value="'+escapeAttr(p.stripe_product_id||'')+'" placeholder="Created by TradeFlow"></label>'+
 '<label>Stripe monthly Price ID<input name="stripe_monthly_price_id" value="'+escapeAttr(p.stripe_monthly_price_id||'')+'" placeholder="Created by TradeFlow"></label>'+
 '<label>Stripe annual Price ID<input name="stripe_annual_price_id" value="'+escapeAttr(p.stripe_annual_price_id||'')+'" placeholder="Optional"></label></div>'+
 '<div class="plan-editor-foot"><span class="plan-status" aria-live="polite"></span><button class="table-action" type="submit">Save plan</button>' +
 (p.stripe_monthly_price_id?'':'<button class="table-action" type="button" data-create-stripe="1">Create Stripe billing</button>') +
 '</div></form>').join('');
 document.querySelectorAll('.plan-editor').forEach(form=>{form.onsubmit=savePlan;const create=form.querySelector('[data-create-stripe]');if(create)create.onclick=()=>createStripeBilling(form);});
}
async function setupStripeBilling(){
 const status=$('stripe-setup-status'),button=$('setup-stripe');if(!status||!button)return;
 button.disabled=true;status.textContent='Setting up Stripe billing…';
 try{
  await request('/auth/v1/user');
  const response=await fetch(SUPABASE_URL+'/functions/v1/platform-create-stripe-product',{method:'POST',headers:{apikey:KEY,Authorization:'Bearer '+session.access_token,'Content-Type':'application/json'},body:'{}'});
  const body=await response.json().catch(()=>null);
  if(!response.ok)throw Error(body?.error||'Stripe billing setup failed.');
  status.textContent='Stripe billing is ready. Product '+body.product_id+' · Monthly price '+body.price_id+'.';
  await loadPlans();
 }catch(e){status.textContent=e.message||String(e)}
 finally{button.disabled=false}
}
async function createStripeBilling(form){const status=form.querySelector('.plan-status'),button=form.querySelector('[data-create-stripe]');button.disabled=true;status.textContent='Creating LIVE Stripe Product and monthly Price…';try{await request('/auth/v1/user');const r=await fetch(SUPABASE_URL+'/functions/v1/platform-create-stripe-product',{method:'POST',headers:{apikey:KEY,Authorization:'Bearer '+session.access_token,'Content-Type':'application/json'},body:'{}'});const t=await r.text();let d=null;try{d=t?JSON.parse(t):null}catch{}if(!r.ok)throw Error(d?.error||d?.message||t||'Stripe billing setup failed.');status.textContent='Stripe billing created: '+d.product_id+' / '+d.price_id;await loadPlans()}catch(e){status.textContent=e.message||String(e)}finally{button.disabled=false}}
async function loadPlans(){
 const error=$('plans-error'),host=$('plan-admin-list');if(!host)return;
 error.textContent='';host.innerHTML='<p class="muted">Loading plans…</p>';
 try{const rows=await request('/rest/v1/rpc/platform_owner_get_plans',{method:'POST',body:'{}'});renderPlanAdmin(Array.isArray(rows)?rows:[])}
 catch(e){error.textContent=e.message||String(e);host.innerHTML='<p class="muted">Unable to load commercial plans.</p>'}
}
async function savePlan(e){
 e.preventDefault();const form=e.currentTarget,status=form.querySelector('.plan-status'),button=form.querySelector('button[type="submit"]'),data=new FormData(form);
 const payload={p_plan_id:form.dataset.planId,p_name:String(data.get('name')||''),p_description:String(data.get('description')||''),p_website_visible:data.get('website_visible')==='on',p_monthly_price:String(data.get('monthly_price')||'')===''?null:Number(data.get('monthly_price')),p_annual_price:String(data.get('annual_price')||'')===''?null:Number(data.get('annual_price')),p_currency:String(data.get('currency')||'GBP'),p_trial_days:Number(data.get('trial_days')||30),p_stripe_product_id:String(data.get('stripe_product_id')||''),p_stripe_monthly_price_id:String(data.get('stripe_monthly_price_id')||''),p_stripe_annual_price_id:String(data.get('stripe_annual_price_id')||'')};
 button.disabled=true;status.textContent='Saving…';
 try{await request('/rest/v1/rpc/platform_owner_update_plan',{method:'POST',body:JSON.stringify(payload)});status.textContent='Saved.';await loadPlans()}
 catch(err){status.textContent=err.message||String(err)}
 finally{button.disabled=false}
}
function escapeAttr(value){return escapeHtml(value)}
function escapeHtml(value){return String(value).replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]))}
function formatDate(value){if(!value)return'—';const d=new Date(value);return Number.isNaN(d.getTime())?escapeHtml(value):d.toLocaleDateString('en-GB',{day:'2-digit',month:'short',year:'numeric'})}

async function createComplimentarySubscriber(event){
 event.preventDefault();
 const form=event.currentTarget,button=$('complimentary-submit'),status=$('complimentary-status');
 button.disabled=true;status.textContent='Creating invitation and complimentary workspace…';
 const payload={
  business_name:$('complimentary-business-name').value.trim(),
  owner_name:$('complimentary-owner-name').value.trim(),
  email:$('complimentary-owner-email').value.trim()
 };
 try{
  await request('/auth/v1/user');
  const response=await fetch(SUPABASE_URL+'/functions/v1/platform-create-complimentary-subscriber',{
   method:'POST',
   headers:{apikey:KEY,Authorization:'Bearer '+session.access_token,'Content-Type':'application/json'},
   body:JSON.stringify(payload)
  });
  const raw=await response.text();let data=null;try{data=raw?JSON.parse(raw):null}catch{}
  if(!response.ok)throw Error(data?.error||data?.message||raw||'Unable to create complimentary subscriber.');
  status.textContent=data?.message||'Complimentary subscriber workspace created and invitation sent.';
  form.reset();
  await loadTenants();
 }catch(error){status.textContent=error?.message||String(error)}
 finally{button.disabled=false}
}

$('complimentary-subscriber-form')?.addEventListener('submit',createComplimentarySubscriber);

$('refresh').onclick=loadTenants;$('refresh-domain-actions').onclick=loadDomainActions;$('refresh-product-pages')?.addEventListener('click',loadProductPages);
$('platform-email-form').onsubmit=savePlatformEmail;

$('sign-out').onclick=()=>{session=null;save();location.reload()};

(async()=>{
  try{if(!session?.access_token)throw Error('Sign in required');await establish();hideAuth();await Promise.allSettled([loadTenants(),loadPlans(),loadPlatformEmail(),loadDomainActions(),loadProductPages(),loadCloudAiProviders(),loadCloudAiJobs(),loadCloudAiReviewQueue(),loadManualAiResearchBatches(),window.loadPublicPages?.()])}
  catch(e){showAuth('')}
})();

/* Sidebar links open their matching owner-dashboard accordion. */
function initOwnerSectionAccordions(){
 const detailsFor=id=>{const section=document.getElementById(id);return section?Array.from(section.children).find(el=>el.matches&&el.matches('details.owner-section-accordion')):null};
 const openSection=id=>{const details=detailsFor(id);if(details)details.open=true};
 document.querySelectorAll('.sidebar nav a[href^="#"]').forEach(link=>link.addEventListener('click',()=>openSection(link.hash.slice(1))));
 window.addEventListener('hashchange',()=>{if(location.hash)openSection(decodeURIComponent(location.hash.slice(1)))});
 if(location.hash)openSection(decodeURIComponent(location.hash.slice(1)));
}
initOwnerSectionAccordions();


/* Cloud AI Research Manager — owner-only controls backed by protected RPCs. */
const cloudAiProviderDefaults=[
 {provider_key:'gemini',display_name:'Google Gemini',model_id:'gemini-2.5-flash'},
 {provider_key:'groq',display_name:'Groq',model_id:'llama-3.3-70b-versatile'},
 {provider_key:'openrouter',display_name:'OpenRouter',model_id:''},
 {provider_key:'cerebras',display_name:'Cerebras',model_id:'llama-3.3-70b'},
 {provider_key:'sambanova',display_name:'SambaNova',model_id:'Meta-Llama-3.3-70B-Instruct'},
 {provider_key:'nvidia_nim',display_name:'NVIDIA NIM',model_id:'meta/llama-3.3-70b-instruct'},
 {provider_key:'mistral',display_name:'Mistral',model_id:'mistral-small-latest'},
 {provider_key:'huggingface',display_name:'Hugging Face',model_id:'Qwen/Qwen2.5-72B-Instruct'},
 {provider_key:'github_models',display_name:'GitHub Models',model_id:'openai/gpt-4.1-mini'}
];
function renderCloudAiProviders(rows){
 const host=$('cloud-ai-providers');if(!host)return;
 const byKey=new Map((rows||[]).map(x=>[x.provider_key,x]));
 host.innerHTML=cloudAiProviderDefaults.map(d=>{
  const p=byKey.get(d.provider_key)||{};
  return '<form class="plan-editor cloud-ai-provider" data-provider="'+d.provider_key+'">'+
   '<div class="plan-editor-head"><div><div class="eyebrow">'+escapeHtml(d.provider_key)+'</div><h3>'+escapeHtml(d.display_name)+'</h3></div><label class="plan-live"><input name="enabled" type="checkbox" '+(p.enabled?'checked':'')+'> Enabled</label></div>'+
   '<label>Model ID<input name="model_id" required maxlength="180" value="'+escapeAttr(p.model_id||d.model_id)+'"></label>'+
   '<label>API key <input name="api_key" type="password" autocomplete="new-password" placeholder="'+(p.has_key?'Key saved securely — enter a new key to replace':'Paste provider API key')+'"></label>'+
   '<label>Daily request cap<input name="daily_request_limit" type="number" min="0" max="10000" value="'+(p.daily_request_limit||20)+'"></label>'+
   '<label class="plan-live"><input name="free_tier_confirmed" type="checkbox" '+(p.free_tier_confirmed?'checked':'')+'> I have verified this API/model is available without paid billing on my account</label>'+
   '<div class="plan-editor-foot"><span class="plan-status">'+escapeHtml(p.status||'not configured')+(p.has_key?' · key stored in Vault':' · no key')+'</span><button type="submit">Save provider</button><button type="button" data-test-provider="'+d.provider_key+'">Test connection</button></div>'+(p.last_error?'<p class="muted cloud-ai-provider-detail" style="margin-top:6px">'+escapeHtml(p.last_error)+'</p>':'<p class="muted cloud-ai-provider-detail" style="margin-top:6px"></p>')+'</form>';
 }).join('');
 host.querySelectorAll('form').forEach(f=>{f.addEventListener('submit',saveCloudAiProvider);f.querySelector('[data-test-provider]')?.addEventListener('click',()=>testCloudAiProvider(f));});
}
async function loadCloudAiProviders(){
 const host=$('cloud-ai-providers');if(!host)return;
 try{const rows=await request('/rest/v1/rpc/platform_owner_list_cloud_ai_providers',{method:'POST',body:'{}'});renderCloudAiProviders(Array.isArray(rows)?rows:[])}
 catch(e){host.innerHTML='<p class="error">'+escapeHtml(e.message||String(e))+'</p>'}
}
async function saveCloudAiProvider(e){
 e.preventDefault();const form=e.currentTarget,button=form.querySelector('button[type="submit"]'),status=form.querySelector('.plan-status'),data=new FormData(form);
 button.disabled=true;status.textContent='Saving securely…';
 try{
  const result=await request('/rest/v1/rpc/platform_owner_save_cloud_ai_provider',{method:'POST',body:JSON.stringify({
   p_provider_key:form.dataset.provider,p_model_id:String(data.get('model_id')||'').trim(),
   p_enabled:form.elements.enabled.checked,p_free_tier_confirmed:form.elements.free_tier_confirmed.checked,
   p_api_key:String(data.get('api_key')||'').trim()||null,p_daily_request_limit:Number(data.get('daily_request_limit')||0)
  })});
  status.textContent=result?.saved?'Saved. API key stored in Vault.':'Saved.';
  form.elements.api_key.value='';await loadCloudAiProviders();
 }catch(err){status.textContent=err.message||String(err)}
 finally{button.disabled=false}
}
async function loadCloudAiJobs(){
 const body=$('cloud-ai-jobs');if(!body)return;
 body.innerHTML='<tr><td colspan="6">Loading…</td></tr>';
 try{
  const rows=await request('/rest/v1/rpc/platform_owner_list_cloud_ai_jobs',{method:'POST',body:JSON.stringify({p_limit:100})});
  body.innerHTML=(Array.isArray(rows)?rows:[]).map(j=>'<tr><td>'+escapeHtml(j.manufacturer+' '+j.model+(j.package_name?' · '+j.package_name:''))+'</td><td>'+escapeHtml(j.task_type)+'</td><td>'+escapeHtml(j.status)+'</td><td>'+escapeHtml(j.assigned_provider||'—')+'</td><td>'+escapeHtml(j.attempts+'/'+j.max_attempts)+'</td><td>'+escapeHtml(j.last_error||'—')+'</td></tr>').join('')||'<tr><td colspan="6">No research jobs queued.</td></tr>';
 }catch(e){body.innerHTML='<tr><td colspan="6">'+escapeHtml(e.message||String(e))+'</td></tr>'}
}
const cloudAiCatalogueSelection=new Map();
let cloudAiCatalogueBranches=[];
let cloudAiCatalogueProducts=[];
let cloudAiCatalogueTotal=0;
let cloudAiCatalogueOffset=0;
const cloudAiCataloguePageSize=500;
async function loadCloudAiCatalogueTree(categoryId=null,branchId=null){
 return await request('/rest/v1/rpc/platform_owner_get_cloud_ai_catalogue_tree',{method:'POST',body:JSON.stringify({p_category_id:categoryId,p_branch_id:branchId})});
}
async function loadCloudAiCatalogueCategories(){
 const category=$('cloud-ai-category'),branch=$('cloud-ai-branch');
 if(!category||!branch)return;
 try{
  const data=await loadCloudAiCatalogueTree();
  category.innerHTML='<option value="">Choose a category…</option>'+(data.categories||[]).map(x=>'<option value="'+escapeHtml(x.id)+'">'+escapeHtml(x.name)+' ('+Number(x.product_count||0)+')</option>').join('');
  branch.innerHTML='<option value="">All branches in category</option>';branch.disabled=true;
  $('cloud-ai-catalogue-picker-status').textContent=(data.categories||[]).length+' categories loaded directly from the TradeFlow master catalogue.';
 }catch(err){$('cloud-ai-catalogue-picker-status').textContent='Could not load catalogue categories: '+(err.message||String(err));}
}
async function loadCloudAiCatalogueManufacturers(){
 const categoryId=$('cloud-ai-category')?.value,branchId=$('cloud-ai-branch')?.value||null;
 const select=$('cloud-ai-manufacturer');
 if(!select)return;
 if(!categoryId){select.innerHTML='<option value="">Choose a category first…</option>';select.disabled=true;return;}
 select.innerHTML='<option value="">Loading manufacturers…</option>';select.disabled=true;
 try{
  const data=await request('/rest/v1/rpc/platform_owner_list_cloud_ai_catalogue_manufacturers',{method:'POST',body:JSON.stringify({p_category_id:categoryId,p_branch_id:branchId})});
  const rows=data.manufacturers||[];
  select.innerHTML='<option value="">All manufacturers ('+rows.reduce((n,x)=>n+Number(x.product_count||0),0).toLocaleString()+' products)</option>'+rows.map(x=>'<option value="'+escapeHtml(x.id)+'">'+escapeHtml(x.name)+' ('+Number(x.product_count||0).toLocaleString()+')</option>').join('');
  select.disabled=false;
 }catch(err){
  select.innerHTML='<option value="">Could not load manufacturers</option>';
  $('cloud-ai-catalogue-picker-status').textContent='Could not load manufacturers: '+(err.message||String(err));
 }
}
async function loadCloudAiCatalogueProducts(resetOffset=true){
  const categoryId=$('cloud-ai-category').value,branchId=$('cloud-ai-branch').value||null;
  const manufacturerId=$('cloud-ai-manufacturer')?.value||null;
  const selectedEvidenceFilters=[...document.querySelectorAll('[data-cloud-ai-evidence-filter]:checked')].map(box=>box.dataset.cloudAiEvidenceFilter);
  let evidenceFilter='all';
  if(selectedEvidenceFilters.includes('missing_new')&&selectedEvidenceFilters.includes('missing_used'))evidenceFilter='missing_any';
  else if(selectedEvidenceFilters.includes('missing_new'))evidenceFilter='missing_new';
  else if(selectedEvidenceFilters.includes('missing_used'))evidenceFilter='missing_used';
  else if(selectedEvidenceFilters.includes('no_evidence'))evidenceFilter='no_evidence';
  const evidenceFilterLabel=selectedEvidenceFilters.length?selectedEvidenceFilters.map(value=>({missing_used:'No used evidence',missing_new:'No new evidence',no_evidence:'No evidence at all'}[value])).join(' or '):'All products';
  const host=$('cloud-ai-product-list');
  if(!categoryId){host.innerHTML='<p class="muted">Choose a category to load its products.</p>';return;}
  if(resetOffset)cloudAiCatalogueOffset=0;
  host.innerHTML='<p class="muted">Loading products and existing evidence counts…</p>';
  try{
   const data=await request('/rest/v1/rpc/platform_owner_list_cloud_ai_catalogue_products_filtered',{method:'POST',body:JSON.stringify({
    p_category_id:categoryId,p_branch_id:branchId,p_manufacturer_id:manufacturerId,p_evidence_filter:evidenceFilter,
    p_limit:cloudAiCataloguePageSize,p_offset:cloudAiCatalogueOffset
   })});
   cloudAiCatalogueProducts=data.products||[];
   cloudAiCatalogueTotal=Number(data.total_count||0);
   const first=cloudAiCatalogueTotal?cloudAiCatalogueOffset+1:0,last=Math.min(cloudAiCatalogueOffset+cloudAiCatalogueProducts.length,cloudAiCatalogueTotal);
   $('cloud-ai-product-list-summary').textContent='Showing '+first+'–'+last+' of '+cloudAiCatalogueTotal.toLocaleString()+' matching active products · '+evidenceFilterLabel+'. Evidence counts are active UK new and used records.';
   $('cloud-ai-product-prev').disabled=cloudAiCatalogueOffset===0;
   $('cloud-ai-product-next').disabled=cloudAiCatalogueOffset+cloudAiCatalogueProducts.length>=cloudAiCatalogueTotal;
   $('cloud-ai-queue-branch').disabled=!branchId||cloudAiCatalogueTotal===0;
   $('cloud-ai-queue-category').disabled=cloudAiCatalogueTotal===0;
   if(!cloudAiCatalogueProducts.length){host.innerHTML='<p class="muted">No active products match these filters.</p>';return;}
   host.innerHTML='<table style="width:100%;border-collapse:collapse;font-size:13px"><thead><tr style="text-align:left;border-bottom:2px solid var(--border,#ddd)"><th style="padding:8px;width:34px">Pick</th><th style="padding:8px">Manufacturer / model / package</th><th style="padding:8px;text-align:center">New evidence</th><th style="padding:8px;text-align:center">Used evidence</th><th style="padding:8px;text-align:center">Total</th></tr></thead><tbody>'+cloudAiCatalogueProducts.map(p=>'<tr style="border-bottom:1px solid var(--border,#ddd)"><td style="padding:8px"><input type="checkbox" data-catalogue-product="'+escapeHtml(p.product_id)+'" '+(cloudAiCatalogueSelection.has(p.product_id)?'checked':'')+' aria-label="Select '+escapeHtml(p.manufacturer_name+' '+p.model)+'"></td><td style="padding:8px"><strong>'+escapeHtml(p.manufacturer_name)+' | '+escapeHtml(p.model)+'</strong>'+(p.package_name?'<div class="muted">'+escapeHtml(p.package_name)+'</div>':'')+'</td><td style="padding:8px;text-align:center;font-weight:600">'+Number(p.new_evidence_count||0)+'</td><td style="padding:8px;text-align:center;font-weight:600">'+Number(p.used_evidence_count||0)+'</td><td style="padding:8px;text-align:center">'+Number(p.total_evidence_count||0)+'</td></tr>').join('')+'</tbody></table>';
   host.querySelectorAll('[data-catalogue-product]').forEach(box=>box.addEventListener('change',()=>{
    const p=cloudAiCatalogueProducts.find(x=>x.product_id===box.dataset.catalogueProduct);
    if(box.checked&&p){if(cloudAiCatalogueSelection.size>=500){box.checked=false;$('cloud-ai-status').textContent='A maximum of 500 individual products can be selected at once. Use the whole-branch or whole-category action for larger batches.';return;}cloudAiCatalogueSelection.set(p.product_id,p);}
    else cloudAiCatalogueSelection.delete(box.dataset.catalogueProduct);
    renderCloudAiCatalogueSelection();
   }));
  }catch(err){host.innerHTML='<p class="muted">Could not load catalogue products: '+escapeHtml(err.message||String(err))+'</p>';}
 }
 async function onCloudAiCategoryChange(){
  const branch=$('cloud-ai-branch'),manufacturer=$('cloud-ai-manufacturer');
  cloudAiCatalogueBranches=[];cloudAiCatalogueProducts=[];cloudAiCatalogueSelection.clear();renderCloudAiCatalogueSelection();
  branch.innerHTML='<option value="">Loading branches…</option>';branch.disabled=true;
  if(manufacturer){manufacturer.innerHTML='<option value="">Choose a category first…</option>';manufacturer.disabled=true;}
  $('cloud-ai-queue-branch').disabled=true;$('cloud-ai-queue-category').disabled=true;
  if(!$('cloud-ai-category').value){branch.innerHTML='<option value="">Choose a category first…</option>';loadCloudAiCatalogueProducts();return;}
  try{
   const data=await loadCloudAiCatalogueTree($('cloud-ai-category').value);
   cloudAiCatalogueBranches=data.branches||[];
   branch.innerHTML='<option value="">All branches in category</option>'+cloudAiCatalogueBranches.map(x=>'<option value="'+escapeHtml(x.id)+'">'+escapeHtml(x.name)+' ('+Number(x.product_count||0)+' products)</option>').join('');
   branch.disabled=false;
   await loadCloudAiCatalogueManufacturers();
   await loadCloudAiCatalogueProducts(true);
  }catch(err){branch.innerHTML='<option value="">Could not load branches</option>';$('cloud-ai-catalogue-picker-status').textContent=err.message||String(err);}
 }
 async function onCloudAiBranchChange(){
  cloudAiCatalogueSelection.clear();renderCloudAiCatalogueSelection();
  await loadCloudAiCatalogueManufacturers();
  await loadCloudAiCatalogueProducts(true);
 }
 function renderCloudAiCatalogueSelection(){
 const count=cloudAiCatalogueSelection.size;
 $('cloud-ai-selected-count').textContent=count.toLocaleString()+' individual product'+(count===1?'':'s')+' selected';
 if($('cloud-ai-queue-selected'))$('cloud-ai-queue-selected').disabled=!count;
 if($('manual-ai-create-batch'))$('manual-ai-create-batch').disabled=!count;
 $('cloud-ai-selected-products').textContent=count?[...cloudAiCatalogueSelection.values()].slice(0,8).map(p=>p.manufacturer_name+' | '+p.model+(p.package_name?' | '+p.package_name:'')).join(' · ')+(count>8?' · and '+(count-8)+' more':''):'No individual products selected yet.';
}
function selectCloudAiFirst(count){
 if(!cloudAiCatalogueProducts.length)return;
 for(const p of cloudAiCatalogueProducts.slice(0,count)){
  if(cloudAiCatalogueSelection.size>=500)break;
  cloudAiCatalogueSelection.set(p.product_id,p);
 }
 renderCloudAiCatalogueSelection();
 cloudAiCatalogueProducts.forEach(p=>{const box=$('cloud-ai-product-list').querySelector('[data-catalogue-product="'+p.product_id+'"]');if(box)box.checked=cloudAiCatalogueSelection.has(p.product_id);});
}
async function queueCloudAiCatalogueScope(scope){
 const categoryId=$('cloud-ai-category').value,branchId=$('cloud-ai-branch').value||null;
 if(!categoryId)return;
 const label=scope==='category'?'the entire category': 'the entire selected branch';
 const expected=scope==='category'?Number($('cloud-ai-category').selectedOptions[0]?.textContent.match(/\((\d+)\)/)?.[1]||cloudAiCatalogueTotal):Number(cloudAiCatalogueBranches.find(x=>x.id===branchId)?.product_count||cloudAiCatalogueTotal);
 if(!window.confirm('Queue research for '+label+' ('+expected.toLocaleString()+' products)? This will create research jobs only; it will not change catalogue products or existing evidence.'))return;
 const button=scope==='category' ? $('cloud-ai-queue-category') : $('cloud-ai-queue-branch');
 button.disabled=true;$('cloud-ai-status').textContent='Queueing '+label+'…';
 try{
  const data=await request('/rest/v1/rpc/platform_owner_enqueue_cloud_ai_catalogue_scope',{method:'POST',body:JSON.stringify({
   p_product_ids:null,p_category_id:categoryId,p_branch_id:scope==='branch'?branchId:null,p_task_type:$('cloud-ai-task-type').value||'price_evidence'
  })});
  $('cloud-ai-status').textContent=(data.selected||0).toLocaleString()+' catalogue products selected; '+(data.queued_or_existing||0).toLocaleString()+' research jobs queued or already present.';
  await loadCloudAiJobs();
 }catch(err){$('cloud-ai-status').textContent='Could not queue '+label+': '+(err.message||String(err));}
 finally{button.disabled=false;}
}
$('cloud-ai-category')?.addEventListener('change',onCloudAiCategoryChange);
$('cloud-ai-branch')?.addEventListener('change',onCloudAiBranchChange);
$('cloud-ai-manufacturer')?.addEventListener('change',()=>loadCloudAiCatalogueProducts(true));
document.querySelectorAll('[data-cloud-ai-evidence-filter]').forEach(box=>box.addEventListener('change',()=>loadCloudAiCatalogueProducts(true)));
$('cloud-ai-product-prev')?.addEventListener('click',()=>{cloudAiCatalogueOffset=Math.max(0,cloudAiCatalogueOffset-cloudAiCataloguePageSize);loadCloudAiCatalogueProducts(false);});
$('cloud-ai-product-next')?.addEventListener('click',()=>{cloudAiCatalogueOffset+=cloudAiCataloguePageSize;loadCloudAiCatalogueProducts(false);});
document.querySelectorAll('[data-cloud-ai-select-count]')?.forEach(button=>button.addEventListener('click',()=>selectCloudAiFirst(Number(button.dataset.cloudAiSelectCount))));
$('cloud-ai-clear-selection')?.addEventListener('click',()=>{cloudAiCatalogueSelection.clear();renderCloudAiCatalogueSelection();cloudAiCatalogueProducts.forEach(p=>{const box=$('cloud-ai-product-list').querySelector('[data-catalogue-product="'+p.product_id+'"]');if(box)box.checked=false;});});
$('cloud-ai-queue-category')?.addEventListener('click',()=>queueCloudAiCatalogueScope('category'));
$('cloud-ai-queue-branch')?.addEventListener('click',()=>queueCloudAiCatalogueScope('branch'));
async function enqueueCloudAiJob(e){
 e.preventDefault();
 const button=$('cloud-ai-queue-selected'),status=$('cloud-ai-status');
 const productIds=[...cloudAiCatalogueSelection.keys()];
 if(!productIds.length){status.textContent='Tick one or more products in the catalogue list first.';return;}
 button.disabled=true;status.textContent='Queueing '+productIds.length+' selected catalogue products…';
 try{
  const data=await request('/rest/v1/rpc/platform_owner_enqueue_cloud_ai_catalogue_scope',{method:'POST',body:JSON.stringify({
   p_product_ids:productIds,p_category_id:null,p_branch_id:null,p_task_type:$('cloud-ai-task-type').value||'price_evidence'
  })});
  status.textContent=(data.selected||productIds.length)+' selected catalogue products; '+(data.queued_or_existing||0)+' research jobs queued or already present.';
  cloudAiCatalogueSelection.clear();renderCloudAiCatalogueSelection();await loadCloudAiJobs();
 }catch(err){status.textContent='Could not queue selected catalogue products: '+(err.message||String(err));}
 finally{button.disabled=false;}
}

async function loadManualAiResearchBatches(){
 const host=$('manual-ai-batches');if(!host)return;
 host.innerHTML='<p class="muted">Loading saved batches…</p>';
 try{
  const batches=await request('/rest/v1/rpc/platform_owner_list_manual_ai_research_batches',{method:'POST',body:JSON.stringify({p_limit:10})});
  renderManualAiResearchBatches(Array.isArray(batches)?batches:[]);
 }catch(err){host.innerHTML='<p class="error">'+escapeHtml(err.message||String(err))+'</p>';}
}
function renderManualAiResearchBatches(batches){
 const host=$('manual-ai-batches');if(!host)return;
 if(!batches.length){host.innerHTML='<p class="muted">No manual research batches yet. Select products above and generate your first prompts.</p>';return;}
 host.innerHTML=batches.map(batch=>{
  const prompts=Array.isArray(batch.prompts)?batch.prompts:[];
  const completed=prompts.filter(p=>['completed','no_findings'].includes(p.status));
  const active=prompts.filter(p=>!['completed','no_findings'].includes(p.status));
  const complete=completed.length;
  const header='<div class="plan-editor-head"><div><div class="eyebrow">Manual research batch · '+escapeHtml(formatDate(batch.created_at))+'</div><h3>'+escapeHtml(batch.assistant_name)+' · '+Number(batch.product_count||0).toLocaleString()+' products</h3><p class="muted">'+Number(batch.prompt_count||0)+' prompts · '+Number(batch.products_per_prompt||20)+' products per prompt</p></div><span class="plan-status">'+complete+'/'+prompts.length+' prompts completed · '+escapeHtml(batch.status)+'</span></div>';
  const progress='<div style="height:7px;background:var(--border,#ddd);border-radius:10px;overflow:hidden;margin:8px 0 14px"><div style="height:7px;background:#16834a;width:'+(prompts.length?Math.round(complete/prompts.length*100):0)+'%"></div></div>';
  const activeMarkup=active.map(p=>{
   return '<section style="border-top:1px solid var(--border,#ddd);padding-top:12px;margin-top:12px">'+
    '<div style="display:flex;justify-content:space-between;align-items:center;gap:10px;flex-wrap:wrap"><label style="display:flex;align-items:center;gap:7px"><input type="checkbox" data-manual-delete-select data-manual-delete-batch="'+escapeHtml(batch.id)+'" value="'+escapeHtml(p.id)+'"> <strong>Prompt '+p.prompt_number+' of '+prompts.length+' · '+Number(p.product_count||0)+' products</strong></label><span class="plan-status">'+escapeHtml(String(p.status||'ready').replace('_',' '))+'</span></div>'+
    '<div style="display:flex;gap:8px;align-items:center;flex-wrap:wrap;margin:9px 0"><button type="button" data-manual-copy="'+escapeHtml(p.id)+'">Copy research prompt</button><a href="'+escapeAttr(batch.assistant_url)+'" target="_blank" rel="noopener noreferrer">Open '+escapeHtml(batch.assistant_name)+' website ↗</a>'+(p.status==='ready'&&!p.response_draft?'<button type="button" data-manual-refresh-prompt="'+escapeHtml(p.id)+'">Regenerate with improved research rules</button>':'')+'</div>'+
    '<label>Generated research prompt<textarea id="manual-ai-prompt-'+escapeHtml(p.id)+'" rows="6" readonly style="width:100%;font-family:Consolas,monospace;font-size:12px;white-space:pre;overflow:auto">'+escapeHtml(p.prompt_text)+'</textarea></label>'+
    '<label style="display:block;margin-top:12px">Paste the complete AI response<textarea id="manual-ai-response-'+escapeHtml(p.id)+'" rows="9" maxlength="300000" placeholder="Paste the complete assistant reply here, including readable price tables and any structured findings.">'+escapeHtml(p.response_draft||'')+'</textarea></label>'+
    '<div style="display:flex;gap:8px;flex-wrap:wrap;margin-top:8px"><button type="button" data-manual-copy-evidence-review="'+escapeHtml(p.id)+'">Copy ChatGPT evidence-review prompt</button><button type="button" data-manual-save="'+escapeHtml(p.id)+'">Save response draft</button><button type="button" data-manual-submit="'+escapeHtml(p.id)+'">Validate and send to Evidence Awaiting Review</button></div>'+
    '<p class="muted" id="manual-ai-prompt-status-'+escapeHtml(p.id)+'" role="status" aria-live="polite"></p>'+
   '</section>';
  }).join('');
  const history=completed.length?'<details style="margin-top:12px"><summary><strong>Completed research ('+completed.length+')</strong> · show submitted reports</summary>'+completed.map(p=>
   '<section style="border-top:1px solid var(--border,#ddd);padding-top:10px;margin-top:10px"><label style="display:flex;align-items:center;gap:7px"><input type="checkbox" data-manual-delete-select data-manual-delete-batch="'+escapeHtml(batch.id)+'" value="'+escapeHtml(p.id)+'"> <strong>Prompt '+p.prompt_number+' of '+prompts.length+' · '+Number(p.product_count||0)+' products</strong></label><p class="note">Response submitted '+escapeHtml(p.response_submitted_at?formatDate(p.response_submitted_at):'')+'. '+Number(p.candidates_created||0)+' reference/candidate record(s) created; '+Number(p.findings_rejected||0)+' finding(s) rejected by validation.</p>'+(p.response_text?'<details style="margin-top:8px"><summary><strong>View complete AI research report and price comparisons</strong></summary><pre style="white-space:pre-wrap;overflow-wrap:anywhere;max-height:620px;overflow:auto;padding:12px;background:var(--surface-secondary,#f6f6f6);border-radius:8px">'+escapeHtml(p.response_text)+'</pre></details>':'')+'</section>'
  ).join('')+'</details>':'';
  return '<article class="plan-editor" data-manual-batch-card="'+escapeHtml(batch.id)+'" style="margin-top:12px">'+header+progress+activeMarkup+history+'</article>';
 }).join('');
 host.insertAdjacentHTML('afterbegin','<div style="display:flex;gap:8px;align-items:center;flex-wrap:wrap;margin:12px 0;padding:10px;border:1px solid var(--border,#ddd);border-radius:8px"><button type="button" data-manual-select-all-global>Select all prompts across all batches</button><button type="button" data-manual-delete-selected-global disabled>Delete selected (0)</button><span class="muted">Tick only the prompts you want removed. Submitted evidence candidates already sent to review are kept.</span></div>');
 host.querySelectorAll('[data-manual-copy]').forEach(button=>button.addEventListener('click',()=>copyManualAiPrompt(button.dataset.manualCopy,button)));
 host.querySelectorAll('[data-manual-refresh-prompt]').forEach(button=>button.addEventListener('click',()=>refreshManualAiPrompt(button.dataset.manualRefreshPrompt,button)));
 host.querySelectorAll('[data-manual-copy-evidence-review]').forEach(button=>button.addEventListener('click',()=>copyChatGptEvidenceReviewPrompt(button)));
 host.querySelectorAll('[data-manual-save]').forEach(button=>button.addEventListener('click',()=>saveManualAiDraft(button.dataset.manualSave,button)));
 host.querySelectorAll('[data-manual-submit]').forEach(button=>button.addEventListener('click',()=>submitManualAiResponse(button.dataset.manualSubmit,button)));
 host.querySelectorAll('[data-manual-delete-select]').forEach(box=>box.addEventListener('change',updateManualAiGlobalDeleteControls));
 host.querySelector('[data-manual-select-all-global]')?.addEventListener('click',toggleManualAiGlobalSelection);
 host.querySelector('[data-manual-delete-selected-global]')?.addEventListener('click',deleteSelectedManualAiPrompts);
}

function updateManualAiGlobalDeleteControls(){
 const host=$('manual-ai-batches');if(!host)return;
 const boxes=[...host.querySelectorAll('[data-manual-delete-select]')],selected=boxes.filter(box=>box.checked);
 const del=host.querySelector('[data-manual-delete-selected-global]'),all=host.querySelector('[data-manual-select-all-global]');
 if(del){del.disabled=!selected.length;del.textContent='Delete selected ('+selected.length+')';}
 if(all)all.textContent=boxes.length&&selected.length===boxes.length?'Clear all selections':'Select all prompts across all batches';
}
function toggleManualAiGlobalSelection(){
 const host=$('manual-ai-batches');if(!host)return;
 const boxes=[...host.querySelectorAll('[data-manual-delete-select]')],select=boxes.some(box=>!box.checked);
 boxes.forEach(box=>{box.checked=select;});updateManualAiGlobalDeleteControls();
}
async function deleteSelectedManualAiPrompts(){
 const host=$('manual-ai-batches');if(!host)return;
 const ids=[...host.querySelectorAll('[data-manual-delete-select]:checked')].map(box=>box.value).filter(Boolean);
 if(!ids.length)return;
 if(!window.confirm('Delete the '+ids.length+' selected prompt'+(ids.length===1?'':'s')+' across all research batches? Saved drafts and submitted reports will be removed. Evidence candidates already sent to Evidence Awaiting Review will remain.'))return;
 const button=host.querySelector('[data-manual-delete-selected-global]');if(button)button.disabled=true;
 const status=$('manual-ai-status');if(status)status.textContent='Deleting selected research prompts…';
 try{
  const result=await request('/rest/v1/rpc/platform_owner_delete_manual_ai_research_prompts',{method:'POST',body:JSON.stringify({p_prompt_ids:ids})});
  if(status)status.textContent='Deleted '+Number(result.deleted_prompts||ids.length)+' prompt(s). Evidence candidates already in review were preserved.';
  await loadManualAiResearchBatches();
 }catch(err){if(status)status.textContent='Could not delete the selected prompts: '+(err.message||String(err));if(button)button.disabled=false;}
}
async function refreshManualAiPrompt(promptId,button){
 if(!window.confirm('Replace this unstarted saved prompt with the improved package-comparison research instructions? Any existing response draft or submitted response is protected and cannot be replaced.'))return;
 button.disabled=true;
 const status=$('manual-ai-status');
 if(status)status.textContent='Regenerating research prompt…';
 try{
  const result=await request('/rest/v1/rpc/platform_owner_refresh_manual_ai_research_prompt',{method:'POST',body:JSON.stringify({p_prompt_id:promptId})});
  if(status)status.textContent='Updated prompt for '+result.products+' selected product(s). Your product selection and assistant are unchanged.';
  await loadManualAiResearchBatches();
 }catch(err){if(status)status.textContent='Could not regenerate this prompt: '+(err.message||String(err));}
 finally{button.disabled=false;}
}
async function copyManualAiPrompt(promptId,button){
 const field=$('manual-ai-prompt-'+promptId);if(!field)return;
 try{
  await navigator.clipboard.writeText(field.value);
  const old=button.textContent;button.textContent='Copied';setTimeout(()=>{button.textContent=old;},1500);
 }catch(err){
  field.focus();field.select();
  const copied=document.execCommand('copy');
  if(copied){const old=button.textContent;button.textContent='Copied';setTimeout(()=>{button.textContent=old;},1500);}
  else $('manual-ai-status').textContent='Copy was blocked by the browser. Select the prompt text and copy it manually.';
 }
}
async function createManualAiResearchBatch(){
 const button=$('manual-ai-create-batch'),status=$('manual-ai-status');
 const productIds=[...cloudAiCatalogueSelection.keys()];
 if(!productIds.length){status.textContent='Select one or more catalogue products first.';return;}
 const assistant=$('manual-ai-assistant').value;
 const batchSize=Number($('manual-ai-products-per-prompt').value||20);
 button.disabled=true;status.textContent='Preparing deep-research prompts for '+productIds.length+' selected products…';
 try{
  const batch=await request('/rest/v1/rpc/platform_owner_create_manual_ai_research_batch',{method:'POST',body:JSON.stringify({
   p_product_ids:productIds,p_assistant_key:assistant,p_products_per_prompt:batchSize,p_research_type:'price_evidence'
  })});
  cloudAiCatalogueSelection.clear();renderCloudAiCatalogueSelection();
  status.textContent='Created '+batch.prompt_count+' saved prompt(s) for '+batch.product_count+' products. Copy the first prompt and open '+batch.assistant_name+' in a new tab.';
  await loadManualAiResearchBatches();
 }catch(err){status.textContent='Could not generate the research batch: '+(err.message||String(err));}
 finally{button.disabled=false;renderCloudAiCatalogueSelection();}
}
async function saveManualAiDraft(promptId,button){
 const textarea=$('manual-ai-response-'+promptId),status=$('manual-ai-prompt-status-'+promptId);
 if(!textarea)return;
 button.disabled=true;if(status)status.textContent='Saving response draft…';
 try{
  await request('/rest/v1/rpc/platform_owner_save_manual_ai_research_draft',{method:'POST',body:JSON.stringify({
   p_prompt_id:promptId,p_response_draft:textarea.value
  })});
  if(status)status.textContent='Draft saved to TradeFlow. You can return to it later.';
  await loadManualAiResearchBatches();
 }catch(err){if(status)status.textContent='Could not save draft: '+(err.message||String(err));}
 finally{button.disabled=false;}
}
function normalizeManualAiSmartQuotes(value){
 return String(value||'').replace(/[“”„‟]/g,'"').replace(/[‘’]/g,"'").replace(/\u00a0/g,' ');
}
function tryParseManualAiJsonReply(raw){
 const text=normalizeManualAiSmartQuotes(raw).trim();
 const fence=String.fromCharCode(96).repeat(3);
 const pattern=new RegExp(fence+'\\s*json\\s*([\\s\\S]*?)\\s*'+fence,'i');
 const match=text.match(pattern);
 let clean=match?match[1].trim():text;
 if(!match){
  const start=clean.indexOf('{'),end=clean.lastIndexOf('}');
  if(start<0||end<=start)return null;
  clean=clean.slice(start,end+1);
 }
 try{
  const data=JSON.parse(clean);
  if(data.schema_version==='tradeflow_manual_research_v1'&&Array.isArray(data.findings)&&Array.isArray(data.not_found))return data;
 }catch(err){}
 return null;
}
function parseManualAiReportTables(raw,prompt){
 const text=String(raw||'');
 const snapshot=Array.isArray(prompt.products_snapshot)?prompt.products_snapshot:[];
 const lines=text.split(/\r?\n/);
 const refs=[];
 let section=null,context=[];
 const linkPattern=/\[([^\]]+)\]\((https?:\/\/[^)\s]+)\)/gi;
 const pricePattern=/£\s*([0-9][0-9,]*(?:\.[0-9]{1,2})?)/g;
 for(let i=0;i<lines.length;i++){
  const line=lines[i].trim();
  if(/new prices|new price comparison|new \(uk|new retail/i.test(line))section='uk_new';
  if(/used prices|used price comparison|second.hand prices|pre.owned prices/i.test(line))section='uk_used';
  const isPipeTable=line.startsWith('|');
  const isTabTable=!isPipeTable&&line.includes('\t')&&line.split('\t').length>=3;
  if(!isPipeTable&&!isTabTable){if(line)context.push(line);if(context.length>12)context.shift();continue;}
  const cells=isPipeTable?line.replace(/^\|/,'').replace(/\|$/,'').split('|').map(x=>x.trim()):line.split('\t').map(x=>x.trim());
  if(cells.length<3||cells.every(x=>/^:?-{2,}:?$/.test(x)))continue;
  if(/^(package|item|product|model)$/i.test((cells[0]||'').replace(/\*/g,'').trim())&&/price/i.test(cells[1]||''))continue;
  if(!section)continue;
  const packageName=cells[0]||'Package not stated';
  const priceDisplay=cells[1]||'';
  const sourceCell=cells[2]||'';
  const notes=cells.slice(3).join(' | ');
  const prices=[...priceDisplay.matchAll(pricePattern)].map(m=>Number(m[1].replace(/,/g,'')));
  const uniquePrices=[...new Set(prices)];
  const priceIsRange=/£?\s*[0-9,.]+\s*[–—-]\s*£?\s*[0-9,.]+/.test(priceDisplay);
  const exactPrice=!priceIsRange&&uniquePrices.length?uniquePrices[0]:null;
  let product=null;
  const contextText=(context.slice(-8).join(' ')+' '+line).toLowerCase();
  if(snapshot.length===1)product=snapshot[0];
  else{
   const exactPackage=snapshot.filter(p=>String(p.package_name||'').toLowerCase()===packageName.toLowerCase());
   if(exactPackage.length===1)product=exactPackage[0];
   if(!product){
    const modelMatches=snapshot.filter(p=>contextText.includes(String(p.model||'').toLowerCase())||contextText.includes(String(p.manufacturer||'').toLowerCase()+' '+String(p.model||'').toLowerCase()));
    if(modelMatches.length===1)product=modelMatches[0];
   }
  }
  if(!product)continue;
  const links=[...sourceCell.matchAll(linkPattern)].map(m=>({name:m[1],url:m[2]}));
  const rawUrls=[...sourceCell.matchAll(/https?:\/\/[^\s)\]]+/gi)].map(m=>m[0].replace(/[.,;]+$/,''));
  if(!links.length&&rawUrls.length)links.push(...rawUrls.map(url=>({name:sourceCell.replace(url,'').trim()||'Source URL',url})));
  const cleanedSource=sourceCell.replace(linkPattern,'$1').replace(/\*\*/g,'').trim();
  const sourceNames=cleanedSource.split(/[,;](?=\s*(?:eBay|Amazon|MPB|Wex|Park Cameras|CeX|Gumtree|Facebook|PriceSpy|E-Catalog|u-buy|Supersales))/i).map(x=>x.trim()).filter(Boolean);
  const sources=links.length?links:[{name:sourceNames[0]||cleanedSource||'Source not linked in report',url:''}];
  const kindFor=url=>{
   const host=(url.match(/^https?:\/\/([^/]+)/i)||[])[1]||'';
   if(/ebay|amazon|gumtree|facebook|cex/i.test(host))return 'marketplace_listing';
   if(/pricespy|price.?spy|e-catalog|idealo|pricerunner/i.test(host))return 'price_aggregator';
   if(/supersales|wex|parkcameras|mpb|u-buy/i.test(host))return 'retailer_product_page';
   return url?'reported_source':'source_not_linked';
  };
  for(const source of sources){
   refs.push({
    product_id:product.product_id,manufacturer:product.manufacturer,model:product.model,
    evidence_type:section,package_name:packageName,price_display:priceDisplay,
    price_gbp:exactPrice,
    source_name:source.name||cleanedSource||'Source not identified',
    source_url:source.url||null,source_kind:kindFor(source.url||''),
    item_condition:section==='uk_new'?'New / condition stated in report':'Used / condition stated in report',
    availability:'Reported in comparison table; verify live listing',
    table_row:line,notes:notes+(priceIsRange?' Price is a range; exact numeric price not assumed.':uniquePrices.length>1?' Multiple amounts are shown; main price needs source verification.':'')
   });
  }
 }
 return refs;
}
async function submitManualAiResponse(promptId,button){
 const textarea=$('manual-ai-response-'+promptId),status=$('manual-ai-prompt-status-'+promptId);
 if(!textarea)return;
 const raw=textarea.value;
 const batches=await request('/rest/v1/rpc/platform_owner_list_manual_ai_research_batches',{method:'POST',body:JSON.stringify({p_limit:20})});
 const prompt=(Array.isArray(batches)?batches:[]).flatMap(b=>(b.prompts||[]).map(p=>({...p,batch_assistant:b.assistant_name}))).find(p=>p.id===promptId);
 if(!prompt){if(status)status.textContent='Could not find the saved product selection for this prompt. Refresh the research batches and try again.';return;}
 const json=tryParseManualAiJsonReply(raw);
 let references=[];
 if(!json){
  references=parseManualAiReportTables(raw,prompt);
  if(!references.length){
   if(status)status.textContent='I could not find a TradeFlow JSON block or recognisable New prices / Used prices tables. You can still save the full reply as a draft; no evidence will be discarded.';
   return;
  }
 }
 const message=json
  ?'Validate the structured AI findings and add valid exact-package evidence to review. Any non-exact sources are kept separately as comparisons.'
  :'TradeFlow found '+references.length+' price-table reference(s). It will save the complete report and stage these as UNVERIFIED comparisons. You will then match each reference to the correct catalogue package and verify the source before approval. Nothing will be imported automatically.';
 if(!window.confirm(message))return;
 button.disabled=true;if(status)status.textContent=json?'Validating structured evidence…':'Extracting price tables and saving the full research report…';
 try{
  if(json){
   const result=await request('/rest/v1/rpc/platform_owner_submit_manual_ai_research_response',{method:'POST',body:JSON.stringify({
    p_prompt_id:promptId,p_response_text:normalizeManualAiSmartQuotes(raw)
   })});
   if(status)status.textContent='Structured reply checked. '+(result.catalogue_evidence_candidates||0)+' exact-package evidence candidate(s); '+(result.comparison_only_references||0)+' comparison reference(s); '+(result.findings_rejected||0)+' rejected.';
  }else{
   const result=await request('/rest/v1/rpc/platform_owner_stage_manual_ai_report',{method:'POST',body:JSON.stringify({
    p_prompt_id:promptId,p_response_text:raw,p_references:references
   })});
   if(status)status.textContent='Complete report saved. '+result.references_created+' unverified comparison reference(s) staged. Match each reference to the right catalogue package and verify the source before approving.';
  }
  $('manual-ai-status').textContent='Research report captured in TradeFlow. Nothing has been imported into master evidence; source verification and catalogue matching are next.';
  await loadManualAiResearchBatches();
  await loadCloudAiReviewQueue();
 }catch(err){if(status)status.textContent='Response not submitted: '+(err.message||String(err));}
 finally{button.disabled=false;}
}
$('manual-ai-create-batch')?.addEventListener('click',createManualAiResearchBatch);
$('manual-ai-refresh')?.addEventListener('click',loadManualAiResearchBatches);

$('cloud-ai-refresh')?.addEventListener('click',loadCloudAiProviders);
$('cloud-ai-jobs-refresh')?.addEventListener('click',loadCloudAiJobs);
$('cloud-ai-enqueue-form')?.addEventListener('submit',enqueueCloudAiJob);
loadCloudAiCatalogueCategories();

async function testCloudAiProvider(form){
 const button=form.querySelector('[data-test-provider]'),status=form.querySelector('.plan-status');
 button.disabled=true;status.textContent='Testing provider connection…';
 try{
  const result=await request('/functions/v1/tradeflow-cloud-ai-manager',{method:'POST',body:JSON.stringify({action:'test_provider',provider_key:form.dataset.provider})});
  status.textContent=result?.ok&&result.model_listed?'Connected · model confirmed · '+result.models_checked+' models checked':result?.ok?'API reachable · configured model unavailable · '+result.models_checked+' models checked':(result?.error||'Connection check failed');
  const detail=form.querySelector('.cloud-ai-provider-detail');if(detail)detail.textContent=result?.error||'';
 }catch(e){status.textContent=e.message||String(e)}
 finally{button.disabled=false}
}

async function processNextCloudAiJob(){
 const button=$('cloud-ai-process-one'),status=$('cloud-ai-status');if(!button)return;
 button.disabled=true;status.textContent='Running one research job…';
 try{const result=await request('/functions/v1/tradeflow-cloud-ai-manager',{method:'POST',body:JSON.stringify({action:'process_next_job'})});
  status.textContent=result?.processed?'Research completed. '+result.candidates_saved+' evidence candidate(s) submitted by '+result.provider+'.':(result?.message||result?.error||'No job was processed.');
  await loadCloudAiJobs();await loadCloudAiReviewQueue();
 }catch(e){status.textContent=e.message||String(e)}
 finally{button.disabled=false}
}
async function loadCloudAiReviewQueue(){
 const host=$('cloud-ai-review-list');if(!host)return;
 try{
  const rows=await request('/rest/v1/rpc/platform_owner_list_catalogue_research_queue',{method:'POST',body:JSON.stringify({p_status:'all',p_limit:200})});
  const items=(Array.isArray(rows)?rows:[]).filter(x=>x.agent_name==='Cloud AI Research Manager'||String(x.agent_name||'').startsWith('Manual AI Research · '));
  const pending=items.filter(x=>x.status==='pending_review'),processed=items.filter(x=>x.status!=='pending_review');
  const renderItem=x=>{
   const meta=x.raw_payload||{},comparison=meta.evidence_role==='comparison_only'||!x.live_master_product_id,mapped=meta.evidence_role==='catalogue_match_assigned';
   const matchLabel=comparison?'Unverified comparison — match to catalogue and verify':mapped?'Matched to catalogue — source still needs verification':'Exact package — eligible for evidence review';
   const actualPackage=x.package_name?'<p><strong>Package found:</strong> '+escapeHtml(x.package_name)+'</p>':'';
   const source=x.source_url?'<a href="'+escapeAttr(x.source_url)+'" target="_blank" rel="noopener">Open source page</a>':'<span class="muted">No direct source URL was included in the report</span>';
   const matchTools=comparison&&x.status==='pending_review'?'<div style="margin-top:12px;padding:10px;border:1px solid var(--border,#ddd);border-radius:8px"><strong>Match this reference to a catalogue product</strong><div id="manual-ai-match-'+x.id+'" style="margin-top:8px"><button type="button" data-match-load="'+x.id+'">Find matching catalogue packages</button></div></div>':'';
   const reviewTools=x.status==='pending_review'?'<button type="button" data-review-id="'+x.id+'" data-decision="approved">Approve after verification</button><button type="button" data-review-id="'+x.id+'" data-decision="needs_research">Needs more research</button><button type="button" data-review-id="'+x.id+'" data-decision="rejected">Reject</button>':'<span class="muted">Processed · '+escapeHtml(x.status)+'</span>';
   return '<article class="plan-editor" style="margin-top:10px"><label style="display:flex;align-items:center;gap:8px;margin-bottom:8px"><input type="checkbox" data-ai-queue-delete value="'+escapeHtml(x.id)+'"> <strong>Select this '+(x.status==='pending_review'?'pending':'processed')+' record for deletion</strong></label><div class="plan-editor-head"><div><div class="eyebrow">'+escapeHtml(x.evidence_type||x.record_type||'comparison')+'</div><h3>'+escapeHtml((x.manufacturer||'')+' '+(x.model||''))+'</h3></div><span class="plan-status">'+escapeHtml(x.status)+'</span></div><p><strong>'+escapeHtml(matchLabel)+'</strong></p>'+actualPackage+'<p><strong>Price:</strong> '+escapeHtml(x.price_currency||'GBP')+' '+escapeHtml(x.observed_price??(meta.price_display||'Not stated'))+' · '+escapeHtml(x.item_condition||'condition unknown')+'</p><p><strong>Source:</strong> '+escapeHtml(x.source_name||'')+' · '+source+'</p><p>'+escapeHtml(x.source_excerpt||'')+'</p><p class="muted">'+escapeHtml(x.research_notes||'')+'</p>'+matchTools+'<div class="plan-editor-foot">'+reviewTools+'</div></article>';
  };
  host.innerHTML='<div style="display:flex;gap:8px;align-items:center;flex-wrap:wrap;margin-bottom:12px;padding:10px;border:1px solid var(--border,#ddd);border-radius:8px"><button type="button" data-ai-queue-select-all>Select all AI research records</button><button type="button" data-ai-queue-delete-selected disabled>Delete selected (0)</button><span class="muted">Deletes research queue records only. Imported catalogue evidence is kept.</span></div><h3>Awaiting review ('+pending.length+')</h3>'+pending.map(renderItem).join('')+'<details style="margin-top:18px"><summary><strong>Processed research history ('+processed.length+')</strong> · select old queue records to delete</summary>'+processed.map(renderItem).join('')+'</details>';
  const update=()=>{const boxes=[...host.querySelectorAll('[data-ai-queue-delete]')],selected=boxes.filter(b=>b.checked),del=host.querySelector('[data-ai-queue-delete-selected]'),all=host.querySelector('[data-ai-queue-select-all]');if(del){del.disabled=!selected.length;del.textContent='Delete selected ('+selected.length+')';}if(all)all.textContent=boxes.length&&selected.length===boxes.length?'Clear all selections':'Select all AI research records';};
  host.querySelectorAll('[data-ai-queue-delete]').forEach(b=>b.addEventListener('change',update));
  host.querySelector('[data-ai-queue-select-all]')?.addEventListener('click',()=>{const boxes=[...host.querySelectorAll('[data-ai-queue-delete]')],select=boxes.some(b=>!b.checked);boxes.forEach(b=>{b.checked=select});update();});
  host.querySelector('[data-ai-queue-delete-selected]')?.addEventListener('click',async()=>{
   const ids=[...host.querySelectorAll('[data-ai-queue-delete]:checked')].map(b=>b.value);if(!ids.length)return;
   if(!window.confirm('Delete '+ids.length+' selected AI research queue record(s)? This removes queue/history rows only. Imported catalogue evidence will not be deleted.'))return;
   const btn=host.querySelector('[data-ai-queue-delete-selected]');btn.disabled=true;
   try{const result=await request('/rest/v1/rpc/platform_owner_delete_catalogue_research_queue_items',{method:'POST',body:JSON.stringify({p_ids:ids})});alert('Deleted '+Number(result.deleted_queue_records||ids.length)+' queue record(s). Catalogue evidence was preserved.');await loadCloudAiReviewQueue();}
   catch(err){alert(err.message||String(err));btn.disabled=false;}
  });
  host.querySelectorAll('[data-match-load]').forEach(b=>b.addEventListener('click',()=>loadManualAiComparisonMatches(b.dataset.matchLoad,b)));
  host.querySelectorAll('[data-match-save]').forEach(b=>b.addEventListener('click',()=>matchManualAiComparison(b.dataset.matchSave,b)));
  host.querySelectorAll('[data-review-id]').forEach(b=>b.addEventListener('click',()=>reviewCloudAiCandidate(b.dataset.reviewId,b.dataset.decision,b)));
 }catch(e){host.innerHTML='<p class="error">'+escapeHtml(e.message||String(e))+'</p>'}
}
async function loadManualAiComparisonMatches(queueId,button){
 if(button)button.disabled=true;
 const host=$('manual-ai-match-'+queueId);if(!host)return;
 host.innerHTML='<span class="muted">Finding active catalogue products with the same manufacturer and model…</span>';
 try{
  const rows=await request('/rest/v1/rpc/platform_owner_list_manual_ai_comparison_matches',{method:'POST',body:JSON.stringify({p_queue_id:queueId})});
  if(!Array.isArray(rows)||!rows.length){host.innerHTML='<p class="muted">No active same-model catalogue packages were found. Keep this as a comparison reference until the catalogue is checked.</p>';return;}
  host.innerHTML='<label>Choose the correct catalogue package<select id="manual-ai-match-choice-'+queueId+'"><option value="">Select matching package…</option>'+rows.map(p=>'<option value="'+escapeHtml(p.product_id)+'">'+escapeHtml(p.manufacturer+' '+p.model+' — '+(p.package_name||'Package not named'))+'</option>').join('')+'</select></label><button type="button" data-match-save="'+queueId+'" style="margin-top:8px">Match selected catalogue package</button><p class="muted">Only the same manufacturer and model are listed. Check the actual bundle and source page before matching.</p>';
  host.querySelector('[data-match-save]')?.addEventListener('click',()=>matchManualAiComparison(queueId,host.querySelector('[data-match-save]')));
 }catch(err){host.innerHTML='<p class="error">'+escapeHtml(err.message||String(err))+'</p>';}
 finally{if(button)button.disabled=false;}
}
async function matchManualAiComparison(queueId,button){
 const choice=$('manual-ai-match-choice-'+queueId),productId=choice?.value;
 if(!productId){alert('Choose the matching catalogue package first.');return;}
 if(!window.confirm('Match this comparison reference to the selected catalogue package? It will remain pending verification; no evidence will be imported automatically.'))return;
 button.disabled=true;
 try{
  await request('/rest/v1/rpc/platform_owner_match_manual_ai_comparison',{method:'POST',body:JSON.stringify({p_queue_id:queueId,p_product_id:productId})});
  await loadCloudAiReviewQueue();
 }catch(err){alert(err.message||String(err));button.disabled=false;}
}
async function reviewCloudAiCandidate(id,decision,button){
 button.disabled=true;
 try{await request('/rest/v1/rpc/platform_owner_review_catalogue_research_item',{method:'POST',body:JSON.stringify({p_id:id,p_decision:decision,p_notes:'Reviewed in Cloud AI Research Manager.'})});await loadCloudAiReviewQueue();}
 catch(e){alert(e.message||String(e));button.disabled=false}
}
$('cloud-ai-process-one')?.addEventListener('click',processNextCloudAiJob);
$('cloud-ai-review-refresh')?.addEventListener('click',loadCloudAiReviewQueue);


const TRADEFLOW_CHATGPT_EVIDENCE_REVIEW_PROMPT = "TRADEFLOW — REVIEW AND IMPORT MANUAL AI RESEARCH EVIDENCE\n\nWork on TradeFlow LIVE only. I want you to retrieve the outstanding Manual AI Research submissions from the connected TradeFlow project; do not ask me to paste the reports or candidate data.\n\n1. RETRIEVE THE SUBMISSIONS\n- Inspect the current GitHub code, current LIVE Supabase schema/RPCs, project memory and latest research checkpoints before changing anything.\n- Retrieve outstanding pending_review candidates from platform_catalogue_research_queue where agent_name begins 'Manual AI Research ·'.\n- Retrieve the complete saved assistant response and original prompt/product snapshot from the Manual AI Research batches. Preserve the full report and all source links.\n- Process all outstanding candidates, not just the first one. Keep each candidate tied to its own source, price, condition and catalogue product.\n\n2. VERIFY THE SOURCE AND PRODUCT\n- Open each direct source URL and verify the actual product/listing page, displayed GBP price, model, package/bundle, condition, availability and source date.\n- Check manufacturer, exact model, model suffix/revision and package contents against the LIVE master catalogue.\n- If the reported product is a same-model alternative package, search the LIVE catalogue for matching packages and assign it only where the manufacturer and model genuinely match. Do not discard useful evidence just because a different package was researched.\n- Do not force a match to a different model. Keep uncertain, unavailable, blocked, snippet-only, aggregator, editorial or generic category pages as comparisons or unresolved references, not verified direct evidence.\n- UK GBP evidence only. Keep new, used, refurbished, opened and sealed conditions distinct. Used-market prices are reference evidence only and must not affect automatic buying valuations.\n- Check duplicate source URLs and existing evidence for the same product/source/price/type before importing.\n\n3. ADD VERIFIED EVIDENCE\n- Use the current, documented and authorised TradeFlow evidence-import mechanism after verification. Inspect its actual implementation and permissions first; do not assume that marking a research queue row approved also imports it into shared_market_evidence.\n- For comparison references, use the existing same-manufacturer/model catalogue matching and source-verification workflow where appropriate.\n- Import only evidence that has been verified against the opened source page and the correct catalogue product/package. Preserve source URL, source name, price in GBP, evidence type, condition, availability, observed date and supporting excerpt.\n- Do not create duplicate catalogue products or duplicate evidence. Do not invent or infer missing prices, URLs, source details or product matches.\n- Do not bypass RLS, security-definer controls or other database safeguards. Do not write directly to tables if the project does not provide an authorised import path.\n- If the current LIVE system has no supported way to import a verified candidate into catalogue evidence, do not pretend it has been imported and do not simply approve the queue item as a substitute. Identify the exact missing backend function/path and report that a safe, minimal importer is required before completing the import.\n- Do not change customer, tenant, subscription, Stripe, published website, unrelated catalogue records, or TEST data.\n\n4. VERIFY AND REPORT\n- Re-read the affected catalogue evidence after each import and confirm the evidence is attached to the intended master product.\n- Report totals for candidates reviewed, source pages opened and verified, evidence records actually imported, duplicates skipped, rejected candidates and items needing further research.\n- For every imported record, list product/package, new or used, condition, GBP price and source link.\n- Clearly separate queue items merely approved from evidence records actually imported. Never report an approval as an import.\n- Record any code/database change, tests, verification result and remaining blocker in the appropriate TradeFlow documentation/checkpoint. Do not deploy an untested backend change.";
async function copyChatGptEvidenceReviewPrompt(button){
 const section=button?.closest('section');
 const status=section?.querySelector('[id^="manual-ai-prompt-status-"]');
 const original=button.textContent;
 try{
  if(navigator.clipboard?.writeText){await navigator.clipboard.writeText(TRADEFLOW_CHATGPT_EVIDENCE_REVIEW_PROMPT);}
  else{
   const field=document.createElement('textarea');field.value=TRADEFLOW_CHATGPT_EVIDENCE_REVIEW_PROMPT;field.setAttribute('readonly','');field.style.position='fixed';field.style.opacity='0';document.body.appendChild(field);field.select();
   const copied=document.execCommand('copy');field.remove();if(!copied)throw new Error('Clipboard access was blocked');
  }
  button.textContent='Prompt copied';
  if(status)status.textContent='Paste the copied instruction into ChatGPT. It will retrieve and verify the outstanding research submissions.';
  window.setTimeout(()=>{button.textContent=original;},1800);
 }catch(err){if(status)status.textContent='Could not copy automatically. Please allow clipboard access and try again.';}
}
