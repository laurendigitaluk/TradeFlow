import "jsr:@supabase/functions-js/edge-runtime.d.ts";
const SUPABASE_URL=Deno.env.get('SUPABASE_URL')!;
const SERVICE_ROLE_KEY=Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
const STRIPE_WEBHOOK_SECRET=Deno.env.get('STRIPE_WEBHOOK_SECRET');
const STRIPE_SECRET_KEY=Deno.env.get('STRIPE_SECRET_KEY');
const headers={'Content-Type':'application/json','Access-Control-Allow-Origin':'*','Access-Control-Allow-Headers':'authorization, x-client-info, apikey, content-type'};
const json=(body:unknown,status=200)=>new Response(JSON.stringify(body),{status,headers});
function hex(b:ArrayBuffer){return[...new Uint8Array(b)].map(x=>x.toString(16).padStart(2,'0')).join('')}
async function hmac(secret:string,msg:string){const k=await crypto.subtle.importKey('raw',new TextEncoder().encode(secret),{name:'HMAC',hash:'SHA-256'},false,['sign']);return hex(await crypto.subtle.sign('HMAC',k,new TextEncoder().encode(msg)))}
function safeEqual(a:string,b:string){if(a.length!==b.length)return false;let x=0;for(let i=0;i<a.length;i++)x|=a.charCodeAt(i)^b.charCodeAt(i);return x===0}
async function callRpc(name:string,body:unknown){
 const r=await fetch(`${SUPABASE_URL}/rest/v1/rpc/${name}`,{method:'POST',headers:{apikey:SERVICE_ROLE_KEY,Authorization:`Bearer ${SERVICE_ROLE_KEY}`,'Content-Type':'application/json'},body:JSON.stringify(body)});
 const t=await r.text();let d:any;try{d=t?JSON.parse(t):null}catch{d=t}
 if(!r.ok)throw Error(d?.message||d?.hint||d?.details||d||`RPC ${name} failed`);
 return d;
}
async function getStripeSubscription(id:string){
 if(!STRIPE_SECRET_KEY)throw Error('Stripe secret is required to read the subscription.');
 const r=await fetch(`https://api.stripe.com/v1/subscriptions/${encodeURIComponent(id)}`,{headers:{Authorization:`Bearer ${STRIPE_SECRET_KEY}`}});
 const d=await r.json();if(!r.ok)throw Error(d?.error?.message||'Unable to read Stripe subscription.');
 return d;
}
function subscriptionFields(s:any){
 const item=s?.items?.data?.[0];
 return {
  subscription_id:String(s?.id||''),
  status:String(s?.status||''),
  customer_id:s?.customer?String(s.customer):null,
  price_id:item?.price?.id?String(item.price.id):null,
  trial_end:s?.trial_end?new Date(Number(s.trial_end)*1000).toISOString():null,
  current_period_start:s?.current_period_start?new Date(Number(s.current_period_start)*1000).toISOString():null,
  current_period_end:s?.current_period_end?new Date(Number(s.current_period_end)*1000).toISOString():null,
  cancel_at_period_end:!!s?.cancel_at_period_end,
  provider_metadata:s?.metadata||{}
 };
}
Deno.serve(async req=>{
 if(req.method==='OPTIONS')return new Response('ok',{headers});
 if(req.method!=='POST')return json({error:'Method not allowed'},405);
 if(!STRIPE_WEBHOOK_SECRET)return json({error:'Stripe webhook secret is not configured on this TradeFlow environment yet.'},503);
 const sig=req.headers.get('stripe-signature');if(!sig)return json({error:'Missing Stripe signature'},400);
 const raw=await req.text();
 try{
  const parts=Object.fromEntries(sig.split(',').map(p=>{const i=p.indexOf('=');return[p.slice(0,i),p.slice(i+1)]}));
  const ts=Number(parts.t),provided=parts.v1||'';
  if(!Number.isFinite(ts)||Math.abs(Date.now()/1000-ts)>300)return json({error:'Expired Stripe signature'},400);
  const expected=await hmac(STRIPE_WEBHOOK_SECRET,`${ts}.${raw}`);
  if(!safeEqual(expected,provided))return json({error:'Invalid Stripe signature'},400);
  const event=JSON.parse(raw),object=event?.data?.object;
  if(!event?.id||!event?.type||!object)return json({received:true});

  if(event.type==='checkout.session.completed' && object.mode==='subscription'){
    const metadata=object.metadata||{};
    const userId=metadata.user_id;
    const businessName=metadata.business_name;
    const planCode=metadata.plan_code||'enhanced';
    const subscriptionId=object.subscription;
    if(!userId||!businessName||!subscriptionId)return json({error:'Subscriber checkout metadata is incomplete'},400);
    const sub=await getStripeSubscription(String(subscriptionId));
    const f=subscriptionFields(sub);
    const tenantId=await callRpc('subscriber_finalize_signup',{
      p_user_id:userId,p_business_name:businessName,p_plan_code:planCode,
      p_customer_id:f.customer_id,p_subscription_id:f.subscription_id,p_price_id:f.price_id,
      p_subscription_status:f.status,p_trial_end:f.trial_end,p_current_period_start:f.current_period_start,
      p_current_period_end:f.current_period_end,p_metadata:{stripe_checkout_session_id:object.id,stripe_event_id:event.id,...f.provider_metadata}
    });
    return json({received:true,subscriber_signup:true,tenant_id:tenantId});
  }

  if(event.type==='customer.subscription.updated'||event.type==='customer.subscription.deleted'){
    const f=subscriptionFields(object);
    if(!f.subscription_id)return json({received:true});
    const synced=await callRpc('subscriber_sync_subscription',{
      p_subscription_id:f.subscription_id,p_status:f.status,p_customer_id:f.customer_id,p_price_id:f.price_id,
      p_trial_end:f.trial_end,p_current_period_start:f.current_period_start,p_current_period_end:f.current_period_end,
      p_cancel_at_period_end:f.cancel_at_period_end,p_provider_metadata:{stripe_event_id:event.id,...f.provider_metadata}
    });
    return json({received:true,subscription_synced:synced});
  }

  let tenantId=object.metadata?.tenant_id,paymentId=object.metadata?.payment_id,orderId=object.metadata?.order_id,domainOrderId=object.metadata?.domain_order_id,providerPaymentId=object.id,amount=Number(object.amount_total??object.amount_received??0)/100,currency=String(object.currency||'gbp').toUpperCase(),newStatus:string|null=null;
  if(event.type==='checkout.session.completed'||event.type==='checkout.session.async_payment_succeeded'){if(object.payment_status!=='paid')return json({received:true,ignored:'payment_not_paid'});newStatus='paid'}
  else if(event.type==='checkout.session.expired'){newStatus='cancelled'}
  else if(event.type==='payment_intent.succeeded'||event.type==='payment_intent.payment_failed'){newStatus=event.type==='payment_intent.succeeded'?'paid':'failed';amount=Number(object.amount_received??object.amount??0)/100;currency=String(object.currency||'gbp').toUpperCase()}
  else return json({received:true});
  if(domainOrderId){
    if(newStatus==='paid'){
      const {data:domainOrder,error:domainOrderError}=await admin.from('tenant_domain_orders').select('id,tenant_id,status,payment_reference,metadata').eq('id',String(domainOrderId)).maybeSingle();
      if(domainOrderError||!domainOrder)return json({error:'Domain order not found for Stripe payment.'},404);
      const mergedMetadata={...(domainOrder.metadata||{}),stripe_event_id:event.id,stripe_payment_event_type:event.type};
      if(event.type==='checkout.session.completed'||event.type==='checkout.session.async_payment_succeeded') mergedMetadata.stripe_checkout_session_id=object.id;
      if(event.type==='payment_intent.succeeded') mergedMetadata.stripe_payment_intent_id=object.id;
      const nextStatus=['registrant_details_saved','registered'].includes(domainOrder.status)?domainOrder.status:'payment_confirmed';
      const {error:updateError}=await admin.from('tenant_domain_orders').update({
        status:nextStatus,
        payment_provider:'stripe',
        payment_reference:domainOrder.payment_reference||((event.type==='checkout.session.completed'||event.type==='checkout.session.async_payment_succeeded')?object.id:null),
        failure_reason:null,
        metadata:mergedMetadata,
        updated_at:new Date().toISOString()
      }).eq('id',domainOrder.id);
      if(updateError)return json({error:updateError.message},500);
      return json({received:true,domain_payment_confirmed:true,order_id:domainOrder.id,status:nextStatus});
    }
    if(newStatus==='cancelled'){
      const {error:updateError}=await admin.from('tenant_domain_orders').update({status:'cancelled',failure_reason:'Stripe Checkout session expired.',updated_at:new Date().toISOString()}).eq('id',String(domainOrderId)).eq('status','pending_payment');
      if(updateError)return json({error:updateError.message},500);
      return json({received:true,domain_payment_cancelled:true,order_id:String(domainOrderId)});
    }
  }
  if(!tenantId||!paymentId||!newStatus)return json({received:true,ignored:'not_a_tradeflow_order_payment'});
  const payload={p_provider:'stripe',p_event_id:event.id,p_event_type:event.type,p_tenant_id:tenantId,p_payment_id:paymentId,p_provider_payment_id:providerPaymentId,p_new_status:newStatus,p_amount:amount,p_currency:currency,p_metadata:{stripe_event_id:event.id,stripe_order_id:orderId||null}};
  const r=await fetch(`${SUPABASE_URL}/rest/v1/rpc/process_external_payment_event`,{method:'POST',headers:{apikey:SERVICE_ROLE_KEY,Authorization:`Bearer ${SERVICE_ROLE_KEY}`,'Content-Type':'application/json'},body:JSON.stringify(payload)});
  if(!r.ok)return json({error:await r.text()},500);
  const result=await r.json();const conflict=Array.isArray(result)?result[0]===false:result===false;
  if(conflict&&newStatus==='paid'){
    if(!STRIPE_SECRET_KEY)return json({error:'Stripe secret is required to refund a payment when the product has already sold'},503);
    const paymentIntentId=object?.payment_intent;if(!paymentIntentId)return json({error:'Stripe PaymentIntent missing for conflict refund'},500);
    let refund=await fetch('https://api.stripe.com/v1/refunds',{method:'POST',headers:{Authorization:`Bearer ${STRIPE_SECRET_KEY}`,'Content-Type':'application/x-www-form-urlencoded'},body:new URLSearchParams({payment_intent:String(paymentIntentId),reason:'requested_by_customer'}).toString()});
    if(!refund.ok){const existing=await fetch(`https://api.stripe.com/v1/refunds?payment_intent=${encodeURIComponent(String(paymentIntentId))}&limit=10`,{headers:{Authorization:`Bearer ${STRIPE_SECRET_KEY}`}});const er=existing.ok?await existing.json():null;const already=Array.isArray(er?.data)&&er.data.some((x:any)=>x.status==='succeeded'||x.status==='pending');if(!already)return json({error:'Payment could not be refunded after the product became unavailable'},500)}
    const cancelPayload={...payload,p_event_id:`${event.id}:conflict-refunded`,p_event_type:'stripe.checkout.session.conflict_refunded',p_new_status:'cancelled'};
    const cr=await fetch(`${SUPABASE_URL}/rest/v1/rpc/process_external_payment_event`,{method:'POST',headers:{apikey:SERVICE_ROLE_KEY,Authorization:`Bearer ${SERVICE_ROLE_KEY}`,'Content-Type':'application/json'},body:JSON.stringify(cancelPayload)});if(!cr.ok)return json({error:await cr.text()},500);
    return json({received:true,refunded:true,reason:'product_already_sold'});
  }
  return json({received:true});
 }catch(e){return json({error:e instanceof Error?e.message:String(e)},400)}
});