const SUPABASE_URL='https://twfbmjwwqzxdxvclxbun.supabase.co';const $=id=>document.getElementById(id);
const params=new URLSearchParams(window.location.search);const orderId=params.get('order_id');
const esc=v=>String(v??'').replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]||c));
async function loadOrder(auth){
  if(!orderId) throw Error('No domain order was supplied.');
  const r=await fetch(SUPABASE_URL+'/rest/v1/tenant_domain_orders?id=eq.'+encodeURIComponent(orderId)+'&select=id,hostname,status,retail_amount,currency',{headers:{apikey:auth.key,Authorization:'Bearer '+auth.session.access_token}});
  const text=await r.text();let body;try{body=JSON.parse(text)}catch{body=null}
  if(!r.ok||!Array.isArray(body)||!body[0]) throw Error('Domain order could not be loaded.');
  const order=body[0];
  if(!['payment_confirmed','registrant_details_saved'].includes(order.status)) throw Error('This domain order is not ready for registrant details.');
  $('domain-name').textContent=order.hostname;
  $('payment-summary').textContent='Payment received: £'+Number(order.retail_amount).toFixed(2)+' '+order.currency+'.';
}
(async()=>{try{
 const auth=await window.tradeflowSubscriberAuthReady;window.__tradeflowDomainAuth=auth;
 $('business-name').textContent=auth.tenants?.[auth.tenantId]||'Domain registration';
 $('sign-out').onclick=()=>window.tradeflowSubscriberSignOut?.();
 await loadOrder(auth);
 $('registrant-form').onsubmit=async e=>{
  e.preventDefault();$('message').textContent='Saving registrant details…';$('save-button').disabled=true;
  const data={tenant_id:auth.tenantId,order_id:orderId,registrant_name:$('registrant_name').value,organisation:$('organisation').value,address_line1:$('address_line1').value,address_line2:$('address_line2').value,city:$('city').value,region:$('region').value,postal_code:$('postal_code').value,country_code:$('country_code').value,email:$('email').value,phone:$('phone').value};
  try{
   const r=await fetch(SUPABASE_URL+'/functions/v1/save-domain-registrant',{method:'POST',headers:{apikey:auth.key,Authorization:'Bearer '+auth.session.access_token,'Content-Type':'application/json'},body:JSON.stringify(data)});
   const text=await r.text();let body;try{body=JSON.parse(text)}catch{body=null}
   if(!r.ok) throw Error(body?.error||text||('HTTP '+r.status));
   $('message').textContent='Registrant details saved. The domain is now ready for registration.';
   $('save-button').textContent='Details saved';
  }catch(err){$('message').textContent=err.message||String(err);$('save-button').disabled=false;}
 };
}catch(err){$('message').textContent=err.message||String(err);}})();