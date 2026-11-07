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
    save();await establish();hideAuth();await loadTenants();await loadPlans();await loadPlatformEmail();await loadDomainActions();await loadProductPages();await window.loadPublicPages?.();
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
  try{if(!session?.access_token)throw Error('Sign in required');await establish();hideAuth();await Promise.allSettled([loadTenants(),loadPlans(),loadPlatformEmail(),loadDomainActions(),loadProductPages(),loadGemmaControlCentre(),loadGemmaTasks(),loadGemmaQueue(),loadGemmaBatchCategories(),window.loadPublicPages?.()])}
  catch(e){showAuth('')}
})();

function gemmaCategoryMeta(agent){
 const raw=String(agent.category||agent.agent_key||'').toLowerCase();
 if(/3d[- ]?printers?|printer.*equipment/.test(raw)||String(agent.agent_key||'')==='3d-printers')return{slug:'3d-printers-equipment',label:'3D Printers & Equipment'};
 if(/pokemon/.test(raw))return{slug:'pokemon-trading-cards',label:'Pokémon Trading Cards'};
 if(/camera/.test(raw))return{slug:'cameras',label:'Cameras and lenses'};
 if(/drone/.test(raw))return{slug:'drones',label:'Drones and accessories'};
 if(/gaming|console/.test(raw))return{slug:'gaming-consoles-accessories',label:'Gaming consoles and accessories'};
 if(/laptop|computer/.test(raw))return{slug:'laptops',label:'Laptops and computers'};
 if(/metal detector/.test(raw))return{slug:'metal-detectors',label:'Metal detectors and accessories'};
 if(/mobile|phone/.test(raw))return{slug:'mobile-phones',label:'Mobile phones'};
 return{slug:String(agent.agent_key||raw).toLowerCase().replace(/[^a-z0-9]+/g,'-'),label:String(agent.category||agent.agent_name||'General research')};
}
function renderGemmaResearcherCards(agents){
 const host=$('gemma-researcher-cards');if(!host)return;
 const specialists=(agents||[]).filter(a=>!String(a.agent_key||'').includes('worker')&&!/task control|release monitor|catalogue importer/i.test(String(a.category||'')));
 const groups=new Map();
 for(const a of specialists){const meta=gemmaCategoryMeta(a);if(!groups.has(meta.slug))groups.set(meta.slug,{...meta,list:[]});groups.get(meta.slug).list.push(a)}
 if(!groups.has('pokemon-trading-cards'))groups.set('pokemon-trading-cards',{slug:'pokemon-trading-cards',label:'Pokémon Trading Cards',list:[],unlinked:true});
 const order=[...groups.values()].sort((a,b)=>a.label.localeCompare(b.label));
 host.innerHTML=order.map(group=>{
  const list=group.list,active=list.filter(a=>a.status==='running'&&a.last_heartbeat&&Date.now()-new Date(a.last_heartbeat).getTime()<120000).length;
  const completed=list.reduce((n,a)=>n+Number(a.tasks_completed||0),0),candidates=list.reduce((n,a)=>n+Number(a.candidates_found||0),0);
  const agentsHtml=list.map(a=>'<div class="gemma-researcher-agent"><div><strong>'+escapeHtml(a.agent_name||a.agent_key)+'</strong> '+gemmaStatus(a)+'</div><small>Current work: '+escapeHtml(a.current_task||'Idle')+' · Last heartbeat: '+gemmaDate(a.last_heartbeat)+'</small>'+(a.last_error?'<small class="gemma-error-text">'+escapeHtml(a.last_error)+'</small>':'')+'</div>').join('');
  return '<article class="gemma-researcher-card"><div class="gemma-researcher-head"><div><span class="eyebrow">CATEGORY TEAM</span><h4>'+escapeHtml(group.label)+'</h4></div><span class="gemma-team-live">'+(group.unlinked?'Not linked':active+' active')+'</span></div><div class="gemma-researcher-metrics"><div><strong>'+completed+'</strong><small>Tasks completed</small></div><div><strong>'+candidates+'</strong><small>Candidates found</small></div><div><strong>'+list.length+'</strong><small>Registered agents</small></div></div>'+(agentsHtml||'<p class="muted">No research agent linked. This category is reserved for future research.</p>')+'<button type="button" class="gemma-manage-sources" data-manage-sources="'+escapeHtml(group.slug)+'">Manage research websites</button></article>';
 }).join('');
}
let gemmaSelectedSourceCategory='';
async function loadGemmaSources(category){
 gemmaSelectedSourceCategory=category;const panel=$('gemma-source-manager');if(!panel)return;panel.hidden=false;
 const names={'3d-printers-equipment':'3D Printers & Equipment','pokemon-trading-cards':'Pokémon Trading Cards','cameras':'Cameras and lenses','drones':'Drones and accessories','gaming-consoles-accessories':'Gaming consoles and accessories','laptops':'Laptops and computers','metal-detectors':'Metal detectors and accessories','mobile-phones':'Mobile phones'};
 $('gemma-source-title').textContent=(names[category]||category)+' — research websites';
 $('gemma-source-list').textContent='Loading approved websites…';$('gemma-source-status').textContent='';
 try{const rows=await request('/rest/v1/rpc/platform_owner_list_research_sources',{method:'POST',body:JSON.stringify({p_category_slug:category})});
  $('gemma-source-list').innerHTML=rows.length?'<table><thead><tr><th>Website</th><th>Type</th><th>Scope</th><th>Status</th><th>Category access</th></tr></thead><tbody>'+rows.map(x=>'<tr><td><strong>'+escapeHtml(x.source_name)+'</strong><br><a href="'+escapeHtml(x.homepage_url)+'" target="_blank" rel="noopener">'+escapeHtml(x.domain)+'</a></td><td>'+escapeHtml(x.source_kind)+'</td><td>'+escapeHtml(x.research_scope)+'</td><td>'+(x.enabled?'Enabled':'Disabled')+'</td><td>'+(x.universal?'<span class="gemma-universal-source">Universal</span>':'<label class="gemma-source-toggle"><input type="checkbox" data-source-id="'+escapeHtml(x.id)+'" '+(x.category_slugs.includes(category)?'checked':'')+'> Search this category</label>')+'</td></tr>').join('')+'</tbody></table>':'<p class="muted">No websites are assigned to this category yet. Add the websites you want Gemma to search below.</p>';
  $('gemma-source-list').querySelectorAll('[data-source-id]').forEach(el=>el.onchange=async()=>{el.disabled=true;try{await request('/rest/v1/rpc/platform_owner_set_research_source_category',{method:'POST',body:JSON.stringify({p_source_id:el.dataset.sourceId,p_category_slug:category,p_enabled:el.checked})});await loadGemmaSources(category)}catch(e){$('gemma-source-status').textContent=e.message||String(e);el.checked=!el.checked;el.disabled=false}});
 }catch(e){$('gemma-source-list').textContent=e.message||String(e)}
}
async function addGemmaResearchSource(e){
 e.preventDefault();const status=$('gemma-source-status'),button=e.currentTarget.querySelector('button[type=submit]');if(!gemmaSelectedSourceCategory)return;
 const p={p_source_name:$('gemma-source-name').value.trim(),p_domain:$('gemma-source-domain').value.trim().toLowerCase(),p_homepage_url:$('gemma-source-url').value.trim(),p_category_slug:gemmaSelectedSourceCategory,p_source_kind:$('gemma-source-kind').value,p_research_scope:$('gemma-source-scope').value};
 button.disabled=true;status.textContent='Adding website…';
 try{await request('/rest/v1/rpc/platform_owner_add_research_source',{method:'POST',body:JSON.stringify(p)});e.currentTarget.reset();status.textContent='Website added to this category.';await loadGemmaSources(gemmaSelectedSourceCategory)}catch(err){status.textContent=err.message||String(err)}finally{button.disabled=false}
}
function gemmaDate(value){if(!value)return'Never';const d=new Date(value);if(Number.isNaN(d.getTime()))return'Unknown';return d.toLocaleString('en-GB',{day:'2-digit',month:'short',hour:'2-digit',minute:'2-digit'})}
function gemmaStatus(agent){const age=agent.last_heartbeat?Date.now()-new Date(agent.last_heartbeat).getTime():Infinity;if(agent.status==='running'&&age<120000)return'<span class="gemma-status running">Running</span>';if(agent.status==='error')return'<span class="gemma-status error">Error</span>';if(agent.status==='paused')return'<span class="gemma-status paused">Paused</span>';if(age>300000)return'<span class="gemma-status offline">Offline / stale</span>';return'<span class="gemma-status idle">Idle</span>'}
async function loadGemmaControlCentre(){
 const error=$('gemma-error'),rows=$('gemma-agent-rows'),activity=$('gemma-activity');if(!rows||!activity)return;
 error.textContent='';rows.innerHTML='<tr><td colspan="7">Refreshing…</td></tr>';
 try{
  const data=await request('/rest/v1/rpc/platform_owner_get_ai_agent_control_centre',{method:'POST',body:JSON.stringify({p_activity_limit:60})});
  const agents=Array.isArray(data?.agents)?data.agents:[],events=Array.isArray(data?.activity)?data.activity:[];window.gemmaLastAgents=agents;
  $('gemma-agent-count').textContent=agents.length;
  $('gemma-running-count').textContent=agents.filter(a=>a.status==='running'&&a.last_heartbeat&&Date.now()-new Date(a.last_heartbeat).getTime()<120000).length;
  $('gemma-task-count').textContent=agents.reduce((n,a)=>n+Number(a.tasks_completed||0),0);
  $('gemma-candidate-count').textContent=agents.reduce((n,a)=>n+Number(a.candidates_found||0),0);
  $('gemma-evidence-count').textContent=agents.reduce((n,a)=>n+Number(a.evidence_queued||0),0);
  rows.innerHTML=agents.length?agents.map(a=>'<tr><td><strong>'+escapeHtml(a.agent_name||a.agent_key)+'</strong>'+(a.last_error?'<small class="gemma-error-text">'+escapeHtml(a.last_error)+'</small>':'')+'</td><td>'+escapeHtml(a.category||'—')+'</td><td>'+gemmaStatus(a)+'</td><td>'+escapeHtml(a.current_task||'—')+'</td><td>'+Number(a.tasks_completed||0)+'</td><td>'+Number(a.candidates_found||0)+'</td><td>'+gemmaDate(a.last_heartbeat)+'</td></tr>').join(''):'<tr><td colspan="7">No agent telemetry has been reported yet.</td></tr>';
  renderGemmaResearcherCards(agents);await loadGemmaBatchBranches();
  activity.innerHTML=events.length?events.map(e=>'<article class="gemma-event"><div class="gemma-event-head"><strong>'+escapeHtml(e.agent_name||e.agent_key||'Agent')+'</strong><time>'+gemmaDate(e.created_at)+'</time></div><div>'+escapeHtml(e.message||e.event_type||'Activity')+'</div><small>'+escapeHtml(e.event_type||'event')+(e.task_key?' · '+escapeHtml(e.task_key):'')+'</small></article>').join(''):'<p class="muted">No activity has been reported yet.</p>';
  $('gemma-updated').textContent='Updated '+new Date().toLocaleTimeString('en-GB',{hour:'2-digit',minute:'2-digit'});
 }catch(e){error.textContent=e.message||String(e);rows.innerHTML='<tr><td colspan="7">Unable to load agent telemetry.</td></tr>';activity.innerHTML='<p class="muted">Activity unavailable.</p>'}
}
async function loadGemmaTasks(){
 const target=$('gemma-task-list');if(!target)return;target.textContent='Loading task queue…';
 try{
  const rows=await request('/rest/v1/rpc/platform_owner_list_ai_agent_tasks',{method:'POST',body:JSON.stringify({p_limit:50})});
  const items=Array.isArray(rows)?rows:[];
  target.innerHTML=items.length?'<table><thead><tr><th>Task</th><th>Status</th><th>Attempts</th><th>Created</th><th>Error</th></tr></thead><tbody>'+items.map(x=>'<tr><td><strong>'+escapeHtml(x.task_key)+'</strong><small>'+escapeHtml((x.payload?.tasks||[]).map(t=>t.manufacturer+' '+t.model).join(', '))+'</small></td><td>'+escapeHtml(x.status)+'</td><td>'+Number(x.attempts||0)+'</td><td>'+gemmaDate(x.created_at)+'</td><td>'+escapeHtml(x.last_error||'—')+'</td></tr>').join('')+'</tbody></table>':'<p class="muted">No research tasks submitted yet.</p>';
 }catch(e){target.textContent='Task queue unavailable: '+(e.message||String(e))}
}
async function loadGemmaQueue(){
 const target=$('gemma-queue-list');if(!target)return;target.textContent='Loading LIVE research queue…';
 try{
  const rows=await request('/rest/v1/rpc/platform_owner_list_catalogue_research_queue',{method:'POST',body:JSON.stringify({p_status:'all',p_limit:100})});
  const items=Array.isArray(rows)?rows:[];
  target.innerHTML=items.length?'<table><thead><tr><th>Product</th><th>Category</th><th>Price</th><th>Source</th><th>Status</th><th>Received</th><th>Owner review</th></tr></thead><tbody>'+items.map(x=>'<tr><td><strong>'+escapeHtml(x.manufacturer+' '+x.model)+'</strong><small>'+escapeHtml(x.package_name||'')+'</small></td><td>'+escapeHtml(x.category_slug||'—')+'</td><td>'+(x.observed_price==null?'—':'£'+Number(x.observed_price).toFixed(2))+'</td><td>'+(x.source_url?'<a href="'+escapeHtml(x.source_url)+'" target="_blank" rel="noopener">Open source</a>':'—')+'</td><td>'+escapeHtml(x.status||'—')+'</td><td>'+gemmaDate(x.created_at)+'</td><td>'+(x.status==='pending_review'||x.status==='needs_research'?'<button type="button" data-gemma-review="approved" data-id="'+escapeHtml(x.id)+'">Approve for import review</button> <button type="button" data-gemma-review="needs_research" data-id="'+escapeHtml(x.id)+'">Research again</button> <button type="button" data-gemma-review="rejected" data-id="'+escapeHtml(x.id)+'">Reject</button>':'Reviewed')+'</td></tr>').join('')+'</tbody></table>':'<p class="muted">No research candidates are waiting in LIVE.</p>';
 }catch(e){target.textContent='Queue unavailable: '+(e.message||String(e))}
}
async function reviewGemmaCandidate(id,decision){
 const notes=decision==='approved'?'Owner accepted candidate for subsequent verification/import review.':decision==='rejected'?'Owner rejected candidate.':'Candidate requires further research.';
 try{await request('/rest/v1/rpc/platform_owner_review_catalogue_research_item',{method:'POST',body:JSON.stringify({p_id:id,p_decision:decision,p_notes:notes})});await loadGemmaQueue()}
 catch(e){$('gemma-error').textContent=e.message||String(e)}
}
$('gemma-queue-list')?.addEventListener('click',e=>{const b=e.target.closest('[data-gemma-review]');if(b){b.disabled=true;reviewGemmaCandidate(b.dataset.id,b.dataset.gemmaReview)}});
let gemmaBatchProducts=[],gemmaSelectedProducts=new Set();
async function loadGemmaBatchCategories(){
 const category=$('gemma-task-category');if(!category)return;
 try{const rows=await request('/rest/v1/rpc/platform_owner_list_gemma_research_categories',{method:'POST',body:'{}'});const current=category.value;
 category.innerHTML=(rows||[]).filter(x=>x.slug!=='pokemon-trading-cards').map(x=>'<option value="'+escapeHtml(x.slug)+'">'+escapeHtml(x.name)+'</option>').join('');
 if(current&&[...category.options].some(o=>o.value===current))category.value=current;
 await loadGemmaBatchBranches();await loadGemmaBatchProducts();
 }catch(e){$('gemma-product-list').textContent='Unable to load LIVE catalogue categories: '+(e.message||String(e))}
}
async function loadGemmaBatchBranches(){
 const category=$('gemma-task-category')?.value,branch=$('gemma-task-branch');if(!category||!branch)return;
 const rows=await request('/rest/v1/rpc/platform_owner_list_gemma_research_categories',{method:'POST',body:'{}'}),selected=(rows||[]).find(x=>x.slug===category),current=branch.value;
 branch.innerHTML='<option value="">All branches</option>'+((selected?.branches)||[]).map(x=>'<option value="'+escapeHtml(x.slug)+'">'+escapeHtml(x.name)+'</option>').join('');
 if(current&&[...branch.options].some(o=>o.value===current))branch.value=current;
 const agents=window.gemmaLastAgents||[],team=agents.filter(a=>String(a.category||'').toLowerCase().replace(/[^a-z0-9]+/g,'-')===category||String(a.agent_key||'')===category||(/3d-printers/.test(category)&&/3d-printers/.test(String(a.agent_key||''))));
 const agent=$('gemma-task-agent');if(agent)agent.innerHTML='<option value="">Automatically use category researcher</option>'+team.map(a=>'<option value="'+escapeHtml(a.agent_key)+'">'+escapeHtml(a.agent_name||a.agent_key)+'</option>').join('');
}
async function loadGemmaBatchProducts(){
 const category=$('gemma-task-category')?.value;if(!category)return;
 const host=$('gemma-product-list'),status=$('gemma-product-count');host.textContent='Checking LIVE catalogue and evidence…';
 try{const rows=await request('/rest/v1/rpc/platform_owner_list_gemma_research_products',{method:'POST',body:JSON.stringify({p_category_slug:category,p_branch_slug:$('gemma-task-branch').value||null,p_evidence_filter:$('gemma-task-filter').value,p_limit:Number($('gemma-task-limit').value)})});
 gemmaBatchProducts=Array.isArray(rows)?rows:[];gemmaSelectedProducts=new Set([...gemmaSelectedProducts].filter(id=>gemmaBatchProducts.some(x=>x.product_id===id)));
 status.textContent=gemmaBatchProducts.length+' matching products · '+gemmaSelectedProducts.size+' selected';
 host.innerHTML=gemmaBatchProducts.length?'<table><thead><tr><th>Select</th><th>Product</th><th>Branch</th><th>New evidence</th><th>Used evidence</th></tr></thead><tbody>'+gemmaBatchProducts.map(x=>'<tr><td><input type="checkbox" data-gemma-product="'+escapeHtml(x.product_id)+'" '+(gemmaSelectedProducts.has(x.product_id)?'checked':'')+'></td><td><strong>'+escapeHtml(x.manufacturer||'')+' '+escapeHtml(x.model)+'</strong><small>'+escapeHtml(x.package_name||x.package_key||'')+'</small></td><td>'+escapeHtml(x.branch_name||'—')+'</td><td>'+Number(x.new_evidence_count||0)+'</td><td>'+Number(x.used_evidence_count||0)+'</td></tr>').join('')+'</tbody></table>':'<p class="muted">No products match this category and evidence filter.</p>';
 host.querySelectorAll('[data-gemma-product]').forEach(el=>el.onchange=()=>{if(el.checked)gemmaSelectedProducts.add(el.dataset.gemmaProduct);else gemmaSelectedProducts.delete(el.dataset.gemmaProduct);status.textContent=gemmaBatchProducts.length+' matching products · '+gemmaSelectedProducts.size+' selected'});
 }catch(e){host.textContent='Catalogue coverage unavailable: '+(e.message||String(e))}
}
async function submitGemmaBatch(){
 const status=$('gemma-task-status'),button=$('gemma-task-submit'),selected=gemmaBatchProducts.filter(x=>gemmaSelectedProducts.has(x.product_id));
 if(!selected.length){status.textContent='Select at least one product first.';return}
 const batch=$('gemma-task-batch').value,chosen=selected.slice(0,batch==='all'?selected.length:Number(batch)),type=$('gemma-task-type').value,category=$('gemma-task-category').value,agent=$('gemma-task-agent').value;
 const tasks=chosen.map(x=>({category_slug:category,branch_slug:x.branch_slug||null,agent_key:agent||category,manufacturer:x.manufacturer,model:x.model,package_key:x.package_key||'standard',package_name:x.package_name||'Standard package',research_type:type,search_query:[x.manufacturer,x.model,x.package_name,'UK',type==='uk_new'?'new price':type==='uk_used'?'used price':'new and used price'].filter(Boolean).join(' ')}));
 const taskKey='owner-'+category+'-'+Date.now();button.disabled=true;status.textContent='Submitting '+tasks.length+' products to LIVE…';
 try{const result=await request('/rest/v1/rpc/platform_owner_enqueue_ai_agent_task',{method:'POST',body:JSON.stringify({p_task_key:taskKey,p_payload:{tasks},p_priority:50})});status.textContent='Queued '+tasks.length+' products in LIVE: '+(result?.task_key||taskKey);chosen.forEach(x=>gemmaSelectedProducts.delete(x.product_id));await loadGemmaBatchProducts();await loadGemmaTasks();await loadGemmaQueue();await loadGemmaControlCentre()}
 catch(e){status.textContent=e.message||String(e)}finally{button.disabled=false}
}

$('gemma-refresh')?.addEventListener('click',loadGemmaControlCentre);
$('gemma-queue-refresh')?.addEventListener('click',()=>{loadGemmaQueue();loadGemmaTasks()});
$('gemma-task-refresh')?.addEventListener('click',loadGemmaTasks);
$('gemma-task-submit')?.addEventListener('click',submitGemmaBatch);$('gemma-task-category')?.addEventListener('change',async()=>{await loadGemmaBatchBranches();await loadGemmaBatchProducts()});$('gemma-task-branch')?.addEventListener('change',loadGemmaBatchProducts);$('gemma-task-filter')?.addEventListener('change',loadGemmaBatchProducts);$('gemma-task-limit')?.addEventListener('change',loadGemmaBatchProducts);$('gemma-select-visible')?.addEventListener('click',()=>{gemmaBatchProducts.forEach(x=>gemmaSelectedProducts.add(x.product_id));loadGemmaBatchProducts()});$('gemma-clear-selection')?.addEventListener('click',()=>{gemmaSelectedProducts.clear();loadGemmaBatchProducts()});$('gemma-load-products')?.addEventListener('click',loadGemmaBatchProducts);
$('gemma-researcher-cards')?.addEventListener('click',e=>{const b=e.target.closest('[data-manage-sources]');if(b)loadGemmaSources(b.dataset.manageSources)});
$('gemma-source-close')?.addEventListener('click',()=>$('gemma-source-manager').hidden=true);
$('gemma-source-form')?.addEventListener('submit',addGemmaResearchSource);
setInterval(()=>{if(document.visibilityState==='visible'){loadGemmaControlCentre();loadGemmaTasks();loadGemmaQueue()}},20000);

/* Sidebar links open their matching owner-dashboard accordion. */
function initOwnerSectionAccordions(){
 const detailsFor=id=>{const section=document.getElementById(id);return section?Array.from(section.children).find(el=>el.matches&&el.matches('details.owner-section-accordion')):null};
 const openSection=id=>{const details=detailsFor(id);if(details)details.open=true};
 document.querySelectorAll('.sidebar nav a[href^="#"]').forEach(link=>link.addEventListener('click',()=>openSection(link.hash.slice(1))));
 window.addEventListener('hashchange',()=>{if(location.hash)openSection(decodeURIComponent(location.hash.slice(1)))});
 if(location.hash)openSection(decodeURIComponent(location.hash.slice(1)));
}
initOwnerSectionAccordions();
