const SUPABASE_URL='https://twfbmjwwqzxdxvclxbun.supabase.co';const $=id=>document.getElementById(id);
const params=new URLSearchParams(window.location.search);const orderId=params.get('order_id');
function showValidation(){const p=$('validation-panel');if(p)p.style.display='block';}
async function validateRegistration(auth){const m=$('validation-message');if(!m)return;m.textContent='Checking Porkbun registration requirements…';const r=await fetch(SUPABASE_URL+'/functions/v1/porkbun-domain-registration-dry-run',{method:'POST',headers:{apikey:auth.key,Authorization:'Bearer '+auth.session.access_token,'Content-Type':'application/json'},body:JSON.stringify({tenant_id:auth.tenantId,order_id:orderId})});const t=await r.text();let body;try{body=JSON.parse(t)}catch{body=null}if(!r.ok)throw Error(body?.error||t||('HTTP '+r.status));m.textContent=body.would_succeed?'Porkbun sandbox validation passed. The registration request would succeed and no charge or real registration was made.':'Porkbun sandbox validation completed, but the registration is not currently ready: '+(body.message||'wouldSucceed=false');if(body.would_succeed){const p=$('registration-panel');if(p)p.style.display='block';}}
const esc=v=>String(v??'').replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]||c));
async function loadOrder(auth){
  if(!orderId) throw Error('No domain order was supplied.');
  const r=await fetch(SUPABASE_URL+'/rest/v1/tenant_domain_orders?id=eq.'+encodeURIComponent(orderId)+'&select=id,hostname,status,retail_amount,currency,expires_at,provider_order_id',{headers:{apikey:auth.key,Authorization:'Bearer '+auth.session.access_token}});
  const text=await r.text();let body;try{body=JSON.parse(text)}catch{body=null}
  if(!r.ok||!Array.isArray(body)||!body[0]) throw Error('Domain order could not be loaded.');
  const order=body[0];
  if(!['payment_confirmed','registrant_details_saved','registered'].includes(order.status)) throw Error('This domain order is not ready for registrant details.');
  $('domain-name').textContent=order.hostname;
  $('payment-summary').textContent='Payment received: £'+Number(order.retail_amount).toFixed(2)+' '+order.currency+'.';
}
(async()=>{try{
 const auth=await window.tradeflowSubscriberAuthReady;window.__tradeflowDomainAuth=auth;
 $('business-name').textContent=auth.tenants?.[auth.tenantId]||'Domain registration';
 $('sign-out').onclick=()=>window.tradeflowSubscriberSignOut?.();
 const order=await loadOrder(auth);
 if(params.get('domain_payment')==='success'||order.status==='registered')showValidation();
 if(order.status==='registered'){
   $('validation-message').textContent='TEST registration is already recorded. Use the reconciliation action to refresh the provider expiry and registration details without creating another registration.';
   const rb=$('register-button');if(rb)rb.textContent='Refresh provider registration details';
   const rp=$('registration-panel');if(rp)rp.style.display='block';
 }
 const rb=$('register-button');if(rb)rb.onclick=async()=>{rb.disabled=true;$('registration-message').textContent='Registering in Porkbun TEST sandbox…';try{const r=await fetch(SUPABASE_URL+'/functions/v1/porkbun-domain-registration',{method:'POST',headers:{apikey:auth.key,Authorization:'Bearer '+auth.session.access_token,'Content-Type':'application/json'},body:JSON.stringify({tenant_id:auth.tenantId,order_id:orderId})});const t=await r.text();let body;try{body=JSON.parse(t)}catch{body=null}if(!r.ok)throw Error(body?.error||t||('HTTP '+r.status));$('registration-message').textContent='TEST sandbox registration/reconciliation completed. Provider order: '+(body.provider_order_id||'recorded')+'. Expiry: '+(body.expires_at||'not returned by provider')+'. TradeFlow status is now registered.';rb.textContent=body.expires_at?'Provider details refreshed':'Refresh provider details';}catch(err){$('registration-message').textContent=err.message||String(err);rb.disabled=false;}};const vb=$('validate-button');if(vb)vb.onclick=async()=>{vb.disabled=true;try{await validateRegistration(auth)}catch(err){$('validation-message').textContent=err.message||String(err)}finally{vb.disabled=false}};
 $('registrant-form').onsubmit=async e=>{
  e.preventDefault();$('message').textContent='Saving registrant details…';$('save-button').disabled=true;
  const data={tenant_id:auth.tenantId,order_id:orderId,registrant_name:$('registrant_name').value,organisation:$('organisation').value,address_line1:$('address_line1').value,address_line2:$('address_line2').value,city:$('city').value,region:$('region').value,postal_code:$('postal_code').value,country_code:$('country_code').value,email:$('email').value,phone:$('phone').value};
  try{
   const r=await fetch(SUPABASE_URL+'/functions/v1/save-domain-registrant',{method:'POST',headers:{apikey:auth.key,Authorization:'Bearer '+auth.session.access_token,'Content-Type':'application/json'},body:JSON.stringify(data)});
   const text=await r.text();let body;try{body=JSON.parse(text)}catch{body=null}
   if(!r.ok) throw Error(body?.error||text||('HTTP '+r.status));
   $('message').textContent='Registrant details saved. The domain is now ready for registration.';
   $('save-button').textContent='Details saved';
   showValidation();
  }catch(err){$('message').textContent=err.message||String(err);$('save-button').disabled=false;}
 };
}catch(err){$('message').textContent=err.message||String(err);}})();