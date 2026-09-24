window.tradeflowBuyingDashboardScriptLoaded=true;
function money(v,c='GBP'){if(v==null)return'—';try{return new Intl.NumberFormat('en-GB',{style:'currency',currency:c}).format(Number(v))}catch{return`${c} ${v}`}}
async function parcel2goShippingCall(body){
 const r=await fetch(SUPABASE_URL+'/functions/v1/parcel2go-subscriber-shipping',{
  method:'POST',
  headers:{'apikey':key,'Authorization':'Bearer '+(session?.access_token||''),'Content-Type':'application/json'},
  body:JSON.stringify(body)
 });
 const text=await r.text();let data=null;try{data=text?JSON.parse(text):null}catch{data=text}
 if(!r.ok)throw Error(data?.error||data?.message||text||'Parcel2Go shipping request failed');
 return data;
}
function p2gField(id,name){return Number($(name+'-'+id)?.value)}
function p2gMoney(v,c='GBP'){if(v==null||v==='')return'—';try{return new Intl.NumberFormat('en-GB',{style:'currency',currency:c}).format(Number(v))}catch{return String(v)}}
function renderParcel2GoQuotes(id,quotes){
 const box=$('p2g-quotes-'+id);if(!box)return;
 if(!Array.isArray(quotes)||!quotes.length){box.innerHTML='<div class="small">Parcel2Go returned no eligible services for these parcel details.</div>';return}
 box.innerHTML='<div style="display:grid;gap:8px">'+quotes.map(q=>{
   const code=esc(q.service_code||'');
   return '<div style="border:1px solid #d8dee5;border-radius:8px;padding:10px;background:#fff"><div style="display:flex;justify-content:space-between;gap:12px;align-items:center"><div><strong>'+esc(q.service_name||'Shipping service')+'</strong><div class="small">'+esc(q.carrier||'Parcel2Go')+(q.delivery?' · '+esc(q.delivery):'')+'</div></div><div><strong>'+p2gMoney(q.price,q.currency||'GBP')+'</strong></div></div><div class="actions" style="margin-top:8px"><button type="button" data-action="parcel2go-order" data-id="'+esc(id)+'" data-service-code="'+code+'">SELECT &amp; CREATE SHIPMENT</button></div></div>';
 }).join('')+'</div>';
 document.querySelectorAll('[data-action="parcel2go-order"][data-id="'+CSS.escape(id)+'"]').forEach(b=>b.onclick=()=>createParcel2GoOrder(id,b.dataset.serviceCode,b));
}
async function getParcel2GoQuotes(id,b){
 const weight=p2gField(id,'p2g-weight'),length=p2gField(id,'p2g-length'),width=p2gField(id,'p2g-width'),height=p2gField(id,'p2g-height');
 if(!weight||!length||!width||!height)return msg('Enter the parcel weight and all three dimensions before requesting a Parcel2Go quote.','error');
 setBusy(b,true);
 try{
  const result=await parcel2goShippingCall({action:'quote',tenant_id:tenantId,buying_item_id:id,weight,length,width,height});
  renderParcel2GoQuotes(id,result.quotes||[]);
  msg('Parcel2Go quotes loaded. Choose the service you want to use.','success');
 }catch(e){msg(e.message||String(e),'error')}finally{setBusy(b,false)}
}
async function createParcel2GoOrder(id,serviceCode,b){
 const weight=p2gField(id,'p2g-weight'),length=p2gField(id,'p2g-length'),width=p2gField(id,'p2g-width'),height=p2gField(id,'p2g-height');
 if(!weight||!length||!width||!height)return msg('Enter the parcel dimensions before creating the shipment.','error');
 if(!serviceCode)return msg('Select a Parcel2Go service first.','error');
 if(!confirm('Create this Parcel2Go shipment? The shipment will be created against the subscriber’s connected Parcel2Go account.'))return;
 setBusy(b,true);
 try{
  const result=await parcel2goShippingCall({action:'create_order',tenant_id:tenantId,buying_item_id:id,service_code:serviceCode,weight,length,width,height});
  if(result.payment_url){
   msg('Parcel2Go shipment created. Complete the Parcel2Go payment before the customer sends the item.','success');
   window.open(result.payment_url,'_blank','noopener');
  }else{
   msg('Parcel2Go shipment created.','success');
  }
  await load();if(openRequestId)await showRequest(openRequestId,currentRequests);
 }catch(e){msg(e.message||String(e),'error')}finally{setBusy(b,false)}
}
async function publishShippingHandoff(id,b){
 const url=$('ship-url-'+id)?.value.trim(),storagePath=$('ship-path-'+id)?.value.trim(),qrUrl=$('ship-qr-url-'+id)?.value.trim(),qrPath=$('ship-qr-path-'+id)?.value.trim();
 if(!url&&!storagePath&&!qrUrl&&!qrPath)return msg('Add a shipping label URL, upload a label, add a QR code URL, or upload a QR code before sending the manual shipping instructions.','error');
 setBusy(b,true);
 try{
  await api('/rest/v1/rpc/subscriber_publish_buying_item_shipping_handoff',{method:'POST',body:JSON.stringify({p_tenant_id:tenantId,p_buying_item_id:id,p_shipping_method:'subscriber_override',p_shipping_label_url:url||null,p_shipping_label_storage_path:storagePath||null,p_shipping_qr_url:qrUrl||null,p_shipping_qr_storage_path:qrPath||null,p_shipping_carrier:$('ship-carrier-'+id)?.value.trim()||null,p_shipping_service:$('ship-service-'+id)?.value.trim()||null,p_shipping_tracking_number:$('ship-tracking-'+id)?.value.trim()||null,p_shipping_instructions:$('ship-instructions-'+id)?.value.trim()||null,p_shipping_service_url:$('ship-service-url-'+id)?.value.trim()||null})});
  msg('Your manual shipping method and handoff have been published to the customer.','success');await load();if(openRequestId)await showRequest(openRequestId,currentRequests);
 }catch(e){msg(e.message||String(e),'error')}finally{setBusy(b,false)}
}

async function uploadShippingLabel(id,b){const file=$('ship-file-'+id)?.files?.[0];if(!file)return msg('Choose a PDF, PNG or JPEG shipping label first.','error');if(!['application/pdf','image/png','image/jpeg'].includes(file.type))return msg('Shipping labels must be PDF, PNG or JPEG files.','error');if(file.size>10*1024*1024)return msg('Shipping labels must be 10 MB or smaller.','error');setBusy(b,true);try{const ext=(file.name.split('.').pop()||'pdf').toLowerCase().replace(/[^a-z0-9]/g,'')||'pdf';const path=tenantId+'/buying-items/'+id+'/shipping-label-'+Date.now()+'.'+ext;await storageUpload(path,file);await storageSignedUrl(path);await api('/rest/v1/buying_item_shipping?buying_item_id=eq.'+encodeURIComponent(id)+'&tenant_id=eq.'+encodeURIComponent(tenantId),{method:'PATCH',headers:{Prefer:'return=minimal'},body:JSON.stringify({shipping_method:'subscriber_override',shipping_label_storage_path:path,shipping_label_url:null})});msg('Shipping label uploaded. You can open/print it now or save & resend it to the customer.','success');await load();}catch(e){msg(e.message||String(e),'error')}finally{setBusy(b,false)}}
async function uploadShippingQr(id,b){const file=$('ship-qr-file-'+id)?.files?.[0];if(!file)return msg('Choose a PNG or JPEG QR code image first.','error');if(!['image/png','image/jpeg'].includes(file.type))return msg('QR codes must be PNG or JPEG images.','error');if(file.size>5*1024*1024)return msg('QR code images must be 5 MB or smaller.','error');setBusy(b,true);try{const ext=(file.name.split('.').pop()||'png').toLowerCase().replace(/[^a-z0-9]/g,'')||'png';const path=tenantId+'/buying-items/'+id+'/shipping-qr-'+Date.now()+'.'+ext;await storageUpload(path,file);await storageSignedUrl(path);await api('/rest/v1/buying_item_shipping?buying_item_id=eq.'+encodeURIComponent(id)+'&tenant_id=eq.'+encodeURIComponent(tenantId),{method:'PATCH',headers:{Prefer:'return=minimal'},body:JSON.stringify({shipping_method:'subscriber_override',shipping_qr_storage_path:path,shipping_qr_url:null})});msg('QR code uploaded. You can open it now or save & resend the shipping instructions.','success');await load();}catch(e){msg(e.message||String(e),'error')}finally{setBusy(b,false)}}
async function shippingAssetUrl(id,kind){
 const path=$(kind==='label'?'ship-path-'+id:'ship-qr-path-'+id)?.value.trim();
 const direct=$(kind==='label'?'ship-url-'+id:'ship-qr-url-'+id)?.value.trim();
 if(direct)return direct;
 if(path)return storageSignedUrl(path);
 throw Error(kind==='label'?'No shipping label has been added yet.':'No QR code has been added yet.');
}
async function openShippingLabel(id){try{window.open(await shippingAssetUrl(id,'label'),'_blank','noopener');}catch(e){msg(e.message||String(e),'error')}}
async function openShippingQr(id){try{window.open(await shippingAssetUrl(id,'qr'),'_blank','noopener');}catch(e){msg(e.message||String(e),'error')}}
async function downloadShippingAsset(id,kind,b){
 setBusy(b,true);try{const url=await shippingAssetUrl(id,kind);const r=await fetch(url);if(!r.ok)throw Error('Could not download the shipping '+kind+'.');const blob=await r.blob();const ext=kind==='label'?(blob.type.includes('pdf')?'pdf':'png'):'png';const a=document.createElement('a');a.href=URL.createObjectURL(blob);a.download=(kind==='label'?'shipping-label':'shipping-qr-code')+'.'+ext;document.body.appendChild(a);a.click();a.remove();setTimeout(()=>URL.revokeObjectURL(a.href),1000);}catch(e){msg(e.message||String(e),'error')}finally{setBusy(b,false)}
}
async function printShippingAsset(id,kind,b){
 setBusy(b,true);try{const url=await shippingAssetUrl(id,kind);const w=window.open('about:blank','_blank');if(!w)throw Error('Allow pop-ups to print the shipping '+kind+'.');const title=kind==='label'?'Shipping label':'Shipping QR code';w.document.write('<!doctype html><html><head><title>'+title+'</title><style>html,body{margin:0;padding:20px;text-align:center;font-family:Arial,sans-serif}img{max-width:100%;max-height:95vh}iframe{width:100%;height:95vh;border:0}</style></head><body><div>Preparing '+title+'…</div></body></html>');w.document.close();if(kind==='label'&&/\.pdf($|\?)/i.test(url)){w.document.body.innerHTML='<iframe src="'+esc(url)+'"></iframe>';}else{w.document.body.innerHTML='<img src="'+esc(url)+'" alt="'+title+'">';}setTimeout(()=>{try{w.focus();w.print()}catch{}},1200);}catch(e){msg(e.message||String(e),'error')}finally{setBusy(b,false)}
}
async function resendShippingHandoff(id,b){
 setBusy(b,true);try{
  const method=$('ship-method-'+id)?.value||'subscriber_override';
  const body={p_tenant_id:tenantId,p_buying_item_id:id,p_shipping_method:method,p_shipping_label_url:$('ship-url-'+id)?.value.trim()||null,p_shipping_label_storage_path:$('ship-path-'+id)?.value.trim()||null,p_shipping_qr_url:$('ship-qr-url-'+id)?.value.trim()||null,p_shipping_qr_storage_path:$('ship-qr-path-'+id)?.value.trim()||null,p_shipping_carrier:$('ship-carrier-'+id)?.value.trim()||null,p_shipping_service:$('ship-service-'+id)?.value.trim()||null,p_shipping_tracking_number:$('ship-tracking-'+id)?.value.trim()||null,p_shipping_instructions:$('ship-instructions-'+id)?.value.trim()||null,p_shipping_service_url:$('ship-service-url-'+id)?.value.trim()||null};
  await api('/rest/v1/rpc/subscriber_publish_buying_item_shipping_handoff',{method:'POST',body:JSON.stringify(body)});
  msg('Shipping label/QR and instructions have been resent to the customer.','success');await load();if(openRequestId)await showRequest(openRequestId,currentRequests);
 }catch(e){msg(e.message||String(e),'error')}finally{setBusy(b,false)}
}
async function markBuyingItemReceived(id,b){
 setBusy(b,true);try{await api('/rest/v1/rpc/subscriber_mark_buying_item_received',{method:'POST',body:JSON.stringify({p_tenant_id:tenantId,p_buying_item_id:id})});msg('Item received. The item is now ready for purchasing inspection.','success');await load();if(openRequestId)await showRequest(openRequestId,currentRequests)}catch(e){msg(e.message||String(e),'error')}finally{setBusy(b,false)}
}

window.tradeflowStartBuyingItemInspection=startBuyingItemInspection;
async function startBuyingItemInspection(id,b){
 setBusy(b,true);
 try{
  await api('/rest/v1/rpc/subscriber_start_buying_item_inspection',{method:'POST',body:JSON.stringify({p_tenant_id:tenantId,p_buying_item_id:id})});
  msg('Inspection started. The item is now in the Purchasing inspection stage.','success');
  await load();
  if(openRequestId)await showRequest(openRequestId,currentRequests);
 }catch(e){
  msg(e.message||String(e),'error');
 }finally{setBusy(b,false)}
}

const SUPABASE_URL='https://twfbmjwwqzxdxvclxbun.supabase.co';
let key=''; let session=null; let tenantId=null; let currentRequests=[]; let openRequestId=null; let statusRefreshTimer=null; let shippingConnections=[];
function providerLabel(p){return ({parcel2go:'Parcel2Go',sendcloud:'Sendcloud',shippo:'Shippo'})[p]||p||'Shipping provider';}
const params=new URLSearchParams(location.search); openRequestId=params.get('request')||null;
const $=id=>document.getElementById(id); const esc=v=>String(v??'').replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c])); function money(v,c='GBP'){if(v==null||v==='')return'—';try{return new Intl.NumberFormat('en-GB',{style:'currency',currency:c}).format(Number(v))}catch{return String(c)+' '+String(v)}}
function msg(t,type=''){ $('message').className=`small ${type}`.trim(); $('message').textContent=t||''; }
async function api(path,options={}){ if(!key) throw Error('TradeFlow subscriber authentication is not connected.'); const h=new Headers(options.headers||{}); h.set('apikey',key); h.set('Content-Type','application/json'); if(session?.access_token) h.set('Authorization',`Bearer ${session.access_token}`); const r=await fetch(`${SUPABASE_URL}${path}`,{...options,headers:h}); const text=await r.text(); let b=null; try{b=text?JSON.parse(text):null}catch{b=text} if(!r.ok) throw Error(b?.message||b?.msg||b?.error||text||`HTTP ${r.status}`); return b; }
async function storageUpload(path,file){const h=new Headers({'apikey':key,'Authorization':`Bearer ${session?.access_token||''}`,'Content-Type':file.type||'application/octet-stream','x-upsert':'false'});const r=await fetch(`${SUPABASE_URL}/storage/v1/object/tradeflow-media/${path}`,{method:'POST',headers:h,body:file});const text=await r.text();let b=null;try{b=text?JSON.parse(text):null}catch{b=text}if(!r.ok)throw Error(b?.message||b?.error||text||`Storage upload failed (${r.status})`);return b;}
async function storageSignedUrl(path){const r=await fetch(`${SUPABASE_URL}/storage/v1/object/sign/tradeflow-media/${path}`,{method:'POST',headers:{'apikey':key,'Authorization':`Bearer ${session?.access_token||''}`,'Content-Type':'application/json'},body:JSON.stringify({expiresIn:86400})});const text=await r.text();let b=null;try{b=text?JSON.parse(text):null}catch{b=text}if(!r.ok)throw Error(b?.message||b?.error||text||`Could not create shipping label link (${r.status})`);return b?.signedURL?.startsWith('http')?b.signedURL:`${SUPABASE_URL}/storage/v1${b.signedURL}`;}
function tenantName(){ return window.tradeflowSubscriberAuth?.tenants?.[tenantId]||tenantId; }
async function transition(entityType,entityId,from,to,notes=''){ return api('/rest/v1/rpc/transition_workflow_entity',{method:'POST',body:JSON.stringify({p_tenant_id:tenantId,p_entity_type:entityType,p_entity_id:entityId,p_expected_from:from,p_to_status:to,p_notes:notes||null,p_metadata:{source:'subscriber_buying_dashboard'}})}); }
function openInspectionWorkspace(ev){
 ev?.preventDefault();
 const targetId='tradeflow-inspection-workspace';
 const reveal=()=>{
   const el=document.getElementById(targetId);
   if(!el)return false;
   history.replaceState(null,'','#'+targetId);
   el.scrollIntoView({behavior:'smooth',block:'start'});
   el.style.outline='2px solid #1f2937';
   setTimeout(()=>{el.style.outline='';},1400);
   return true;
 };
 if(reveal())return false;
 (async()=>{
   try{
     if(typeof window.tradeflowRefreshInspectionWorkspace==='function')await window.tradeflowRefreshInspectionWorkspace();
   }catch(e){
     msg(e?.message||String(e),'error');
   }
   if(reveal())return;
   let tries=0;
   const timer=setInterval(()=>{tries++;if(reveal()||tries>=100)clearInterval(timer)},50);
 })();
 return false;
}
window.tradeflowOpenInspection=openInspectionWorkspace;

function shippingHandoffHtml(r){
 const a=r?.preShipping||null;
 const id=a?.buying_item_id||r?.buying_item_id;
 if(!id||!['offer_accepted','awaiting_item','shipping','received','inspection'].includes(r?.status))return '';
 const label=a?.shipping_label_storage_path||a?.shipping_label_url,qr=a?.shipping_qr_storage_path||a?.shipping_qr_url;
 const service=[a?.shipping_carrier,a?.shipping_service].filter(Boolean).join(' · ')||'Shipping service not specified';
 const serviceUrl=a?.shipping_service_url?'<a href="'+esc(a.shipping_service_url)+'" target="_blank" rel="noopener">Open shipping service website</a>':'';
 const labelControls=label?'<div class="actions" style="margin-top:8px"><button type="button" data-action="shipping-print" data-id="'+esc(id)+'">Print shipping label</button><button type="button" data-action="shipping-download" data-id="'+esc(id)+'">Download shipping label</button></div>':'<p class="small">No physical shipping label is currently stored.</p>';
 const qrControls=qr?'<div class="actions" style="margin-top:8px"><button type="button" data-action="qr-print" data-id="'+esc(id)+'">Print QR code</button><button type="button" data-action="qr-download" data-id="'+esc(id)+'">Download QR code</button></div>':'<p class="small">No physical QR code is currently stored.</p>';
 const resend='<div class="actions" style="margin-top:12px"><button type="button" data-action="shipping-resend" data-id="'+esc(id)+'">'+(label||qr?'Resend shipping label / QR and instructions':'Send shipping label / QR and instructions')+'</button></div>';
 if(r.status==='offer_accepted'||(r.status==='awaiting_item'&&!a?.shipping_status)){
   return '<section class="shipping-method-card" style="margin-top:12px;border:1px solid #b9d8c0;border-radius:8px;padding:14px;background:#f4faf5">'+
    '<h3>Shipping handoff</h3>'+
    '<p><strong>The customer has accepted the initial offer. Arrange the shipping before the item is sent.</strong></p>'+
    '<div class="notice" style="margin:12px 0;padding:14px;border:1px solid #c8dfce;border-radius:8px;background:#fff">'+
      '<h4 style="margin:0 0 6px">Integrated shipping — Parcel2Go</h4>'+
      '<p class="small" style="margin:0 0 12px">Use the subscriber’s connected Parcel2Go account to compare available courier services for this parcel. Parcel2Go handles the courier choice and shipping charge.</p>'+
      '<div class="form-grid">'+
        '<label><strong>Weight (kg)</strong><input id="p2g-weight-'+esc(id)+'" type="number" min="0.01" step="0.01" placeholder="e.g. 2.5"></label>'+
        '<label><strong>Length (cm)</strong><input id="p2g-length-'+esc(id)+'" type="number" min="1" step="0.1" placeholder="e.g. 35"></label>'+
        '<label><strong>Width (cm)</strong><input id="p2g-width-'+esc(id)+'" type="number" min="1" step="0.1" placeholder="e.g. 25"></label>'+
        '<label><strong>Height (cm)</strong><input id="p2g-height-'+esc(id)+'" type="number" min="1" step="0.1" placeholder="e.g. 15"></label>'+
      '</div>'+
      '<div class="actions" style="margin-top:12px"><button type="button" data-action="parcel2go-quote" data-id="'+esc(id)+'">GET PARCEL2GO QUOTES</button></div>'+
      '<div id="p2g-quotes-'+esc(id)+'" style="margin-top:12px"></div>'+
      '<p class="small" style="margin:10px 0 0"><strong>Customer delivery address:</strong> Parcel2Go uses the customer\'s saved <strong>Delivery address</strong> from <strong>My Details</strong>. Creating a shipment is a separate action and opens the Parcel2Go payment step; TradeFlow does not take the shipping payment.</p>'+
    '</div>'+
    '<details style="margin-top:12px"><summary><strong>Manual shipping fallback</strong></summary>'+
      '<p class="small">Use this only when you are not using the connected Parcel2Go account.</p>'+
      '<div class="form-grid" style="margin-top:10px">'+
        '<label><strong>Shipping label URL</strong><input id="ship-url-'+esc(id)+'" type="text" placeholder="Optional if uploading a label"></label>'+
        '<label><strong>QR code URL</strong><input id="ship-qr-url-'+esc(id)+'" type="text" placeholder="Optional if uploading a QR code"></label>'+
        '<label><strong>Carrier</strong><input id="ship-carrier-'+esc(id)+'" type="text"></label>'+
        '<label><strong>Service</strong><input id="ship-service-'+esc(id)+'" type="text"></label>'+
        '<label><strong>Tracking number</strong><input id="ship-tracking-'+esc(id)+'" type="text"></label>'+
        '<label><strong>Carrier website</strong><input id="ship-service-url-'+esc(id)+'" type="text"></label>'+
        '<label class="full"><strong>Customer instructions</strong><textarea id="ship-instructions-'+esc(id)+'" rows="3"></textarea></label>'+
      '</div>'+
      '<div class="actions" style="margin-top:12px"><button type="button" data-action="shipping" data-id="'+esc(id)+'">SEND MANUAL SHIPPING INSTRUCTIONS</button></div>'+
    '</details>'+
   '</section>';
 }
 if(r.status==='received'||r.status==='inspection'){
   if(r.status==='inspection')return '<section class="shipping-method-card" style="margin-top:12px;border:1px solid #b9d8c0;border-radius:8px;padding:14px;background:#f4faf5"><h3>Inspection in progress</h3><p><strong>The item has been received and is now being inspected.</strong></p><p class="small">The item is still outside Acquisitions and Inventory until the final offer is accepted and payment is recorded.</p><div class="actions" style="margin-top:10px"><a class="button" href="#tradeflow-inspection-workspace" onclick="return window.tradeflowOpenInspection(event)">OPEN INSPECTION</a></div></section>';
   return '<section class="shipping-method-card" style="margin-top:12px;border:1px solid #b9d8c0;border-radius:8px;padding:14px;background:#f4faf5"><h3>Item received — inspection next</h3><p><strong>You have received the customer item.</strong></p><p class="small">The item is not an acquisition yet. Complete the purchasing inspection first.</p><div class="actions" style="margin-top:10px"><button type="button" data-action="start-inspection" data-id="'+esc(id)+'">START INSPECTION</button></div></section>';
 }
 if(r.status==='shipping')return '<section class="shipping-method-card" style="margin-top:12px;border:1px solid #b9d8c0;border-radius:8px;padding:14px;background:#f4faf5"><h3>Item on its way — awaiting receipt</h3><p><strong>The customer has confirmed that the item has been sent.</strong></p><div class="form-grid" style="margin-top:10px"><div><strong>Shipping service</strong><br>'+esc(service)+(serviceUrl?'<br>'+serviceUrl:'')+'</div><div><strong>Tracking number</strong><br>'+esc(a?.shipping_tracking_number||'Not provided')+(a?.shipping_tracking_url?'<br><a href="'+esc(a.shipping_tracking_url)+'" target="_blank" rel="noopener">Track shipment</a>':'')+'</div></div><div style="margin-top:12px"><strong>Shipping label</strong>'+labelControls+'</div><div style="margin-top:12px"><strong>QR code</strong>'+qrControls+'</div><div class="actions" style="margin-top:12px"><button type="button" data-action="acq-received" data-id="'+esc(id)+'">Confirm item received</button></div></section>';
 if(r.status==='awaiting_item')return '<section class="shipping-method-card" style="margin-top:12px;border:1px solid #b9d8c0;border-radius:8px;padding:14px;background:#f4faf5"><h3>Shipping handoff sent — awaiting item</h3><p><strong>The customer has the shipping instructions and can now send the item.</strong></p><div class="form-grid" style="margin-top:10px"><div><strong>Shipping service</strong><br>'+esc(service)+(serviceUrl?'<br>'+serviceUrl:'')+'</div><div><strong>Tracking number</strong><br>'+esc(a?.shipping_tracking_number||'Not provided')+'</div></div><div style="margin-top:12px"><strong>Shipping label</strong>'+labelControls+'</div><div style="margin-top:12px"><strong>QR code</strong>'+qrControls+'</div>'+(a?.shipping_instructions?'<div style="margin-top:12px"><strong>Customer instructions</strong><br>'+esc(a.shipping_instructions).replace(/\n/g,'<br>')+'</div>':'')+resend+'</section>';
 return '';
}

function requestStatusLabel(status){const map={offer_ready:'Manual offer sent — awaiting customer',awaiting_item:'Awaiting item from customer',shipping:'Item on its way — awaiting receipt',received:'Item received — inspection next',inspection:'Inspection in progress',testing:'Testing required',repair:'Repair required',return_pending:'Return to customer',final_offer_required:'Inspection accepted — final offer required',final_offer_sent:'Final offer sent — awaiting customer',final_offer_accepted:'Final offer accepted — payment required',final_offer_refused:'Final offer refused — return item',purchased:'Purchased — now in Inventory',offer_refused:'Offer refused',valued:'Valuation approved — offer not yet sent'};return map[status]||String(status||'').replace(/_/g,' ').replace(/^./,m=>m.toUpperCase())}
function requestStatusClass(status){return status==='submitted'?'status-approved':status==='offer_accepted'?'status-offer':status==='awaiting_item'?'status-approved':status==='shipping'?'status-approved':status==='received'?'status-approved':status==='inspection'?'status-review':status==='finalised'?'status-approved':status==='valued'?'status-approved':status==='offer_ready'?'status-offer':status==='offer_refused'?'status-refused':status==='under_review'?'status-review':'status-pending'}
function renderRequests(rows){ if(!Array.isArray(rows)||!rows.length) return '<div class="empty">No customer buying requests have been submitted to this tenant.</div>'; return '<div class="request-list">'+rows.map(r=>'<div class="request-card"><div><div class="ref">'+esc(r.request_reference)+'</div><div class="meta"><strong>'+esc(r.customer_name||'Customer')+'</strong> · Customer submission · '+(r.submitted_at?new Date(r.submitted_at).toLocaleString('en-GB'):'—')+'</div></div><div><span class="cell-label">Status</span><span class="status-pill '+requestStatusClass(r.status)+'">'+esc(requestStatusLabel(r.status))+'</span>'+(r.offer_amount!=null?'<div class="request-amount">'+money(r.offer_amount,r.offer_currency||'GBP')+'</div>':'')+'</div><div><span class="cell-label">Customer</span><span>'+esc(r.customer_name||'—')+'</span></div><div><span class="cell-label">Source</span><span>'+esc(r.source==='customer_portal'?'Customer portal':r.source||'—')+'</span></div><button type="button" data-action="open-request" data-id="'+esc(r.id)+'">Open request</button></div>').join('')+'</div>'; } 
function renderCompletedPurchases(rows){
 if(!Array.isArray(rows)||!rows.length)return '<div class="empty">No completed purchases yet.</div>';
 return '<div class="request-list">'+rows.map(r=>'<div class="request-card completed-purchase-card"><div><div class="ref">'+esc(r.request_reference)+'</div><div class="meta"><strong>'+esc(r.customer_name||'Customer')+'</strong> · Completed purchase · '+(r.purchase_date?new Date(r.purchase_date).toLocaleString('en-GB'):'—')+'</div></div><div><span class="cell-label">Status</span><span class="status-pill status-approved">Completed & paid</span>'+(r.offer_amount!=null?'<div class="request-amount">'+money(r.offer_amount,r.offer_currency||'GBP')+'</div>':'')+'</div><div><span class="cell-label">Item</span><span>'+esc(r.item_title||'—')+'</span></div><div><span class="cell-label">Customer</span><span>'+esc(r.customer_name||'—')+'</span></div></div>').join('')+'</div>';
}
async function load(){try{
 const auth=await window.tradeflowSubscriberAuthReady;key=auth?.key||'';session=auth?.session||null;tenantId=auth?.tenantId||null;
 if(!tenantId||!key||!session?.access_token)throw Error('Subscriber authentication did not provide a valid business session.');
 $('business-name').textContent=tenantName();msg('Loading…');
 const results=await Promise.allSettled([
  api('/rest/v1/buying_requests?select=id,request_reference,status,source,notes,submitted_at,closed_at,created_at,customer_id&tenant_id=eq.'+encodeURIComponent(tenantId)+'&order=created_at.desc'),
  api('/rest/v1/buying_items?select=id,buying_request_id,title,item_reference,purchase_stage&tenant_id=eq.'+encodeURIComponent(tenantId)),
  api('/rest/v1/trading_values?select=buying_item_id,amount,cash_price,trade_in_price,currency,status&tenant_id=eq.'+encodeURIComponent(tenantId)+'&status=eq.approved'),
  api('/rest/v1/offers?select=id,buying_item_id,amount,currency,status,offer_reference,published_at,responded_at,offer_type&tenant_id=eq.'+encodeURIComponent(tenantId)+'&order=created_at.desc'),
  api('/rest/v1/shipping_provider_connections?select=id,provider,status,display_name,connected_at&tenant_id=eq.'+encodeURIComponent(tenantId)+'&order=provider'),
  api('/rest/v1/buying_item_shipping?select=buying_item_id,shipping_method,shipping_provider,shipping_provider_connection_id,shipping_status,shipping_label_url,shipping_label_storage_path,shipping_qr_url,shipping_qr_storage_path,shipping_service_url,shipping_carrier,shipping_service,shipping_tracking_number,shipping_tracking_url,shipping_instructions,posted_at,customer_sent_at&tenant_id=eq.'+encodeURIComponent(tenantId)),
  api('/rest/v1/acquisitions?select=id,acquisition_reference,status,source_offer_id&tenant_id=eq.'+encodeURIComponent(tenantId)+'&order=created_at.desc')
 ]);
 const valueOf=i=>results[i].status==='fulfilled'?results[i].value:[];
 const failed=results.map((x,i)=>x.status==='rejected'?{i,error:x.reason?.message||String(x.reason)}:null).filter(Boolean);
 if(failed.some(x=>x.i<4))throw Error('Buying data could not be loaded: '+failed.filter(x=>x.i<4).map(x=>x.error).join(' | '));
 if(failed.length)console.warn('Optional buying data could not be loaded:',failed);
 const requests=valueOf(0),items=valueOf(1),values=valueOf(2),offers=valueOf(3),connections=valueOf(4),preShipping=valueOf(5),acquisitions=valueOf(6);
 shippingConnections=connections||[];
 const itemByRequest=Object.fromEntries((items||[]).map(i=>[i.buying_request_id,i]));
 const valueByItem=Object.fromEntries((values||[]).map(v=>[v.buying_item_id,v]));
 const offerByItem=Object.fromEntries((offers||[]).map(o=>[o.buying_item_id,o]));
 const preShippingByItem=Object.fromEntries((preShipping||[]).map(s=>[s.buying_item_id,s]));
 const acquisitionByOffer=Object.fromEntries((acquisitions||[]).filter(a=>a.source_offer_id).map(a=>[a.source_offer_id,a]));
 const paidOfferByItem=Object.fromEntries((offers||[]).filter(o=>acquisitionByOffer[o.id]?.status==='paid').map(o=>[o.buying_item_id,{offer:o,acquisition:acquisitionByOffer[o.id]}]));
 const enriched=(requests||[]).map(r=>{const i=itemByRequest[r.id],v=i&&valueByItem[i.id],o=i&&offerByItem[i.id],a=o&&acquisitionByOffer[o.id],paid=i&&paidOfferByItem[i.id],s=i&&preShippingByItem[i.id];const workflowStatus=i?.purchase_stage&&i.purchase_stage!=='none'?i.purchase_stage:(o?.status==='refused'?'offer_refused':o?.status==='published'?'offer_ready':v?'valued':r.status);return {...r,status:workflowStatus,customer_name:'—',offer_amount:paid?.offer?.amount??o?.amount??v?.cash_price??v?.amount??v?.trade_in_price??null,offer_currency:paid?.offer?.currency??o?.currency??v?.currency??'GBP',acquisition:a||paid?.acquisition||null,preShipping:s,buying_item_id:i?.id||null,item_title:i?.title||'—',purchase_date:i?.purchased_at||paid?.acquisition?.paid_at||null,completed:Boolean((i?.purchase_stage==='purchased')||(paid?.acquisition?.status==='paid'))}});
 let completedPurchases=enriched.filter(r=>r.completed);
 let activeRequests=enriched.filter(r=>!r.completed&&r.status!=='closed');
 currentRequests=activeRequests;
 $('request-list').innerHTML=renderRequests(activeRequests);
 if($('request-count'))$('request-count').textContent=activeRequests.length+' active request'+(activeRequests.length===1?'':'s');
 $('completed-purchases-list').innerHTML=renderCompletedPurchases(completedPurchases);
 if($('completed-count'))$('completed-count').textContent=completedPurchases.length;
 msg(enriched.length+' request(s) loaded.','success');

 // Customer names are enrichment only; they must never block the buying dashboard from rendering.
 const customerIds=[...new Set((requests||[]).map(r=>r.customer_id).filter(Boolean))];
 if(customerIds.length){
  try{
   const customers=await api('/rest/v1/customers?select=id,first_name,last_name&tenant_id=eq.'+encodeURIComponent(tenantId)+'&id=in.('+customerIds.join(',')+')');
   const customerById=Object.fromEntries((customers||[]).map(c=>[c.id,c]));
   enriched.forEach(r=>{const c=customerById[r.customer_id];r.customer_name=[c?.first_name,c?.last_name].filter(Boolean).join(' ')||'—';});
   completedPurchases=enriched.filter(r=>r.completed);
   activeRequests=enriched.filter(r=>!r.completed&&r.status!=='closed');
   currentRequests=activeRequests;
   $('request-list').innerHTML=renderRequests(activeRequests);
   $('completed-purchases-list').innerHTML=renderCompletedPurchases(completedPurchases);
   if($('completed-count'))$('completed-count').textContent=completedPurchases.length;
  }catch(e){
   console.warn('Customer name enrichment failed; buying requests remain available:',e);
  }
 }

 if(openRequestId){const latest=currentRequests.find(x=>x.id===openRequestId);if(latest){await showRequest(openRequestId,currentRequests);setTimeout(()=>document.getElementById('tradeflow-inspection-workspace')?.scrollIntoView({behavior:'smooth',block:'start'}),150);}}
}catch(e){msg(e.message||String(e),'error')}}
async function showRequest(id,requests){ openRequestId=id; const r=requests.find(x=>x.id===id); if(!r)return; $('detail-panel').hidden=false; $('detail-title').textContent=r.request_reference; const publishedHandoff=r.status==='awaiting_item'&&Boolean(r.preShipping?.shipping_status||r.preShipping?.shipping_label_storage_path||r.preShipping?.shipping_qr_storage_path||r.preShipping?.shipping_instructions);
 const workflowState=r.status; const notice=workflowState==='offer_ready'?'<div class="subscriber-action-notice sent"><strong>Manual offer sent — awaiting customer</strong><span>The approved valuation has been sent as an offer. The customer can now accept or refuse it.</span></div>':workflowState==='awaiting_item'?'<div class="subscriber-action-notice sent"><strong>Shipping label sent — awaiting item from customer</strong><span>The shipping handoff is published. The customer now follows the supplied label/instructions and confirms Item sent after handing the parcel to the courier.</span></div>':workflowState==='received'?'<div class="subscriber-action-notice sent"><strong>Item received — inspection next</strong><span>You have received the customer item. The next step is to inspect it.</span></div>':workflowState==='inspection'?'<div class="subscriber-action-notice sent"><strong>Inspection in progress</strong><span>The item has been received and is now being inspected.</span></div>':workflowState==='offer_accepted'?(publishedHandoff?'<div class="subscriber-action-notice sent"><strong>Shipping label and instructions sent to customer</strong><span>The customer has accepted the offer and the shipping handoff has been published. The purchase workflow is now awaiting the item.</span></div>':'<div class="subscriber-action-notice sent"><strong>Offer accepted — send customer shipping label</strong><span>The customer has accepted the £'+Number(r.offer_amount||0).toFixed(2)+' offer. The next action is to provide the shipping label and instructions so the customer can send the item.</span><div class="actions" style="margin-top:10px"><span>The shipping handoff is managed here in the Buying workflow.</span></div></div>'):workflowState==='offer_refused'?'<div class="subscriber-action-notice refused"><strong>Offer refused by customer</strong><span>The customer has declined this offer.</span></div>':workflowState==='valued'?'<div class="subscriber-action-notice action"><strong>Action required — send the offer</strong><span>The valuation is approved. Send the approved valuation to the customer so they can accept or refuse it.</span></div>':''; let details=null; try{details=await api('/rest/v1/rpc/subscriber_get_buying_item_customer_details',{method:'POST',body:JSON.stringify({p_tenant_id:tenantId,p_buying_item_id:(await itemRequestItems(id))[0]?.id})});}catch(e){console.warn('Structured customer details unavailable:',e)} const customer=details?.customer||null; const customerCard=customer?'<div class="customer-contact"><h3>Customer</h3><div class="customer-contact-grid"><div><span>Customer</span><strong>'+esc([customer.first_name,customer.last_name].filter(Boolean).join(' ')||'—')+'</strong></div><div><span>Customer reference</span><strong>'+esc(customer.customer_reference||'—')+'</strong></div><div><span>Email</span><strong>'+esc(customer.email||'—')+'</strong></div><div><span>Phone</span><strong>'+esc(customer.phone||'—')+'</strong></div></div></div>':''; $('detail').innerHTML=notice+customerCard+'<div class="request-summary"><div class="summary-card"><span>Status</span><strong>'+esc(requestStatusLabel(r.status))+'</strong></div><div class="summary-card"><span>Offer / valuation</span><strong>'+money(r.offer_amount,r.offer_currency||'GBP')+'</strong></div><div class="summary-card"><span>Source</span><strong>'+esc(r.source==='customer_portal'?'Customer portal':r.source||'—')+'</strong></div><div class="summary-card"><span>Submitted</span><strong>'+(r.submitted_at?new Date(r.submitted_at).toLocaleString('en-GB'):'—')+'</strong></div></div>'+shippingHandoffHtml(r)+'<div class="customer-info"><h3>Customer supplied information</h3><p>All customer-provided information is shown here for valuation and review.</p>'+(r.notes?'<div class="customer-supplied"><h4>Request notes</h4><div class="supplied-text">'+esc(r.notes)+'</div></div>':'<div class="small">No request-level notes supplied.</div>')+'</div><h3>Items submitted</h3><div id="item-detail"><div class="empty">Loading items…</div></div>'; try{ const items=await api('/rest/v1/buying_items?select=id,item_reference,status,purchase_stage,title,description,quantity,category_id,branch_id,buying_product_id,item_condition,created_at&tenant_id=eq.'+encodeURIComponent(tenantId)+'&buying_request_id=eq.'+encodeURIComponent(id)+'&order=sort_order'); $('item-detail').innerHTML=items?.length?items.map(i=>renderItem(i,r,customer)).join(''):'<div class="empty">No items found.</div>'; bindItemActions(r); setTimeout(()=>window.tradeflowRefreshInspectionWorkspace?.(),0); }catch(e){$('item-detail').textContent=e.message||String(e);} }
async function updateOpenRequestStatus(r){const el=document.querySelector('.request-live-status');if(el)el.innerHTML='<span class="cell-label">Status</span><strong>'+esc(requestStatusLabel(r.status))+'</strong>';const notice=document.querySelector('.subscriber-action-notice');if(notice){const map={offer_ready:['sent','Manual offer sent — awaiting customer','The approved valuation has been sent as an offer. The customer can now accept or refuse it.'],awaiting_item:['sent','Shipping handoff sent — awaiting item from customer','The customer has the shipping instructions and has not yet confirmed the item is on its way.'],shipping:['sent','Item on its way — awaiting receipt','The customer has confirmed the item has been sent.'],received:['sent','Item received — inspection next','You have received the customer item. The next step is to inspect it.'],inspection:['sent','Inspection in progress','The item has been received and is now being inspected.'],testing:['sent','Testing required','The item is in the pre-acquisition testing route.'],repair:['sent','Repair required','The item is in the pre-acquisition repair route.'],return_pending:['refused','Return to customer','The item was refused during inspection and should be returned to the customer.'],final_offer_required:['sent','Inspection accepted — final offer required','The inspection was accepted. Prepare the final offer to the customer.'],final_offer_sent:['sent','Final offer sent — awaiting customer','The final offer has been sent and is awaiting the customer response.'],final_offer_accepted:['sent','Final offer accepted — payment required','The customer accepted the final offer. Record the bank payment before creating the acquisition.'],final_offer_refused:['refused','Final offer refused — return item','The customer refused the final offer. Return the item; do not create an acquisition.'],purchased:['sent','Purchase complete — acquisition created','The final offer was accepted and payment was recorded. The item is now in Inventory.'],offer_refused:['refused','Offer refused by customer','The customer has declined this offer.']};const n=map[r.status];if(n){notice.className='subscriber-action-notice '+n[0];notice.innerHTML='<strong>'+esc(n[1])+'</strong><span>'+esc(n[2])+'</span>';}}}
async function refreshBuyingStatus(){if(!tenantId||!key||!session?.access_token)return;try{
 const [requests,items,values,offers,acquisitions]=await Promise.all([
  api('/rest/v1/buying_requests?select=id,request_reference,status,source,notes,submitted_at,closed_at,created_at,customer_id&tenant_id=eq.'+encodeURIComponent(tenantId)+'&order=created_at.desc'),
  api('/rest/v1/buying_items?select=id,buying_request_id,title,item_reference,purchase_stage&tenant_id=eq.'+encodeURIComponent(tenantId)),
  api('/rest/v1/trading_values?select=buying_item_id,amount,cash_price,trade_in_price,currency,status&tenant_id=eq.'+encodeURIComponent(tenantId)+'&status=eq.approved'),
  api('/rest/v1/offers?select=id,buying_item_id,amount,currency,status,offer_reference,published_at,responded_at,offer_type&tenant_id=eq.'+encodeURIComponent(tenantId)+'&order=created_at.desc'),
  api('/rest/v1/acquisitions?select=id,acquisition_reference,status,source_offer_id&tenant_id=eq.'+encodeURIComponent(tenantId)+'&order=created_at.desc')
 ]);
 const itemByRequest=Object.fromEntries((items||[]).map(i=>[i.buying_request_id,i])),valueByItem=Object.fromEntries((values||[]).map(v=>[v.buying_item_id,v])),offerByItem=Object.fromEntries((offers||[]).map(o=>[o.buying_item_id,o])),acquisitionByOffer=Object.fromEntries((acquisitions||[]).filter(a=>a.source_offer_id).map(a=>[a.source_offer_id,a]));
 const enriched=(requests||[]).map(r=>{const i=itemByRequest[r.id],v=i&&valueByItem[i.id],o=i&&offerByItem[i.id],a=o&&acquisitionByOffer[o.id],existing=currentRequests.find(x=>x.id===r.id);const workflowStatus=i?.purchase_stage&&i.purchase_stage!=='none'?i.purchase_stage:(o?.status==='refused'?'offer_refused':o?.status==='published'?'offer_ready':v?'valued':r.status);return {...r,status:workflowStatus,customer_name:existing?.customer_name||'—',offer_amount:o?.amount??v?.cash_price??v?.amount??v?.trade_in_price??null,offer_currency:o?.currency??v?.currency??'GBP',acquisition:a,buying_item_id:i?.id||null,completed:Boolean(i?.purchase_stage==='purchased'||a?.status==='paid')}});
 const activeRequests=enriched.filter(r=>!r.completed&&r.status!=='closed');currentRequests=activeRequests;$('request-list').innerHTML=renderRequests(activeRequests);if($('request-count'))$('request-count').textContent=activeRequests.length+' active request'+(activeRequests.length===1?'':'s');if(openRequestId){const latest=activeRequests.find(x=>x.id===openRequestId);if(latest)updateOpenRequestStatus(latest);}
}catch(e){console.warn('Buying status refresh failed:',e)}}
async function itemRequestItems(requestId){return api('/rest/v1/buying_items?select=id&tenant_id=eq.'+encodeURIComponent(tenantId)+'&buying_request_id=eq.'+encodeURIComponent(requestId)+'&order=sort_order&limit=1')}
function renderCustomerSuppliedDescription(description){
 const normalized=String(description||'').replace(/\\r?\\n/g,'\\n').replace(/\\n/g,'\\n');
 const fieldPattern=/(Product type|Manufacturer|Model|Package|Condition|Missing items|Legal right to sell)\\s*:/gi;
 const matches=[...normalized.matchAll(fieldPattern)];
 const pairs=[];
 if(matches.length){
  matches.forEach((m,index)=>{
   const valueStart=m.index+m[0].length;
   const valueEnd=index+1<matches.length?matches[index+1].index:normalized.length;
   pairs.push([m[1].trim(),normalized.slice(valueStart,valueEnd).replace(/^\\s+|\\s+$/g,'')]);
  });
 }else{
  const lines=normalized.split(/\\n+/).map(x=>x.trim()).filter(Boolean);
  lines.forEach(line=>{
   const m=line.match(/^([^:]+):\\s*(.*)$/);
   if(m)pairs.push([m[1].trim(),m[2].trim()]);
  });
 }
 if(!pairs.length)return '<div class="supplied-text">'+esc(description||'No additional item description was supplied.')+'</div>';
 return '<div class="field-grid customer-general-details">'+pairs.map(p=>'<div><span class="cell-label">'+esc(p[0])+'</span><strong>'+esc(p[1]||'—')+'</strong></div>').join('')+'</div>';
}
function renderItem(i,request,customer){
 const customerName=[customer?.first_name,customer?.last_name].filter(Boolean).join(' ')||'Customer';
 const requestNotes=request?.notes||'';
 const submitted=String(i.status||'')==='submitted';
 const workflowGrid='<div class="workflow-grid"><div class="workflow-box"><h4>Catalogue & pricing</h4><div id="match-'+i.id+'" class="small">'+(i.buying_product_id?'Catalogue product linked.':'No subscriber catalogue product linked yet. Manual valuation is available below.')+'</div><label style="display:block;margin:10px 0">Condition<select id="condition-'+i.id+'" style="width:100%;padding:8px"><option value="">Select condition</option><option value="sealed" '+(i.item_condition==='sealed'?'selected':'')+'>Sealed</option><option value="opened_never_used" '+(i.item_condition==='opened_never_used'?'selected':'')+'>Opened, Never Used</option><option value="excellent" '+(i.item_condition==='excellent'?'selected':'')+'>Excellent</option><option value="good" '+(i.item_condition==='good'?'selected':'')+'>Good</option><option value="poor" '+(i.item_condition==='poor'?'selected':'')+'>Poor</option></select></label><div id="configured-price-'+i.id+'" class="small">Select the condition to calculate the configured buying price.</div><button type="button" data-action="calculate" data-id="'+i.id+'" style="margin-top:8px">Calculate automatic price</button></div><div class="workflow-box"><h4>Valuation & manual offer</h4><div id="offer-history-'+i.id+'" class="small">Loading current valuation and offer…</div><div id="offer-status-'+i.id+'" class="small" style="margin-top:8px">Automatic pricing takes priority when an automatic price is available. Otherwise enter the manual buying and trade-in offers below.</div><div class="money-grid" style="grid-template-columns:1fr 1fr;gap:12px;margin-top:10px"><div style="border:1px solid #d8dee5;border-radius:8px;padding:12px;background:#fff"><strong>Manual buyer offer</strong><div class="small" style="margin:4px 0 8px">Cash purchase price offered to the customer.</div><input id="offer-cash-'+i.id+'" type="number" min="0" step="0.01" placeholder="Buyer offer (£)" style="width:100%"></div><div style="border:1px solid #d8dee5;border-radius:8px;padding:12px;background:#fff"><strong>Manual trade-in offer</strong><div class="small" style="margin:4px 0 8px">Trade-in value offered against a retail purchase.</div><input id="offer-trade-'+i.id+'" type="number" min="0" step="0.01" placeholder="Trade-in offer (£)" style="width:100%"></div></div><button type="button" data-action="offer" data-id="'+i.id+'" style="margin-top:8px">Send manual offer to customer</button></div></div>'; return '<article class="item-workspace"><div class="item-header"><div><h3>'+esc(i.title||'Untitled')+'</h3><p><span class="cell-label">Item reference</span> '+esc(i.item_reference)+' · Customer: <strong>'+esc(customerName)+'</strong> · Status: <strong>'+esc(i.status)+'</strong> · Purchase stage: <strong>'+esc(i.purchase_stage||'none').replace(/_/g,' ')+'</strong> · Quantity: '+esc(i.quantity)+'</p></div><div class="actions">'+nextButtons(i)+'</div></div><section class="customer-review-stage submitted-stage"><div class="section-head"><div><h4>Review customer submission</h4><p class="small">Check the complete customer submission before moving it into valuation and offer review.</p></div><span class="status-pill '+requestStatusClass(i.status)+'">'+esc(requestStatusLabel(i.status))+'</span></div><div class="customer-contact-grid"><div><span>Customer</span><strong>'+esc(customerName)+'</strong></div><div><span>Customer reference</span><strong>'+esc(customer?.customer_reference||'—')+'</strong></div><div><span>Email</span><strong>'+esc(customer?.email||'—')+'</strong></div><div><span>Phone</span><strong>'+esc(customer?.phone||'—')+'</strong></div></div><div class="customer-supplied"><h4>Customer supplied product details</h4><p class="small"><strong>Everything below is information supplied by the customer. Use it when checking the item and setting the valuation.</strong></p>'+renderCustomerSuppliedDescription(i.description||'')+'<div class="field-grid customer-general-details"><div><span class="cell-label">Quantity</span><strong>'+esc(i.quantity??'1')+'</strong></div></div>'+(requestNotes?'<div class="supplied-request-notes"><span class="cell-label">Customer request notes</span><div class="supplied-text">'+esc(requestNotes)+'</div></div>':'')+'<div id="fields-'+i.id+'" class="small" style="margin-top:10px">Loading customer-supplied fields…</div></div><div id="photos-'+i.id+'" class="customer-photo-review"><h4>Photographs</h4><div class="small">Loading photographs…</div></div></section>'+ (submitted?'<section class="workflow-next-step"><h4>Review stage</h4><p>Check the customer details, supplied product information and photographs above. When everything is ready, move the item to review.</p><div class="actions">'+nextButtons(i)+'</div></section>':'<section class="valuation-offer-stage"><div class="section-head"><div><h4>Valuation & offer stage</h4><p class="small">The submission has been moved into review. Compare the research evidence, set the manual buyer/trade-in offer, then send it to the customer.</p></div></div>'+workflowGrid+'</section>')+'<div id="evidence-'+i.id+'" class="customer-info" style="margin-top:16px"><h4 style="margin:0 0 8px">Research evidence</h4><div class="small">Loading evidence…</div></div></article>';
}
function nextButtons(i){
 if(String(i.status||'')==='submitted')return '<button type="button" data-action="transition" data-id="'+i.id+'" data-from="submitted" data-to="under_review">START REVIEW</button>';
 return '';
}
async function loadItemFinancials(itemId,requestStatus=''){
 try{
  const values=await api('/rest/v1/trading_values?select=id,method,status,amount,currency,cash_price,trade_in_price,approved_at,notes&tenant_id=eq.'+encodeURIComponent(tenantId)+'&buying_item_id=eq.'+encodeURIComponent(itemId)+'&order=created_at.desc');
  const offers=await api('/rest/v1/offers?select=id,trading_value_id,offer_reference,offer_type,offer_mode,status,amount,currency,published_at,expires_at&tenant_id=eq.'+encodeURIComponent(tenantId)+'&buying_item_id=eq.'+encodeURIComponent(itemId)+'&order=created_at.desc');
  const approved=values?.find(v=>v.status==='approved');
  const automaticValueIds=new Set((values||[]).filter(v=>v.status==='approved'&&v.method==='automatic').map(v=>v.id));
  const automaticActive=(values||[]).some(v=>v.status==='approved'&&v.method==='automatic')||(offers||[]).some(o=>o.status==='published'&&o.offer_type==='initial'&&automaticValueIds.has(o.trading_value_id));
  const history=$('offer-history-'+itemId);
  const cashInput=$('offer-cash-'+itemId),tradeInput=$('offer-trade-'+itemId),sendButton=document.querySelector('[data-action="offer"][data-id="'+itemId+'"]'),statusBox=$('offer-status-'+itemId);
  if(history){
   history.innerHTML=(values?.length?'<div><strong>Latest valuation:</strong> '+(approved?('Buying '+money(approved.cash_price)+' / Trade-in '+money(approved.trade_in_price)):esc(values[0].status))+' · '+esc(approved?.method||values[0].method)+'</div>':'<div>No valuation recorded yet.</div>')+
    (offers?.length?'<div style="margin-top:8px"><strong>Offers:</strong> '+offers.map(o=>money(o.amount,o.currency)+' — '+esc(o.offer_mode==='trade_in'?'Trade-in':'Buyer')+' — '+(o.status==='published'?'sent':o.status)).join(' · ')+'</div>':'');
  }
  if(approved&&!automaticActive){
   if(cashInput&&cashInput.value==='')cashInput.value=approved.cash_price??'';
   if(tradeInput&&tradeInput.value==='')tradeInput.value=approved.trade_in_price??'';
  }
  if(automaticActive){
   if(statusBox)statusBox.innerHTML='<strong>Automatic pricing is active.</strong> The automatic buying/trade-in prices override manual initial offers.';
   if(cashInput)cashInput.disabled=true;
   if(tradeInput)tradeInput.disabled=true;
   if(sendButton)sendButton.disabled=true;
  }else if(statusBox){
   statusBox.textContent='No automatic initial offer is active. Compare the research evidence below, then enter the manual buyer and/or trade-in offer and send it to the customer.';
  }
 }catch(e){
  const el=$('offer-history-'+itemId);
  if(el)el.textContent=e.message||String(e);
 }
}
async function calculateConfiguredValuation(itemId,b){
 const condition=$('condition-'+itemId)?.value||'';
 if(!condition)return msg('Select the item condition before calculating the automatic price.','error');
 setBusy(b,true);
 try{
  await api('/rest/v1/buying_items?id=eq.'+encodeURIComponent(itemId)+'&tenant_id=eq.'+encodeURIComponent(tenantId),{method:'PATCH',headers:{Prefer:'return=minimal'},body:JSON.stringify({item_condition:condition})});
  const result=await api('/rest/v1/rpc/calculate_buying_item_valuation',{method:'POST',body:JSON.stringify({p_tenant_id:tenantId,p_buying_item_id:itemId})});
  const box=$('configured-price-'+itemId);
  if(result?.mode==='automatic'){
    if($('offer-cash-'+itemId))$('offer-cash-'+itemId).value=result.amount??'';
    if($('offer-trade-'+itemId))$('offer-trade-'+itemId).value=result.trade_in_amount??'';
    if(box)box.innerHTML='<strong>Automatic valuation available:</strong> '+money(result.amount)+' cash'+(result.trade_in_amount!=null?' / '+money(result.trade_in_amount)+' trade-in':'')+' — '+esc(result.percentage)+'%'+(result.trade_in_percentage!=null?' / '+esc(result.trade_in_percentage)+'% trade-in':'')+' of '+money(result.base_price)+' '+(result.reference_type==='uk_used'?'UK Used':'UK New')+' research. <span class="small">'+esc(result.source_name||'')+'</span>';
    await createAutomaticOffers(itemId,result);
  }else if(result?.mode==='manual'){
    try{await api('/rest/v1/rpc/queue_customer_manual_valuation_notification',{method:'POST',body:JSON.stringify({p_tenant_id:tenantId,p_buying_item_id:itemId})});}catch(e){console.warn('Manual valuation customer notification could not be queued:',e)}
  }else if(result?.mode==='manual_override'){
    if($('offer-cash-'+itemId))$('offer-cash-'+itemId).value=result.amount??'';
    if($('offer-trade-'+itemId))$('offer-trade-'+itemId).value=result.trade_in_amount??'';
    if(box)box.innerHTML='<strong>Manual override:</strong> '+money(result.amount)+(result.trade_in_amount!=null?' / '+money(result.trade_in_amount)+' trade-in':'')+' — this configured buying price overrides the percentage calculation for this condition.';
  }else{
    if(result?.amount!==null&&result?.amount!==undefined&&$('offer-cash-'+itemId))$('offer-cash-'+itemId).value=result.amount;
    if(result?.trade_in_amount!==null&&result?.trade_in_amount!==undefined&&$('offer-trade-'+itemId))$('offer-trade-'+itemId).value=result.trade_in_amount;
    if(box)box.innerHTML='<strong>Manual price required.</strong> '+esc(result.reason||'No automatic rule available.')+(result.amount!==null&&result.amount!==undefined?' Suggested/manual amount: '+money(result.amount):'');
  }
  await load();
 }catch(e){
  const box=$('configured-price-'+itemId);if(box)box.textContent=e.message||String(e);
 }finally{setBusy(b,false)}
}
async function loadItemMedia(itemId){
 try{
  const el=$('photos-'+itemId); if(!el)return;
  const links=await api('/rest/v1/buying_item_media?select=media_asset_id,sort_order&tenant_id=eq.'+encodeURIComponent(tenantId)+'&buying_item_id=eq.'+encodeURIComponent(itemId)+'&order=sort_order');
  const rows=Array.isArray(links)?links.filter(x=>x.media_asset_id):[];
  if(!rows.length){el.innerHTML='<h4>Photographs</h4><div class="small">No photographs were supplied with this submission.</div>';return;}
  const ids=rows.map(x=>x.media_asset_id);
  const assets=await api('/rest/v1/media_assets?select=id,original_filename,mime_type,storage_bucket,storage_path&tenant_id=eq.'+encodeURIComponent(tenantId)+'&id=in.('+ids.join(',')+')');
  const byId=Object.fromEntries((assets||[]).map(x=>[x.id,x]));
  const cards=[];
  for(const link of rows){
   const asset=byId[link.media_asset_id];
   if(!asset?.storage_path)continue;
   try{
    const url=await storageSignedUrl(asset.storage_path);
    cards.push('<figure class="customer-photo-card"><a href="'+esc(url)+'" target="_blank" rel="noopener"><img src="'+esc(url)+'" alt="'+esc(asset.original_filename||'Customer photograph')+'" loading="lazy"></a><figcaption>'+esc(asset.original_filename||'Customer photograph')+'</figcaption></figure>');
   }catch(e){cards.push('<div class="small error">Photograph could not be opened: '+esc(e.message||String(e))+'</div>');}
  }
  el.innerHTML='<h4>Photographs</h4>'+(cards.length?'<div class="customer-photo-grid">'+cards.join('')+'</div>':'<div class="small">Photographs were recorded but could not be loaded.</div>');
 }catch(e){
  const el=$('photos-'+itemId);
  if(el)el.innerHTML='<h4>Photographs</h4><div class="small error">Customer photographs could not be loaded: '+esc(e.message||String(e))+'</div>';
 }
}
async function loadCustomerFields(itemId){ try{ const el=$('fields-'+itemId); if(!el)return; const data=await api('/rest/v1/rpc/subscriber_get_buying_item_customer_details',{method:'POST',body:JSON.stringify({p_tenant_id:tenantId,p_buying_item_id:itemId})}); const fields=Array.isArray(data?.fields)?data.fields:[]; if(!fields.length){el.innerHTML='<div class="small">No category-specific customer fields are configured for this item category.</div>';return;} el.innerHTML='<div class="field-grid">'+fields.map(f=>'<div><span class="cell-label">'+esc(f.label||f.field_key||'Customer detail')+'</span><strong>'+esc(typeof f.value==='object'&&f.value!==null?JSON.stringify(f.value):f.value??'—')+'</strong></div>').join('')+'</div>'; }catch(e){const el=$('fields-'+itemId);if(el)el.innerHTML='<div class="small error">Customer supplied fields could not be loaded: '+esc(e.message||String(e))+'</div>';}}
async function loadResearchEvidence(itemId){ try{ const item=await api('/rest/v1/buying_items?select=buying_product_id,title&id=eq.'+encodeURIComponent(itemId)+'&tenant_id=eq.'+encodeURIComponent(tenantId)); const el=$('evidence-'+itemId); if(!el||!item?.length)return; const productId=item[0].buying_product_id; if(!productId){el.innerHTML='<h4 style="margin:0 0 8px">Research evidence</h4><div class="small">No subscriber catalogue product is linked to this item yet. Automatic pricing/offer rules and product-specific evidence cannot be applied until the item is matched.</div>';return;} const rows=await api('/rest/v1/tenant_buying_research?select=evidence_type,source_name,source_url,observed_price,price_currency,item_condition,availability,notes,checked_at&tenant_id=eq.'+encodeURIComponent(tenantId)+'&buying_product_id=eq.'+encodeURIComponent(productId)+'&order=checked_at.desc'); el.innerHTML='<h4 style="margin:0 0 8px">Research evidence</h4>'+(rows?.length?'<div class="evidence-list">'+rows.map(x=>'<div class="evidence-row"><div><strong>'+esc(x.source_name||'Research source')+'</strong><div class="meta">'+esc(x.evidence_type)+' · '+esc(x.item_condition||'condition not stated')+' · '+esc(x.availability||'')+'</div></div><div><strong>'+money(x.observed_price,x.price_currency)+'</strong></div><div>'+(x.source_url?'<a href="'+esc(x.source_url)+'" target="_blank" rel="noopener">Open evidence</a>':'')+'</div></div>').join('')+'</div>':'<div class="small">No research evidence has been recorded for the matched product.</div>'); }catch(e){const el=$('evidence-'+itemId);if(el)el.innerHTML='<h4 style="margin:0 0 8px">Research evidence</h4><div class="small error">'+esc(e.message||String(e))+'</div>';}} 
function bindItemActions(request){ document.querySelectorAll('[data-action="calculate"]').forEach(b=>b.onclick=()=>calculateConfiguredValuation(b.dataset.id,b)); document.querySelectorAll('[data-action="transition"]').forEach(b=>b.onclick=async()=>{setBusy(b,true);try{await transition('buying_item',b.dataset.id,b.dataset.from,b.dataset.to);msg(`Item moved to ${b.dataset.to}.`,'success');await load(); startBuyingStatusRefresh();}catch(e){msg(e.message||String(e),'error');}finally{setBusy(b,false);}}); document.querySelectorAll('[data-action="offer"]').forEach(b=>b.onclick=()=>createOffer(b.dataset.id,b)); document.querySelectorAll('.customer-photo-review').forEach(el=>{const id=el.id.replace(/^photos-/,'');loadItemMedia(id);}); document.querySelectorAll('[data-action="shipping"]').forEach(b=>b.onclick=()=>publishShippingHandoff(b.dataset.id,b));document.querySelectorAll('[id^="ship-method-"]').forEach(sel=>sel.addEventListener('change',()=>{const id=sel.id.replace('ship-method-','');const manual=sel.value!=='automated';const m=document.getElementById('ship-manual-'+id),c=document.getElementById('ship-connected-'+id);if(m)m.style.display=manual?'block':'none';if(c)c.style.display=manual?'none':'block';}));document.querySelectorAll('[data-action="upload-shipping"]').forEach(b=>b.onclick=()=>uploadShippingLabel(b.dataset.id,b));document.querySelectorAll('[data-action="upload-qr"]').forEach(b=>b.onclick=()=>uploadShippingQr(b.dataset.id,b));document.querySelectorAll('[data-action="qr-open"]').forEach(b=>b.onclick=()=>openShippingQr(b.dataset.id));document.querySelectorAll('[data-action="shipping-open"]').forEach(b=>b.onclick=()=>openShippingLabel(b.dataset.id));document.querySelectorAll('[data-action="shipping-print"]').forEach(b=>b.onclick=()=>printShippingAsset(b.dataset.id,'label',b));document.querySelectorAll('[data-action="shipping-download"]').forEach(b=>b.onclick=()=>downloadShippingAsset(b.dataset.id,'label',b));document.querySelectorAll('[data-action="qr-print"]').forEach(b=>b.onclick=()=>printShippingAsset(b.dataset.id,'qr',b));document.querySelectorAll('[data-action="qr-download"]').forEach(b=>b.onclick=()=>downloadShippingAsset(b.dataset.id,'qr',b));document.querySelectorAll('[data-action="shipping-resend"]').forEach(b=>b.onclick=()=>resendShippingHandoff(b.dataset.id,b));document.querySelectorAll('[data-action="acq-received"]').forEach(b=>b.onclick=()=>markBuyingItemReceived(b.dataset.id,b));  document.querySelectorAll('.item-workspace').forEach(w=>{const field=w.querySelector('[id^="fields-"]');const id=field?.id.replace('fields-','');if(id){loadCustomerFields(id);loadResearchEvidence(id);}});document.querySelectorAll('[id^="offer-history-"]').forEach(e=>{const id=e.id.replace('offer-history-','');loadItemFinancials(id,request?.status);}); }
document.addEventListener('click',e=>{const open=e.target.closest('[data-action="open-request"]');if(open){e.preventDefault();const id=open.dataset.id;if(id){showRequest(id,currentRequests).catch(err=>msg(err.message||String(err),'error'));}return;}const b=e.target.closest('[data-action="start-inspection"],[data-tf-inspect]');if(!b)return;e.preventDefault();if(b.disabled)return;startBuyingItemInspection(b.dataset.id||b.dataset.tfInspect,b);});
function setBusy(b,busy){b.disabled=busy;if(busy){b.dataset.label=b.textContent;b.textContent='Working…';}else if(b.dataset.label)b.textContent=b.dataset.label;}
async function supersedePublishedInitialOffers(itemId){
 const active=await api('/rest/v1/offers?select=id,offer_type,status&tenant_id=eq.'+encodeURIComponent(tenantId)+'&buying_item_id=eq.'+encodeURIComponent(itemId)+'&status=eq.published');
 for(const o of (active||[]))if(['initial','revised'].includes(o.offer_type))await transition('offer',o.id,'published','superseded','Replaced by a new initial offer.');
}
async function supersedeApprovedValuations(itemId){
 const active=await api('/rest/v1/trading_values?select=id,status&tenant_id=eq.'+encodeURIComponent(tenantId)+'&buying_item_id=eq.'+encodeURIComponent(itemId)+'&status=eq.approved');
 for(const v of (active||[]))await transition('trading_value',v.id,'approved','superseded','Replaced by a new valuation.');
}
async function advanceItemToOfferReady(itemId){
 const itemRows=await api('/rest/v1/buying_items?select=status&id=eq.'+encodeURIComponent(itemId)+'&tenant_id=eq.'+encodeURIComponent(tenantId));
 const itemStatus=itemRows?.[0]?.status;
 if(itemStatus==='valued')await transition('buying_item',itemId,'valued','offer_ready');
 else if(itemStatus==='under_review')await transition('buying_item',itemId,'under_review','valued').then(()=>transition('buying_item',itemId,'valued','offer_ready'));
 else if(itemStatus==='submitted')await transition('buying_item',itemId,'submitted','under_review').then(()=>transition('buying_item',itemId,'under_review','valued')).then(()=>transition('buying_item',itemId,'valued','offer_ready'));
 const requestId=await itemRequestId(itemId);
 if(requestId){
  const rr=await api('/rest/v1/buying_requests?select=status&id=eq.'+encodeURIComponent(requestId)+'&tenant_id=eq.'+encodeURIComponent(tenantId));
  const rs=rr?.[0]?.status;
  if(rs==='under_review')await transition('buying_request',requestId,'under_review','valued').then(()=>transition('buying_request',requestId,'valued','offer_ready'));
  else if(rs==='submitted')await transition('buying_request',requestId,'submitted','under_review').then(()=>transition('buying_request',requestId,'under_review','valued')).then(()=>transition('buying_request',requestId,'valued','offer_ready'));
 }
}
async function createInitialOffer(itemId,offerChoice,source='manual',valuationOverride=null){
 const cash=Number.isFinite(Number(offerChoice?.cash))?Number(offerChoice.cash):null;
 const trade=Number.isFinite(Number(offerChoice?.trade_in))?Number(offerChoice.trade_in):null;
 const mode=offerChoice?.mode==='trade_in'?'trade_in':(cash!==null?'cash':'trade_in');
 const amount=mode==='trade_in'?trade:cash;
 if(amount===null)throw Error('Enter a cash offer, a trade-in offer, or both.');
 await supersedePublishedInitialOffers(itemId);
 let valuation=valuationOverride;
 if(!valuation){
  const values=await api('/rest/v1/trading_values?select=id,status,method,amount,cash_price,trade_in_price&tenant_id=eq.'+encodeURIComponent(tenantId)+'&buying_item_id=eq.'+encodeURIComponent(itemId)+'&status=eq.approved&order=approved_at.desc&limit=1');
  valuation=values?.[0];
 }
 if(!valuation)throw Error('Approve the valuation before sending the initial offer.');
 const rows=await api('/rest/v1/offers',{method:'POST',headers:{Prefer:'return=representation'},body:JSON.stringify({tenant_id:tenantId,buying_item_id:itemId,trading_value_id:valuation.id,offer_reference:'OF-'+crypto.randomUUID().replaceAll('-','').slice(0,10).toUpperCase(),offer_type:'initial',offer_mode:mode,status:'draft',amount,currency:'GBP',created_by:session.user.id})});
 const offer=Array.isArray(rows)?rows[0]:rows;
 await transition('offer',offer.id,'draft','published',source==='automatic'?'Automatic initial offer published.':'Manual initial offer published.');
 await advanceItemToOfferReady(itemId);
 return offer;
}
async function createAutomaticOffers(itemId,result){
 try{
  await supersedePublishedInitialOffers(itemId);
  await supersedeApprovedValuations(itemId);
  const rows=await api('/rest/v1/trading_values',{method:'POST',headers:{Prefer:'return=representation'},body:JSON.stringify({tenant_id:tenantId,buying_item_id:itemId,method:'automatic',status:'draft',amount:Number(result.amount),currency:'GBP',cash_price:Number(result.amount),trade_in_price:Number.isFinite(Number(result.trade_in_amount))?Number(result.trade_in_amount):null,calculated_at:new Date().toISOString(),notes:'Automatic catalogue pricing',metadata:{source:'subscriber_buying_dashboard',valuation_source:'automatic'}})});
  const valuation=Array.isArray(rows)?rows[0]:rows;
  await transition('trading_value',valuation.id,'draft','approved','Automatic catalogue valuation approved.');
  await createInitialOffer(itemId,{cash:Number(result.amount),trade_in:Number(result.trade_in_amount),mode:Number.isFinite(Number(result.amount))?'cash':'trade_in'},'automatic',valuation);
  msg('Automatic valuation completed and the automatic cash/trade-in offer is now active. Manual initial offers are overridden.','success');
  await load();
 }catch(e){
  console.warn('Automatic offer could not be published:',e);
  const box=$('offer-status-'+itemId);if(box)box.textContent='Automatic valuation calculated, but the offer could not be published yet: '+(e.message||String(e));
 }
}
async function createOffer(itemId,b){
 const cash=parseFloat($('offer-cash-'+itemId)?.value);
 const trade=parseFloat($('offer-trade-'+itemId)?.value);
 if(!Number.isFinite(cash)&&!Number.isFinite(trade))return msg('Enter a manual buyer offer, a trade-in offer, or both.','error');
 setBusy(b,true);
 try{
  const stageRows=await api('/rest/v1/buying_items?select=purchase_stage&tenant_id=eq.'+encodeURIComponent(tenantId)+'&id=eq.'+encodeURIComponent(itemId));
  const purchaseStage=stageRows?.[0]?.purchase_stage||'none';
  if(['awaiting_item','shipping','received','inspection','testing','repair','final_offer_required','final_offer_sent','final_offer_accepted','purchased'].includes(purchaseStage))throw Error('The customer has already accepted the initial offer. The item is now in the receipt and inspection workflow.');
  const auto=await api('/rest/v1/trading_values?select=id&tenant_id=eq.'+encodeURIComponent(tenantId)+'&buying_item_id=eq.'+encodeURIComponent(itemId)+'&method=eq.automatic&status=eq.approved&limit=1');
  if(auto?.length)throw Error('Automatic pricing is active and overrides manual initial offers.');
  await supersedeApprovedValuations(itemId);
  const amount=Number.isFinite(cash)?cash:trade;
  const rows=await api('/rest/v1/trading_values',{method:'POST',headers:{Prefer:'return=representation'},body:JSON.stringify({tenant_id:tenantId,buying_item_id:itemId,method:'manual',status:'draft',amount,currency:'GBP',cash_price:Number.isFinite(cash)?cash:null,trade_in_price:Number.isFinite(trade)?trade:null,calculated_at:new Date().toISOString(),notes:'Manual buyer/trade-in offer',metadata:{source:'subscriber_buying_dashboard',valuation_source:'manual'}})});
  const valuation=Array.isArray(rows)?rows[0]:rows;
  await transition('trading_value',valuation.id,'draft','approved','Manual buyer/trade-in valuation approved.');
  await createInitialOffer(itemId,{cash,trade_in:trade,mode:Number.isFinite(cash)?'cash':'trade_in'},'manual',valuation);
  await load();
  msg('Manual buyer/trade-in offer sent to the customer. The customer can choose which offer to accept.','success');
 }catch(e){msg(e.message||String(e),'error');}finally{setBusy(b,false);}
}

async function itemRequestId(itemId){const rows=await api(`/rest/v1/buying_items?select=buying_request_id&id=eq.${encodeURIComponent(itemId)}&tenant_id=eq.${encodeURIComponent(tenantId)}`);return rows?.[0]?.buying_request_id;}
$('sign-out').addEventListener('click',()=>{ if(window.tradeflowSubscriberSignOut) window.tradeflowSubscriberSignOut(); else location.href='subscriber-login.html'; }); load(); startBuyingStatusRefresh();
function startBuyingStatusRefresh(){if(statusRefreshTimer)clearInterval(statusRefreshTimer);statusRefreshTimer=setInterval(refreshBuyingStatus,10000);document.addEventListener('visibilitychange',()=>{if(!document.hidden)refreshBuyingStatus()});}
