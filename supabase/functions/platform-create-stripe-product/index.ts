import "jsr:@supabase/functions-js/edge-runtime.d.ts";
const SUPABASE_URL=Deno.env.get('SUPABASE_URL')!;
const SERVICE_ROLE_KEY=Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
const STRIPE_SECRET_KEY=Deno.env.get('STRIPE_SECRET_KEY');
const headers={'Content-Type':'application/json','Access-Control-Allow-Origin':'*','Access-Control-Allow-Headers':'authorization, x-client-info, apikey, content-type'};
const json=(b:unknown,s=200)=>new Response(JSON.stringify(b),{status:s,headers});
async function rpc(path:string,body:unknown,auth?:string){
 const h:any={apikey:SERVICE_ROLE_KEY,Authorization:auth||`Bearer ${SERVICE_ROLE_KEY}`,'Content-Type':'application/json'};
 const r=await fetch(SUPABASE_URL+path,{method:'POST',headers:h,body:JSON.stringify(body)});
 const t=await r.text(); let d:any; try{d=t?JSON.parse(t):null}catch{d=t}
 if(!r.ok)throw Error(d?.message||d?.hint||d?.details||d||'Supabase request failed');
 return d;
}
Deno.serve(async req=>{
 if(req.method==='OPTIONS')return new Response('ok',{headers});
 if(req.method!=='POST')return json({error:'Method not allowed'},405);
 if(!STRIPE_SECRET_KEY)return json({error:'Stripe is not configured on the LIVE TradeFlow environment.'},503);
 const auth=req.headers.get('Authorization'); if(!auth)return json({error:'Authentication required'},401);
 try{
  const userRes=await fetch(SUPABASE_URL+'/auth/v1/user',{headers:{apikey:SERVICE_ROLE_KEY,Authorization:auth}});
  if(!userRes.ok)return json({error:'Unable to verify the platform owner session.'},401);
  const user=await userRes.json();
  const plans=await rpc('/rest/v1/rpc/platform_owner_get_plans',{},auth);
  const plan=Array.isArray(plans)?plans.find((p:any)=>p.code==='enhanced'):null;
  if(!plan)return json({error:'TradeFlow plan is not configured.'},409);
  if(plan.stripe_product_id&&plan.stripe_monthly_price_id)return json({product_id:plan.stripe_product_id,price_id:plan.stripe_monthly_price_id,reused:true});
  if(!plan.monthly_price||Number(plan.monthly_price)<=0)return json({error:'Set the TradeFlow monthly price before creating Stripe billing.'},409);
  const productParams=new URLSearchParams();
  productParams.set('name',String(plan.name||'TradeFlow'));
  productParams.set('description',String(plan.description||'The complete TradeFlow workspace.'));
  productParams.set('metadata[tradeflow_plan_code]',String(plan.code));
  const productRes=await fetch('https://api.stripe.com/v1/products',{method:'POST',headers:{Authorization:`Bearer ${STRIPE_SECRET_KEY}`,'Content-Type':'application/x-www-form-urlencoded'},body:productParams});
  const product=await productRes.json();
  if(!productRes.ok)return json({error:product?.error?.message||'Unable to create the Stripe Product.'},502);
  const priceParams=new URLSearchParams();
  priceParams.set('product',product.id);
  priceParams.set('currency',String(plan.currency||'GBP').toLowerCase());
  priceParams.set('unit_amount',String(Math.round(Number(plan.monthly_price)*100)));
  priceParams.set('recurring[interval]','month');
  priceParams.set('metadata[tradeflow_plan_code]',String(plan.code));
  const priceRes=await fetch('https://api.stripe.com/v1/prices',{method:'POST',headers:{Authorization:`Bearer ${STRIPE_SECRET_KEY}`,'Content-Type':'application/x-www-form-urlencoded'},body:priceParams});
  const price=await priceRes.json();
  if(!priceRes.ok)return json({error:price?.error?.message||'Unable to create the Stripe recurring Price.',product_id:product.id},502);
  const saved=await rpc('/rest/v1/rpc/platform_owner_update_plan',{
    p_plan_id:plan.id,p_name:plan.name,p_description:plan.description||'',p_website_visible:true,p_monthly_price:Number(plan.monthly_price),
    p_annual_price:plan.annual_price===null?null:Number(plan.annual_price),p_currency:plan.currency||'GBP',p_trial_days:Number(plan.trial_days??30),
    p_stripe_product_id:product.id,p_stripe_monthly_price_id:price.id,p_stripe_annual_price_id:plan.stripe_annual_price_id||''
  },auth);
  return json({product_id:product.id,price_id:price.id,plan:saved});
 }catch(e){return json({error:e instanceof Error?e.message:String(e)},500)}
});