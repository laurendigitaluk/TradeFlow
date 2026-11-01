import "jsr:@supabase/functions-js/edge-runtime.d.ts";
const SUPABASE_URL=Deno.env.get('SUPABASE_URL')!;
const SERVICE_ROLE_KEY=Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
const STRIPE_SECRET_KEY=Deno.env.get('STRIPE_SECRET_KEY');
const ALLOWED_CHECKOUT_ORIGINS=new Set([
 'https://tradeflow.laurendigital.co.uk',
 'https://laurendigital.co.uk',
 'https://www.laurendigital.co.uk',
 'https://tradeflow.leannelaurenlowe.workers.dev'
]);
function getAllowedOrigin(req:Request):string|null{
 const value=req.headers.get('origin');
 if(!value)return null;
 try{
  const parsed=new URL(value);
  if(parsed.protocol!=='https:'||parsed.origin!==value||parsed.username||parsed.password)return null;
  return ALLOWED_CHECKOUT_ORIGINS.has(parsed.origin)?parsed.origin:null;
 }catch{return null}
}
function corsHeaders(origin:string|null){
 const h=new Headers({
  'Content-Type':'application/json',
  'Access-Control-Allow-Headers':'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods':'POST, OPTIONS',
  'Vary':'Origin'
 });
 if(origin)h.set('Access-Control-Allow-Origin',origin);
 return h;
}
Deno.serve(async req=>{
 const origin=getAllowedOrigin(req);
 const json=(b:unknown,s=200)=>new Response(JSON.stringify(b),{status:s,headers:corsHeaders(origin)});
 if(req.method==='OPTIONS'){
  if(!origin)return new Response('Forbidden',{status:403,headers:{'Vary':'Origin'}});
  return new Response('ok',{headers:corsHeaders(origin)});
 }
 if(!origin)return json({error:'Checkout origin is not permitted.'},403);
 if(req.method!=='POST')return json({error:'Method not allowed'},405);
 if(!STRIPE_SECRET_KEY)return json({error:'Stripe is not configured on the LIVE TradeFlow environment.'},503);
 const auth=req.headers.get('Authorization'); if(!auth)return json({error:'Authentication required'},401);
 try{
  const userRes=await fetch(SUPABASE_URL+'/auth/v1/user',{headers:{apikey:SERVICE_ROLE_KEY,Authorization:auth}});
  if(!userRes.ok)return json({error:'Authentication failed.'},401);
  const user=await userRes.json();
  const membershipRes=await fetch(SUPABASE_URL+'/rest/v1/rpc/subscriber_get_my_memberships',{
   method:'POST',
   headers:{apikey:SERVICE_ROLE_KEY,Authorization:auth,'Content-Type':'application/json'},
   body:'{}'
  });
  if(!membershipRes.ok)return json({error:'Unable to verify whether this account already has a TradeFlow business. Please sign in again or contact support.'},503);
  const memberships=await membershipRes.json();
  if(!Array.isArray(memberships))return json({error:'Unable to verify this account’s existing TradeFlow business membership.'},503);
  if(memberships.length)return json({error:'This account already has an active TradeFlow business. Sign in to access your existing workspace instead of starting another subscription.'},409);
  const body=await req.json();
  const businessName=String(body?.business_name||'').trim();
  const planCode=String(body?.plan_code||'enhanced').trim();
  const billingInterval=String(body?.billing_interval||'month').trim();
  if(!businessName)return json({error:'Business name is required.'},400);
  if(planCode!=='enhanced')return json({error:'The TradeFlow subscription plan is required.'},400);
  const planRes=await fetch(SUPABASE_URL+'/rest/v1/plans?code=eq.enhanced&active=eq.true&select=id,code,name,description,monthly_price,annual_price,currency,trial_days,stripe_monthly_price_id,stripe_annual_price_id&limit=1',{headers:{apikey:SERVICE_ROLE_KEY,Authorization:`Bearer ${SERVICE_ROLE_KEY}`}});
  if(!planRes.ok)return json({error:'Unable to load the TradeFlow plan.'},500);
  const plans=await planRes.json(); const plan=plans?.[0];
  if(!plan)return json({error:'TradeFlow plan is not configured.'},409);
  const selectedPriceId=billingInterval==='year'?plan.stripe_annual_price_id:plan.stripe_monthly_price_id;
  if(billingInterval!=='month'&&billingInterval!=='year')return json({error:'Choose a monthly or annual TradeFlow subscription.'},400);
  if(!selectedPriceId)return json({error:`TradeFlow ${billingInterval==='year'?'annual':'monthly'} Stripe billing has not been connected yet. Please contact the platform owner.`},409);
  const metadata={user_id:user.id,business_name:businessName,plan_code:plan.code};
  const params=new URLSearchParams();
  params.set('mode','subscription');
  params.set('line_items[0][price]',selectedPriceId);
  params.set('line_items[0][quantity]','1');
  params.set('customer_email',String(user.email||''));
  params.set('client_reference_id',String(user.id));
  params.set('metadata[user_id]',String(user.id));
  params.set('metadata[business_name]',businessName);
  params.set('metadata[plan_code]',plan.code);
  params.set('subscription_data[trial_period_days]',String(Number(plan.trial_days??30)));
  params.set('subscription_data[metadata][user_id]',String(user.id));
  params.set('subscription_data[metadata][business_name]',businessName);
  params.set('subscription_data[metadata][plan_code]',plan.code);
  params.set('subscription_data[metadata][tradeflow_plan_id]',String(plan.id));
  params.set('success_url',`${origin}/subscriber-signup-success.html?session_id={CHECKOUT_SESSION_ID}`);
  params.set('cancel_url',`${origin}/subscriber-signup.html?plan=${encodeURIComponent(plan.code)}&checkout=cancelled`);
  const stripeRes=await fetch('https://api.stripe.com/v1/checkout/sessions',{method:'POST',headers:{Authorization:`Bearer ${STRIPE_SECRET_KEY}`,'Content-Type':'application/x-www-form-urlencoded','Idempotency-Key':`tradeflow-subscriber-signup-${user.id}`},body:params});
  const stripe=await stripeRes.json();
  if(!stripeRes.ok){
   if(stripe?.error?.type==='idempotency_error')return json({error:'A signup checkout is already in progress for this account. Continue with the existing checkout, or wait for it to expire before starting a different billing selection.'},409);
   return json({error:stripe?.error?.message||'Unable to start Stripe subscription checkout.'},502);
  }
  return json({checkout_url:stripe.url,session_id:stripe.id,trial_days:Number(plan.trial_days??30),billing_interval:billingInterval,price:Number(billingInterval==='year'?plan.annual_price:plan.monthly_price)});
 }catch(e){return json({error:e instanceof Error?e.message:String(e)},500)}
});