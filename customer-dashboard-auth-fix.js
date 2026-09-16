/* TradeFlow customer-dashboard authentication fallback.
 * Uses the Supabase publishable key only; never a service-role secret.
 * If the main dashboard handler is not responding, this capture-phase
 * handler performs the password sign-in, stores the normal session, and
 * reloads the dashboard so the main portal controller can restore it.
 */
(()=>{
  const SUPABASE_URL='https://twfbmjwwqzxdxvclxbun.supabase.co';
  const KEY='sb_publishable_AvcMgtUKV0O5k8H6k94mZQ_qH4pEIS9';
  const SESSION_STORAGE='tradeflow_testlab_session';
  const button=document.getElementById('auth-sign-in');
  const message=document.getElementById('customer-message');
  if(!button)return;
  localStorage.setItem('tradeflow_testlab_publishable_key',localStorage.getItem('tradeflow_testlab_publishable_key')||KEY);
  const show=(text,type='error')=>{if(message){message.textContent=text;message.className=type}};
  button.addEventListener('click',async event=>{
    event.preventDefault();
    event.stopImmediatePropagation();
    const email=document.getElementById('auth-email')?.value.trim();
    const password=document.getElementById('auth-password')?.value||'';
    if(!email||!password){show('Enter your email and password.');return;}
    button.disabled=true;
    const original=button.textContent;
    button.textContent='Signing in…';
    try{
      const response=await fetch(`${SUPABASE_URL}/auth/v1/token?grant_type=password`,{
        method:'POST',
        headers:{apikey:KEY,'Content-Type':'application/json'},
        body:JSON.stringify({email,password})
      });
      const text=await response.text();
      let data=null;try{data=text?JSON.parse(text):null}catch{data={message:text}};
      if(!response.ok)throw Error(data?.msg||data?.message||data?.error_description||data?.error||text||`HTTP ${response.status}`);
      localStorage.setItem(SESSION_STORAGE,JSON.stringify(data));
      location.reload();
    }catch(error){
      show(error?.message||String(error));
      button.disabled=false;
      button.textContent=original;
    }
  },true);
})();
