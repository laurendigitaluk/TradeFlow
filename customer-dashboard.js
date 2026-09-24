const SUPABASE_URL='https://twfbmjwwqzxdxvclxbun.supabase.co';
const KEY='sb_publishable_AvcMgtUKV0O5k8H6k94mZQ_qH4pEIS9';
let sellingStatusRefreshTimer=null;
const SESSION_STORAGE='tradeflow_customer_session';
let key=KEY,session=null,tenantId=new URLSearchParams(location.search).get('tenant_id'),profile=null;
const $=id=>document.getElementById(id);
function setMessage(t,type=''){const e=$('customer-message');if(e){e.textContent=t||'';e.className=type}}
function setBusy(b,v,l){if(!b)return;b.disabled=v;if(v&&l){b.dataset.label=b.textContent;b.textContent=l}if(!v&&b.dataset.label)b.textContent=b.dataset.label}
async function api(path,o={}){if(!key)throw Error('TradeFlow Supabase is not connected.');const h=new Headers(o.headers||{});h.set('apikey',key);h.set('Content-Type','application/json');if(session?.access_token)h.set('Authorization',`Bearer ${session.access_token}`);const r=await fetch(`${SUPABASE_URL}${path}`,{...o,headers:h}),t=await r.text();let b=null;try{b=t?JSON.parse(t):null}catch{b=t}if(!r.ok)throw Error(b?.msg||b?.message||b?.error_description||b?.error||t||`HTTP ${r.status}`);return b}
async function storageSignedUrl(path){const r=await fetch(`${SUPABASE_URL}/storage/v1/object/sign/tradeflow-media/${path}`,{method:'POST',headers:{'apikey':key,'Authorization':`Bearer ${session?.access_token||''}`,'Content-Type':'application/json'},body:JSON.stringify({expiresIn:86400})});const t=await r.text();let b=null;try{b=t?JSON.parse(t):null}catch{b=t}if(!r.ok)throw Error(b?.message||b?.error||t||`Could not open the shipping label (${r.status})`);return b?.signedURL?.startsWith('http')?b.signedURL:`${SUPABASE_URL}/storage/v1${b.signedURL}`;}
function saveSession(v){session=v||null;if(session?.access_token)localStorage.setItem(SESSION_STORAGE,JSON.stringify(session));else localStorage.removeItem(SESSION_STORAGE)}
async function restoreSession(){return Boolean(session?.access_token)}
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
async function loadCategories(){const data=await rpc('customer_get_buying_categories'),s=$('request-category');s.innerHTML='<option value="">Select a category…</option>';for(const c of Array.isArray(data)?data:[]){const o=document.createElement('option');o.value=c.category_id;o.textContent=c.name;s.appendChild(o)}if(!data?.length)s.innerHTML='<option value="">No buying categories available</option>';s.onchange=loadRequestFields}
function offerAction(r){if(r.status!=='published')return '<span class="status-pill '+(r.status==='accepted'?'status-approved':'status-neutral')+'">'+esc(r.status==='accepted'?'Accepted by you':r.status==='refused'?'Refused':r.status)+'</span>';return`<div class="offer-action-card"><div class="offer-action-title">Action required: review this offer</div><p class="small">You can accept or refuse this offer below.</p><textarea class="offer-response-notes" data-offer-id="${esc(r.offer_id)}" rows="2" placeholder="Optional response notes"></textarea><div class="actions"><button type="button" class="offer-accept" data-offer-id="${esc(r.offer_id)}">Accept offer</button><button type="button" class="offer-refuse" data-offer-id="${esc(r.offer_id)}">Refuse offer</button></div></div>`}
async function respond(id,a){const n=document.querySelector(`.offer-response-notes[data-offer-id="${CSS.escape(id)}"]`)?.value.trim()||null;try{await api(`/rest/v1/rpc/${a==='accept'?'customer_accept_offer':'customer_refuse_offer'}`,{method:'POST',body:JSON.stringify({p_tenant_id:tenantId,p_offer_id:id,p_response_notes:n})});setMessage(a==='accept'?'Offer accepted. Shipping and receipt workflow can now begin.':'Offer refused.','success');await loadPortalData()}catch(e){setMessage(e.message||String(e),'error')}}
async function checkout(id){const b=document.querySelector(`.buy-listing[data-listing-id="${CSS.escape(id)}"]`);if(b?.disabled)return;try{setBusy(b,true,'Processing…');setMessage('Creating your order…','message');const result=await api('/rest/v1/rpc/customer_create_retail_order',{method:'POST',body:JSON.stringify({p_tenant_id:tenantId,p_listing_id:id})});const orderId=Array.isArray(result)?result[0]?.order_id||result[0]?.id||result[0]?.retail_order_id:result?.order_id||result?.id||result?.retail_order_id;if(!orderId)throw Error('The order was not returned by TradeFlow.');setMessage('Order created and awaiting payment. The listing has been reserved.','success');await loadPortalData();await payOrder(orderId)}catch(e){console.error('TradeFlow customer checkout failed:',e);setMessage(e.message||String(e),'error');setBusy(b,false)}}
async function payOrder(id){const b=document.querySelector(`[data-pay-order-id="${CSS.escape(id)}"]`);try{setBusy(b,true,'Opening secure payment…');const result=await api('/functions/v1/create-stripe-checkout-session',{method:'POST',body:JSON.stringify({tenant_id:tenantId,order_id:id})});if(!result?.checkout_url)throw Error(result?.error||'Payment checkout URL was not returned.');location.href=result.checkout_url}catch(e){setMessage(e.message||String(e),'error');setBusy(b,false)}}
async function createPayment(id){return payOrder(id)}
async function requestReturn(){const item=$('return-order-item').value;if(!item)return setMessage('Select an eligible order item.','error');try{await api('/rest/v1/rpc/customer_request_return',{method:'POST',body:JSON.stringify({p_tenant_id:tenantId,p_order_item_id:item,p_reason_code:$('return-reason-code').value,p_reason:$('return-reason').value.trim()||null,p_customer_notes:$('return-reason').value.trim()||null})});$('return-order-item').value='';$('return-reason').value='';setMessage('Return request submitted.','success');await loadPortalData()}catch(e){setMessage(e.message||String(e),'error')}}
async function renderSellingStatus(data,offers,acquisitions,shipping,bankDetails,completedSales=[]){
 const box=$('selling-status-panel');if(!box)return;
 if(!Array.isArray(data)||!data.length){box.hidden=true;return}
 const completedIds=new Set((Array.isArray(completedSales)?completedSales:[]).map(a=>a.buying_item_id).filter(Boolean));
 const completedRefs=new Set((Array.isArray(completedSales)?completedSales:[]).map(a=>a.request_reference).filter(Boolean));
 const activeData=data.filter(r=>String(r.request_status||r.status||'').toLowerCase()!=='closed'&&String(r.purchase_stage||r.stage||'').toLowerCase()!=='purchased'&&!completedIds.has(r.buying_item_id)&&!completedRefs.has(r.request_reference));
 if(!activeData.length){box.hidden=true;return}
 const base=activeData[0];
 const ship=Array.isArray(shipping)?shipping.find(x=>x.buying_item_id===base.buying_item_id):null;
 const stage=base.stage||'submitted';
 const stageCopy={
  awaiting_item:['Shipping instructions sent — ready to send','Your item is still in the pre-purchase selling process. Follow the shipping instructions and confirm when you have handed the item to the courier.'],
  shipping:['Item sent — on its way to the business','You have confirmed that the item has been sent. The business is now awaiting receipt.'],
  received:['Item received — inspection next','The business has received your item. It is now waiting for inspection.'],
  inspection:['Item under inspection','Your item has been received and is now being inspected.'],
  testing:['Testing required','The business has routed your item for testing. It has not been purchased yet.'],
  repair:['Repair required','The business has routed your item for repair. It has not been purchased yet.'],
  return_pending:['Return to customer','The item was refused during inspection and will be returned to you.'],
  final_offer_required:['Inspection accepted — final offer required','The inspection was accepted. The business will now prepare a final offer for you.'],
  final_offer_sent:['Final offer received — awaiting your response','A final offer has been sent. Review it and choose Accept offer or Refuse offer.'],
  final_offer_accepted:['Final offer accepted — payment pending','You accepted the final offer. The business must now make the payment.'],
  final_offer_refused:['Final offer refused — return item','The final offer was refused. The item remains outside the purchase and inventory process.'],
  purchased:['Payment sent','The business has sent your payment. Please check your bank account for the payment.']
 };
 const fallback=stage==='offer_ready'?['Manual offer received — awaiting your response','Your offer is ready to review.']:stage==='manual_valuation'?['Manual valuation required','Your item requires a manual valuation.']:['Selling request in progress','Your selling request is being processed.'];
 const active={...base,stage,message:(stageCopy[stage]||fallback)[1]};
 const title=(stageCopy[stage]||fallback)[0];
 const cls=['received','inspection','final_offer_required','final_offer_sent','final_offer_accepted','purchased'].includes(stage)?'accepted':stage==='final_offer_refused'||stage==='return_pending'?'manual':stage==='offer_ready'?'ready':'progress';
 let action='';
 const liveOffer=Array.isArray(offers)?offers.find(o=>o.status==='published'&&o.buying_item_id===base.buying_item_id):null;
 if(liveOffer){action='<div class="customer-offer-action"><div class="offer-action-kicker">ACTION REQUIRED</div><strong>Manual offer received: '+money(liveOffer.amount,liveOffer.currency)+'</strong><p>This offer is waiting for your response. Choose Accept offer or Refuse offer.</p><textarea class="offer-response-notes" data-offer-id="'+esc(liveOffer.offer_id||liveOffer.id)+'" rows="2" placeholder="Optional response notes"></textarea><div class="actions"><button type="button" class="offer-accept status-offer-accept" data-offer-id="'+esc(liveOffer.offer_id||liveOffer.id)+'">Accept offer</button><button type="button" class="offer-refuse" data-offer-id="'+esc(liveOffer.offer_id||liveOffer.id)+'">Refuse offer</button></div></div>'}
 let handoff='';
 if(stage==='final_offer_accepted'){
  const hasBank=Boolean(bankDetails?.has_details);
  handoff=`<div class="customer-bank-details" style="margin-top:14px;padding:16px;border:1px solid #d8dee5;border-radius:8px;background:#fff"><h4 style="margin:0 0 8px">Bank details for payment</h4><p class="small">Your final offer has been accepted. Enter the UK bank account details the business should use to pay you. Payment cannot be completed until these details have been provided.</p><div class="form-grid" style="margin-top:12px"><label>Account holder name<input id="bank-account-holder" autocomplete="name" value="${esc(bankDetails?.account_holder_name||'')}"></label><label>Bank name (optional)<input id="bank-name" autocomplete="organization" value="${esc(bankDetails?.bank_name||'')}"></label><label>Sort code<input id="bank-sort-code" inputmode="numeric" autocomplete="off" maxlength="8" placeholder="12-34-56" value="${esc(bankDetails?.sort_code||'')}"></label><label>Account number<input id="bank-account-number" inputmode="numeric" autocomplete="off" maxlength="8" placeholder="12345678" value="${esc(bankDetails?.account_number||'')}"></label></div><div class="actions" style="margin-top:12px"><button type="button" id="save-bank-details">${hasBank?'Update bank details':'Save bank details'}</button></div><p id="bank-details-message" class="small" style="margin-top:8px">${hasBank?'Bank details are on record. The business can now complete the payment step.':'Bank details have not yet been provided.'}</p></div>`;
 }
 if(['awaiting_item','shipping'].includes(stage)){
  let labelUrl=ship?.shipping_label_url||'';if(!labelUrl&&ship?.shipping_label_storage_path){try{labelUrl=await storageSignedUrl(ship.shipping_label_storage_path)}catch{}}
  let qrUrl=ship?.shipping_qr_url||'';if(!qrUrl&&ship?.shipping_qr_storage_path){try{qrUrl=await storageSignedUrl(ship.shipping_qr_storage_path)}catch{}}
  const labelActions=labelUrl?'<div class="actions" style="margin-top:8px"><button type="button" class="shipping-asset-download" data-url="'+esc(labelUrl)+'" data-name="shipping-label">Download your label</button><button type="button" class="shipping-asset-print" data-url="'+esc(labelUrl)+'" data-name="Shipping label">Print your label</button></div>':'<p class="small">No physical shipping label has been uploaded.</p>';
  const qrActions=qrUrl?'<div class="actions" style="margin-top:8px"><button type="button" class="shipping-asset-download" data-url="'+esc(qrUrl)+'" data-name="shipping-qr">Download your QR code</button><button type="button" class="shipping-asset-print" data-url="'+esc(qrUrl)+'" data-name="Shipping QR code">Print your QR code</button></div>':'<p class="small">No physical QR code has been uploaded.</p>';
  handoff='<div class="shipping-handoff-summary" style="margin-top:12px;padding:14px;border:1px solid #b9d8c0;border-radius:8px;background:#f4faf5"><h4 style="margin:0 0 8px">Your shipping information</h4><p>Use the label, QR code and instructions below to send the item.</p><div style="margin-top:12px"><strong>Shipping service</strong><br>'+esc([ship?.shipping_carrier,ship?.shipping_service].filter(Boolean).join(' · ')||'Provided by business')+'</div>'+(ship?.shipping_tracking_number?'<div style="margin-top:10px"><strong>Tracking number</strong><br>'+esc(ship.shipping_tracking_number)+(ship.shipping_tracking_url?'<br><a href="'+esc(ship.shipping_tracking_url)+'" target="_blank" rel="noopener">Track shipment</a>':'')+'</div>':'')+(ship?.shipping_instructions?'<div style="margin-top:10px"><strong>Instructions</strong><br>'+esc(ship.shipping_instructions).replace(/\n/g,'<br>')+'</div>':'')+'<div style="margin-top:14px"><strong>Shipping label</strong>'+labelActions+'</div><div style="margin-top:14px"><strong>QR code</strong>'+qrActions+'</div>'+ (stage==='awaiting_item'?'<div style="margin-top:16px"><button type="button" class="mark-item-sent" data-buying-item-id="'+esc(base.buying_item_id)+'" style="width:100%;font-size:16px;padding:14px;font-weight:700">Item sent</button><p class="small" style="margin-top:6px">Only click this after the item has actually been handed to the courier or dropped off.</p></div>':'<div style="margin-top:16px;padding:12px;border-radius:6px;background:#eaf6ed"><strong>Item on its way</strong><br>The business has been notified that you have sent the item.</div>')+'</div>';
 }
 box.hidden=false;box.className='selling-status '+cls;
 box.innerHTML='<div class="status-kicker">SELLING REQUEST</div><h3>'+esc(title)+'</h3><p><strong>'+esc(active.item_title||'Your item')+'</strong></p><div class="status-meta"><span>Request <strong>'+esc(active.request_reference)+'</strong></span><span>Item <strong>'+esc(active.item_reference||'—')+'</strong></span></div><p>'+esc(active.message)+'</p><div class="status-meta"><span>Stage <strong>'+esc(String(stage).replace(/_/g,' '))+'</strong></span></div>'+action+handoff+'</div>';
 if(stage==='final_offer_accepted'){
  const saveBank=$('save-bank-details');
  if(saveBank)saveBank.onclick=async()=>{
   setBusy(saveBank,true,'Saving…');
   try{
    const holder=$('bank-account-holder')?.value.trim()||'';
    const sort=$('bank-sort-code')?.value.trim()||'';
    const account=$('bank-account-number')?.value.trim()||'';
    const bank=$('bank-name')?.value.trim()||null;
    const result=await api('/rest/v1/rpc/customer_save_bank_details',{method:'POST',body:JSON.stringify({p_tenant_id:tenantId,p_account_holder_name:holder,p_sort_code:sort,p_account_number:account,p_bank_name:bank})});
    if(!result?.saved)throw Error('Bank details were not saved.');
    setMessage('Bank details saved. The business can now make the payment.','success');
    await loadPortalData();
   }catch(e){setMessage(e.message||String(e),'error');setBusy(saveBank,false)}
  };
 }
}
function renderSellingValuations(data){
 const box=$('valuation-list');if(!box)return;
 if(!Array.isArray(data)||!data.length){box.innerHTML='<div class="empty">No valuations have been issued yet. Your valuation will appear here when the business has completed it.</div>';return}
 box.innerHTML=data.map(v=>'<article class="selling-handover valuation-card '+(String(v.status).toLowerCase()==='approved'?'approved':'')+'"><div><strong>'+esc(v.request_reference||'Selling request')+'</strong> <span class="status-pill '+(String(v.status).toLowerCase()==='approved'?'status-approved':'status-neutral')+'">'+esc(v.status||'valuation')+'</span></div><p><strong>Valuation:</strong> '+money(v.cash_price??v.amount??v.trade_in_price,v.currency)+'</p><p class="small">'+esc(v.method||'Valuation')+' · Calculated '+(v.calculated_at?new Date(v.calculated_at).toLocaleDateString('en-GB'):'—')+(v.approved_at?' · Approved '+new Date(v.approved_at).toLocaleDateString('en-GB'):'')+'</p></article>').join('');
}
async function markBuyingItemPosted(id){
 try{await api('/rest/v1/rpc/customer_mark_buying_item_posted',{method:'POST',body:JSON.stringify({p_tenant_id:tenantId,p_buying_item_id:id})});setMessage('Your item has been marked as posted.','success');await loadPortalData()}catch(e){setMessage(e.message||String(e),'error')}
}

async function renderSellingShipping(data,addresses=[]){
 const box=$('selling-shipping'); if(box){box.hidden=true;box.innerHTML='';}
}
function renderCustomerFulfilments(data){$('fulfilment-list').innerHTML=rows(data,[{key:'fulfilment_reference',label:'Reference'},{key:'status',label:'Status'},{key:'carrier',label:'Carrier'},{key:'tracking_number',label:'Tracking',render:r=>r.tracking_url?`<a href="${esc(r.tracking_url)}" target="_blank" rel="noopener">${esc(r.tracking_number||'Track')}</a>`:esc(r.tracking_number||'—')},{key:'delivered_at',label:'Delivered',render:r=>r.delivered_at?new Date(r.delivered_at).toLocaleDateString('en-GB'):'—'}],'No fulfilments yet.')}
async function cancelOrder(id){
 const order=(window.tradeflowCustomerOrders||[]).find(o=>o.order_id===id);
 if(!order)return;
 if(!['initiated','pending_payment'].includes(order.status))return setMessage('This order can no longer be cancelled.','error');
 if(!window.confirm('Cancel '+(order.order_reference||'this order')+'?'))return;
 const b=document.querySelector('[data-cancel-order-id="'+CSS.escape(id)+'"]');
 setBusy(b,true,'Cancelling…');
 try{
  await api('/rest/v1/rpc/customer_cancel_retail_order',{method:'POST',body:JSON.stringify({p_tenant_id:tenantId,p_order_id:id,p_reason:'Cancelled by customer'})});
  setMessage('Order cancelled.','success');
  await loadPortalData();
 }catch(e){
  setMessage(e.message||String(e),'error');
  setBusy(b,false);
 }
}
function renderCustomerReturns(data,items,orders){$('return-list').innerHTML=rows(data,[{key:'return_reference',label:'Reference'},{key:'status',label:'Status'},{key:'reason',label:'Reason'},{key:'refund_amount',label:'Refund',render:r=>r.refund_amount==null?'—':money(r.refund_amount,r.currency)},{key:'requested_at',label:'Requested',render:r=>r.requested_at?new Date(r.requested_at).toLocaleDateString('en-GB'):'—'}],'No returns yet.');const eligible=(Array.isArray(items)?items:[]).filter(i=>['paid','fulfilment','completed'].includes(orders.find(o=>o.id===i.order_id)?.status));const s=$('return-order-item');s.innerHTML='<option value="">Select an eligible order item…</option>'+eligible.map(i=>`<option value="${esc(i.order_item_id)}">${esc(orders.find(o=>o.id===i.order_id)?.order_reference||i.order_id)} — ${esc(i.title)} × ${esc(i.quantity)}</option>`).join('')}
async function refreshCustomerSellingStatus(){
 try{
   const [sellingStatus,offers,acq,shipping,bankDetails]=await Promise.all([
     rpc('customer_get_selling_status'),
     rpc('customer_get_offers'),
     rpc('customer_get_acquisitions'),
     rpc('customer_get_pre_acquisition_shipping'),
     rpc('customer_get_bank_details')
   ]);
   await renderSellingStatus(sellingStatus,activeOffers,acq,shipping,bankDetails,completedSales);
 }catch(e){console.warn('TradeFlow customer selling status refresh failed:',e)}
}
function startCustomerSellingStatusRefresh(){
 if(sellingStatusRefreshTimer)clearInterval(sellingStatusRefreshTimer);
 sellingStatusRefreshTimer=setInterval(()=>{if(!document.hidden)refreshCustomerSellingStatus()},10000);
}
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
async function loadPortalData(){const [buying,values,offers,acq,shipping,orders,items,fulfilments,returns,shop,addresses,sellingStatus,bankDetails,completedSales]=await Promise.all([rpc('customer_get_buying_requests'),rpc('customer_get_trading_values'),rpc('customer_get_offers'),rpc('customer_get_acquisitions'),rpc('customer_get_pre_acquisition_shipping'),rpc('customer_get_orders'),rpc('customer_get_order_items'),rpc('customer_get_fulfilments'),rpc('customer_get_returns'),rpc('customer_get_store_listings'),rpc('customer_get_addresses'),rpc('customer_get_selling_status'),rpc('customer_get_bank_details'),rpc('customer_get_completed_sales')]);profile=(await rpc('customer_get_profile'))?.[0]||null;$('customer-name').textContent=profile?`${profile.first_name||''} ${profile.last_name||''}`.trim()||'Customer':'Customer';const completedAcquisitions=Array.isArray(completedSales)?completedSales:[];
const completedRequestRefs=new Set(completedAcquisitions.map(a=>a.request_reference).filter(Boolean));
const completedItemIds=new Set(completedAcquisitions.map(a=>a.buying_item_id).filter(Boolean));
const completedBuying=(Array.isArray(buying)?buying:[]).filter(r=>String(r.status||'').toLowerCase()==='closed'||String(r.purchase_stage||'').toLowerCase()==='purchased'||String(r.acquisition_status||'').toLowerCase()==='paid'||completedRequestRefs.has(r.request_reference)||completedItemIds.has(r.buying_item_id));
const activeBuying=(Array.isArray(buying)?buying:[]).filter(r=>!completedBuying.includes(r));
const activeAcquisitions=(Array.isArray(acq)?acq:[]).filter(a=>!completedAcquisitions.includes(a));
$('buying-count').textContent=activeBuying.length;$('order-count').textContent=orders?.length||0;$('return-count').textContent=returns?.length||0;$('buying-list').innerHTML=rows(activeBuying,[{key:'request_reference',label:'Reference'},{key:'status',label:'Status'},{key:'source',label:'Source'}],'No active selling requests.');const activeOffers=(Array.isArray(offers)?offers:[]).filter(o=>!completedItemIds.has(o.buying_item_id));await renderSellingStatus(sellingStatus,activeOffers,acq,shipping,bankDetails,completedSales);renderSellingValuations(await rpc('customer_get_selling_valuations'));
$('offer-list').innerHTML=activeOffers.length?'<div class="offer-instruction">A published offer requires your response. Review the amount and choose <strong>Accept offer</strong> or <strong>Refuse offer</strong>.</div>'+rows(activeOffers,[{key:'offer_reference',label:'Offer'},{key:'offer_type',label:'Type'},{key:'status',label:'Response',render:offerAction},{key:'amount',label:'Amount',render:r=>money(r.amount,r.currency)}],'No active offers.'):'<div class="empty">No active offer requires your response.</div>';$('acquisition-list').innerHTML=rows(activeAcquisitions,[{key:'acquisition_reference',label:'Reference'},{key:'status',label:'Status'},{key:'agreed_total',label:'Agreed',render:r=>money(r.agreed_total,r.currency)}],'No accepted sales currently in progress.');
$('completed-selling-list').innerHTML=rows(completedAcquisitions,[{key:'request_reference',label:'Request'},{key:'item_title',label:'Item'},{key:'status',label:'Status'},{key:'agreed_total',label:'Paid',render:r=>money(r.agreed_total,r.currency)},{key:'paid_at',label:'Completed',render:r=>r.paid_at?new Date(r.paid_at).toLocaleDateString('en-GB'):'—'}],'No completed sales to this business yet.');await renderSellingShipping(shipping,addresses);$('order-list').innerHTML=rows(orders,[{key:'order_reference',label:'Order'},{key:'status',label:'Status'},{key:'total',label:'Total',render:r=>money(r.total,r.currency)},{key:'payment_status',label:'Payment',render:r=>r.status==='pending_payment'?`Awaiting payment`:esc(r.payment_status)},{key:'placed_at',label:'Placed',render:r=>r.placed_at?new Date(r.placed_at).toLocaleDateString('en-GB'):'—'},{key:'order_id',label:'Action',render:r=>r.status==='pending_payment'?`<div class="actions"><button type="button" data-pay-order-id="${esc(r.order_id)}">Pay now</button><button type="button" data-cancel-order-id="${esc(r.order_id)}">Cancel order</button></div>`:r.status==='initiated'?`<button type="button" data-cancel-order-id="${esc(r.order_id)}">Cancel order</button>`:'—'}],'No orders yet.');$('shop-list').innerHTML=rows(shop,[{key:'listing_reference',label:'Listing'},{key:'title',label:'Item'},{key:'asking_price',label:'Price',render:r=>money(r.asking_price,r.currency)},{key:'listing_id',label:'Action',render:r=>`<button type="button" class="buy-listing" data-listing-id="${esc(r.listing_id)}">Buy</button>`}],'No published items currently available.');$('valuation-summary').textContent=values?.length?`${values.length} valuation record(s) available.`:'No approved valuation is currently available.';if(profile){
  $('profile-first-name').value=profile.first_name||'';
  $('profile-last-name').value=profile.last_name||'';
  $('profile-email').value=profile.email||'';
  $('profile-phone').value=profile.phone||'';
  $('profile-list').textContent='';
}else{
  $('profile-list').textContent='Profile not available.';
}
$('address-list').innerHTML=rows(addresses,[{key:'address_type',label:'Type'},{key:'line1',label:'Address'},{key:'city',label:'City'},{key:'postcode',label:'Postcode'}],'No saved addresses.');renderCustomerFulfilments(fulfilments);renderCustomerReturns(returns,items,orders);document.querySelectorAll('.buy-listing').forEach(b=>b.onclick=null);document.querySelectorAll('[data-pay-order-id]').forEach(b=>b.onclick=()=>payOrder(b.dataset.payOrderId));document.querySelectorAll('[data-cancel-order-id]').forEach(b=>b.onclick=()=>cancelOrder(b.dataset.cancelOrderId));await loadCategories();restoreSellingJourney()}
async function loadRequestFields(){const cat=$('request-category')?.value,box=$('request-fields');if(!box)return;if(!cat){box.innerHTML='';return}box.innerHTML='<div class="small">Loading customer information fields…</div>';try{const fields=await api('/rest/v1/rpc/customer_get_buying_category_fields?p_tenant_id='+encodeURIComponent(tenantId)+'&p_category_id='+encodeURIComponent(cat),{method:'GET'});if(!Array.isArray(fields)||!fields.length){box.innerHTML='<div class="small">No additional customer information fields are configured for this category.</div>';return}box.innerHTML=fields.map(f=>{const opts=Array.isArray(f.options)?f.options:[];let control='';if(['select','multiselect'].includes(f.field_type)){control='<select '+(f.field_type==='multiselect'?'multiple':'')+' data-field-id="'+esc(f.field_id)+'" data-field-type="'+esc(f.field_type)+'">'+(f.field_type==='select'?'<option value="">Select…</option>':'')+opts.map(o=>'<option value="'+esc(o.value)+'">'+esc(o.label||o.value)+'</option>').join('')+'</select>'}else if(f.field_type==='textarea'){control='<textarea rows="3" data-field-id="'+esc(f.field_id)+'" data-field-type="textarea"></textarea>'}else if(f.field_type==='boolean'){control='<input type="checkbox" data-field-id="'+esc(f.field_id)+'" data-field-type="boolean">'}else{const type=['number','currency','date','email','phone','url'].includes(f.field_type)?(f.field_type==='currency'?'number':f.field_type):'text';control='<input type="'+type+'" data-field-id="'+esc(f.field_id)+'" data-field-type="'+esc(f.field_type)+'">'}return '<label>'+esc(f.label)+(f.required_for_buying?' *':'')+control+'</label>'}).join('')}catch(e){box.innerHTML='<div class="small error">'+esc(e.message||String(e))+'</div>'}}
function collectRequestFields(){return Array.from(document.querySelectorAll('#request-fields [data-field-id]')).map(el=>{let value;if(el.type==='checkbox')value=el.checked;else if(el.multiple)value=Array.from(el.selectedOptions).map(o=>o.value);else value=el.value.trim();return {field_id:el.dataset.fieldId,value}}).filter(x=>x.value!==''&&!(Array.isArray(x.value)&&!x.value.length))}
async function submitBuyingRequest(){if(localStorage.getItem('tradeflow_subscriber_session'))return setMessage('Subscriber accounts cannot submit customer buying requests. Sign out of the business account and use a separate customer account to test this journey.','error');const notes=$('request-notes').value.trim(),title=$('request-title').value.trim(),cat=$('request-category').value;if(!cat)return setMessage('Select a buying category.','error');if(!title)return setMessage('Enter what you want to sell.','error');try{await api('/rest/v1/rpc/customer_submit_buying_request',{method:'POST',body:JSON.stringify({p_tenant_id:tenantId,p_notes:notes||null,p_items:[{category_id:cat,title,description:notes||null,quantity:1,fields:collectRequestFields()}]})});$('request-title').value='';$('request-notes').value='';await loadPortalData();location.hash='#selling';setMessage('Your item has been submitted for valuation. We are now reviewing it. If an automatic valuation is not available, it will move to manual valuation.','success')}catch(e){setMessage(e.message||String(e),'error')}}
function splitFullName(value){
  const parts=String(value||'').trim().split(/\\s+/).filter(Boolean);
  if(!parts.length)return {first:'',last:''};
  return {first:parts.shift(),last:parts.join(' ')};
}
async function submitStoredSellingJourney(){
 const raw=sessionStorage.getItem('tradeflow_selling_journey');
 if(!raw)return false;
 let payload=null;try{payload=JSON.parse(raw)}catch{sessionStorage.removeItem('tradeflow_selling_journey');return false}
 if(!payload?.category_id||payload.tenant_id!==tenantId)return false;
 const details=[
  payload.product_type&&('Product type: '+payload.product_type),
  payload.manufacturer&&('Manufacturer: '+payload.manufacturer),
  payload.model&&('Model: '+payload.model),
  payload.package_name&&('Package / version: '+payload.package_name),
  payload.condition&&('Condition: '+payload.condition),
  payload.missing_items&&('Missing items: '+payload.missing_items),
  payload.legal_right&&('Legal right to sell: '+payload.legal_right),
  payload.serial_number&&('Serial number: '+payload.serial_number),
  payload.notes&&('Customer notes: '+payload.notes)
 ].filter(Boolean).join(' | ');
 await api('/rest/v1/rpc/customer_submit_buying_request',{method:'POST',body:JSON.stringify({p_tenant_id:tenantId,p_notes:payload.notes||null,p_items:[{category_id:payload.category_id,title:[payload.manufacturer,payload.model,payload.package_name].filter(Boolean).join(' ')||'Selling request',description:details||payload.notes||null,quantity:1,fields:[]}]})});
 sessionStorage.removeItem('tradeflow_selling_journey');
 return true;
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
async function initialisePortal(){if(!tenantId)return setMessage('This customer portal needs a valid business tenant.','error'),showAuth(true);if(!session?.access_token)return showAuth(true);showAuth(false);try{await ensureCustomerRegistration();const submitted=await submitStoredSellingJourney();await loadPortalData();startCustomerSellingStatusRefresh();const p=new URLSearchParams(location.search);if(p.get('submitted')==='1'||submitted){location.hash='#selling';setMessage('Your valuation request has been submitted. You can now view it here and follow its progress.','success')}else if(p.get('payment')==='success')setMessage('Payment completed. Your order will move into fulfilment once the provider confirmation is received.','success');else if(p.get('payment')==='cancelled')setMessage('Payment was cancelled. Your order remains awaiting payment.','error')}catch(e){setMessage(e.message||String(e),'error')}}
function signOut(){saveSession(null);showAuth(true);setMessage('Signed out.','success')}
async function handleAuthSuccess(data){saveSession(data);showAuth(false);try{await loadTenantBranding();await ensureCustomerRegistration();const submitted=await submitStoredSellingJourney();await loadPortalData();if(submitted){location.hash='#selling';setMessage('Your valuation request has been submitted. You can now view it here and follow its progress.','success')}}catch(err){setMessage(err.message||String(err),'error')}}
async function shippingAssetBlob(url){const r=await fetch(url);if(!r.ok)throw Error('The shipping file could not be downloaded.');return await r.blob();}
async function downloadShippingAsset(url,name,button){try{setBusy(button,true,'Downloading…');const blob=await shippingAssetBlob(url);const a=document.createElement('a');a.href=URL.createObjectURL(blob);a.download=name+(blob.type==='application/pdf'?'.pdf':blob.type==='image/png'?'.png':'.jpg');document.body.appendChild(a);a.click();a.remove();setTimeout(()=>URL.revokeObjectURL(a.href),2000)}catch(e){setMessage(e.message||String(e),'error')}finally{setBusy(button,false)}}
async function printShippingAsset(url,title,button){try{setBusy(button,true,'Opening…');const blob=await shippingAssetBlob(url);const objectUrl=URL.createObjectURL(blob);const w=window.open('','_blank','noopener');if(!w)throw Error('Allow pop-ups to print the shipping file.');const type=blob.type;const body=type==='application/pdf'?'<iframe src="'+objectUrl+'" style="width:100%;height:100vh;border:0"></iframe>':'<img src="'+objectUrl+'" style="max-width:100%;max-height:95vh;display:block;margin:auto">';w.document.write('<!doctype html><title>'+esc(title)+'</title><body style="margin:0;padding:20px;font-family:Arial">'+body+'</body>');w.document.close();setTimeout(()=>{try{w.focus();w.print()}catch(e){}},1200)}catch(e){setMessage(e.message||String(e),'error')}finally{setBusy(button,false)}}
document.addEventListener('click',e=>{const sentButton=e.target.closest?.('.mark-item-sent');if(sentButton){e.preventDefault();e.stopPropagation();markBuyingItemPosted(sentButton.dataset.buyingItemId);return}const assetDownload=e.target.closest?.('.shipping-asset-download');if(assetDownload){e.preventDefault();e.stopPropagation();downloadShippingAsset(assetDownload.dataset.url,assetDownload.dataset.name,assetDownload);return}const assetPrint=e.target.closest?.('.shipping-asset-print');if(assetPrint){e.preventDefault();e.stopPropagation();printShippingAsset(assetPrint.dataset.url,assetPrint.dataset.name,assetPrint);return}const offerButton=e.target.closest?.('.offer-accept,.offer-refuse');if(offerButton){e.preventDefault();e.stopPropagation();respond(offerButton.dataset.offerId,offerButton.classList.contains('offer-accept')?'accept':'refuse');return}const b=e.target.closest?.('.buy-listing');if(!b)return;e.preventDefault();e.stopPropagation();checkout(b.dataset.listingId)});window.tradeflowHandleCustomerAuthSuccess=handleAuthSuccess;
window.addEventListener('tradeflow-auth-success',e=>handleAuthSuccess(e.detail));
$('submit-request')?.addEventListener('click',submitBuyingRequest);$('request-category')?.addEventListener('change',loadRequestFields);
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
(async()=>{await loadTenantBranding();if(!key)return setMessage('TradeFlow customer portal is not configured.','error');await initialisePortal()})();
