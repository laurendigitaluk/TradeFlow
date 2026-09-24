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
function offerAction(r,valuation){if(r.status!=='published')return '<span class="status-pill '+(r.status==='accepted'?'status-approved':'status-neutral')+'">'+esc(r.status==='accepted'?'Accepted by you':r.status==='refused'?'Refused':r.status)+'</span>';const cash=valuation?.cash_price!=null?Number(valuation.cash_price):null;const trade=valuation?.trade_in_price!=null?Number(valuation.trade_in_price):null;const offerId=esc(r.offer_id||r.id);return'<div class="offer-action-card"><div class="offer-action-title">Action required: choose your offer</div><p class="small">The cash purchase and trade-in values are part of the same offer. Choose one.</p><div class="offer-choice-grid" style="display:grid;grid-template-columns:1fr 1fr;gap:12px;margin-top:12px">'+(cash!==null?'<div class="offer-choice" style="padding:12px;border:1px solid #d8dee5;border-radius:8px"><strong>Cash offer: '+money(cash,r.currency)+'</strong><div class="actions" style="margin-top:10px"><button type="button" class="offer-accept" data-offer-id="'+offerId+'" data-offer-mode="cash">Accept cash offer</button></div></div>':'')+(trade!==null?'<div class="offer-choice" style="padding:12px;border:1px solid #d8dee5;border-radius:8px"><strong>Trade-in offer: '+money(trade,r.currency)+'</strong><div class="actions" style="margin-top:10px"><button type="button" class="offer-accept" data-offer-id="'+offerId+'" data-offer-mode="trade_in">Accept trade-in offer</button></div></div>':'')+'</div><textarea class="offer-response-notes" data-offer-id="'+offerId+'" rows="2" placeholder="Optional response notes" style="margin-top:12px"></textarea><div class="actions"><button type="button" class="offer-refuse" data-offer-id="'+offerId+'">Refuse offer</button></div></div>'}
async function respond(id,a,mode){const n=document.querySelector(`.offer-response-notes[data-offer-id="${CSS.escape(id)}"]`)?.value.trim()||null;try{const fn=a==='accept'?'customer_accept_offer_choice':'customer_refuse_offer';const body={p_tenant_id:tenantId,p_offer_id:id,p_response_notes:n};if(a==='accept')body.p_offer_mode=mode||'cash';await api(`/rest/v1/rpc/${fn}`,{method:'POST',body:JSON.stringify(body)});setMessage(a==='accept'?'Offer accepted. Shipping and receipt workflow can now begin.':'Offer refused.','success');await loadPortalData()}catch(e){setMessage(e.message||String(e),'error')}}
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
  awaiting_shipping_label:['Shipping label required — not ready to send','Your offer has been accepted. The business must create your shipping label and instructions before you send the item.'],
  awaiting_item:['Shipping instructions sent — ready to send','Your shipping label and instructions are ready. Send the item and confirm when you have handed the item to the courier.'],
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
 const liveOffer=(Array.isArray(offers)?offers:[]).find(o=>o.status==='published'&&o.buying_item_id===base.buying_item_id);
 if(liveOffer){ action=offerAction(liveOffer); }
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
function renderCustomerAddresses(addresses){
 const box=$('customer-addresses');if(!box)return;
 const list=Array.isArray(addresses)?addresses:[];
 const card=a=>'<div class="account-address-card" style="border:1px solid #d8dee5;border-radius:8px;padding:14px;margin:10px 0"><div style="display:flex;justify-content:space-between;gap:12px"><strong>'+esc(a.address_type==='billing'?'Payment address':'Delivery address')+'</strong><span class="small">'+(a.is_default?'Default':'')+'</span></div><div class="small" style="margin-top:8px">'+esc([a.recipient_name,a.company_name,a.line1,a.line2,a.city,a.county,a.postcode,a.country_code].filter(Boolean).join(', '))+'</div><div class="actions" style="margin-top:10px"><button type="button" class="edit-customer-address" data-address-id="'+esc(a.id)+'">Edit</button><button type="button" class="delete-customer-address" data-address-id="'+esc(a.id)+'">Remove</button>'+(a.is_default?'':'<button type="button" class="default-customer-address" data-address-id="'+esc(a.id)+'">Make default</button>')+'</div></div>';
 box.innerHTML='<h3>Addresses</h3><p class="small">Save separate payment and delivery addresses for purchases. You can edit or change your default address at any time.</p>'+list.map(card).join('')+'<div class="actions" style="margin-top:12px"><button type="button" id="add-payment-address">Add payment address</button><button type="button" id="add-delivery-address">Add delivery address</button></div>';
}
function addressForm(address){
 const a=address||{};
 return '<div id="customer-address-form" style="margin-top:16px;padding:16px;border:1px solid #d8dee5;border-radius:8px"><h4>'+(a.id?'Edit':'Add')+' '+(a.address_type==='billing'?'payment':'delivery')+' address</h4><div class="form-grid"><label>Address type<select id="address-type"><option value="delivery" '+(a.address_type==='delivery'?'selected':'')+'>Delivery</option><option value="billing" '+(a.address_type==='billing'?'selected':'')+'>Payment</option></select></label><label>Recipient name<input id="address-recipient" value="'+esc(a.recipient_name||'')+'"></label><label>Company name<input id="address-company" value="'+esc(a.company_name||'')+'"></label><label>Address line 1<input id="address-line1" value="'+esc(a.line1||'')+'"></label><label>Address line 2<input id="address-line2" value="'+esc(a.line2||'')+'"></label><label>Town / City<input id="address-city" value="'+esc(a.city||'')+'"></label><label>County<input id="address-county" value="'+esc(a.county||'')+'"></label><label>Postcode<input id="address-postcode" value="'+esc(a.postcode||'')+'"></label><label>Country code<input id="address-country" maxlength="2" value="'+esc(a.country_code||'GB')+'"></label><label><input type="checkbox" id="address-default" '+(a.is_default?'checked':'')+'> Make this the default '+(a.address_type==='billing'?'payment':'delivery')+' address</label></div><div class="actions"><button type="button" id="save-customer-address" data-address-id="'+esc(a.id||'')+'">Save address</button><button type="button" id="cancel-customer-address">Cancel</button></div></div>';
}
function openAddressForm(type,id){
 const list=window.tradeflowCustomerAddresses||[];
 const a=id?list.find(x=>x.id===id):{address_type:type,country_code:'GB'};
 const box=$('customer-address-form-wrap');if(box)box.innerHTML=addressForm(a);
}
async function saveCustomerAddress(){
 const b=$('save-customer-address');if(!b)return;setBusy(b,true,'Saving…');
 try{
  const type=$('address-type').value, line1=$('address-line1').value.trim(), city=$('address-city').value.trim(), postcode=$('address-postcode').value.trim();
  if(!line1||!city||!postcode)throw Error('Address line 1, town/city and postcode are required.');
  await api('/rest/v1/rpc/customer_upsert_address',{method:'POST',body:JSON.stringify({p_tenant_id:tenantId,p_address_id:b.dataset.addressId||null,p_address_type:type,p_recipient_name:$('address-recipient').value.trim()||null,p_company_name:$('address-company').value.trim()||null,p_line1:line1,p_line2:$('address-line2').value.trim()||null,p_city:city,p_county:$('address-county').value.trim()||null,p_postcode:postcode,p_country_code:($('address-country').value.trim()||'GB').toUpperCase(),p_is_default:$('address-default').checked})});
  setMessage('Address saved.','success');await loadPortalData();
 }catch(e){setMessage(e.message||String(e),'error');setBusy(b,false)}
}
async function deleteCustomerAddress(id){
 if(!confirm('Remove this saved address?'))return;
 try{await api('/rest/v1/rpc/customer_delete_address',{method:'POST',body:JSON.stringify({p_tenant_id:tenantId,p_address_id:id})});setMessage('Address removed.','success');await loadPortalData()}catch(e){setMessage(e.message||String(e),'error')}
}
async function defaultCustomerAddress(id){
 try{await api('/rest/v1/rpc/customer_set_default_address',{method:'POST',body:JSON.stringify({p_tenant_id:tenantId,p_address_id:id})});setMessage('Default address updated.','success');await loadPortalData()}catch(e){setMessage(e.message||String(e),'error')}
}
function renderCustomerBankDetails(bankDetails){
 const box=$('customer-bank-details');if(!box)return;
 const has=Boolean(bankDetails?.has_details);
 box.innerHTML='<h3>Bank details for payments</h3><p class="small">These are the UK bank details Camera Shack will use when paying you for items you sell. You can update them at any time.</p><div class="form-grid" style="margin-top:12px"><label>Account holder name<input id="account-bank-holder" autocomplete="name" value="'+esc(bankDetails?.account_holder_name||'')+'"></label><label>Bank name (optional)<input id="account-bank-name" autocomplete="organization" value="'+esc(bankDetails?.bank_name||'')+'"></label><label>Sort code<input id="account-bank-sort-code" inputmode="numeric" autocomplete="off" maxlength="8" placeholder="12-34-56" value="'+esc(bankDetails?.sort_code||'')+'"></label><label>Account number<input id="account-bank-number" inputmode="numeric" autocomplete="off" maxlength="8" placeholder="12345678" value="'+esc(bankDetails?.account_number||'')+'"></label></div><div class="actions" style="margin-top:12px"><button type="button" id="save-account-bank-details">'+(has?'Update bank details':'Save bank details')+'</button></div><p id="account-bank-message" class="small" style="margin-top:8px">'+(has?'Bank details are on record. You can change them here whenever needed.':'Bank details have not yet been provided.')+'</p>';
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
async function cancelOrder(id,reference){
 if(!id)return setMessage('This order could not be identified.','error');
 if(!window.confirm('Cancel '+(reference||'this order')+'?'))return;
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
   const [sellingStatus,offers,acq,shipping,bankDetails,completedSales]=await Promise.all([
     rpc('customer_get_selling_status'),
     rpc('customer_get_offer_choices'),
     rpc('customer_get_acquisitions'),
     rpc('customer_get_pre_acquisition_shipping'),
     rpc('customer_get_bank_details'),
     rpc('customer_get_completed_sales')
   ]);
   const completedItemIds=new Set((Array.isArray(completedSales)?completedSales:[]).map(a=>a.buying_item_id).filter(Boolean));
   const activeOffers=(Array.isArray(offers)?offers:[]).filter(o=>!completedItemIds.has(o.buying_item_id));
await renderSellingStatus(sellingStatus,activeOffers,acq,shipping,bankDetails,completedSales);
 }catch(e){console.warn('TradeFlow customer selling status refresh failed:',e)}
}
function startCustomerSellingStatusRefresh(){
 if(sellingStatusRefreshTimer)clearInterval(sellingStatusRefreshTimer);
 sellingStatusRefreshTimer=setInterval(()=>{if(!document.hidden)refreshCustomerSellingStatus()},10000);
}
async function loadPortalData(){const [buying,values,offers,acq,shipping,orders,items,fulfilments,returns,addresses,sellingStatus,bankDetails,completedSales]=await Promise.all([rpc('customer_get_buying_requests'),rpc('customer_get_trading_values'),rpc('customer_get_offer_choices'),rpc('customer_get_acquisitions'),rpc('customer_get_pre_acquisition_shipping'),rpc('customer_get_orders'),rpc('customer_get_order_items'),rpc('customer_get_fulfilments'),rpc('customer_get_returns'),rpc('customer_get_addresses'),rpc('customer_get_selling_status'),rpc('customer_get_bank_details'),rpc('customer_get_completed_sales')]);profile=(await rpc('customer_get_profile'))?.[0]||null;$('customer-name').textContent=profile?`${profile.first_name||''} ${profile.last_name||''}`.trim()||'Customer':'Customer';const completedAcquisitions=Array.isArray(completedSales)?completedSales:[];
const completedRequestRefs=new Set(completedAcquisitions.map(a=>a.request_reference).filter(Boolean));
const completedItemIds=new Set(completedAcquisitions.map(a=>a.buying_item_id).filter(Boolean));
const completedBuying=(Array.isArray(buying)?buying:[]).filter(r=>String(r.status||'').toLowerCase()==='closed'||String(r.purchase_stage||'').toLowerCase()==='purchased'||String(r.acquisition_status||'').toLowerCase()==='paid'||completedRequestRefs.has(r.request_reference)||completedItemIds.has(r.buying_item_id));
const activeBuying=(Array.isArray(buying)?buying:[]).filter(r=>!completedBuying.includes(r));
const completedAcquisitionIds=new Set(completedAcquisitions.map(a=>a.acquisition_id).filter(Boolean));
const activeAcquisitions=(Array.isArray(acq)?acq:[]).filter(a=>!completedAcquisitionIds.has(a.acquisition_id));
const activeOffers=(Array.isArray(offers)?offers:[]).filter(o=>!completedItemIds.has(o.buying_item_id));
$('order-count').textContent=orders?.length||0;$('return-count').textContent=returns?.length||0;$('buying-list').innerHTML=rows(activeBuying,[{key:'request_reference',label:'Reference'},{key:'status',label:'Status'},{key:'source',label:'Source'}],'No active selling requests.');await renderSellingStatus(sellingStatus,activeOffers,acq,shipping,bankDetails,completedSales);const valuations=await rpc('customer_get_selling_valuations');
const visibleValuations=(Array.isArray(valuations)?valuations:[]).filter(v=>!completedRequestRefs.has(v.request_reference));
$('buying-count').textContent=visibleValuations.length;
renderSellingValuations(visibleValuations);
const hasSellingActivity=(Array.isArray(buying)&&buying.length>0)||(Array.isArray(valuations)&&valuations.length>0)||(activeOffers.length>0)||(activeAcquisitions.length>0)||(completedAcquisitions.length>0);
const valuationsPanel=$('valuations');if(valuationsPanel)valuationsPanel.hidden=!hasSellingActivity;
const valuationsNav=$('valuations-nav-link');if(valuationsNav)valuationsNav.hidden=!hasSellingActivity;
const secondaryOffers=activeOffers.filter(o=>o.offer_type!=='initial');$('offer-list').innerHTML=secondaryOffers.length?'<div class="offer-instruction">Additional offers and later revisions are shown here.</div>'+rows(secondaryOffers,[{key:'offer_reference',label:'Offer'},{key:'offer_type',label:'Type'},{key:'offer_mode',label:'Offer',render:r=>r.offer_mode==='trade_in'?'Trade-in':'Cash'},{key:'status',label:'Response',render:offerAction},{key:'amount',label:'Amount',render:r=>money(r.amount,r.currency)}],'No additional offers.'):'<div class="empty">No additional offers currently.</div>';$('acquisition-list').innerHTML=rows(activeAcquisitions,[{key:'acquisition_reference',label:'Reference'},{key:'status',label:'Status'},{key:'agreed_total',label:'Agreed',render:r=>money(r.agreed_total,r.currency)}],'No accepted sales currently in progress.');
$('completed-selling-list').innerHTML=rows(completedAcquisitions,[{key:'request_reference',label:'Request'},{key:'item_title',label:'Item'},{key:'status',label:'Status'},{key:'agreed_total',label:'Paid',render:r=>money(r.agreed_total,r.currency)},{key:'paid_at',label:'Completed',render:r=>r.paid_at?new Date(r.paid_at).toLocaleDateString('en-GB'):'—'}],'No completed sales to this business yet.');
const completedPanel=$('completed-sales-panel');if(completedPanel)completedPanel.hidden=!completedAcquisitions.length;const activePanel=$('active-selling-panel');if(activePanel)activePanel.hidden=!activeBuying.length;
const valuationPanel=$('valuation-panel');if(valuationPanel)valuationPanel.hidden=!Array.isArray(valuations)||!valuations.length;
const offersPanel=$('offers-panel');if(offersPanel)offersPanel.hidden=!secondaryOffers.length;
const acceptedPanel=$('accepted-sales-panel');if(acceptedPanel)acceptedPanel.hidden=!activeAcquisitions.length;await renderSellingShipping(shipping,addresses);$('order-list').innerHTML=rows(orders,[{key:'order_reference',label:'Order'},{key:'status',label:'Status'},{key:'total',label:'Total',render:r=>money(r.total,r.currency)},{key:'payment_status',label:'Payment',render:r=>r.status==='pending_payment'?`Awaiting payment`:esc(r.payment_status)},{key:'placed_at',label:'Placed',render:r=>r.placed_at?new Date(r.placed_at).toLocaleDateString('en-GB'):'—'},{key:'order_id',label:'Action',render:r=>r.status==='pending_payment'?`<div class="actions"><button type="button" data-pay-order-id="${esc(r.order_id)}">Pay now</button><button type="button" data-cancel-order-id="${esc(r.order_id)}" data-cancel-order-reference="${esc(r.order_reference||'this order')}">Cancel order</button></div>`:r.status==='initiated'?`<button type="button" data-cancel-order-id="${esc(r.order_id)}" data-cancel-order-reference="${esc(r.order_reference||'this order')}">Cancel order</button>`:'—'}],'No orders yet.');$('valuation-summary').textContent=values?.length?`${values.length} valuation record(s) available.`:'No approved valuation is currently available.';if(profile){
  $('profile-first-name').value=profile.first_name||'';
  $('profile-last-name').value=profile.last_name||'';
  $('profile-email').value=profile.email||'';
  $('profile-phone').value=profile.phone||'';
  $('profile-list').textContent='';
}else{
  $('profile-list').textContent='Profile not available.';
}
window.tradeflowCustomerAddresses=Array.isArray(addresses)?addresses:[];renderCustomerAddresses(window.tradeflowCustomerAddresses);renderCustomerBankDetails(bankDetails);renderCustomerFulfilments(fulfilments);renderCustomerReturns(returns,items,orders);document.querySelectorAll('[data-pay-order-id]').forEach(b=>b.onclick=()=>payOrder(b.dataset.payOrderId))}
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
document.addEventListener('click',e=>{const cancelButton=e.target.closest?.('[data-cancel-order-id]');if(cancelButton){e.preventDefault();e.stopPropagation();cancelOrder(cancelButton.dataset.cancelOrderId,cancelButton.dataset.cancelOrderReference);return;}const sentButton=e.target.closest?.('.mark-item-sent');if(sentButton){e.preventDefault();e.stopPropagation();markBuyingItemPosted(sentButton.dataset.buyingItemId);return}const assetDownload=e.target.closest?.('.shipping-asset-download');if(assetDownload){e.preventDefault();e.stopPropagation();downloadShippingAsset(assetDownload.dataset.url,assetDownload.dataset.name,assetDownload);return}const assetPrint=e.target.closest?.('.shipping-asset-print');if(assetPrint){e.preventDefault();e.stopPropagation();printShippingAsset(assetPrint.dataset.url,assetPrint.dataset.name,assetPrint);return}const offerButton=e.target.closest?.('.offer-accept,.offer-refuse');if(offerButton){e.preventDefault();e.stopPropagation();respond(offerButton.dataset.offerId,offerButton.classList.contains('offer-accept')?'accept':'refuse',offerButton.dataset.offerMode);return}});window.tradeflowHandleCustomerAuthSuccess=handleAuthSuccess;
window.addEventListener('tradeflow-auth-success',e=>handleAuthSuccess(e.detail));

$('request-return')?.addEventListener('click',requestReturn);
document.addEventListener('click',e=>{
 const addPay=e.target.closest?.('#add-payment-address');if(addPay){e.preventDefault();openAddressForm('billing');return}
 const addDel=e.target.closest?.('#add-delivery-address');if(addDel){e.preventDefault();openAddressForm('delivery');return}
 const edit=e.target.closest?.('.edit-customer-address');if(edit){e.preventDefault();openAddressForm(null,edit.dataset.addressId);return}
 const del=e.target.closest?.('.delete-customer-address');if(del){e.preventDefault();deleteCustomerAddress(del.dataset.addressId);return}
 const def=e.target.closest?.('.default-customer-address');if(def){e.preventDefault();defaultCustomerAddress(def.dataset.addressId);return}
 if(e.target.closest?.('#cancel-customer-address')){e.preventDefault();$('customer-address-form-wrap').innerHTML='';return}
 if(e.target.closest?.('#save-customer-address')){e.preventDefault();saveCustomerAddress();return}
});
$('save-account-bank-details')?.addEventListener('click',async()=>{
 const b=$('save-account-bank-details');setBusy(b,true,'Saving…');
 try{
  const holder=$('account-bank-holder')?.value.trim()||'';
  const sort=$('account-bank-sort-code')?.value.trim()||'';
  const account=$('account-bank-number')?.value.trim()||'';
  const bank=$('account-bank-name')?.value.trim()||null;
  const result=await api('/rest/v1/rpc/customer_save_bank_details',{method:'POST',body:JSON.stringify({p_tenant_id:tenantId,p_account_holder_name:holder,p_sort_code:sort,p_account_number:account,p_bank_name:bank})});
  if(!result?.saved)throw Error('Bank details were not saved.');
  setMessage('Bank details updated.','success');
  await loadPortalData();
 }catch(e){setMessage(e.message||String(e),'error');setBusy(b,false)}
});
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
