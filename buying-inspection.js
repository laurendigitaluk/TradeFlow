/* TradeFlow Purchasing Inspection Workspace
   Pre-acquisition workflow. No acquisition or inventory asset is created until the final offer is accepted and bank payment is recorded. */
(function(){
  const SUPABASE_URL='https://twfbmjwwqzxdxvclxbun.supabase.co';
  let key=null,session=null,tenantId=null,authReady=null,lastReference='',busy=false;

  const $=id=>document.getElementById(id);
  const esc=v=>String(v??'').replace(/[&<>\"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','\"':'&quot;',"'":'&#39;'}[c]));
  const api=async(path,options={})=>{
    const h=new Headers(options.headers||{});
    h.set('apikey',key);h.set('Content-Type','application/json');
    if(session?.access_token)h.set('Authorization','Bearer '+session.access_token);
    const r=await fetch(SUPABASE_URL+path,{...options,headers:h});
    const text=await r.text();let b=null;try{b=text?JSON.parse(text):null}catch{b=text}
    if(!r.ok)throw Error(b?.message||b?.msg||b?.error||text||('HTTP '+r.status));
    return b;
  };
  const storageUpload=async(path,file)=>{
    const r=await fetch(SUPABASE_URL+'/storage/v1/object/tradeflow-media/'+path,{method:'POST',headers:{apikey:key,Authorization:'Bearer '+(session?.access_token||''),'Content-Type':file.type,'x-upsert':'false'},body:file});
    const text=await r.text();let b=null;try{b=text?JSON.parse(text):null}catch{b=text}
    if(!r.ok)throw Error(b?.message||b?.error||text||'Inspection photograph upload failed.');
    return b;
  };
  const msg=(text,type='')=>{const el=$('message');if(el){el.className=('small '+type).trim();el.textContent=text||'';}};

  async function auth(){
    if(authReady)return authReady;
    authReady=(async()=>{
      const a=await window.tradeflowSubscriberAuthReady;
      if(!a?.session?.access_token||!a?.key||!a?.tenantId)throw Error('Subscriber authentication is not available.');
      key=a.key;session=a.session;tenantId=a.tenantId;
    })();
    return authReady;
  }

  async function currentWorkflow(){
    await auth(); const title=($('detail-title')?.textContent||'').trim(); if(!title)return null;
    const requests=await api('/rest/v1/buying_requests?select=id,request_reference,status,notes,customer_id&tenant_id=eq.'+encodeURIComponent(tenantId)+'&request_reference=eq.'+encodeURIComponent(title)+'&limit=1');
    const request=requests?.[0]; if(!request)return null;
    const items=await api('/rest/v1/buying_items?select=id,item_reference,title,description,quantity,category_id,branch_id,buying_product_id,item_condition,status,purchase_stage,item_received_at,inspection_completed_at,final_offer_accepted_at,purchased_at&tenant_id=eq.'+encodeURIComponent(tenantId)+'&buying_request_id=eq.'+encodeURIComponent(request.id)+'&order=sort_order');
    const out=[]; for(const item of (items||[])){const offers=await api('/rest/v1/offers?select=id,offer_reference,offer_type,status,amount,currency,published_at,responded_at,response_notes&tenant_id=eq.'+encodeURIComponent(tenantId)+'&buying_item_id=eq.'+encodeURIComponent(item.id)+'&order=created_at.desc');const initial=offers?.find(o=>o.offer_type==='initial')||offers?.[0];const final=offers?.find(o=>o.offer_type==='final'&&(o.status==='published'||o.status==='accepted'||o.status==='refused'))||offers?.find(o=>o.offer_type==='final');out.push({request,item,offer:initial,finalOffer:final});} return out;
  }

  function replaceNotice(row){
    // The main Buying dashboard owns the workflow notice and START INSPECTION CTA.
    // This workspace must not rewrite that DOM every polling cycle.
  }

  async function startInspection(id){
    if(busy)return; busy=true;
    try{await api('/rest/v1/rpc/subscriber_start_buying_item_inspection',{method:'POST',body:JSON.stringify({p_tenant_id:tenantId,p_buying_item_id:id})});location.reload();}
    catch(e){msg(e.message||String(e),'error');busy=false}
  }

  async function uploadPhoto(file,buyingItemId,index){
    if(!file.type.startsWith('image/'))throw Error(file.name+' is not an image.'); if(file.size>10*1024*1024)throw Error(file.name+' is larger than 10MB.');
    const ext=(file.name.split('.').pop()||'jpg').toLowerCase().replace(/[^a-z0-9]/g,'')||'jpg';const path=tenantId+'/buying-items/'+buyingItemId+'/inspection-'+crypto.randomUUID()+'.'+ext;
    await storageUpload(path,file);
    const rows=await api('/rest/v1/media_assets',{method:'POST',headers:{Prefer:'return=representation'},body:JSON.stringify({tenant_id:tenantId,storage_bucket:'tradeflow-media',storage_path:path,original_filename:file.name,mime_type:file.type,byte_size:file.size,asset_kind:'inspection_photo',retention_policy:'sold_90_days_after_sale',created_by:session?.user?.id||null})});
    const media=Array.isArray(rows)?rows[0]:rows;if(!media?.id)throw Error('Inspection photograph metadata could not be created.');
    await api('/rest/v1/buying_item_media',{method:'POST',body:JSON.stringify({tenant_id:tenantId,buying_item_id:buyingItemId,media_asset_id:media.id,sort_order:index})});
  }

  async function renderInspection(row){
    const host=$('item-detail');if(!host)return;
    let media=[];
    try{
      media=(await api('/rest/v1/buying_item_media?select=id&tenant_id=eq.'+encodeURIComponent(tenantId)+'&buying_item_id=eq.'+encodeURIComponent(row.item.id)))||[];
    }catch(e){
      console.warn('TradeFlow inspection media lookup failed; continuing without media:',e);
    }
    let structured=[];try{const details=await api('/rest/v1/rpc/subscriber_get_buying_item_customer_details',{method:'POST',body:JSON.stringify({p_tenant_id:tenantId,p_buying_item_id:row.item.id})});structured=Array.isArray(details?.fields)?details.fields:[]}catch{}
    const section=document.createElement('section');section.id='tradeflow-inspection-workspace';section.style.cssText='margin-top:18px;border:1px solid #d8dee5;border-radius:10px;background:#fff;padding:18px;';
    const stage=row.item.purchase_stage;
    if(stage==='received'){
      section.innerHTML='<div class="cell-label">PURCHASING INSPECTION</div><h2 style="margin:4px 0 8px">Item received — inspection next</h2><p>The customer item has been received but has <strong>not</strong> become an acquisition or inventory asset. Start the inspection to record the physical checks.</p><button type="button" id="tf-start-inspection">START INSPECTION</button>';
      section.querySelector('#tf-start-inspection').onclick=()=>startInspection(row.item.id);
    }else if(stage==='inspection'){
      const fieldHtml=structured.length?'<div class="field-grid">'+structured.map(f=>'<div><span class="cell-label">'+esc(f.label||f.field_key)+'</span><strong>'+esc(typeof f.value==='object'&&f.value!==null?JSON.stringify(f.value):f.value??'—')+'</strong></div>').join('')+'</div>':'<div class="small">No structured category fields were supplied. Use the request information and item description above as the customer record.</div>';
      section.innerHTML='<div class="cell-label">PURCHASING INSPECTION</div><h2 style="margin:4px 0 8px">Inspect item before any purchase</h2><p class="small">The item is still the customer\'s property at this stage. A passed inspection only creates a <strong>final offer</strong>; it does not create an acquisition or inventory asset.</p>'+
        '<div class="customer-supplied" style="margin-top:14px"><h3>Customer supplied information</h3><div class="supplied-text">'+esc(row.item.description||'No item description supplied.')+'</div><div style="margin-top:8px"><span class="cell-label">Request notes</span><div class="supplied-text">'+esc(row.request.notes||'No request notes supplied.')+'</div></div><div style="margin-top:10px">'+fieldHtml+'</div></div>'+
        '<div class="form-grid" style="margin-top:16px"><label><strong>Customer description matches</strong><select id="tf-description"><option value="">Select…</option><option value="yes">Yes — matches</option><option value="no">No — discrepancy found</option></select></label><label><strong>Condition matches customer declaration</strong><select id="tf-condition-match"><option value="">Select…</option><option value="yes">Yes — matches</option><option value="no">No — discrepancy found</option></select></label><label><strong>Package / accessories</strong><select id="tf-accessories"><option value="">Select…</option><option value="pass">Complete</option><option value="fail">Missing / incorrect</option><option value="na">Not applicable</option></select></label><label><strong>Serial / model verification</strong><select id="tf-serial"><option value="">Select…</option><option value="pass">Verified</option><option value="fail">Mismatch / unable to verify</option><option value="na">Not applicable</option></select></label><label><strong>Physical condition / damage</strong><select id="tf-physical"><option value="">Select…</option><option value="pass">No material issue</option><option value="fail">Damage / defect found</option><option value="na">Not applicable</option></select></label><label><strong>Function / technical test</strong><select id="tf-function"><option value="">Select…</option><option value="pass">Passed</option><option value="fail">Failed / fault found</option><option value="na">Not applicable</option></select></label><label><strong>Inspector condition grade</strong><select id="tf-grade"><option value="">Select grade…</option><option value="A">A</option><option value="B">B</option><option value="C">C</option><option value="D">D</option></select></label><label><strong>Inspection outcome</strong><select id="tf-outcome"><option value="">Select next route…</option><option value="accepted">Accept — continue to final offer</option><option value="testing_required">Send to Testing</option><option value="repair_required">Requires Repair</option><option value="refused">Refuse — return to customer</option></select></label><label class="full"><strong>Discrepancies / missing items / faults</strong><textarea id="tf-discrepancies" rows="4"></textarea></label><label class="full"><strong>Inspection notes</strong><textarea id="tf-notes" rows="4"></textarea></label></div><div class="customer-info" style="margin-top:14px"><h3>Inspection photographs</h3><input id="tf-photos" type="file" accept="image/jpeg,image/png,image/webp" multiple><p class="small">'+media.length+' existing inspection photograph(s).</p></div><div class="actions" style="margin-top:16px"><button type="button" id="tf-complete">COMPLETE INSPECTION</button></div><p class="small" style="margin-top:10px">Accepted = final offer required. Refused = return to customer. Testing and repair remain outside Acquisitions and Inventory.</p>';
      section.querySelector('#tf-complete').onclick=async()=>{if(busy)return;const v=id=>section.querySelector('#'+id)?.value||'';const description=v('tf-description'),conditionMatch=v('tf-condition-match'),accessories=v('tf-accessories'),serial=v('tf-serial'),physical=v('tf-physical'),functional=v('tf-function'),grade=v('tf-grade'),outcome=v('tf-outcome'),discrepancies=v('tf-discrepancies').trim(),notes=v('tf-notes').trim();if(!description||!conditionMatch||!accessories||!serial||!physical||!functional||!grade||!outcome)return msg('Complete every inspection check and choose the outcome before continuing.','error');if(outcome==='accepted'&&[description,conditionMatch,accessories,serial,physical,functional].some(x=>x==='no'||x==='fail'))return msg('The item cannot be accepted while an inspection check has failed. Use Testing, Repair or Refuse instead.','error');busy=true;section.querySelector('#tf-complete').disabled=true;try{const files=[...(section.querySelector('#tf-photos')?.files||[])];for(let i=0;i<files.length;i++)await uploadPhoto(files[i],row.item.id,media.length+i);const metadata={customer_description_confirmed:description==='yes',condition_confirmed:conditionMatch==='yes',checks:{package_accessories:accessories,serial_verification:serial,physical_condition:physical,functional_test:functional},description_comparison:description,discrepancies,source:'subscriber_buying_inspection'};await api('/rest/v1/rpc/subscriber_complete_buying_item_inspection',{method:'POST',body:JSON.stringify({p_tenant_id:tenantId,p_buying_item_id:row.item.id,p_condition_grade:grade,p_passed:outcome==='accepted',p_outcome:outcome,p_notes:notes,p_metadata:metadata})});location.reload();}catch(e){msg(e.message||String(e),'error');busy=false;section.querySelector('#tf-complete').disabled=false}};
    }else if(stage==='final_offer_required'){
      section.innerHTML='<div class="cell-label">FINAL OFFER</div><h2 style="margin:4px 0 8px">Inspection accepted — final offer required</h2><p>The item passed inspection. It is still outside Acquisitions and Inventory. Enter the final amount and send the customer a separate final offer.</p><div class="workflow-box" style="margin-top:14px"><label><strong>Final offer amount (£)</strong><input id="tf-final-offer-amount" type="number" min="0" step="0.01" value="'+esc(row.offer?.amount??'')+'"></label><label style="display:block;margin-top:10px"><strong>Final offer notes</strong><textarea id="tf-final-offer-notes" rows="4"></textarea></label><div class="actions" style="margin-top:12px"><button type="button" id="tf-send-final-offer">SEND FINAL OFFER TO CUSTOMER</button></div></div>';
      section.querySelector('#tf-send-final-offer').onclick=async()=>{const amount=Number(section.querySelector('#tf-final-offer-amount')?.value),notes=(section.querySelector('#tf-final-offer-notes')?.value||'').trim();if(!Number.isFinite(amount)||amount<0)return msg('Enter a valid final offer amount.','error');if(busy)return;busy=true;const btn=section.querySelector('#tf-send-final-offer');btn.disabled=true;btn.textContent='Sending…';try{await api('/rest/v1/rpc/subscriber_publish_final_offer',{method:'POST',body:JSON.stringify({p_tenant_id:tenantId,p_buying_item_id:row.item.id,p_amount:amount,p_notes:notes||null})});location.reload();}catch(e){msg(e.message||String(e),'error');busy=false;btn.disabled=false;btn.textContent='SEND FINAL OFFER TO CUSTOMER'}};
    }else if(['final_offer_sent','final_offer_accepted','final_offer_refused'].includes(stage)){
      const f=row.finalOffer;const amount=f?.amount!=null?new Intl.NumberFormat('en-GB',{style:'currency',currency:f.currency||'GBP'}).format(Number(f.amount)):'—';
      if(stage==='final_offer_accepted'){
        section.innerHTML='<div class="cell-label">PAYMENT REQUIRED</div><h2 style="margin:4px 0 8px">Customer accepted the final offer</h2><p>The customer accepted <strong>'+esc(amount)+'</strong>. No acquisition or inventory record exists yet. Record the bank payment below. Only this step creates the acquisition and inventory asset.</p><div class="workflow-box" style="margin-top:14px"><label><strong>Payment method</strong><input id="tf-payment-method" type="text" value="Bank transfer"></label><label style="display:block;margin-top:10px"><strong>Bank payment reference</strong><input id="tf-payment-reference" type="text"></label><label style="display:block;margin-top:10px"><strong>Payment notes</strong><textarea id="tf-payment-notes" rows="3"></textarea></label><div class="actions" style="margin-top:12px"><button type="button" id="tf-complete-purchase">PAY CUSTOMER &amp; CREATE ACQUISITION</button></div></div>';
        section.querySelector('#tf-complete-purchase').onclick=async()=>{if(busy)return;const method=(section.querySelector('#tf-payment-method')?.value||'').trim(),reference=(section.querySelector('#tf-payment-reference')?.value||'').trim(),notes=(section.querySelector('#tf-payment-notes')?.value||'').trim();if(!method||!reference)return msg('Enter the payment method and bank payment reference before completing the purchase.','error');busy=true;const btn=section.querySelector('#tf-complete-purchase');btn.disabled=true;btn.textContent='Recording payment…';try{await api('/rest/v1/rpc/subscriber_complete_purchase',{method:'POST',body:JSON.stringify({p_tenant_id:tenantId,p_buying_item_id:row.item.id,p_payment_method:method,p_payment_reference:reference,p_payment_notes:notes||null})});location.reload();}catch(e){msg(e.message||String(e),'error');busy=false;btn.disabled=false;btn.textContent='PAY CUSTOMER & CREATE ACQUISITION'}};
      }else if(stage==='final_offer_refused'){section.innerHTML='<div class="cell-label">RETURN TO CUSTOMER</div><h2 style="margin:4px 0 8px">Final offer refused</h2><p>The customer has refused the final offer. The item has not become an acquisition and no inventory asset has been created.</p><div class="workflow-box"><strong>Next step: return the item to the customer.</strong></div>';
      }else section.innerHTML='<div class="cell-label">FINAL OFFER SENT</div><h2 style="margin:4px 0 8px">Awaiting customer response</h2><p>Final offer <strong>'+esc(f?.offer_reference||'—')+'</strong> has been sent for <strong>'+esc(amount)+'</strong>. The item remains outside Acquisitions and Inventory.</p><div class="workflow-box"><strong>Waiting for the customer to accept or refuse the final offer.</strong></div>';
    }else if(stage==='testing'||stage==='repair'){
      section.innerHTML='<div class="cell-label">'+(stage==='testing'?'TESTING':'REPAIR')+'</div><h2 style="margin:4px 0 8px">'+(stage==='testing'?'Testing required':'Repair required')+'</h2><p>This item remains in the pre-acquisition purchasing workflow. It has not been purchased and must not appear in Inventory.</p>';
    }else if(stage==='return_pending'){
      section.innerHTML='<div class="cell-label">RETURN TO CUSTOMER</div><h2 style="margin:4px 0 8px">Item refused — return required</h2><p>The item was refused during inspection. It has not become an acquisition and must not enter Inventory.</p>';
    }else if(stage==='purchased'){
      section.innerHTML='<div class="cell-label">PURCHASE COMPLETE</div><h2 style="margin:4px 0 8px">Purchased and moved into Inventory</h2><p>The final offer was accepted, payment was recorded, and the acquisition/inventory record was created.</p>';
    }else return;
    const existing=$('tradeflow-inspection-workspace');if(existing)existing.remove();host.appendChild(section);
  }

  async function sync(){
    try{
      await auth();
      const rows=await currentWorkflow();
      if(!rows?.length)return false;
      await renderInspection(rows[0]);
      return !!$('tradeflow-inspection-workspace');
    }catch(e){
      console.warn('TradeFlow purchasing inspection workspace:',e);
      msg('Inspection workspace could not be loaded: '+(e?.message||String(e)),'error');
      return false;
    }
  }
  window.tradeflowRefreshInspectionWorkspace=sync;
  const start=()=>{
    if(!$('detail'))return;
    if($('item-detail'))sync();
    else{
      const detail=$('detail');
      const observer=new MutationObserver(()=>{
        if($('item-detail')){
          observer.disconnect();
          sync();
        }
      });
      observer.observe(detail,{childList:true,subtree:true});
    }
  };
  if(document.readyState==='loading')document.addEventListener('DOMContentLoaded',start);else start();
})();