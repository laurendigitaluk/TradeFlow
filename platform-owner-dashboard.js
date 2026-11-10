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
    save();await establish();hideAuth();await loadTenants();await loadPlans();await loadPlatformEmail();await loadDomainActions();await loadProductPages();await loadCloudAiProviders();await loadCloudAiJobs();await loadCloudAiReviewQueue();await window.loadPublicPages?.();
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
  try{if(!session?.access_token)throw Error('Sign in required');await establish();hideAuth();await Promise.allSettled([loadTenants(),loadPlans(),loadPlatformEmail(),loadDomainActions(),loadProductPages(),loadCloudAiProviders(),loadCloudAiJobs(),loadCloudAiReviewQueue(),window.loadPublicPages?.()])}
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
   '<div class="plan-editor-foot"><span class="plan-status">'+escapeHtml(p.status||'not configured')+(p.has_key?' · key stored in Vault':' · no key')+'</span><button type="submit">Save provider</button><button type="button" data-test-provider="'+d.provider_key+'">Test connection</button></div></form>';
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
async function loadCloudAiCatalogueProducts(resetOffset=true){
 const categoryId=$('cloud-ai-category').value,branchId=$('cloud-ai-branch').value||null;
 const host=$('cloud-ai-product-list');
 if(!categoryId){host.innerHTML='<p class="muted">Choose a category to load its products.</p>';return;}
 if(resetOffset)cloudAiCatalogueOffset=0;
 host.innerHTML='<p class="muted">Loading products and existing evidence counts…</p>';
 try{
  const data=await request('/rest/v1/rpc/platform_owner_list_cloud_ai_catalogue_products',{method:'POST',body:JSON.stringify({
   p_category_id:categoryId,p_branch_id:branchId,p_limit:cloudAiCataloguePageSize,p_offset:cloudAiCatalogueOffset
  })});
  cloudAiCatalogueProducts=data.products||[];
  cloudAiCatalogueTotal=Number(data.total_count||0);
  const first=cloudAiCatalogueTotal?cloudAiCatalogueOffset+1:0,last=Math.min(cloudAiCatalogueOffset+cloudAiCatalogueProducts.length,cloudAiCatalogueTotal);
  $('cloud-ai-product-list-summary').textContent='Showing '+first+'–'+last+' of '+cloudAiCatalogueTotal.toLocaleString()+' active catalogue products. Existing counts include active linked UK evidence only.';
  $('cloud-ai-product-prev').disabled=cloudAiCatalogueOffset===0;
  $('cloud-ai-product-next').disabled=cloudAiCatalogueOffset+cloudAiCatalogueProducts.length>=cloudAiCatalogueTotal;
  $('cloud-ai-queue-branch').disabled=!branchId||cloudAiCatalogueTotal===0;
  $('cloud-ai-queue-category').disabled=cloudAiCatalogueTotal===0;
  if(!cloudAiCatalogueProducts.length){host.innerHTML='<p class="muted">No active products found in this selection.</p>';return;}
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
 const branch=$('cloud-ai-branch');
 cloudAiCatalogueBranches=[];cloudAiCatalogueProducts=[];
 cloudAiCatalogueSelection.clear();renderCloudAiCatalogueSelection();
 branch.innerHTML='<option value="">Loading branches…</option>';branch.disabled=true;
 $('cloud-ai-queue-branch').disabled=true;$('cloud-ai-queue-category').disabled=true;
 if(!$('cloud-ai-category').value){branch.innerHTML='<option value="">Choose a category first…</option>';loadCloudAiCatalogueProducts();return;}
 try{
  const data=await loadCloudAiCatalogueTree($('cloud-ai-category').value);
  cloudAiCatalogueBranches=data.branches||[];
  branch.innerHTML='<option value="">All branches in category</option>'+cloudAiCatalogueBranches.map(x=>'<option value="'+escapeHtml(x.id)+'">'+escapeHtml(x.name)+' ('+Number(x.product_count||0)+' products)</option>').join('');
  branch.disabled=false;
  await loadCloudAiCatalogueProducts(true);
 }catch(err){branch.innerHTML='<option value="">Could not load branches</option>';$('cloud-ai-catalogue-picker-status').textContent=err.message||String(err);}
}
async function onCloudAiBranchChange(){
 cloudAiCatalogueSelection.clear();renderCloudAiCatalogueSelection();
 await loadCloudAiCatalogueProducts(true);
}
function renderCloudAiCatalogueSelection(){
 const count=cloudAiCatalogueSelection.size;
 $('cloud-ai-selected-count').textContent=count.toLocaleString()+' individual product'+(count===1?'':'s')+' selected';
 $('cloud-ai-queue-selected').disabled=!count;
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
 const button=scope==='category'?$ ('cloud-ai-queue-category'):$('cloud-ai-queue-branch');
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
$('cloud-ai-refresh')?.addEventListener('click',loadCloudAiProviders);
$('cloud-ai-jobs-refresh')?.addEventListener('click',loadCloudAiJobs);
$('cloud-ai-enqueue-form')?.addEventListener('submit',enqueueCloudAiJob);
loadCloudAiCatalogueCategories();

async function testCloudAiProvider(form){
 const button=form.querySelector('[data-test-provider]'),status=form.querySelector('.plan-status');
 button.disabled=true;status.textContent='Testing provider connection…';
 try{
  const result=await request('/functions/v1/tradeflow-cloud-ai-manager',{method:'POST',body:JSON.stringify({action:'test_provider',provider_key:form.dataset.provider})});
  status.textContent=result?.ok&&result.model_listed?'Connected · model confirmed · '+result.models_checked+' models checked':result?.ok?'Groq API reachable · configured model unavailable · '+result.models_checked+' models checked':(result?.error||'Connection check failed');
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
  const rows=await request('/rest/v1/rpc/platform_owner_list_catalogue_research_queue',{method:'POST',body:JSON.stringify({p_status:'pending_review',p_limit:200})});
  const items=(Array.isArray(rows)?rows:[]).filter(x=>x.agent_name==='Cloud AI Research Manager');
  host.innerHTML=items.map(x=>'<article class="plan-editor"><div class="plan-editor-head"><div><div class="eyebrow">'+escapeHtml(x.evidence_type||x.record_type||'candidate')+'</div><h3>'+escapeHtml((x.manufacturer||'')+' '+(x.model||''))+'</h3></div><span class="plan-status">Pending review</span></div><p><strong>Price:</strong> '+escapeHtml(x.price_currency||'GBP')+' '+escapeHtml(x.observed_price??'Not supplied')+' · '+escapeHtml(x.item_condition||'condition unknown')+'</p><p><strong>Source:</strong> '+escapeHtml(x.source_name||'')+' · <a href="'+escapeAttr(x.source_url||'#')+'" target="_blank" rel="noopener">Open evidence source</a></p><p>'+escapeHtml(x.source_excerpt||'')+'</p><p class="muted">'+escapeHtml(x.research_notes||'')+'</p><div class="plan-editor-foot"><button type="button" data-review-id="'+x.id+'" data-decision="approved">Approve candidate</button><button type="button" data-review-id="'+x.id+'" data-decision="needs_research">Needs more research</button><button type="button" data-review-id="'+x.id+'" data-decision="rejected">Reject</button></div></article>').join('')||'<p class="muted">No AI evidence candidates are awaiting review.</p>';
  host.querySelectorAll('[data-review-id]').forEach(b=>b.addEventListener('click',()=>reviewCloudAiCandidate(b.dataset.reviewId,b.dataset.decision,b)));
 }catch(e){host.innerHTML='<p class="error">'+escapeHtml(e.message||String(e))+'</p>'}
}
async function reviewCloudAiCandidate(id,decision,button){
 button.disabled=true;
 try{await request('/rest/v1/rpc/platform_owner_review_catalogue_research_item',{method:'POST',body:JSON.stringify({p_id:id,p_decision:decision,p_notes:'Reviewed in Cloud AI Research Manager.'})});await loadCloudAiReviewQueue();}
 catch(e){alert(e.message||String(e));button.disabled=false}
}
$('cloud-ai-process-one')?.addEventListener('click',processNextCloudAiJob);
$('cloud-ai-review-refresh')?.addEventListener('click',loadCloudAiReviewQueue);
