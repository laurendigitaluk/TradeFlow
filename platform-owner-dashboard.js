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
    save();await establish();hideAuth();await loadTenants();await loadPlans();await loadPlatformEmail();await loadAiSettings();await loadDomainActions();
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
    const result=await request('/functions/v1/platform-prepare-custom-domain',{
      method:'POST',
      headers:{
        Authorization:`Bearer ${session.access_token}`
      },
      body:JSON.stringify({action_id:actionId})
    });
    if(out)out.textContent='Connection prepared automatically.';
    await loadDomainActions();
    return result;
  }catch(e){
    if(out)out.textContent=e.message||String(e);
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
      if(key==='connection_prepared'){try{await prepareCloudflareConnection(id)}catch{}return;}
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
          if(m.dns_verified!==true || m.ssl_verified!==true || m.routing_verified!==true)throw Error('DNS, SSL and tenant routing must all be verified before activation.');
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
async function loadAiSettings(){const s=$('ai-settings-status');if(!s)return;try{const d=await request('/rest/v1/rpc/platform_owner_get_ai_settings',{method:'POST',body:'{}'});$('ai-active-provider').value=d?.active_provider||'none';$('ai-gemma').checked=!!d?.gemma_enabled;$('ai-openai').checked=!!d?.openai_enabled;$('ai-anthropic').checked=!!d?.anthropic_enabled;$('ai-google').checked=!!d?.google_enabled;$('ai-subscriber').checked=!!d?.subscriber_provider_enabled;s.textContent='AI settings loaded. Active provider: '+($('ai-active-provider').selectedOptions[0]?.text||'None')+'.'}catch(e){s.textContent=e.message||String(e)}}
async function saveAiSettings(e){e.preventDefault();const s=$('ai-settings-status'),b=e.currentTarget.querySelector('button[type="submit"]');const p={p_active_provider:$('ai-active-provider').value,p_subscriber_provider_enabled:$('ai-subscriber').checked,p_gemma_enabled:$('ai-gemma').checked,p_openai_enabled:$('ai-openai').checked,p_anthropic_enabled:$('ai-anthropic').checked,p_google_enabled:$('ai-google').checked};b.disabled=true;s.textContent='Saving…';try{const d=await request('/rest/v1/rpc/platform_owner_update_ai_settings',{method:'POST',body:JSON.stringify(p)});$('ai-active-provider').value=d?.active_provider||p.p_active_provider;s.textContent='Saved. Active provider: '+($('ai-active-provider').selectedOptions[0]?.text||'None')+'.'}catch(e){s.textContent=e.message||String(e)}finally{b.disabled=false}}
function nextPlan(code){return null}
function setActionMessage(text,isError=false){const el=$('action-message');if(el){el.textContent=text;el.className=isError?'action-message error':'action-message'}}
async function manageSubscription(tenantId,action,planCode,name){if(action==='close'&&!confirm('Close the TradeFlow account for "'+name+'"? The tenant will be archived and its subscription cancelled. This does not delete its stored business data.'))return;if(action==='upgrade'&&!confirm('Upgrade "'+name+'" to '+planCode+'?'))return;setActionMessage(action==='close'?'Closing account…':'Updating subscription…');try{await request('/rest/v1/rpc/platform_admin_manage_subscription',{method:'POST',body:JSON.stringify({p_tenant_id:tenantId,p_action:action,p_plan_code:planCode})});setActionMessage(action==='close'?'Account closed.':'Subscription upgraded.');await loadTenants()}catch(e){setActionMessage(e.message||String(e),true)}}
async function loadTenants(){const error=$('error');error.textContent='';$('tenant-rows').innerHTML='<tr><td colspan="9">Loading…</td></tr>';try{const [rows,accounts]=await Promise.all([request('/rest/v1/rpc/platform_admin_list_tenants',{method:'POST',body:'{}'}),request('/rest/v1/rpc/platform_admin_list_subscriber_accounts',{method:'POST',body:'{}'})]);const tenants=Array.isArray(rows)?rows:[],subscriberAccounts=Array.isArray(accounts)?accounts:[],subscriberIds=new Set(subscriberAccounts.map(x=>x.tenant_id)),subscriberTenants=tenants.filter(x=>subscriberIds.has(x.tenant_id));$('tenant-count').textContent=subscriberAccounts.length;$('active-count').textContent=subscriberAccounts.filter(x=>x.business_status==='active').length;$('tradeflow-count').textContent=subscriberTenants.filter(x=>x.plan_code==='enhanced').length;if(!subscriberAccounts.length){$('tenant-rows').innerHTML='<tr><td colspan="9">No subscriber businesses found.</td></tr>';return}const tenantMap=new Map(subscriberTenants.map(x=>[x.tenant_id,x]));$('tenant-rows').innerHTML=subscriberAccounts.map(t=>{const d=tenantMap.get(t.tenant_id)||{},current=d.plan_code||'—',next=nextPlan(current);let actions='';if(t.business_status==='archived'){actions='<span class="muted">Closed</span>'}else{actions+='<button class="table-action danger" data-action="close" data-tenant="'+t.tenant_id+'" data-name="'+escapeAttr(t.business_name)+'">Close account</button>'}return '<tr><td><strong>'+escapeHtml(t.business_name||'—')+'</strong></td><td>'+escapeHtml(t.owner_name||'—')+'</td><td>'+escapeHtml(t.owner_email||'—')+'</td><td>'+escapeHtml(current)+'</td><td>'+escapeHtml(d.subscription_status||'—')+'</td><td>'+escapeHtml(t.business_status||'—')+'</td><td>'+formatDate(t.joined_at)+'</td><td><a class="table-action" href="public-site.html?tenant_id='+encodeURIComponent(t.tenant_id)+'" target="_blank" rel="noopener">View website</a></td><td class="actions-cell">'+actions+'</td></tr>'}).join('');document.querySelectorAll('[data-action]').forEach(b=>b.onclick=()=>manageSubscription(b.dataset.tenant,b.dataset.action,b.dataset.plan,b.dataset.name))}catch(e){error.textContent=e.message||String(e);$('tenant-rows').innerHTML='<tr><td colspan="9">Unable to load platform data.</td></tr>'}}
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

$('refresh').onclick=loadTenants;$('refresh-domain-actions').onclick=loadDomainActions;
$('platform-email-form').onsubmit=savePlatformEmail;
$('ai-settings-form').onsubmit=saveAiSettings;
$('sign-out').onclick=()=>{session=null;save();location.reload()};

(async()=>{
  try{if(!session?.access_token)throw Error('Sign in required');await establish();hideAuth();await Promise.allSettled([loadTenants(),loadPlans(),loadPlatformEmail(),loadAiSettings(),loadDomainActions()])}
  catch(e){showAuth('')}
})();