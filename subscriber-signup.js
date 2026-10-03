const TRADEFLOW_RUNTIME=(()=>{const h=location.hostname;const isTest=h==='localhost'||h==='127.0.0.1'||h.endsWith('.github.io');return isTest?{supabaseUrl:'https://twfbmjwwqzxdxvclxbun.supabase.co',supabasePublishableKey:'sb_publishable_AvcMgtUKV0O5k8H6k94mZQ_qH4pEIS9'}:{supabaseUrl:'https://gxsrajtqzdjvmceqcpgv.supabase.co',supabasePublishableKey:'sb_publishable_Y8NRuGXqHNTu9oaolrpprw_wysMNLuz'};})();
const SUPABASE_URL=TRADEFLOW_RUNTIME.supabaseUrl,KEY=TRADEFLOW_RUNTIME.supabasePublishableKey;
const $=id=>document.getElementById(id);
async function startCheckout(accessToken,businessName,planCode='enhanced'){
 const r=await fetch(SUPABASE_URL+'/functions/v1/create-subscriber-checkout-session',{method:'POST',headers:{apikey:KEY,Authorization:'Bearer '+accessToken,'Content-Type':'application/json'},body:JSON.stringify({business_name:businessName,plan_code:planCode})});
 const text=await r.text();let body;try{body=text?JSON.parse(text):null}catch{body=text}
 if(!r.ok)throw Error(body?.error||body?.message||body||'Unable to start TradeFlow subscription checkout.');
 if(!body?.checkout_url)throw Error('TradeFlow subscription checkout did not return a checkout URL.');
 location.href=body.checkout_url;
}
$('signup-form').onsubmit=async e=>{e.preventDefault();const b=$('submit'),m=$('message');b.disabled=true;b.textContent='Creating account…';m.textContent='';
try{
 const email=$('email').value.trim(),password=$('password').value,businessName=$('business-name').value.trim(),ownerName=$('owner-name').value.trim(),plan='enhanced',nameParts=ownerName.split(/\s+/).filter(Boolean),firstName=nameParts.shift()||'',lastName=nameParts.join(' '),slug=businessName.toLowerCase().replace(/[^a-z0-9]+/g,'-').replace(/^-+|-+$/g,'')||'business';
 if(!businessName||!ownerName||!email||!password)throw Error('Please complete all required fields.');
 const authRes=await fetch(SUPABASE_URL+'/auth/v1/signup',{method:'POST',headers:{apikey:KEY,'Content-Type':'application/json'},body:JSON.stringify({email,password,data:{full_name:ownerName,first_name:firstName,last_name:lastName,business_name:businessName,plan_code:plan}})});
 const authText=await authRes.text();let auth;try{auth=authText?JSON.parse(authText):null}catch{auth=authText}
 if(!authRes.ok)throw Error(auth?.msg||auth?.message||auth?.error_description||authText||'Account creation failed.');
 localStorage.setItem('tradeflow_pending_signup',JSON.stringify({business_name:businessName,plan_code:plan}));
 if(!auth?.access_token){
  m.className='success';m.textContent='Account created. Check your email to confirm your account, then sign in to continue to secure Stripe Checkout and start your free month.';
  setTimeout(()=>{location.href='subscriber-login.html?signup=created'},1200);return;
 }
 localStorage.setItem('tradeflow_subscriber_session',JSON.stringify(auth));
 b.textContent='Opening secure checkout…';
 await startCheckout(auth.access_token,businessName,plan);
}catch(err){m.className='error';m.textContent=err.message||String(err)}finally{b.disabled=false;b.textContent='Start my free month'}};
