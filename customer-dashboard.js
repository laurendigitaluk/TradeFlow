const SUPABASE_URL='https://twfbmjwwqzxdxvclxbun.supabase.co';
const KEY='sb_publishable_AvcMgtUKV0O5k8H6k94mZQ_qH4pEIS9';
const SESSION_STORAGE='tradeflow_customer_session';
let key=KEY,session=null,tenantId=new URLSearchParams(location.search).get('tenant_id')||localStorage.getItem('tradeflow_customer_tenant_id'),profile=null;
const $=id=>document.getElementById(id);
function esc(v){return String(v??'').replace(/[&<>\"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','\"':'&quot;',"'":'&#39;'}[c]||c))}
function money(v,c='GBP'){if(v==null)return'—';try{return new Intl.NumberFormat('en-GB',{style:'currency',currency:c}).format(Number(v))}catch{return c+' '+v}}
function message(t,type=''){const e=$('customer-message');if(e){e.textContent=t||'';e.className='message '+type}}
function showAuth(v){$('auth-panel').hidden=!v;$('portal').hidden=v}
async function api(path,o={}){const h=new Headers(o.headers||{});h.set('apikey',key);h.set('Content-Type','application/json');if(session?.access_token)h.set('Authorization','Bearer '+session.access_token);const r=await fetch(SUPABASE_URL+path,{...o,headers:h});const t=await r.text();let b=null;try{b=t?JSON.parse(t):null}catch{b=t}if(!r.ok)throw Error(b?.message||b?.msg||b?.error_description||b?.error||t||('HTTP '+r.status));return b}
async function rpc(name,body){return api('/rest/v1/rpc/'+name,{method:'POST',body:JSON.stringify(Object.assign({p_tenant_id:tenantId},body||{}))})}
function saveSession(v){session=v||null;if(session?.access_token)localStorage.setItem(SESSION_STORAGE,JSON.stringify(session));else localStorage.removeItem(SESSION_STORAGE)}
function restore(){try{const s=JSON.parse(localStorage.getItem(SESSION_STORAGE)||'null');if(s?.access_token)session=s}catch{}}
async function profileCheck(){try{const p=await rpc('customer_get_profile');if(!p)return false;profile=Array.isArray(p)?p[0]:p;return Boolean(profile)}catch{return false}}
async function loadBrand(){try{const r=await api('/rest/v1/tenant_public_profiles?select=business_name,logo_url&tenant_id=eq.'+encodeURIComponent(tenantId));const p=Array.isArray(r)?r[0]:r;const n=p?.business_name||'Customer Portal';$('brand-name').textContent=n;document.title=n+' Customer Portal';if(p?.logo_url)$('brand-logo').innerHTML='<img src="'+esc(p.logo_url)+'" alt="">';$('brand').href='public-site.html?tenant_id='+encodeURIComponent(tenantId)}catch{}}
function updatePortalNav(saleRows,orderRows){
 const saleLink=document.querySelector('.sidebar a[href="#selling"]');
 const orderLink=document.querySelector('.sidebar a[href="#orders"]');
 if(saleLink){
  saleLink.classList.remove('sale-progress','sale-action','sale-complete');
  if(saleRows!==null){if(!saleRows.length)saleLink.classList.add('sale-progress');
  else{
   const stages=saleRows.map(r=>r.stage||'submitted');
   const complete=stages.some(s=>s==='purchased');
   const action=stages.some(s=>['offer_ready','final_offer_sent','final_offer_required','awaiting_item','shipping','received','inspection'].includes(s));
   saleLink.classList.add(complete?'sale-complete':action?'sale-action':'sale-progress');
  }}
 }
 if(orderLink){
  orderLink.classList.remove('orders-empty','orders-active','orders-complete');
  orderLink.classList.add(orderRows.length?'orders-complete':'orders-empty');
 }
}
function orderFlow(s){const names=['Valuation','Offer','Shipping','Received','Inspection','Payment','Complete'];const map={Valuation:['submitted','under_review','valued'],Offer:['offer_ready','final_offer_sent','final_offer_required'],Shipping:['awaiting_item','shipping'],Received:['received'],Inspection:['inspection','testing','repair','return_pending'],Payment:['final_offer_accepted'],Complete:['purchased']};return '<div class="portal-flow">'+names.map(n=>'<div class="portal-step '+(map[n].includes(s)?'active':'')+'">'+n+'</div>').join('')+'</div>'}
async function loadSelling(){const data=await rpc('customer_get_selling_status');const rows=Array.isArray(data)?data:[];const offers=await rpc('customer_get_offers_v2');const offerRows=Array.isArray(offers)?offers:[];let shipping=[];try{shipping=await rpc('customer_get_pre_acquisition_shipping')||[]}catch{}const shippingByItem=Object.fromEntries((Array.isArray(shipping)?shipping:[]).map(x=>[x.buying_item_id,x]));if(!rows.length){$('selling-list').innerHTML='<div class="empty">No active sale or valuation yet.</div>';updatePortalNav([],[]);return}const offerByItem=Object.fromEntries(offerRows.map(o=>[o.buying_item_id,o]));$('selling-list').innerHTML=rows.map(r=>{const s=r.stage||'submitted',o=offerByItem[r.buying_item_id];let action='';if(o?.status==='accepted'&&!(s==='final_offer_accepted'&&o.offer_mode==='trade_in')){action='<div class="offer"><strong>Offer accepted</strong><div class="two offer-values" style="margin-top:10px"><div><span class="label">Customer choice</span><strong>'+(o.offer_mode==='trade_in'?'Trade-in offer':'Cash offer')+'</strong></div><div><span class="label">Accepted value</span><strong>'+money(o.amount,o.currency)+'</strong></div></div></div>'}if(s==='final_offer_accepted'&&o?.status==='accepted'&&o.offer_mode==='trade_in'){action='<div class="offer"><strong>Trade-in credit being processed</strong><p class="small">Your agreed trade-in value of '+money(o.amount,o.currency)+' is being added to your customer credit account.</p></div>'}if(o?.status==='published'){action='<div class="offer"><strong>Offer available</strong><div class="two offer-values" style="margin-top:10px"><div><span class="label">Cash offer</span><strong>'+money(o.cash_price!=null?o.cash_price:o.amount,o.currency)+'</strong></div><div><span class="label">Trade-in offer</span><strong>'+money(o.trade_in_price,o.currency)+'</strong></div></div><p class="small">Choose the cash or trade-in offer, or refuse.</p><div class="actions">'+(o.cash_price!=null?'<button data-offer="'+o.offer_id+'" data-choice="cash">Accept cash offer</button>':'')+(o.trade_in_price!=null?'<button data-offer="'+o.offer_id+'" data-choice="trade_in">Accept trade-in offer</button>':'')+'<button data-refuse="'+o.offer_id+'">Refuse offer</button></div></div>'}if(['awaiting_item','shipping'].includes(s)&&r.message){const sh=shippingByItem[r.buying_item_id];let ship='<div class="notice" style="margin-top:12px"><strong>Shipping</strong><p>'+esc(r.message)+'</p>';if(sh?.shipping_label_storage_path||sh?.shipping_label_url)ship+='<div class="actions"><button data-label="'+esc(r.buying_item_id)+'">Open shipping label</button></div>';if(sh?.shipping_qr_storage_path||sh?.shipping_qr_url)ship+='<div class="actions"><button data-qr="'+esc(r.buying_item_id)+'">Open QR code</button></div>';ship+='<div class="actions"><button data-post="'+r.buying_item_id+'">I have sent my item</button></div></div>';action+=ship}if(s==='final_offer_sent'&&o?.status==='published')action='<div class="offer"><strong>Final offer received</strong><div class="two offer-values" style="margin-top:10px"><div><span class="label">Cash offer</span><strong>'+money(o.cash_price!=null?o.cash_price:o.amount,o.currency)+'</strong></div><div><span class="label">Trade-in offer</span><strong>'+money(o.trade_in_price,o.currency)+'</strong></div></div><p class="small">This is the final purchase offer after inspection.</p><div class="actions">'+(o.cash_price!=null?'<button data-offer="'+o.offer_id+'" data-choice="cash">Accept cash offer</button>':'')+(o.trade_in_price!=null?'<button data-offer="'+o.offer_id+'" data-choice="trade_in">Accept trade-in offer</button>':'')+'<button data-refuse="'+o.offer_id+'">Refuse final offer</button></div></div>';return '<div class="sale-card current"><div class="sale-grid"><div><span class="label">Item</span><strong>'+esc(r.item_title||'Your item')+'</strong><div class="small">'+esc(r.item_reference||r.request_reference||'')+'</div></div><div><span class="label">Stage</span><span class="stage active">'+esc(s.replaceAll('_',' '))+'</span></div><div><span class="label">Status</span><strong>'+((o?.status==='accepted')?('Accepted: '+(o.offer_mode==='trade_in'?'Trade-in offer':'Cash offer')+' — '+money(o.amount,o.currency)):esc(r.message||'In progress'))+'</strong></div></div>'+orderFlow(s)+action+'</div>'}).join('');updatePortalNav(rows,[]);document.querySelectorAll('[data-offer]').forEach(b=>b.onclick=()=>respondOffer(b.dataset.offer,'accept',b.dataset.choice));document.querySelectorAll('[data-refuse]').forEach(b=>b.onclick=()=>respondOffer(b.dataset.refuse,'refuse'));document.querySelectorAll('[data-post]').forEach(b=>b.onclick=()=>postItem(b.dataset.post,b));document.querySelectorAll('[data-label]').forEach(b=>b.onclick=()=>openShip(b.dataset.label,'label'));document.querySelectorAll('[data-qr]').forEach(b=>b.onclick=()=>openShip(b.dataset.qr,'qr'))}
async function respondOffer(id,a,mode){try{await rpc(a==='accept'?'customer_accept_offer_choice':'customer_refuse_offer',a==='accept'?{p_offer_id:id,p_offer_mode:mode||'cash',p_response_notes:null}:{p_offer_id:id,p_response_notes:null});message(a==='accept'?'Offer accepted.':'Offer refused.','success');await loadSelling()}catch(e){message(e.message||String(e),'error')}}
async function openShip(id,kind){
 const popup=window.open('','tradeflowShippingPrint','width=1000,height=850,resizable=yes,scrollbars=yes');
 if(!popup){
  message('Please allow pop-ups for the Customer Portal to open the shipping file.','error');
  return;
 }
 try{
  popup.document.open();
  popup.document.write('<!doctype html><html><head><title>Shipping '+(kind==='label'?'Label':'QR Code')+'</title><style>'+
   'html,body{margin:0;padding:0;background:#e5e7eb;color:#17202a;font-family:Arial,sans-serif}'+
   '.toolbar{position:sticky;top:0;z-index:2;display:flex;gap:8px;align-items:center;padding:12px 16px;background:#fff;border-bottom:1px solid #d8dee5}'+
   '.toolbar strong{margin-right:auto}.toolbar button{padding:8px 14px;border:1px solid #17202a;background:#17202a;color:#fff;border-radius:4px;cursor:pointer}.toolbar button.secondary{background:#fff;color:#17202a}'+
   '.status{padding:30px;text-align:center}.page{width:4in;height:6in;margin:24px auto;background:#fff;display:flex;align-items:center;justify-content:center;overflow:hidden;box-shadow:0 2px 12px rgba(0,0,0,.16)}'+
   '.page img,.page iframe{display:block;width:6in;height:4in;max-width:none;max-height:none;border:0;background:#fff;object-fit:fill;transform:rotate(90deg);transform-origin:center center}'+
   'body.a4 .page{width:4in;height:6in;margin:0;box-shadow:0 2px 12px rgba(0,0,0,.16)}'+
   '@page{size:4in 6in;margin:0}@media print{html,body{background:#fff!important}.toolbar{display:none!important}.page{width:4in!important;height:6in!important;margin:0!important;box-shadow:none!important}.page img,.page iframe{width:4in!important;height:6in!important;max-width:6in!important;max-height:4in!important}body.a4 .page{width:4in!important;height:6in!important;margin:0!important}}'+
   'body.a4{background:#fff}body.a4 .page{}'+
   '</style></head><body><div class="toolbar"><strong>Shipping '+(kind==='label'?'Label':'QR Code')+'</strong><button onclick="printLabel(false)">Print 6×4</button><button class="secondary" onclick="printLabel(true)">Print on A4</button><button class="secondary" onclick="window.close()">Close</button></div><div id="status" class="status">Opening secure shipping file…</div><script>function printLabel(a4){document.body.classList.toggle("a4",!!a4);var s=document.createElement("style");s.id="print-size";s.textContent="@page{size:"+(a4?"A4":"4in 6in")+";margin:"+(a4?"0":"0")+"}";var old=document.getElementById("print-size");if(old)old.remove();document.head.appendChild(s);window.print();}</script></body></html>');
  popup.document.close();

  const rows=await rpc('customer_get_pre_acquisition_shipping');
  const x=(Array.isArray(rows)?rows:[]).find(r=>r.buying_item_id===id);
  const path=kind==='label'?x?.shipping_label_storage_path:x?.shipping_qr_storage_path;
  const direct=kind==='label'?x?.shipping_label_url:x?.shipping_qr_url;
  if(!path&&!direct)throw Error('Shipping file is not available yet.');

  let fileUrl=direct;
  if(!fileUrl){
   const r=await fetch(SUPABASE_URL+'/storage/v1/object/sign/tradeflow-media/'+path,{
    method:'POST',
    headers:{apikey:key,Authorization:'Bearer '+(session?.access_token||''),'Content-Type':'application/json'},
    body:JSON.stringify({expiresIn:86400})
   });
   const t=await r.text();
   let b=null;try{b=t?JSON.parse(t):null}catch{b=t}
   if(!r.ok)throw Error(b?.message||b?.error||t||'Could not open shipping file');
   const signedUrl=b?.signedURL;
   if(!signedUrl)throw Error('Could not create a secure shipping file link.');
   fileUrl=signedUrl.startsWith('http')?signedUrl:(signedUrl.startsWith('/storage/v1/')?SUPABASE_URL+signedUrl:(signedUrl.startsWith('/')?SUPABASE_URL+'/storage/v1'+signedUrl:SUPABASE_URL+'/storage/v1/'+signedUrl));
  }

  const cleanUrl=String(fileUrl).split('?')[0].toLowerCase();
  const isImage=/\.(png|jpe?g|gif|webp)$/i.test(cleanUrl);
  const content=isImage
   ?'<div class="page"><img src="'+String(fileUrl).replace(/&/g,'&amp;').replace(/"/g,'&quot;')+'" alt="Shipping '+(kind==='label'?'label':'QR code')+'"></div>'
   :'<div class="page"><iframe src="'+String(fileUrl).replace(/&/g,'&amp;').replace(/"/g,'&quot;')+'" title="Shipping '+(kind==='label'?'label':'QR code')+'"></iframe></div>';
  popup.document.getElementById('status').outerHTML=content;
  popup.focus();
 }catch(e){
  try{
   popup.document.getElementById('status').textContent=e.message||String(e);
  }catch{}
  message(e.message||String(e),'error');
 }
}
async function postItem(id,b){b.disabled=true;try{await rpc('customer_mark_buying_item_posted',{p_buying_item_id:id});message('Item sent status recorded.','success');await loadSelling()}catch(e){message(e.message||String(e),'error')}finally{b.disabled=false}}
async function loadCreditAccount(){try{const rows=await rpc('customer_get_credit_account');const a=Array.isArray(rows)?rows[0]:rows||{};$('credit-balance').textContent=money(Number(a.balance||0),a.currency||'GBP');$('credit-status').textContent='Available customer credit';}catch(e){$('credit-balance').textContent='£0.00';$('credit-status').textContent='Customer credit account';}}
async function loadOrders(){try{const rows=await rpc('customer_get_orders');const r=Array.isArray(rows)?rows:[];updatePortalNav(null,r);$('order-list').innerHTML=r.length?r.map(o=>'<div class="sale-card"><strong>'+esc(o.order_reference||'Order')+'</strong><p>'+esc(o.status||'')+' · '+money(o.total,o.currency)+'</p></div>').join(''):'<div class="empty">No orders yet.</div>'}catch(e){$('order-list').textContent=e.message||String(e)}}
async function loadDetails(){const p=await rpc('customer_get_profile');profile=Array.isArray(p)?p[0]:p||{};$('customer-name').textContent=(profile.first_name||'')+' '+(profile.last_name||'');$('profile-first-name').value=profile.first_name||'';$('profile-last-name').value=profile.last_name||'';$('profile-email').value=profile.email||'';$('profile-phone').value=profile.phone||'';const a=await rpc('customer_get_addresses');const addresses=Array.isArray(a)?a:[];const billing=addresses.find(x=>x.address_type==='billing')||{};const shipping=addresses.find(x=>x.address_type==='shipping')||{};$('customer-addresses').innerHTML='<h3>Addresses</h3><div class="two"><div class="sale-card"><strong>Payment address</strong><label>Recipient<input id="bill-recipient" value="'+esc(billing.recipient_name||'')+'"></label><label>Address<input id="bill-line1" value="'+esc(billing.line1||'')+'"></label><label>City<input id="bill-city" value="'+esc(billing.city||'')+'"></label><label>Postcode<input id="bill-postcode" value="'+esc(billing.postcode||'')+'"></label><div class="actions"><button data-address="billing" data-id="'+esc(billing.address_id||'')+'">Save payment address</button></div></div><div class="sale-card"><strong>Delivery address</strong><label>Recipient<input id="ship-recipient" value="'+esc(shipping.recipient_name||'')+'"></label><label>Address<input id="ship-line1" value="'+esc(shipping.line1||'')+'"></label><label>City<input id="ship-city" value="'+esc(shipping.city||'')+'"></label><label>Postcode<input id="ship-postcode" value="'+esc(shipping.postcode||'')+'"></label><div class="actions"><button data-address="shipping" data-id="'+esc(shipping.address_id||'')+'">Save delivery address</button></div></div></div><p class="small">Delivery address is stored internally as the shipping address type.</p>';document.querySelectorAll('[data-address]').forEach(b=>b.onclick=()=>saveAddress(b.dataset.address,b.dataset.id,b));const bank=await rpc('customer_get_bank_details');$('customer-bank-details').innerHTML='<h3>Bank details</h3><div class="two"><label>Account holder<input id="bank-holder" value="'+esc(bank?.account_holder_name||'')+'"></label><label>Bank name<input id="bank-name" value="'+esc(bank?.bank_name||'')+'"></label><label>Sort code<input id="bank-sort" value="'+esc(bank?.sort_code||'')+'"></label><label>Account number<input id="bank-number" value="'+esc(bank?.account_number||'')+'"></label></div><div class="actions"><button id="save-bank" type="button">Save bank details</button></div>';$('save-bank').onclick=saveBank}
async function saveAddress(type,id,b){try{b.disabled=true;const p={p_tenant_id:tenantId,p_address_id:id||null,p_address_type:type,p_recipient_name:$(type==='billing'?'bill-recipient':'ship-recipient').value.trim(),p_company_name:null,p_line1:$(type==='billing'?'bill-line1':'ship-line1').value.trim(),p_line2:null,p_city:$(type==='billing'?'bill-city':'ship-city').value.trim(),p_county:null,p_postcode:$(type==='billing'?'bill-postcode':'ship-postcode').value.trim(),p_country_code:'GB',p_is_default:true};await api('/rest/v1/rpc/customer_upsert_address',{method:'POST',body:JSON.stringify(p)});message(type==='billing'?'Payment address saved.':'Delivery address saved.','success');await loadDetails()}catch(e){message(e.message||String(e),'error')}finally{b.disabled=false}}
async function saveBank(){try{await api('/rest/v1/rpc/customer_save_bank_details',{method:'POST',body:JSON.stringify({p_tenant_id:tenantId,p_account_holder_name:$('bank-holder').value.trim(),p_sort_code:$('bank-sort').value.trim(),p_account_number:$('bank-number').value.trim(),p_bank_name:$('bank-name').value.trim()||null})});message('Bank details saved.','success');await loadDetails()}catch(e){message(e.message||String(e),'error')}}
async function loadPortal(){try{const ok=await profileCheck();if(!ok){saveSession(null);showAuth(true);message('This login is not registered for this business. Use Create customer account to create a new account.','error');return}showAuth(false);await loadBrand();await Promise.all([loadSelling(),loadOrders(),loadDetails(),loadCreditAccount()])}catch(e){showAuth(false);message(e.message||String(e),'error')}}
$('save-profile').onclick=async()=>{try{await rpc('customer_update_profile',{p_first_name:$('profile-first-name').value.trim(),p_last_name:$('profile-last-name').value.trim(),p_phone:$('profile-phone').value.trim()||null});message('Details saved.','success');await loadDetails()}catch(e){message(e.message||String(e),'error')}};
$('sign-out').onclick=()=>{saveSession(null);localStorage.removeItem('tradeflow_pending_customer_registration');showAuth(true);message('Signed out.','success');location.hash='';window.scrollTo(0,0);};
window.tradeflowCustomerDashboardRefresh=loadPortal;
window.addEventListener('tradeflow-auth-success',async(event)=>{if(event?.detail?.access_token)session=event.detail;else restore();await loadPortal()});
restore();loadBrand();if(session?.access_token)loadPortal();else showAuth(true);