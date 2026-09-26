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
 const annual=p.annual_price===null||p.annual_price===undefined?'':'<small>'+new Intl.NumberFormat('en-GB',{style:'currency',currency:p.currency||'GBP'}).format(Number(p.annual_price))+' per year</small>';return '<strong>'+money+'</strong><span>per month</span>'+annual;
}
function tradeflowPlanHighlights(code){
 return ['Complete buying and valuation workflow','Trade-ins, offers and customer portal','Inventory, selling, orders and fulfilment','Customer-facing website and Website Builder','Staff management and staff messaging','Audit tools and analytics','Integrations and market intelligence','TradeFlow starting catalogue'];
}
function renderTradeflowPlanCards(host,plans){
 host.innerHTML=plans.map((p,i)=>{
  const featured=' featured-plan';
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
async function initTradeflowPlanDetails(){
 const comparison=document.getElementById('plan-comparison-wrap');
 const basic=document.getElementById('basic'),enhanced=document.getElementById('enhanced');
 if(!comparison&&!basic&&!enhanced)return;
 try{
  const plans=await tradeflowAvailablePlans(),codes=new Set(plans.map(p=>p.code));
  if(basic)basic.hidden=!codes.has('basic');
  if(enhanced)enhanced.hidden=!codes.has('enhanced');
  document.querySelectorAll('.details-actions a[href*="subscriber-signup.html?plan="]').forEach(a=>{
   const m=a.href.match(/[?&]plan=([^&#]+)/);if(m)a.hidden=!codes.has(decodeURIComponent(m[1]));
  });
  if(comparison)comparison.hidden=!(codes.has('basic')&&codes.has('enhanced'));
  const catalogue=document.getElementById('catalogue-dynamic');
  if(codes.has('catalogue')&&!catalogue){
   const p=plans.find(x=>x.code==='catalogue'),section=document.createElement('section');
   section.className='package-detail catalogue-detail';section.id='catalogue-dynamic';
   section.innerHTML='<div class="package-detail-heading"><div><div class="eyebrow">TRADEFLOW CATALOGUE</div><h2>'+p.name+'</h2></div><p>'+ (p.description||'') +'</p></div><div class="detail-grid"><article class="detail-card"><h3>Everything in Enhanced</h3><p>The Catalogue plan includes the Enhanced workspace plus a TradeFlow-provided starting catalogue.</p></article><article class="detail-card"><h3>Starting catalogue</h3><p>Use the TradeFlow-provided categories, subcategories and products as a starting point for your business.</p></article></div>';
   const principle=document.querySelector('.plan-principles');if(principle)principle.parentNode.insertBefore(section,principle);
  }
 }catch(e){console.warn(e)}
}
document.addEventListener('DOMContentLoaded',()=>{initTradeflowPublicPlans();initTradeflowPlanDetails()});
