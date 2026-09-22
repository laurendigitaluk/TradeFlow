const SUPABASE_URL='https://twfbmjwwqzxdxvclxbun.supabase.co';
const SUPABASE_KEY='sb_publishable_AvcMgtUKV0O5k8H6k94mZQ_qH4pEIS9';
const SESSION_STORAGE='tradeflow_customer_session';
const tenantId=new URLSearchParams(location.search).get('tenant_id');
const $=id=>document.getElementById(id);
const message=(text,type='')=>{const e=$('customer-message');if(e){e.textContent=text;e.className=type}};
const busy=(button,value,label)=>{if(!button)return;button.disabled=value;if(value){button.dataset.authLabel=button.textContent;if(label)button.textContent=label}else if(button.dataset.authLabel)button.textContent=button.dataset.authLabel};
async function authRequest(path,body){
 const response=await fetch(SUPABASE_URL+path,{method:'POST',headers:{apikey:SUPABASE_KEY,'Content-Type':'application/json'},body:JSON.stringify(body)});
 const text=await response.text();let data=null;try{data=text?JSON.parse(text):null}catch{data=text}
 if(!response.ok)throw Error(data?.msg||data?.message||data?.error_description||data?.error||text||'Authentication request failed.');
 return data;
}
function saveSession(data){localStorage.setItem(SESSION_STORAGE,JSON.stringify(data));}
function revealPortal(){
 const auth=$('auth-panel'),portal=$('portal');
 if(auth)auth.hidden=true;
 if(portal)portal.hidden=false;
}
function dispatchAuthSuccess(data){
 revealPortal();
 if(typeof window.tradeflowHandleCustomerAuthSuccess==='function'){
  window.tradeflowHandleCustomerAuthSuccess(data);
 }else{
  window.tradeflowPendingAuthSession=data;
  window.dispatchEvent(new CustomEvent('tradeflow-auth-success',{detail:data}));
 }
}
async function signIn(){
 const email=$('auth-email')?.value.trim(),password=$('auth-password')?.value||'',button=$('auth-sign-in');
 if(!email||!password)return message('Enter your email and password.','error');
 busy(button,true,'Signing in…');
 try{
  localStorage.removeItem(SESSION_STORAGE);
  const data=await authRequest('/auth/v1/token?grant_type=password',{email,password});
  if(!data?.access_token)throw Error('Supabase did not return a customer session.');
  saveSession(data);
  dispatchAuthSuccess(data);
 }catch(error){message(error.message||String(error),'error');busy(button,false)}
}
async function signUp(){
 if(!tenantId)return message('Open the customer portal from the subscriber website.','error');
 const email=$('auth-email')?.value.trim(),password=$('auth-password')?.value||'',first=$('auth-first-name')?.value.trim(),last=$('auth-last-name')?.value.trim(),button=$('auth-sign-up');
 if(!email||!password||!first)return message('Email, password and first name are required.','error');
 busy(button,true,'Creating account…');
 try{
  localStorage.removeItem(SESSION_STORAGE);
  const data=await authRequest('/auth/v1/signup',{email,password});
  if(!data?.access_token)throw Error('Account created. Confirm your email if required, then sign in.');
  saveSession(data);
  const response=await fetch(SUPABASE_URL+'/rest/v1/rpc/customer_register_for_tenant',{method:'POST',headers:{apikey:SUPABASE_KEY,Authorization:'Bearer '+data.access_token,'Content-Type':'application/json'},body:JSON.stringify({p_tenant_id:tenantId,p_first_name:first,p_last_name:last||null,p_phone:null})});
  const text=await response.text();if(!response.ok){let detail=text;try{const parsed=JSON.parse(text);detail=parsed.message||parsed.msg||parsed.error||text}catch{}throw Error(detail||'Customer registration could not be completed.')}
  dispatchAuthSuccess(data);
 }catch(error){message(error.message||String(error),'error');localStorage.removeItem(SESSION_STORAGE);busy(button,false)}
}
async function restoreExistingSession(){
 const raw=localStorage.getItem(SESSION_STORAGE);
 if(!raw)return;
 try{
  const data=JSON.parse(raw);
  if(!data?.access_token)throw Error('Invalid customer session.');
  const response=await fetch(SUPABASE_URL+'/auth/v1/user',{headers:{apikey:SUPABASE_KEY,Authorization:'Bearer '+data.access_token}});
  if(!response.ok)throw Error('Customer session is no longer valid.');
  dispatchAuthSuccess(data);
 }catch{
  localStorage.removeItem(SESSION_STORAGE);
 }
}
function bind(){
 $('auth-sign-in')?.addEventListener('click',signIn);
 $('auth-sign-up')?.addEventListener('click',signUp);
 $('auth-password')?.addEventListener('keydown',event=>{if(event.key==='Enter'){event.preventDefault();signIn()}});
 restoreExistingSession();
}
if(document.readyState==='loading')document.addEventListener('DOMContentLoaded',bind,{once:true});else bind();
