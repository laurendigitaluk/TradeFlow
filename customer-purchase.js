(()=>{
const $=id=>document.getElementById(id);
const money=(v,c='GBP')=>{try{return new Intl.NumberFormat('en-GB',{style:'currency',currency:c}).format(Number(v))}catch{return c+' '+v}};
const esc=v=>String(v??'').replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]||c));
let listing=null,order=null,credit=0,ready=false;

function message(t,type=''){const e=$('purchase-message');if(e){e.textContent=t||'';e.className='intro '+(type==='error'?'error':'')}}
async function loadListing(id){
 if(!id)throw Error('The product checkout link is incomplete.');
 const rows=await api('/rest/v1/listings?select=id,title,description,asking_price,currency,status,quantity,listing_data,asset_id&id=eq.'+encodeURIComponent(id)+'&tenant_id=eq.'+encodeURIComponent(tenantId)+'&status=eq.published&limit=1');
 listing=Array.isArray(rows)?rows[0]:null;
 if(!listing)throw Error('This product is no longer available.');
}
async function loadCustomer(){
 const p=await rpc('customer_get_profile');const profile=Array.isArray(p)?p[0]:p||{};
 $('customer-name').textContent=((profile.first_name||'')+' '+(profile.last_name||'')).trim()||'Customer';
 const a=await rpc('customer_get_addresses');const rows=Array.isArray(a)?a:[];
 const shipping=rows.find(x=>x.address_type==='shipping')||{},billing=rows.find(x=>x.address_type==='billing')||{};
 $('purchase-delivery').innerHTML='<strong>Delivery address</strong><p class="small">'+esc([shipping.recipient_name,shipping.line1,shipping.city,shipping.postcode].filter(Boolean).join(', ')||'No delivery address saved.')+'</p><strong>Payment address</strong><p class="small">'+esc([billing.recipient_name,billing.line1,billing.city,billing.postcode].filter(Boolean).join(', ')||'No payment address saved.')+'</p>';
 const c=await rpc('customer_get_credit_account');const ca=Array.isArray(c)?c[0]:c||{};credit=Number(ca.balance||0);
}
function render(){
 const d=listing.listing_data||{},media=d.primary_image_url||'';
 $('purchase-product').innerHTML='<div class="purchase-product">'+(media?'<img src="'+esc(media)+'" alt="'+esc(listing.title)+'">':'<div></div>')+'<div><h3>'+esc(listing.title)+'</h3><p class="small">'+esc(listing.description||'')+'</p><div class="purchase-price">'+money(listing.asking_price,listing.currency)+'</div></div></div>';
 $('purchase-summary').innerHTML='<p><strong>Item</strong><br>'+esc(listing.title)+'</p><p><strong>Total</strong><br><span class="purchase-price">'+money(listing.asking_price,listing.currency)+'</span></p>';
 const total=Number(listing.asking_price||0),enough=credit>=total;
 $('purchase-payment-options').innerHTML='<label class="purchase-option selected"><input type="radio" name="purchase-payment" value="internet" checked><strong>Stripe / internet payment</strong><div class="small">Pay securely online using the business payment provider.</div></label><label class="purchase-option"><input type="radio" name="purchase-payment" value="credit" '+(enough?'':'disabled')+'><strong>Use customer credit</strong><div class="small">Available credit: '+money(credit,listing.currency)+(enough?'':' — insufficient for this purchase')+'</div></label>';
 document.querySelectorAll('.purchase-option').forEach(x=>x.onclick=()=>{const r=x.querySelector('input');if(r&&!r.disabled)r.checked=true;document.querySelectorAll('.purchase-option').forEach(y=>y.classList.remove('selected'));if(r&&!r.disabled)x.classList.add('selected')});
}
async function createOrder(){
 if(order)return order;
 const addresses=await rpc('customer_get_addresses');const rows=Array.isArray(addresses)?addresses:[],shipping=rows.find(x=>x.address_type==='shipping')||{},billing=rows.find(x=>x.address_type==='billing')||{};
 if(!shipping.line1||!shipping.postcode)throw Error('Add a delivery address in My Details before completing this purchase.');
 if(!billing.line1||!billing.postcode)throw Error('Add a payment address in My Details before completing this purchase.');
 const s={recipient_name:shipping.recipient_name||null,line1:shipping.line1,line2:shipping.line2||null,city:shipping.city||null,county:shipping.county||null,postcode:shipping.postcode,country_code:shipping.country_code||'GB'};
 const b={recipient_name:billing.recipient_name||null,line1:billing.line1,line2:billing.line2||null,city:billing.city||null,county:billing.county||null,postcode:billing.postcode,country_code:billing.country_code||'GB'};
 const r=await rpc('customer_create_retail_order',{p_listing_id:listing.id,p_shipping_address:s,p_billing_address:b,p_notes:null});order=Array.isArray(r)?r[0]:r;return order;
}
async function pay(){
 const b=$('purchase-pay');b.disabled=true;b.textContent='Working…';
 try{
  const method=document.querySelector('input[name="purchase-payment"]:checked')?.value;if(!method)throw Error('Choose a payment method.');
  const o=await createOrder();
  if(method==='credit'){
   const r=await rpc('customer_pay_retail_order_with_credit',{p_order_id:o.order_id}),x=Array.isArray(r)?r[0]:r;
   message('Payment completed using customer credit. Order '+esc(x.order_reference)+' is now placed.','success');
   $('purchase-payment-options').innerHTML='<div class="success"><strong>Payment complete</strong><p>Your customer credit has been applied to this order.</p><p>Order reference: '+esc(x.order_reference)+'</p></div>';
   b.hidden=true;return;
  }
  const r=await rpc('customer_create_order_payment',{p_order_id:o.order_id,p_idempotency_key:crypto.randomUUID()}),x=Array.isArray(r)?r[0]:r;
  if(x?.status==='pending'||x?.status==='processing'){
   message('Your order is reserved and the online payment has been started. The payment provider must complete payment before the order is marked paid.','success');
   $('purchase-payment-options').innerHTML='<div class="success"><strong>Internet payment started</strong><p>Payment reference: '+esc(x.payment_reference||'')+'</p><p>The payment provider is not connected to this test business yet, so TradeFlow has not marked the order as paid.</p></div>';
   b.hidden=true;
  }else throw Error('The payment provider did not return a payable payment state.');
 }catch(e){message(e.message||String(e),'error');order=null}
 finally{if(!b.hidden){b.disabled=false;b.textContent='Continue'}}
}
async function openPurchase(id){
 if(ready)return;ready=true;
 try{
  if(!session?.access_token){ready=false;return}
  $('portal').hidden=true;$('purchase').hidden=false;
  await loadListing(id);await loadCustomer();render();message('Review your order and choose a payment method.');
  $('purchase-pay').onclick=pay;
 }catch(e){ready=false;message(e.message||String(e),'error')}
}
window.addEventListener('tradeflow-portal-ready',event=>openPurchase(event.detail?.listingId||''));
if(tradeflowPurchaseMode&&session?.access_token)openPurchase(tradeflowListingId);
})();