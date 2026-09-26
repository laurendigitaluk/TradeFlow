const TRADEFLOW_PUBLIC_SUPABASE_URL='https://twfbmjwwqzxdxvclxbun.supabase.co';
const TRADEFLOW_PUBLIC_KEY='sb_publishable_AvcMgtUKV0O5k8H6k94mZQ_qH4pEIS9';
async function tradeflowAvailablePlans(){
 const r=await fetch(TRADEFLOW_PUBLIC_SUPABASE_URL+'/rest/v1/rpc/public_get_available_plans',{method:'POST',headers:{apikey:TRADEFLOW_PUBLIC_KEY,'Content-Type':'application/json'},body:'{}'});
 if(!r.ok)throw Error('Unable to load current TradeFlow plans.');
 const data=await r.json();return Array.isArray(data)?data:[];
}
function tradeflowPlanPrice(p){
 if(p.monthly_price===null||p.monthly_price===undefined)return '<strong>Price to be set</strong><span>per month</span>';
 const money=new Intl.NumberFormat('en-GB',{style:'currency',currency:p.currency||'GBP'}).format(Number(p.monthly_price));
 return '<strong>'+money+'</strong><span>per month</span>';
}
function tradeflowPlanHighlights(code){
 if(code==='basic')return ['Buying','Selling','Inventory management','Orders and fulfilment','Customer portal','Offers and trade-ins','Valuation tools — manual and rules','Your own customer-facing website','Website Builder','Custom categories and subcategories','Website preview and publishing'];
 if(code==='enhanced')return ['Everything in Basic','Staff management — up to 10 staff','Staff messaging','Audit tools','Analytics','Integrations','Market intelligence'];
 if(code==='catalogue')return ['Everything in Enhanced','TradeFlow-provided starting catalogue','Categories and subcategories','Starting product catalogue','Customer-facing website and portal'];
 return ['TradeFlow workspace'];
}
function renderTradeflowPlanCards(host,plans){
 host.innerHTML=plans.map((p,i)=>{
  const featured=p.code==='enhanced'?' featured-plan':'';
  const lis=tradeflowPlanHighlights(p.code).map(x=>'<li>'+x+'</li>').join('');
  const buttonClass=featured?'button button-primary full':'button button-outline full';
  return '<article class="plan-new'+featured+'"><div class="plan-top"><h3>'+p.name+'</h3><p>'+ (p.description||'') +'</p><div class="plan-price">'+tradeflowPlanPrice(p)+'</div></div><ul>'+lis+'</ul><a class="'+buttonClass+'" href="subscriber-signup.html?plan='+encodeURIComponent(p.code)+'">Start with '+p.name+'</a><a class="plan-detail-mini" href="plans.html#'+encodeURIComponent(p.code)+'">View '+p.name+' features →</a></article>';
 }).join('');
}
async function initTradeflowPublicPlans(){
 const host=document.getElementById('public-plan-grid');if(!host)return;
 try{const plans=await tradeflowAvailablePlans();renderTradeflowPlanCards(host,plans)}
 catch(e){host.innerHTML='<p>'+e.message+'</p>'}
}
document.addEventListener('DOMContentLoaded',initTradeflowPublicPlans);
