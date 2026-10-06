const SUPABASE_URL='https://gxsrajtqzdjvmceqcpgv.supabase.co';const $=id=>document.getElementById(id);
const params=new URLSearchParams(window.location.search);const orderId=params.get('order_id');
function showRegistrationReady(){const p=$('registration-ready-panel');if(p)p.style.display='block';}
async function registerDomain(auth){
 const button=$('register-domain-button'),message=$('message');
 if(button){button.disabled=true;button.textContent='Checking registration…'}
 message.textContent='Checking the paid domain with Porkbun…';
 const headers={apikey:auth.key,Authorization:'Bearer '+auth.session.access_token,'Content-Type':'application/json'};
 const body={tenant_id:auth.tenantId,order_id:orderId};
 const pre=await fetch(SUPABASE_URL+'/functions/v1/porkbun-domain-registration',{method:'POST',headers,body:JSON.stringify({...body,action:'preflight'})});
 const pt=await pre.text();let pb;try{pb=JSON.parse(pt)}catch{pb=null}
 if(!pre.ok||pb?.status!=='PREFLIGHT_SUCCESS'){const detail=pb?.provider_message?(' Porkbun message: '+pb.provider_message):'';const code=pb?.provider_code?(' [Porkbun code: '+pb.provider_code+']'):'';const action=pb?.next_action?(typeof pb.next_action==='string'?(' Next action: '+pb.next_action):(' Next action: '+(pb.next_action.hint||pb.next_action.action||JSON.stringify(pb.next_action)))):'';const request=pb?.request_id?(' Request ID: '+pb.request_id):'';const raw=pb?.provider_response?(' Provider response: '+JSON.stringify(pb.provider_response)):'';throw Error((pb?.error||pt||('HTTP '+pre.status))+code+detail+action+request+raw);}
 message.textContent='Registration check passed. Registering '+(pb.hostname||'the domain')+'…';
 if(button)button.textContent='Registering domain…';
 const rr=await fetch(SUPABASE_URL+'/functions/v1/porkbun-domain-registration',{method:'POST',headers,body:JSON.stringify({...body,action:'register'})});
 const rt=await rr.text();let rb;try{rb=JSON.parse(rt)}catch{rb=null}
 if(!rr.ok||rb?.status!=='REGISTERED') throw Error(rb?.error||rb?.provider_message||rt||('HTTP '+rr.status));
 message.textContent='Domain registered successfully. '+rb.hostname+' is now registered with TradeFlow.';
 if(button){button.textContent='Domain registered';button.disabled=true}
 await loadOrder(auth);
}
async function reconcilePayment(auth){
 const r=await fetch(SUPABASE_URL+'/functions/v1/reconcile-domain-payment',{method:'POST',headers:{apikey:auth.key,Authorization:'Bearer '+auth.session.access_token,'Content-Type':'application/json'},body:JSON.stringify({tenant_id:auth.tenantId,order_id:orderId})});
 const text=await r.text();let body;try{body=JSON.parse(text)}catch{body=null}
 if(!r.ok) throw Error(body?.error||text||('HTTP '+r.status)); return body;
}
async function loadOrder(auth){
 if(!orderId) throw Error('No domain order was supplied.');
 const r=await fetch(SUPABASE_URL+'/rest/v1/tenant_domain_orders?id=eq.'+encodeURIComponent(orderId)+'&select=id,tenant_id,hostname,status,retail_amount,currency,expires_at,provider_order_id,payment_reference',{headers:{apikey:auth.key,Authorization:'Bearer '+auth.session.access_token}});
 const text=await r.text();let body;try{body=JSON.parse(text)}catch{body=null}
 if(!r.ok) throw Error(body?.message||'Domain order could not be loaded.');
 if(!Array.isArray(body)||!body[0]) throw Error('Domain order could not be found.');
 const order=body[0];
 if(order.status==='pending_payment') throw Error('Payment is still being confirmed. Please wait a moment and refresh this page.');
 if(!['payment_confirmed','registrant_details_saved','registered'].includes(order.status)) throw Error('This domain order is not ready for registrant details.');
 $('domain-name').textContent=order.hostname;$('payment-summary').textContent='Payment received: £'+Number(order.retail_amount).toFixed(2)+' '+order.currency+'.';
 if(order.status==='registered') $('message').textContent='This domain is already registered in TradeFlow.';
 else if(order.status==='registrant_details_saved'){ $('message').textContent='Registrant details have already been saved. Registration is the next controlled step.';showRegistrationReady(); }
 return order;
}
(async()=>{try{
 const auth=await window.tradeflowSubscriberAuthReady;window.__tradeflowDomainAuth=auth;
 $('business-name').textContent=auth.tenants?.[auth.tenantId]||'Domain registration';
 $('sign-out').onclick=()=>window.tradeflowSubscriberSignOut?.();
 await reconcilePayment(auth);await loadOrder(auth);
 $('register-domain-button').onclick=async()=>{try{await registerDomain(auth)}catch(err){$('message').textContent=err.message||String(err);const b=$('register-domain-button');if(b){b.disabled=false;b.textContent='Register domain'}}};
 $('registrant-form').onsubmit=async e=>{
  e.preventDefault();$('message').textContent='Saving registrant details…';$('save-button').disabled=true;
  const data={tenant_id:auth.tenantId,order_id:orderId,registrant_name:$('registrant_name').value,organisation:$('organisation').value,address_line1:$('address_line1').value,address_line2:$('address_line2').value,city:$('city').value,region:$('region').value,postal_code:$('postal_code').value,country_code:$('country_code').value,email:$('email').value,phone:$('phone').value};
  try{
   const r=await fetch(SUPABASE_URL+'/functions/v1/save-domain-registrant',{method:'POST',headers:{apikey:auth.key,Authorization:'Bearer '+auth.session.access_token,'Content-Type':'application/json'},body:JSON.stringify(data)});
   const text=await r.text();let body;try{body=JSON.parse(text)}catch{body=null}
   if(!r.ok){
    const detail=body?.details?(' '+body.details):'';
    const code=body?.code?(' ['+body.code+']'):'';
    throw Error((body?.error||text||('HTTP '+r.status))+code+detail);
   }
   $('message').textContent='Registrant details saved. The domain is now ready for the controlled registration step.';
   $('save-button').textContent='Details saved';showRegistrationReady();
  }catch(err){$('message').textContent=err.message||String(err);$('save-button').disabled=false;}
 };
}catch(err){$('message').textContent=err.message||String(err);}})();