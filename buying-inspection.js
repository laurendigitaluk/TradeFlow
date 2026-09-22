/* TradeFlow Purchasing Inspection Workspace
   Authoritative editor for received acquisitions. Sales consumes the completed inspection read-only. */
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
    await auth();
    const title=($('detail-title')?.textContent||'').trim();
    if(!title)return null;
    if(title===lastReference)return null;
    const requests=await api('/rest/v1/buying_requests?select=id,request_reference,status,notes,customer_id&tenant_id=eq.'+encodeURIComponent(tenantId)+'&request_reference=eq.'+encodeURIComponent(title)+'&limit=1');
    const request=requests?.[0];
    if(!request)return null;
    const items=await api('/rest/v1/buying_items?select=id,item_reference,title,description,quantity,category_id,branch_id,buying_product_id,item_condition,status&tenant_id=eq.'+encodeURIComponent(tenantId)+'&buying_request_id=eq.'+encodeURIComponent(request.id)+'&order=sort_order');
    const out=[];
    for(const item of (items||[])){
      const offers=await api('/rest/v1/offers?select=id,status,amount,currency&tenant_id=eq.'+encodeURIComponent(tenantId)+'&buying_item_id=eq.'+encodeURIComponent(item.id)+'&order=created_at.desc&limit=1');
      const offer=offers?.[0];
      if(!offer)continue;
      const acqs=await api('/rest/v1/acquisitions?select=id,acquisition_reference,status,source_offer_id,agreed_total,currency,received_at,finalised_at&tenant_id=eq.'+encodeURIComponent(tenantId)+'&source_offer_id=eq.'+encodeURIComponent(offer.id)+'&limit=1');
      const acquisition=acqs?.[0];
      if(acquisition)out.push({request,item,offer,acquisition});
    }
    lastReference=title;
    return out;
  }

  function replaceNotice(row){
    const notice=document.querySelector('.subscriber-action-notice');
    if(!notice||!row)return;
    const a=row.acquisition;
    if(a.status==='received'){
      notice.className='subscriber-action-notice action';
      notice.innerHTML='<strong>Next step required — you\'ve received the item, inspect it</strong><span>Compare the item with the customer\'s submitted information, record the inspection and then send it to the next stage.</span><div class="actions" style="margin-top:10px"><button type="button" data-tf-inspect="'+esc(a.id)+'">START INSPECTION</button></div>';
    }else if(a.status==='inspection'){
      notice.className='subscriber-action-notice action';
      notice.innerHTML='<strong>Next step required — inspect the item</strong><span>The item is now in Purchasing inspection. Complete the inspection below before it can move to Sales.</span>';
    }else if(a.status==='finalised'){
      notice.className='subscriber-action-notice sent';
      notice.innerHTML='<strong>Inspection complete — ready for Sales</strong><span>The item has passed inspection and has been moved into the Sales-ready inventory workflow.</span>';
    }
  }

  async function startInspection(id){
    if(busy)return;busy=true;
    try{
      await api('/rest/v1/rpc/subscriber_start_acquisition_inspection',{method:'POST',body:JSON.stringify({p_tenant_id:tenantId,p_acquisition_id:id})});
      msg('Inspection started.','success');
      location.reload();
    }catch(e){msg(e.message||String(e),'error');busy=false}
  }

  async function uploadPhoto(file,assetId,index){
    if(!file.type.startsWith('image/'))throw Error(file.name+' is not an image.');
    if(file.size>10*1024*1024)throw Error(file.name+' is larger than 10MB.');
    const ext=(file.name.split('.').pop()||'jpg').toLowerCase().replace(/[^a-z0-9]/g,'')||'jpg';
    const path=tenantId+'/inventory/'+assetId+'/inspection-'+crypto.randomUUID()+'.'+ext;
    await storageUpload(path,file);
    const rows=await api('/rest/v1/media_assets',{method:'POST',headers:{Prefer:'return=representation'},body:JSON.stringify({
      tenant_id:tenantId,storage_bucket:'tradeflow-media',storage_path:path,original_filename:file.name,
      mime_type:file.type,byte_size:file.size,asset_kind:'inspection_photo',retention_policy:'sold_90_days_after_sale',
      created_by:session?.user?.id||null
    })});
    const media=Array.isArray(rows)?rows[0]:rows;
    if(!media?.id)throw Error('Inspection photograph metadata could not be created.');
    await api('/rest/v1/inventory_asset_media',{method:'POST',body:JSON.stringify({tenant_id:tenantId,inventory_asset_id:assetId,media_asset_id:media.id,sort_order:index})});
  }

  async function renderInspection(row){
    const host=$('item-detail');if(!host)return;
    let ai=(await api('/rest/v1/acquisition_items?select=id,status&tenant_id=eq.'+encodeURIComponent(tenantId)+'&acquisition_id=eq.'+encodeURIComponent(row.acquisition.id)+'&buying_item_id=eq.'+encodeURIComponent(row.item.id)+'&limit=1'))?.[0];
    let asset=ai?(await api('/rest/v1/inventory_assets?select=id,status,asset_reference,condition_grade,customer_condition,description,serial_number,notes&tenant_id=eq.'+encodeURIComponent(tenantId)+'&acquisition_item_id=eq.'+encodeURIComponent(ai.id)+'&order=created_at.desc&limit=1'))?.[0]:null;
    let inspections=asset?(await api('/rest/v1/inventory_inspections?select=id,outcome,condition_grade,notes,passed,inspected_at,metadata&tenant_id=eq.'+encodeURIComponent(tenantId)+'&inventory_asset_id=eq.'+encodeURIComponent(asset.id)+'&order=created_at.desc'))||[]:[];
    const latest=inspections[0]||null;
    let structured=[];
    try{
      const details=await api('/rest/v1/rpc/subscriber_get_buying_item_customer_details',{method:'POST',body:JSON.stringify({p_tenant_id:tenantId,p_buying_item_id:row.item.id})});
      structured=Array.isArray(details?.fields)?details.fields:[];
    }catch{}
    let existingPhotos=0;
    if(asset){
      const media=await api('/rest/v1/inventory_asset_media?select=id&tenant_id=eq.'+encodeURIComponent(tenantId)+'&inventory_asset_id=eq.'+encodeURIComponent(asset.id));
      existingPhotos=(media||[]).length;
    }

    const section=document.createElement('section');
    section.id='tradeflow-inspection-workspace';
    section.style.cssText='margin-top:18px;border:1px solid #d8dee5;border-radius:10px;background:#fff;padding:18px;';
    if(row.acquisition.status==='received'&&!asset){
      section.innerHTML='<div class="cell-label">PURCHASING INSPECTION</div><h2 style="margin:4px 0 8px">Item received — inspection next</h2><p>Start the inspection to create the linked inventory record and open the full inspection workspace.</p><button type="button" data-tf-inspect="'+esc(row.acquisition.id)+'">START INSPECTION</button>';
    }else if(row.acquisition.status==='inspection'&&asset){
      const fieldHtml=structured.length?'<div class="field-grid">'+structured.map(f=>'<div><span class="cell-label">'+esc(f.label||f.field_key)+'</span><strong>'+esc(typeof f.value==='object'&&f.value!==null?JSON.stringify(f.value):f.value??'—')+'</strong></div>').join('')+'</div>':'<div class="small">No structured category fields were supplied. Use the request information and item description above as the customer record.</div>';
      section.innerHTML='<div class="cell-label">PURCHASING INSPECTION</div><h2 style="margin:4px 0 8px">Inspect item before Sales</h2><p class="small">The customer record below is read-only. Compare the physical item against it and record the actual condition, discrepancies, serial/accessories and testing results.</p>'+
        '<div class="customer-supplied" style="margin-top:14px"><h3>Customer supplied information</h3><div class="supplied-text">'+esc(row.item.description||'No item description supplied.')+'</div><div class="supplied-request-notes" style="margin-top:8px"><span class="cell-label">Request notes</span><div class="supplied-text">'+esc(row.request.notes||'No request notes supplied.')+'</div></div><div style="margin-top:10px">'+fieldHtml+'</div></div>'+
        '<div class="form-grid" style="margin-top:16px">'+
        '<label><strong>Customer description matches</strong><select id="tf-description"><option value="">Select…</option><option value="yes">Yes — matches</option><option value="no">No — discrepancy found</option></select></label>'+
        '<label><strong>Condition matches customer declaration</strong><select id="tf-condition-match"><option value="">Select…</option><option value="yes">Yes — matches</option><option value="no">No — discrepancy found</option></select></label>'+
        '<label><strong>Package / accessories</strong><select id="tf-accessories"><option value="">Select…</option><option value="pass">Complete</option><option value="fail">Missing / incorrect</option><option value="na">Not applicable</option></select></label>'+
        '<label><strong>Serial / model verification</strong><select id="tf-serial"><option value="">Select…</option><option value="pass">Verified</option><option value="fail">Mismatch / unable to verify</option><option value="na">Not applicable</option></select></label>'+
        '<label><strong>Physical condition / damage</strong><select id="tf-physical"><option value="">Select…</option><option value="pass">No material issue</option><option value="fail">Damage / defect found</option><option value="na">Not applicable</option></select></label>'+
        '<label><strong>Function / technical test</strong><select id="tf-function"><option value="">Select…</option><option value="pass">Passed</option><option value="fail">Failed / fault found</option><option value="na">Not applicable</option></select></label>'+
        '<label><strong>Inspector condition grade</strong><select id="tf-grade"><option value="">Select grade…</option><option value="A">A</option><option value="B">B</option><option value="C">C</option><option value="D">D</option></select></label>'+
        '<label><strong>Inspection outcome</strong><select id="tf-outcome"><option value="">Select next route…</option><option value="ready_for_sale">Pass inspection — send to Sales</option><option value="testing_required">Requires Testing</option><option value="repair_required">Requires Repair</option><option value="not_as_described">Not as described — hold for review</option></select></label>'+
        '<label class="full"><strong>Discrepancies / missing items / faults</strong><textarea id="tf-discrepancies" rows="4" placeholder="Record anything that differs from the customer description, condition or package contents."></textarea></label>'+
        '<label class="full"><strong>Inspection notes</strong><textarea id="tf-notes" rows="4" placeholder="Record tests performed and relevant technical findings."></textarea></label></div>'+
        '<div class="customer-info" style="margin-top:14px"><h3>Inspection photographs</h3><input id="tf-photos" type="file" accept="image/jpeg,image/png,image/webp" multiple><p class="small">'+existingPhotos+' existing inspection photograph(s). Add photographs of the item, serial number, condition and any defects.</p></div>'+
        '<div class="actions" style="margin-top:16px"><button type="button" id="tf-complete">COMPLETE INSPECTION &amp; CONTINUE</button></div>'+
        '<p class="small" style="margin-top:10px">The original accepted offer is not changed by inspection. A passed inspection moves the inventory asset to <strong>Ready for Resale</strong> and the completed inspection is read-only for Sales. Repair/testing routes remain in Purchasing/Repairs.</p>';
      section.querySelector('#tf-complete').onclick=async()=>{
        if(busy)return;
        const v=id=>section.querySelector('#'+id)?.value||'';
        const description=v('tf-description'),conditionMatch=v('tf-condition-match'),accessories=v('tf-accessories'),serial=v('tf-serial'),physical=v('tf-physical'),functional=v('tf-function'),grade=v('tf-grade'),outcome=v('tf-outcome');
        const discrepancies=v('tf-discrepancies').trim(),notes=v('tf-notes').trim();
        if(!description||!conditionMatch||!accessories||!serial||!physical||!functional||!grade||!outcome)return msg('Complete every inspection check and choose the next route before continuing.','error');
        if(outcome==='ready_for_sale'&&[description,conditionMatch,accessories,serial,physical,functional].some(x=>x==='no'||x==='fail'))return msg('The item cannot be sent to Sales while an inspection check has failed. Choose Requires Testing, Requires Repair or Not as described.','error');
        busy=true;section.querySelector('#tf-complete').disabled=true;
        try{
          const files=[...(section.querySelector('#tf-photos')?.files||[])];
          for(let i=0;i<files.length;i++)await uploadPhoto(files[i],asset.id,existingPhotos+i);
          const metadata={customer_description_confirmed:description==='yes',condition_confirmed:conditionMatch==='yes',checks:{package_accessories:accessories,serial_verification:serial,physical_condition:physical,functional_test:functional},description_comparison:description,discrepancies,source:'subscriber_buying_inspection'};
          await api('/rest/v1/rpc/subscriber_complete_acquisition_inspection',{method:'POST',body:JSON.stringify({p_tenant_id:tenantId,p_acquisition_id:row.acquisition.id,p_condition_grade:grade,p_passed:outcome==='ready_for_sale',p_outcome:outcome,p_notes:notes,p_metadata:metadata})});
          msg(outcome==='ready_for_sale'?'Inspection completed. Item is ready for Sales.':'Inspection completed. The item has been routed to the selected next stage.','success');
          location.reload();
        }catch(e){msg(e.message||String(e),'error');busy=false;section.querySelector('#tf-complete').disabled=false}
      };
    }else if(row.acquisition.status==='finalised'){
      section.innerHTML='<div class="cell-label">SALES HANDOFF</div><h2 style="margin:4px 0 8px">Inspection complete — ready for Sales</h2><p>The item has passed inspection. The completed inspection is now read-only for Sales.</p>';
    }else return;
    const existing=$('tradeflow-inspection-workspace');if(existing)existing.remove();
    host.appendChild(section);
  }

  async function sync(){
    try{
      await auth();
      const rows=await currentWorkflow();
      if(!rows?.length)return;
      const row=rows[0];
      replaceNotice(row);
      if(['received','inspection','finalised'].includes(row.acquisition.status))await renderInspection(row);
    }catch(e){console.warn('TradeFlow inspection workspace:',e)}
  }

  document.addEventListener('click',e=>{
    const b=e.target.closest('[data-tf-inspect]');
    if(b){e.preventDefault();auth().then(()=>startInspection(b.dataset.tfInspect));}
  });
  const observer=new MutationObserver(()=>{clearTimeout(observer._t);observer._t=setTimeout(sync,150)});
  const start=()=>{const d=$('detail');if(d)observer.observe(d,{childList:true,subtree:true,characterData:true});sync();setInterval(sync,3000)};
  if(document.readyState==='loading')document.addEventListener('DOMContentLoaded',start);else start();
})();