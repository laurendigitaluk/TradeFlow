// TradeFlow subscriber authentication for the test environment.
// This is intentionally separate from customer and Platform Owner sessions.
(()=>{
  const SUPABASE_URL='https://twfbmjwwqzxdxvclxbun.supabase.co';
  const KEY_STORAGE='tradeflow_subscriber_publishable_key';
  const SESSION_STORAGE='tradeflow_subscriber_session';
  const TENANTS={
    'f50fb889-c615-4e55-84d4-f0fd9f48b0b0':'Test Business A',
    '373598f0-7d35-41be-8ed2-3cc7ee9709c7':'Test Business B',
    '50641519-2aa5-4093-95e5-7e92bea733a6':'Test Business C'
  };
  const params=new URLSearchParams(location.search);
  let key=localStorage.getItem(KEY_STORAGE)||localStorage.getItem('tradeflow_platform_admin_publishable_key')||localStorage.getItem('tradeflow_testlab_publishable_key')||null;
  let session=null;
  try{session=JSON.parse(localStorage.getItem(SESSION_STORAGE)||'null')}catch{session=null}
  let tenantId=params.get('tenant_id');
  const storedTenant=localStorage.getItem('tradeflow_subscriber_tenant_id');
  if(!TENANTS[tenantId]&&TENANTS[storedTenant])tenantId=storedTenant;

  let resolveReady,rejectReady;
  window.tradeflowSubscriberAuthReady=new Promise((resolve,reject)=>{resolveReady=resolve;rejectReady=reject});
  window.tradeflowSubscriberAuth={
    get key(){return key},
    get session(){return session},
    get tenantId(){return tenantId},
    tenants:TENANTS
  };

  const style=document.createElement('style');
  style.textContent='.tradeflow-auth-overlay{position:fixed;inset:0;background:rgba(0,0,0,.48);display:flex;align-items:center;justify-content:center;z-index:9999;padding:24px}.tradeflow-auth-overlay[hidden]{display:none!important}.tradeflow-auth-card{width:min(440px,100%);background:#fff;border-radius:12px;padding:28px;box-shadow:0 18px 60px rgba(0,0,0,.25)}.tradeflow-auth-card h2{margin-top:0}.tradeflow-auth-card label{display:block;margin:14px 0 6px}.tradeflow-auth-card input,.tradeflow-auth-card select{width:100%;box-sizing:border-box;padding:10px}.tradeflow-auth-card button{margin-top:16px;padding:10px 16px}.tradeflow-auth-error{color:#a00;margin-top:12px}.tradeflow-auth-small{font-size:13px;opacity:.75}';
  document.head.appendChild(style);

  function save(){if(session?.access_token)localStorage.setItem(SESSION_STORAGE,JSON.stringify(session));else localStorage.removeItem(SESSION_STORAGE)}
  function setTenant(id){if(!TENANTS[id])throw Error('Invalid TradeFlow subscriber tenant.');tenantId=id;localStorage.setItem('tradeflow_subscriber_tenant_id',id);const p=new URLSearchParams(location.search);if(p.get('tenant_id')!==id){p.set('tenant_id',id);history.replaceState(null,'',`${location.pathname}?${p.toString()}`)}document.documentElement.dataset.tradeflowTenantId=id}
  async function refreshSession(){if(!session?.refresh_token)throw Error('Subscriber session has expired. Please sign in again.');const h=new Headers({'apikey':key,'Content-Type':'application/json'});const r=await fetch(`${SUPABASE_URL}/auth/v1/token?grant_type=refresh_token`,{method:'POST',headers:h,body:JSON.stringify({refresh_token:session.refresh_token})});const t=await r.text();let b=null;try{b=t?JSON.parse(t):null}catch{b=t}if(!r.ok||!b?.access_token)throw Error(b?.message||b?.error_description||b?.error||t||'Subscriber session refresh failed.');session={...b,user:session.user};save();return true}
  async function request(path,options={},retry=true){if(!key)throw Error('TradeFlow Supabase publishable key is not connected.');const h=new Headers(options.headers||{});h.set('apikey',key);if(session?.access_token)h.set('Authorization',`Bearer ${session.access_token}`);const method=(options.method||'GET').toUpperCase();if(options.body||!['GET','HEAD'].includes(method))h.set('Content-Type','application/json');const r=await fetch(`${SUPABASE_URL}${path}`,{...options,headers:h});const t=await r.text();let b=null;try{b=t?JSON.parse(t):null}catch{b=t}if(!r.ok){if(r.status===401&&retry&&session?.refresh_token){await refreshSession();return request(path,options,false)}const e=new Error(b?.message||b?.msg||b?.error_description||b?.error||t||`HTTP ${r.status}`);e.status=r.status;throw e}return b}
  function overlay(message=''){
    let el=document.getElementById('tradeflow-subscriber-auth');
    if(!el){el=document.createElement('div');el.id='tradeflow-subscriber-auth';el.className='tradeflow-auth-overlay';el.innerHTML='<div class="tradeflow-auth-card"><h2>Subscriber sign in</h2><p class="tradeflow-auth-small">Sign in with the TradeFlow subscriber Owner, Admin or Staff account for this test business. This session is separate from Customer and Platform Owner sessions.</p><label>Subscriber account email<input id="tradeflow-sub-email" type="email" autocomplete="username"></label><label>Password<input id="tradeflow-sub-password" type="password" autocomplete="current-password"></label><label>Test business<select id="tradeflow-sub-tenant"><option value="f50fb889-c615-4e55-84d4-f0fd9f48b0b0">Test Business A</option><option value="373598f0-7d35-41be-8ed2-3cc7ee9709c7">Test Business B</option><option value="50641519-2aa5-4093-95e5-7e92bea733a6">Test Business C</option></select></label><button id="tradeflow-sub-signin" type="button">Sign in</button><div id="tradeflow-sub-auth-error" class="tradeflow-auth-error"></div></div>';document.body.appendChild(el)}
    if(TENANTS[tenantId])el.querySelector('#tradeflow-sub-tenant').value=tenantId;
    if(message)el.querySelector('#tradeflow-sub-auth-error').textContent=message;
    el.hidden=false;
    el.querySelector('#tradeflow-sub-signin').onclick=signIn;
    el.querySelector('#tradeflow-sub-password').onkeydown=e=>{if(e.key==='Enter')signIn()};
  }
  function hide(){const el=document.getElementById('tradeflow-subscriber-auth');if(el)el.hidden=true}
  async function verify(){
    if(!key||!session?.access_token)return false;
    try{
      const user=await request('/auth/v1/user');
      session.user=user;save();
      const rows=await request('/rest/v1/rpc/subscriber_get_my_memberships',{method:'POST',body:'{}'});
      const allowed=(Array.isArray(rows)?rows:[]).filter(r=>TENANTS[r.tenant_id]);
      if(!allowed.length)return false;
      const selected=allowed.find(r=>r.tenant_id===tenantId)||allowed[0];
      setTenant(selected.tenant_id);
      window.tradeflowSubscriberAuth.role=selected.role_code;
      window.tradeflowSubscriberAuth.user=user;
      window.tradeflowSubscriberAuth.tenantId=tenantId;
      return true;
    }catch{return false}
  }
  async function signIn(){
    const email=document.getElementById('tradeflow-sub-email')?.value.trim(),password=document.getElementById('tradeflow-sub-password')?.value,selectedTenant=document.getElementById('tradeflow-sub-tenant')?.value,button=document.getElementById('tradeflow-sub-signin'),error=document.getElementById('tradeflow-sub-auth-error');
    if(!email||!password){error.textContent='Enter the subscriber email and password.';return}
    button.disabled=true;button.textContent='Signing in…';error.textContent='';
    try{
      const data=await request('/auth/v1/token?grant_type=password',{method:'POST',body:JSON.stringify({email,password})});
      session=data;save();
      const user=await request('/auth/v1/user');session.user=user;save();
      const rows=await request('/rest/v1/rpc/subscriber_get_my_memberships',{method:'POST',body:'{}'});
      const allowed=(Array.isArray(rows)?rows:[]).filter(r=>TENANTS[r.tenant_id]);
      if(!allowed.some(r=>r.tenant_id===selectedTenant))throw Error('This subscriber account is not an active member of the selected test business.');
      const member=allowed.find(r=>r.tenant_id===selectedTenant);setTenant(member.tenant_id);window.tradeflowSubscriberAuth.role=member.role_code;window.tradeflowSubscriberAuth.user=user;window.tradeflowSubscriberAuth.tenantId=tenantId;hide();await renderTenantSwitcher();resolveReady(window.tradeflowSubscriberAuth);
    }catch(e){session=null;save();error.textContent=e.message||String(e)}finally{button.disabled=false;button.textContent='Sign in'}
  }
  async function renderTenantSwitcher(){
    const host=document.getElementById('business-name');
    if(!host||!session?.access_token)return;
    try{
      const rows=await request('/rest/v1/rpc/subscriber_get_my_memberships',{method:'POST',body:'{}'});
      const allowed=(Array.isArray(rows)?rows:[]).filter(r=>TENANTS[r.tenant_id]);
      if(allowed.length<2){host.textContent=TENANTS[tenantId]||'TradeFlow';return}
      const select=document.createElement('select');
      select.id='tradeflow-tenant-switcher';
      select.title='Switch test business';
      select.style.cssText='padding:5px 8px;margin-right:8px';
      allowed.forEach(r=>{const o=document.createElement('option');o.value=r.tenant_id;o.textContent=TENANTS[r.tenant_id];select.appendChild(o)});
      select.value=tenantId;
      select.onchange=async()=>{
        const next=select.value;
        if(!TENANTS[next])return;
        setTenant(next);
        location.reload();
      };
      host.replaceWith(select);
    }catch{}
  }
  window.tradeflowSubscriberSignOut=()=>{session=null;save();location.reload()};
  (async()=>{
    if(await verify()){hide();await renderTenantSwitcher();resolveReady(window.tradeflowSubscriberAuth);return}
    overlay();
  })();
})();