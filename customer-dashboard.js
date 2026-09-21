const SUPABASE_URL='https://twfbmjwwqzxdxvclxbun.supabase.co';
const KEY='sb_publishable_AvcMgtUKV0O5k8H6k94mZQ_qH4pEIS9';
const SESSION_STORAGE='tradeflow_customer_session';
let key=KEY,session=null,tenantId=new URLSearchParams(location.search).get('tenant_id'),profile=null;
const $=id=>document.getElementById(id);
function setMessage(t,type=''){const e=$('customer-message');if(e){e.textContent=t||'';e.className=type}}
function setBusy(b,v,l){if(!b)return;b.disabled=v;if(v&&l){b.dataset.label=b.textContent;b.textContent=l}if(!v&&b.dataset.label)b.textContent=b.dataset.label}
async function api(path,o={}){if(!key)throw Error('TradeFlow Supabase is not connected.');const h=new Headers(o.headers||{});h.set('apikey',key);h.set('Content-Type','application/json');if(session?.access_token)h.set('Authorization',`Bearer ${session.access_token}`);const r=await fetch(`${SUPABASE_URL}${path}`,{...o,headers:h}),t=await r.text();let b=null;try{b=t?JSON.parse(t):null}catch{b=t}if(!r.ok)throw Error(b?.msg||b?.message||b?.error_description||b?.error||t||`HTTP ${r.status}`);return b}
function saveSession(v){session=v||null;if(session?.access_token)localStorage.setItem(SESSION_STORAGE,JSON.stringify(session));else localStorage.removeItem(SESSION_STORAGE)}
async function restoreSession(){const raw=localStorage.getItem(SESSION_STORAGE);if(!raw||!key)return false;try{session=JSON.parse(raw);session.user=await api('/auth/v1/user');return true}catch{saveSession(null);return false}}
async function signIn(){const email=$('auth-email').value.trim(),password=$('auth-password').value;if(!email||!password)return setMessage('Enter your email and password.','error');const b=$('auth-sign-in');setBusy(b,true,'Signing in…');try{saveSession(await api('/auth/v1/token?grant_type=password',{method:'POST',body:JSON.stringify({email,password})}));await initialisePortal()}catch(e){setMessage(e.message||String(e),'error')}finally{setBusy(b,false)}}
async function signUp(){const email=$('auth-email').value.trim(),password=$('auth-password').value,first=$('auth-first-name').value.trim(),last=$('auth-last-name').value.trim();if(!tenantId)return setMessage('Open the customer portal from the subscriber website.','error');if(!email||!password||!first)return setMessage('Email, password and first name are required.','error');const b=$('auth-sign-up');setBusy(b,true,'Creating account…');try{const d=await api('/auth/v1/signup',{method:'POST',body:JSON.stringify({email,password})});if(!d?.access_token)return setMessage('Account created. Confirm your email if required, then sign in.','success');saveSession(d);await api('/rest/v1/rpc/customer_register_for_tenant',{method:'POST',body:JSON.stringify({p_tenant_id:tenantId,p_first_name:first,p_last_name:last||null,p_phone:null})});await initialisePortal()}catch(e){setMessage(e.message||String(e),'error')}finally{setBusy(b,false)}}
function showAuth(v){$('auth-panel').hidden=!v;$('portal').hidden=v}
function applyTenantBranding(p){
 const name=(p?.business_name||'Customer Portal').trim()||'Customer Portal';
 const logoUrl=p?.logo_url||'';
 const brandName=$('brand-name'),brandLogo=$('brand-logo'),brand=$('brand'),website=$('customer-website-link');
 if(brandName)brandName.textContent=name;
 if(brandLogo)brandLogo.innerHTML=logoUrl?'<img src="'+esc(logoUrl)+'" alt="" loading="lazy">':'';
 const websiteUrl=tenantId?'public-site.html?tenant_id='+encodeURIComponent(tenantId):'#';
 if(brand){brand.href=websiteUrl;brand.setAttribute('aria-label','Visit '+name+' website');}
 if(website){website.href=websiteUrl;website.textContent='Visit '+name;website.hidden=!tenantId;}
 document.title=name+' Customer Portal';
}
async function loadTenantBranding(){
 if(!tenantId)return;
 try{
  const rows=await api('/rest/v1/tenant_public_profiles?select=business_name,logo_url&tenant_id=eq.'+encodeURIComponent(tenantId));
  applyTenantBranding(Array.isArray(rows)&&rows.length?rows[0]:null);
 }catch(e){
  console.warn('TradeFlow customer tenant branding unavailable:',e);
  applyTenantBranding(null);
 }
}

function money(v,c='GBP'){if(v==null)return'—';try{return new Intl.NumberFormat('en-GB',{style:'currency',currency:c}).format(Number(v))}catch{return`${c} ${v}`}}
function esc(v){return String(v??'').replace(/[&<>\"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]||c))}
function rows(data,cols,empty){if(!Array.isArray(data)||!data.length)return`<div class="empty">${esc(empty)}</div>`;return`<div class="data-table"><div class="data-head">${cols.map(c=>`<span>${esc(c.label)}</span>`).join('')}</div>${data.map(r=>`<div class="data-row">${cols.map(c=>`<span>${c.render?c.render(r):esc(r[c.key])}</span>`).join('')}</div>`).join('')}</div>`}
async function rpc(name){return api(`/rest/v1/rpc/${name}?p_tenant_id=${encodeURIComponent(tenantId)}`,{method:'GET'})}
async function loadCategories(){const data=await rpc('customer_get_buying_categories'),s=$('request-category');s.innerHTML='<option value="">Select a category…</option>';for(const c of Array.isArray(data)?data:[]){const o=document.createElement('option');o.value=c.category_id;o.textContent=c.name;s.appendChild(o)}if(!data?.length)s.innerHTML='<option value="">No buying categories available</option>'}
function offerAction(r){if(r.status!=='published')return '<span class="status-pill status-neutral">'+esc(r.status)+'</span>';return`<div class="offer-action-card"><div class="offer-action-title">Action required: review this offer</div><p class="small">You can accept or refuse this offer below.</p><textarea class="offer-response-notes" data-offer-id="${esc(r.offer_id)}" rows="2" placeholder="Optional response notes"></textarea><div class="actions"><button type="button" class="offer-accept" data-offer-id="${esc(r.offer_id)}">Accept offer</button><button type="button" class="offer-refuse" data-offer-id="${esc(r.offer_id)}">Refuse offer</button></div></div>`}
async function respond(id,a){const n=document.querySelector(`.offer-response-notes[data-offer-id="${CSS.escape(id)}"]`)?.value.trim()||null;try{await api(`/rest/v1/rpc/${a==='accept'?'customer_accept_offer':'customer_refuse_offer'}`,{method:'POST',body:JSON.stringify({p_tenant_id:tenantId,p_offer_id:id,p_response_notes:n})});setMessage(a==='accept'?'Offer accepted. Acquisition created.':'Offer refused.','success');await loadPortalData()}catch(e){setMessage(e.message||String(e),'error')}}
async function checkout(id){const b=document.querySelector(`.buy-listing[data-listing-id="${CSS.escape(id)}"]`);if(b?.disabled)return;try{setBusy(b,true,'Processing…');setMessage('Creating your order…','message');const result=await api('/rest/v1/rpc/customer_create_retail_order',{method:'POST',body:JSON.stringify({p_tenant_id:tenantId,p_listing_id:id})});const orderId=Array.isArray(result)?result[0]?.order_id||result[0]?.id||result[0]?.retail_order_id:result?.order_id||result?.id||result?.retail_order_id;if(!orderId)throw Error('The order was not returned by TradeFlow.');setMessage('Order created and awaiting payment. The listing has been reserved.','success');await loadPortalData();await payOrder(orderId)}catch(e){console.error('TradeFlow customer checkout failed:',e);setMessage(e.message||String(e),'error');setBusy(b,false)}}
async function payOrder(id){const b=document.querySelector(`[data-pay-order-id="${CSS.escape(id)}"]`);try{setBusy(b,true,'Opening secure payment…');const result=await api('/functions/v1/create-stripe-checkout-session',{method:'POST',body:JSON.stringify({tenant_id:tenantId,order_id:id})});if(!result?.checkout_url)throw Error(result?.error||'Payment checkout URL was not returned.');location.href=result.checkout_url}catch(e){setMessage(e.message||String(e),'error');setBusy(b,false)}}
async function createPayment(id){return payOrder(id)}
async function requestReturn(){const item=$('return-order-item').value;if(!item)return setMessage('Select an eligible order item.','error');try{await api('/rest/v1/rpc/customer_request_return',{method:'POST',body:JSON.stringify({p_tenant_id:tenantId,p_order_item_id:item,p_reason_code:$('return-reason-code').value,p_reason:$('return-reason').value.trim()||null,p_customer_notes:$('return-reason').value.trim()||null})});$('return-order-item').value='';$('return-reason').value='';setMessage('Return request submitted.','success');await loadPortalData()}catch(e){setMessage(e.message||String(e),'error')}}
function renderSellingStatus(data,offers){
 const box=$('selling-status-panel');if(!box)return;
 if(!Array.isArray(data)||!data.length){box.hidden=true;return}
 const active=data.find(x=>x.stage==='offer_ready')||data.find(x=>!['valued'].includes(x.stage))||data[0];
 const cls=active.stage==='manual_valuation'?'manual':active.stage==='offer_ready'?'ready':'progress';
 const title=active.stage==='manual_valuation'?'Manual valuation required':active.stage==='offer_ready'?'Offer sent — awaiting your response':active.stage==='valued'?'Valuation completed':'Valuation in progress';
 const liveOffer=Array.isArray(offers)?offers.find(o=>o.status==='published'&&o.buying_item_id===active.buying_item_id):null;
 box.hidden=false;
 box.className='selling-status '+cls;
 let action='';
 if(liveOffer){action='<div class="customer-offer-action"><div class="offer-action-kicker">ACTION REQUIRED</div><strong>Offer: '+money(liveOffer.amount,liveOffer.currency)+'</strong><p>Review this offer and choose Accept offer or Refuse offer.</p><textarea class="offer-response-notes" data-offer-id="'+esc(liveOffer.offer_id)+'" rows="2" placeholder="Optional response notes"></textarea><div class="actions"><button type="button" class="offer-accept status-offer-accept" data-offer-id="'+esc(liveOffer.offer_id)+'">Accept offer</button><button type="button" class="offer-refuse" data-offer-id="'+esc(liveOffer.offer_id)+'">Refuse offer</button></div></div>'}
 box.innerHTML='<div class="status-kicker">SELLING REQUEST</div><h3>'+esc(title)+'</h3><p><strong>'+esc(active.item_title||'Your item')+'</strong> <span class="status-pill">'+esc(active.item_reference||active.request_reference)+'</span></p><p>'+esc(active.message)+'</p><div class="status-meta"><span>Request <strong>'+esc(active.request_reference)+'</strong></span><span>Stage <strong>'+esc(String(active.stage||'').replace(/_/g,' '))+'</strong></span></div>'+action+(active.stage==='manual_valuation'?'<p class="status-next"><strong>What happens next:</strong> We will complete the manual valuation and show your valuation here when it is ready.</p>':'')+'</div>';
}
function renderSellingValuations(data){
 const box=$('valuation-list');if(!box)return;
 if(!Array.isArray(data)||!data.length){box.innerHTML='<div class="empty">No valuations have been issued yet. Your valuation will appear here when the subscriber has completed it.</div>';return}
 box.innerHTML=data.map(v=>'<article class="selling-handover valuation-card '+(String(v.status).toLowerCase()==='approved'?'approved':'')+'"><div><strong>'+esc(v.request_reference||'Selling request')+'</strong> <span class="status-pill '+(String(v.status).toLowerCase()==='approved'?'status-approved':'status-neutral')+'">'+esc(v.status||'valuation')+'</span></div><p><strong>Valuation:</strong> '+money(v.cash_price??v.amount??v.trade_in_price,v.currency)+'</p><p class="small">'+esc(v.method||'Valuation')+' · Calculated '+(v.calculated_at?new Date(v.calculated_at).toLocaleDateString('en-GB'):'—')+(v.approved_at?' · Approved '+new Date(v.approved_at).toLocaleDateString('en-GB'):'')+'</p></article>').join('');
}
async function markAcquisitionPosted(id){
 try{await api('/rest/v1/rpc/customer_mark_acquisition_posted',{method:'POST',body:JSON.stringify({p_tenant_id:tenantId,p_acquisition_id:id})});setMessage('Your item has been marked as posted.','success');await loadPortalData()}catch(e){setMessage(e.message||String(e),'error')}
}

function renderSellingShipping(data){
 const box=$('selling-shipping');if(!box)return;
 if(!Array.isArray(data)||!data.length){box.innerHTML='<div class="empty">No accepted sales yet. When you accept an offer, delivery instructions will appear here.</div>';return}
 box.innerHTML=data.map(r=>{const status=String(r.status||'').replace(/_/g,' ');const canShip=['accepted','awaiting_item','shipping'].includes(r.status);const label=r.shipping_label_url?'<a href="'+esc(r.shipping_label_url)+'" target="_blank" rel="noopener">Download shipping label</a>':'<span class="small">Shipping label not available yet.</span>';const tracking=r.shipping_tracking_number?'<p><strong>Tracking:</strong> '+esc(r.shipping_tracking_number)+(r.shipping_carrier?' · '+esc(r.shipping_carrier):'')+'</p>':'';const posted=r.posted_at?'<p><strong>Posted:</strong> '+new Date(r.posted_at).toLocaleDateString('en-GB')+'</p>':'';const instructions=r.shipping_instructions?'<p><strong>Instructions</strong><br>'+esc(r.shipping_instructions).replace(/\\n/g,'<br>')+'</p>':'<p class="small">Your subscriber will provide the shipping instructions and label here when the sale is ready for you to send the item.</p>';return '<article class="selling-handover"><div><strong>'+esc(r.acquisition_reference)+'</strong> <span class="status-pill">'+esc(status)+'</span></div><p><strong>Agreed amount:</strong> '+money(r.agreed_total,r.currency)+'</p>'+instructions+tracking+posted+'<div class="actions">'+(canShip?label:'')+(!r.posted_at&&r.shipping_label_url?'<button type="button" class="mark-posted" data-acquisition-id="'+esc(r.acquisition_id)+'">I have posted this item</button>':'')+'</div></article>'}).join('');
 document.querySelectorAll('.mark-posted').forEach(b=>b.onclick=()=>markAcquisitionPosted(b.dataset.acquisitionId));
}
function renderCustomerFulfilments(data){$('fulfilment-list').innerHTML=rows(data,[{key:'fulfilment_reference',label:'Reference'},{key:'status',label:'Status'},{key:'carrier',label:'Carrier'},{key:'tracking_number',label:'Tracking',render:r=>r.tracking_url?`<a href="${esc(r.tracking_url)}" target="_blank" rel="noopener">${esc(r.tracking_number||'Track')}</a>`:esc(r.tracking_number||'—')},{key:'delivered_at',label:'Delivered',render:r=>r.delivered_at?new Date(r.delivered_at).toLocaleDateString('en-GB'):'—'}],'No fulfilments yet.')}
function renderCustomerReturns(data,items,orders){$('return-list').innerHTML=rows(data,[{key:'return_reference',label:'Reference'},{key:'status',label:'Status'},{key:'reason',label:'Reason'},{key:'refund_amount',label:'Refund',render:r=>r.refund_amount==null?'—':money(r.refund_amount,r.currency)},{key:'requested_at',label:'Requested',render:r=>r.requested_at?new Date(r.requested_at).toLocaleDateString('en-GB'):'—'}],'No returns yet.');const eligible=(Array.isArray(items)?items:[]).filter(i=>['paid','fulfilment','completed'].includes(orders.find(o=>o.id===i.order_id)?.status));const s=$('return-order-item');s.innerHTML='<option value="">Select an eligible order item…</option>'+eligible.map(i=>`<option value="${esc(i.order_item_id)}">${esc(orders.find(o=>o.id===i.order_id)?.order_reference||i.order_id)} — ${esc(i.title)} × ${esc(i.quantity)}</option>`).join('')}
function restoreSellingJourney(){
 const raw=sessionStorage.getItem('tradeflow_selling_journey');if(!raw)return;
 let p=null;try{p=JSON.parse(raw)}catch{return}
 if(!p||p.tenant_id!==tenantId)return;
 const category=$('request-category'),title=$('request-title'),notes=$('request-notes');if(category&&p.category_id){category.value=p.category_id}
 if(title){title.value=[p.manufacturer,p.model,p.package_name].filter(Boolean).join(' ')||p.category_name||'Selling request'}
 if(notes){const lines=[];if(p.product_type)lines.push('Product type: '+p.product_type);if(p.condition)lines.push('Condition: '+p.condition);if(p.missing_items)lines.push('Missing items: '+p.missing_items);if(p.legal_right)lines.push('Legal right to sell: '+p.legal_right);if(p.serial_number)lines.push('Serial number: '+p.serial_number);if(p.notes)lines.push('Customer notes: '+p.notes);notes.value=lines.join('\n')}
 location.hash='#selling';sessionStorage.removeItem('tradeflow_selling_journey');
 setMessage('Your selling request details have been carried across. Check them, then submit.','success');
}
async function loadPortalData(){const [buying,values,offers,acq,shipping,orders,items,fulfilments,returns,shop,addresses,sellingStatus]=await Promise.all([rpc('customer_get_buying_requests'),rpc('customer_get_trading_values'),rpc('customer_get_offers'),rpc('customer_get_acquisitions'),rpc('customer_get_acquisition_shipping'),rpc('customer_get_orders'),rpc('customer_get_order_items'),rpc('customer_get_fulfilments'),rpc('customer_get_returns'),rpc('customer_get_store_listings'),rpc('customer_get_addresses'),rpc('customer_get_selling_status')]);profile=(await rpc('customer_get_profile'))?.[0]||null;$('customer-name').textContent=profile?`${profile.first_name||''} ${profile.last_name||''}`.trim()||'Customer':'Customer';$('buying-count').textContent=buying?.length||0;$('order-count').textContent=orders?.length||0;$('return-count').textContent=returns?.length||0;$('buying-list').innerHTML=rows(buying,[{key:'request_reference',label:'Reference'},{key:'status',label:'Status'},{key:'source',label:'Source'}],'No selling requests yet.');renderSellingStatus(sellingStatus,offers);renderSellingValuations(await rpc('customer_get_selling_valuations'));$('offer-list').innerHTML=offers?.length?'<div class="offer-instruction">A published offer requires your response. Review the amount and choose <strong>Accept offer</strong> or <strong>Refuse offer</strong>.</div>'+rows(offers,[{key:'offer_reference',label:'Offer'},{key:'offer_type',label:'Type'},{key:'status',label:'Response',render:offerAction},{key:'amount',label:'Amount',render:r=>money(r.amount,r.currency)}],'No offers published.'):'<div class="empty">No offer has been sent yet. When the subscriber publishes your offer, it will appear here with Accept and Refuse buttons.</div>';$('acquisition-list').innerHTML=rows(acq,[{key:'acquisition_reference',label:'Reference'},{key:'status',label:'Status'},{key:'agreed_total',label:'Agreed',render:r=>money(r.agreed_total,r.currency)}],'No accepted sales yet.');renderSellingShipping(shipping);$('order-list').innerHTML=rows(orders,[{key:'order_reference',label:'Order'},{key:'status',label:'Status'},{key:'total',label:'Total',render:r=>money(r.total,r.currency)},{key:'payment_status',label:'Payment',render:r=>r.status==='pending_payment'?`Awaiting payment`:esc(r.payment_status)},{key:'placed_at',label:'Placed',render:r=>r.placed_at?new Date(r.placed_at).toLocaleDateString('en-GB'):'—'},{key:'order_id',label:'Action',render:r=>r.status==='pending_payment'?`<button type="button" data-pay-order-id="${esc(r.order_id)}">Pay now</button>`:'—'}],'No orders yet.');$('shop-list').innerHTML=rows(shop,[{key:'listing_reference',label:'Listing'},{key:'title',label:'Item'},{key:'asking_price',label:'Price',render:r=>money(r.asking_price,r.currency)},{key:'listing_id',label:'Action',render:r=>`<button type="button" class="buy-listing" data-listing-id="${esc(r.listing_id)}">Buy</button>`}],'No published items currently available.');$('valuation-summary').textContent=values?.length?`${values.length} valuation record(s) available.`:'No approved valuation is currently available.';if(profile){
  $('profile-first-name').value=profile.first_name||'';
  $('profile-last-name').value=profile.last_name||'';
  $('profile-email').value=profile.email||'';
  $('profile-phone').value=profile.phone||'';
  $('profile-list').textContent='';
}else{
  $('profile-list').textContent='Profile not available.';
}
$('address-list').innerHTML=rows(addresses,[{key:'address_type',label:'Type'},{key:'line1',label:'Address'},{key:'city',label:'City'},{key:'postcode',label:'Postcode'}],'No saved addresses.');renderCustomerFulfilments(fulfilments);renderCustomerReturns(returns,items,orders);document.querySelectorAll('.buy-listing').forEach(b=>b.onclick=null);document.querySelectorAll('[data-pay-order-id]').forEach(b=>b.onclick=()=>payOrder(b.dataset.payOrderId));await loadCategories();restoreSellingJourney()}
async function submitBuyingRequest(){if(localStorage.getItem('tradeflow_subscriber_session'))return setMessage('Subscriber accounts cannot submit customer buying requests. Sign out of the subscriber account and use a separate customer account to test this journey.','error');const notes=$('request-notes').value.trim(),title=$('request-title').value.trim(),cat=$('request-category').value;if(!cat)return setMessage('Select a buying category.','error');if(!title)return setMessage('Enter what you want to sell.','error');try{await api('/rest/v1/rpc/customer_submit_buying_request',{method:'POST',body:JSON.stringify({p_tenant_id:tenantId,p_notes:notes||null,p_items:[{category_id:cat,title,quantity:1}]})});$('request-title').value='';$('request-notes').value='';await loadPortalData();location.hash='#selling';setMessage('Your item has been submitted for valuation. We are now reviewing it. If an automatic valuation is not available, it will move to manual valuation.','success')}catch(e){setMessage(e.message||String(e),'error')}}
function splitFullName(value){
  const parts=String(value||'').trim().split(/\\s+/).filter(Boolean);
  if(!parts.length)return {first:'',last:''};
  return {first:parts.shift(),last:parts.join(' ')};
}
async function ensureCustomerRegistration(){
  const existing=await rpc('customer_get_profile');
  if(Array.isArray(existing)&&existing.length){
    const p=existing[0];
    if($('profile-first-name'))$('profile-first-name').value=p.first_name||'';
    if($('profile-last-name'))$('profile-last-name').value=p.last_name||'';
    if($('profile-email'))$('profile-email').value=p.email||'';
    if($('profile-phone'))$('profile-phone').value=p.phone||'';
    return;
  }
  const user=await api('/auth/v1/user');
  const meta=user?.user_metadata||{};
  const name=splitFullName(meta.full_name||meta.name||'');
  const first=$('auth-first-name')?.value.trim()||meta.first_name?.trim()||name.first;
  const last=$('auth-last-name')?.value.trim()||meta.last_name?.trim()||name.last;
  if(!first)throw Error('Enter your first name to complete your customer account.');
  await api('/rest/v1/rpc/customer_register_for_tenant',{method:'POST',body:JSON.stringify({p_tenant_id:tenantId,p_first_name:first,p_last_name:last||null,p_phone:null})});
}
async function initialisePortal(){if(!tenantId)return setMessage('This customer portal needs a valid subscriber tenant.','error'),showAuth(true);if(!session?.access_token)return showAuth(true);showAuth(false);try{await ensureCustomerRegistration();await loadPortalData();const p=new URLSearchParams(location.search);if(p.get('payment')==='success')setMessage('Payment completed. Your order will move into fulfilment once the provider confirmation is received.','success');else if(p.get('payment')==='cancelled')setMessage('Payment was cancelled. Your order remains awaiting payment.','error')}catch(e){setMessage(e.message||String(e),'error')}}
function signOut(){saveSession(null);showAuth(true);setMessage('Signed out.','success')}
async function handleAuthSuccess(data){try{saveSession(data);await ensureCustomerRegistration();await initialisePortal()}catch(err){saveSession(null);setMessage(err.message||String(err),'error')}}
document.addEventListener('click',e=>{const b=e.target.closest?.('.buy-listing');if(!b)return;e.preventDefault();e.stopPropagation();checkout(b.dataset.listingId)});window.tradeflowHandleCustomerAuthSuccess=handleAuthSuccess;
document.addEventListener('click',e=>{
 const accept=e.target.closest?.('.offer-accept');
 const refuse=e.target.closest?.('.offer-refuse');
 if(!accept&&!refuse)return;
 e.preventDefault();
 const id=(accept||refuse)?.dataset?.offerId;
 if(!id)return setMessage('This offer could not be identified. Refresh the page and try again.','error');
 respond(id,accept?'accept':'refuse');
});
window.addEventListener('tradeflow-auth-success',e=>handleAuthSuccess(e.detail));
$('auth-sign-in')?.addEventListener('click',signIn);
$('auth-sign-up')?.addEventListener('click',signUp);
$('submit-request')?.addEventListener('click',submitBuyingRequest);
$('request-return')?.addEventListener('click',requestReturn);
$('save-profile')?.addEventListener('click',async()=>{
  const first=$('profile-first-name')?.value.trim()||'';
  const last=$('profile-last-name')?.value.trim()||'';
  const phone=$('profile-phone')?.value.trim()||'';
  if(!first)return setMessage('First name is required.','error');
  const b=$('save-profile');setBusy(b,true,'Saving…');
  try{
    await api('/rest/v1/rpc/customer_update_profile',{method:'POST',body:JSON.stringify({p_tenant_id:tenantId,p_first_name:first,p_last_name:last||null,p_phone:phone||null})});
    setMessage('Your details have been saved.','success');
    await loadPortalData();
  }catch(e){setMessage(e.message||String(e),'error')}
  finally{setBusy(b,false)}
});
$('sign-out')?.addEventListener('click',signOut);
(async()=>{await loadTenantBranding();if(localStorage.getItem('tradeflow_subscriber_session')){const tid=localStorage.getItem('tradeflow_subscriber_tenant_id');location.replace(tid?'subscriber-dashboard.html?tenant_id='+encodeURIComponent(tid):'subscriber-dashboard.html');return}if(!key)return setMessage('TradeFlow customer portal is not configured.','error');const pending=window.tradeflowPendingAuthSession;if(pending){delete window.tradeflowPendingAuthSession;await handleAuthSuccess(pending);return}await restoreSession();await initialisePortal()})();