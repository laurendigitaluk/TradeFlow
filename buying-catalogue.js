const SUPABASE_URL="https://twfbmjwwqzxdxvclxbun.supabase.co";
const $=id=>document.getElementById(id);
let key=null,token=null,tenantId=null;
let master=[],selections=new Map(),masterSelected=new Set(),masterPage=1;
let products=[],research=[],rules=[],activeCategories=[],activeBranches=[],activeSelected=new Set(),resetArmed=false,resetTimer=null;

const pageSize=100;
const conditions=[
 {key:"sealed",label:"Sealed",defaultRef:"uk_new"},
 {key:"opened_never_used",label:"Opened, Never Used",defaultRef:"uk_new"},
 {key:"excellent",label:"Excellent",defaultRef:"uk_used"},
 {key:"good",label:"Good",defaultRef:"uk_used"},
 {key:"poor",label:"Poor",defaultRef:"uk_used"}
];

function esc(v){return String(v??"").replace(/[&<>"']/g,c=>({"&":"&amp;","<":"&lt;",">":"&gt;","\"":"&quot;","'":"&#39;"}[c]||c))}
function money(v,c="GBP"){if(v===null||v===undefined||v==="")return"—";try{return new Intl.NumberFormat("en-GB",{style:"currency",currency:c||"GBP"}).format(Number(v))}catch{return(c||"")+" "+v}}
function msg(t,type=""){const e=$("message");if(e){e.textContent=t||"";e.className="message "+type}}
async function api(path,options={}){
 const h=new Headers(options.headers||{});h.set("apikey",key);h.set("Authorization","Bearer "+token);
 if(options.body)h.set("Content-Type","application/json");
 const timeoutMs=Number(options.timeoutMs)||20000,controller=new AbortController(),timer=setTimeout(()=>controller.abort(),timeoutMs);
 try{
  const r=await fetch(SUPABASE_URL+path,{...options,headers:h,signal:controller.signal});
  const text=await r.text();let b=null;try{b=text?JSON.parse(text):null}catch{b=text}
  if(!r.ok)throw Error(b?.message||b?.msg||b?.error||text||("HTTP "+r.status));
  return b;
 }catch(e){if(e.name==="AbortError")throw Error("TradeFlow catalogue request timed out. Please refresh and try again.");throw e}
 finally{clearTimeout(timer)}
}

async function init(){
 try{
  const auth=await window.tradeflowSubscriberAuthReady;
  if(!auth?.session?.access_token||!auth.tenantId)throw Error("Subscriber sign-in required.");
  key=auth.key;token=auth.session.access_token;tenantId=auth.tenantId;
  $("business-name").textContent=auth.tenants?.[tenantId]||"Buying Catalogue";
  await loadMaster();
  await loadActiveProducts();
 }catch(e){msg(e.message||String(e),"error")}
}

async function loadMaster(){
 msg("Loading the standalone TradeFlow master catalogue…");
 const rows=await api("/rest/v1/rpc/get_master_catalogue_for_selection",{method:"POST",body:JSON.stringify({p_tenant_id:tenantId}),timeoutMs:30000});
 master=Array.isArray(rows)?rows:[];
 const current=await api("/rest/v1/tenant_catalogue_selections?select=master_product_id,buying_enabled,selling_enabled,active&tenant_id=eq."+encodeURIComponent(tenantId))||[];
 selections=new Map(current.map(x=>[x.master_product_id,x]));
 $("catalogue-status").textContent=master.length+" products available";
 $("catalogue-status").classList.add("live");
 $("catalogue-help").textContent="Standalone TradeFlow catalogue. Subscriber selections are tenant-specific and do not read from GearCashOut.";
 populateMasterFilters();
 renderMaster();
 msg("Master catalogue loaded. Select products to activate them for your business.","success");
}

function masterCategories(){
 const m=new Map();
 master.forEach(p=>{const id=p.category_name||"Uncategorised";if(!m.has(id))m.set(id,{id,name:id,count:0});m.get(id).count++});
 return [...m.values()].sort((a,b)=>a.name.localeCompare(b.name));
}
function masterBranches(){
 const cat=$("master-category").value||"";
 const m=new Map();
 master.filter(p=>(!cat||p.category_name===cat)&&p.branch_name).forEach(p=>{if(!m.has(p.branch_name))m.set(p.branch_name,{id:p.branch_name,name:p.branch_name,count:0});m.get(p.branch_name).count++});
 return [...m.values()].sort((a,b)=>a.name.localeCompare(b.name));
}
function masterManufacturers(){
 const cat=$("master-category").value||"",branch=$("master-branch").value||"";
 const m=new Map();
 master.filter(p=>(!cat||p.category_name===cat)&&(!branch||p.branch_name===branch)&&p.manufacturer_name).forEach(p=>{if(!m.has(p.manufacturer_id))m.set(p.manufacturer_id,{id:p.manufacturer_id,name:p.manufacturer_name,count:0});m.get(p.manufacturer_id).count++});
 return [...m.values()].sort((a,b)=>a.name.localeCompare(b.name));
}
function masterFiltered(){
 const cat=$("master-category").value||"",branch=$("master-branch").value||"",man=$("master-manufacturer").value||"",q=($("master-search").value||"").trim().toLowerCase();
 return master.filter(p=>
  (!cat||p.category_name===cat)&&
  (!branch||p.branch_name===branch)&&
  (!man||p.manufacturer_id===man)&&
  (!q||[p.model,p.package_name,p.product_type,p.catalogue_category,p.main_category,p.manufacturer_name,p.branch_name,p.category_name].some(v=>String(v||"").toLowerCase().includes(q)))
 );
}
function populateMasterFilters(){
 const cat=$("master-category").value||"",branch=$("master-branch").value||"",man=$("master-manufacturer").value||"";
 $("master-category").innerHTML='<option value="">All categories</option>'+masterCategories().map(x=>'<option value="'+esc(x.id)+'">'+esc(x.name)+" ("+x.count+")</option>").join("");
 if([...masterCategories()].some(x=>x.id===cat))$("master-category").value=cat;
 populateMasterBranches(branch,man);
}
function populateMasterBranches(previous="",previousMan=""){
 const valid=masterBranches();
 const branch=valid.some(x=>x.id===previous)?previous:"";
 $("master-branch").innerHTML='<option value="">All branches</option>'+valid.map(x=>'<option value="'+esc(x.id)+'">'+esc(x.name)+" ("+x.count+")</option>").join("");
 $("master-branch").value=branch;
 const mans=masterManufacturers(),man=mans.some(x=>x.id===previousMan)?previousMan:"";
 $("master-manufacturer").innerHTML='<option value="">All manufacturers</option>'+mans.map(x=>'<option value="'+esc(x.id)+'">'+esc(x.name)+" ("+x.count+")</option>").join("");
 $("master-manufacturer").value=man;
}
function renderMaster(){
 const rows=masterFiltered(),pages=Math.max(1,Math.ceil(rows.length/pageSize));if(masterPage>pages)masterPage=pages;
 const start=(masterPage-1)*pageSize,visible=rows.slice(start,start+pageSize);
 $("master-count").textContent=rows.length+" matching products";
 $("page-info").textContent="Showing "+(visible.length?start+1:0)+"–"+(start+visible.length)+" of "+rows.length+" · page "+masterPage+" of "+pages;
 $("master-body").innerHTML=visible.length?visible.map(p=>{
  const s=selections.get(p.product_id)||{buying_enabled:false,selling_enabled:false,active:false};
  return '<tr><td><input class="master-check" type="checkbox" data-master="'+p.product_id+'" '+(masterSelected.has(p.product_id)?"checked":"")+'></td>'+
   '<td class="product-name"><strong>'+esc(p.manufacturer_name+" "+p.model)+'</strong><small>'+esc(p.package_name)+(p.product_type?" · "+esc(p.product_type):"")+'</small></td>'+
   '<td>'+esc(p.category_name)+'</td><td>'+esc(p.branch_name||"—")+'</td><td>'+esc(p.manufacturer_name)+'</td>'+
   '<td><label class="toggle '+(s.buying_enabled?"live-buy":"")+'"><input class="buy-state" type="checkbox" data-master="'+p.product_id+'" '+(s.buying_enabled?"checked":"")+'> '+(s.buying_enabled?"Live":"Off")+'</label></td>'+
   '<td><label class="toggle '+(s.selling_enabled?"live-sell":"")+'"><input class="sell-state" type="checkbox" data-master="'+p.product_id+'" '+(s.selling_enabled?"checked":"")+'> '+(s.selling_enabled?"Live":"Off")+'</label></td></tr>';
 }).join(""):'<tr><td colspan="7" class="empty">No master catalogue products match these filters.</td></tr>';
 document.querySelectorAll(".master-check").forEach(i=>i.addEventListener("change",()=>{i.checked?masterSelected.add(i.dataset.master):masterSelected.delete(i);updateMasterSelectAll()}));
 document.querySelectorAll(".buy-state").forEach(i=>i.addEventListener("change",()=>setOne(i.dataset.master,i.checked,(selections.get(i.dataset.master)||{}).selling_enabled)));
 document.querySelectorAll(".sell-state").forEach(i=>i.addEventListener("change",()=>setOne(i.dataset.master,(selections.get(i.dataset.master)||{}).buying_enabled,i.checked)));
 updateMasterSelectAll();
}
function updateMasterSelectAll(){
 const rows=masterFiltered(),box=$("master-select-all"),selected=rows.filter(p=>masterSelected.has(p.product_id));
 box.checked=rows.length>0&&selected.length===rows.length;
 box.indeterminate=selected.length>0&&selected.length<rows.length;
 $("select-visible").textContent=masterSelected.size?"Select visible ("+masterSelected.size+")":"Select visible";
}
async function setOne(id,buy,sell){
 try{await activate([id],!!buy,!!sell)}catch(e){renderMaster();msg(e.message||String(e),"error")}
}
async function activate(ids,buy,sell){
 if(!ids.length)return msg("Select at least one catalogue product first.","error");
 const buttons=[$("activate-buying"),$("activate-both"),$("turn-off")];buttons.forEach(b=>b.disabled=true);
 try{
  const result=await api("/rest/v1/rpc/activate_master_catalogue_products",{method:"POST",body:JSON.stringify({p_tenant_id:tenantId,p_master_product_ids:ids,p_buying_enabled:!!buy,p_selling_enabled:!!sell})});
  await loadMaster();
  await loadActiveProducts();
  masterSelected.clear();
  msg((result?.products||ids.length)+" product"+((result?.products||ids.length)===1?"":"s")+" updated. Categories, branches and manufacturers were populated automatically; products without configured buying prices remain manual valuation/quote.","success");
 }catch(e){msg(e.message||String(e),"error")}
 finally{buttons.forEach(b=>b.disabled=false)}
}

async function loadActiveProducts(){
 const cats=await api("/rest/v1/categories?select=id,name,slug,active,buying_enabled&tenant_id=eq."+encodeURIComponent(tenantId)+"&buying_enabled=eq.true&active=eq.true&order=name")||[];
 const branches=await api("/rest/v1/category_branches?select=id,category_id,name,slug,active,buying_enabled&tenant_id=eq."+encodeURIComponent(tenantId)+"&buying_enabled=eq.true&active=eq.true&order=name")||[];
 activeCategories=cats;activeBranches=branches;
 products=await api("/rest/v1/tenant_buying_products?select=id,category_id,branch_id,manufacturer,model,package_name,active&tenant_id=eq."+encodeURIComponent(tenantId)+"&active=eq.true&order=manufacturer,model")||[];
 const ids=products.map(p=>p.id);
 research=ids.length?await api("/rest/v1/tenant_buying_research?select=id,buying_product_id,evidence_type,source_name,source_url,observed_price,price_currency,item_condition,checked_at&tenant_id=eq."+encodeURIComponent(tenantId)+"&buying_product_id=in.("+ids.join(",")+")&order=checked_at.desc")||[]:[];
 rules=ids.length?await api("/rest/v1/tenant_buying_condition_rules?select=id,buying_product_id,sealed_percentage,opened_never_used_percentage,excellent_percentage,good_percentage,poor_percentage,sealed_reference_type,opened_never_used_reference_type,excellent_reference_type,good_reference_type,poor_reference_type,sealed_manual_price,opened_never_used_manual_price,excellent_manual_price,good_manual_price,poor_manual_price&tenant_id=eq."+encodeURIComponent(tenantId)+"&buying_product_id=in.("+ids.join(",")+")")||[]:[];
 populateActiveFilters();
 renderMatrix();
 $("active-count").textContent=products.length+" active";
}
function catName(id){return activeCategories.find(c=>c.id===id)?.name||"—"}
function branchName(id){return activeBranches.find(b=>b.id===id)?.name||"—"}
function activeFiltered(){
 const cat=$("active-category").value||"",branch=$("active-branch").value||"",man=$("active-manufacturer").value||"",model=$("active-model").value||"";
 return products.filter(p=>(!cat||p.category_id===cat)&&(!branch||p.branch_id===branch)&&(!man||p.manufacturer===man)&&(!model||p.model===model));
}
function populateActiveFilters(){
 const cat=$("active-category").value||"",branch=$("active-branch").value||"",man=$("active-manufacturer").value||"",model=$("active-model").value||"";
 $("active-category").innerHTML='<option value="">All categories</option>'+activeCategories.map(c=>'<option value="'+c.id+'">'+esc(c.name)+'</option>').join("");
 if(activeCategories.some(c=>c.id===cat))$("active-category").value=cat;
 const validBranches=activeBranches.filter(b=>!$("active-category").value||b.category_id===$("active-category").value);
 $("active-branch").innerHTML='<option value="">All branches</option>'+validBranches.map(b=>'<option value="'+b.id+'">'+esc(b.name)+'</option>').join("");
 if(validBranches.some(b=>b.id===branch))$("active-branch").value=branch;
 const validProducts=products.filter(p=>(!$("active-category").value||p.category_id===$("active-category").value)&&(!$("active-branch").value||p.branch_id===$("active-branch").value));
 const mans=[...new Set(validProducts.map(p=>p.manufacturer).filter(Boolean))].sort((a,b)=>a.localeCompare(b));
 $("active-manufacturer").innerHTML='<option value="">All manufacturers</option>'+mans.map(m=>'<option value="'+esc(m)+'">'+esc(m)+'</option>').join("");
 if(mans.includes(man))$("active-manufacturer").value=man;
 const models=[...new Set(validProducts.filter(p=>!$("active-manufacturer").value||p.manufacturer===$("active-manufacturer").value).map(p=>p.model).filter(Boolean))].sort((a,b)=>a.localeCompare(b));
 $("active-model").innerHTML='<option value="">All models</option>'+models.map(m=>'<option value="'+esc(m)+'">'+esc(m)+'</option>').join("");
 if(models.includes(model))$("active-model").value=model;
}

function latest(p,type){return research.find(r=>r.buying_product_id===p.id&&r.evidence_type===type&&r.observed_price!==null&&String(r.price_currency||"GBP").toUpperCase()==="GBP")||null}
function ruleFor(p){return rules.find(r=>r.buying_product_id===p.id)||{buying_product_id:p.id}}
function refHtml(r){if(!r)return'<div class="ref-price">—</div><div class="ref-source">No research yet</div>';return'<div class="ref-price">'+money(r.observed_price,r.price_currency)+'</div><div class="ref-source">'+(r.source_url?'<a href="'+esc(r.source_url)+'" target="_blank" rel="noopener">'+esc(r.source_name||"Source")+"</a>":esc(r.source_name||"Research"))+"<br>"+new Date(r.checked_at).toLocaleDateString("en-GB")+"</div>"}
function conditionCell(p,c){
 const r=ruleFor(p),pctField=c.key+"_percentage",refField=c.key+"_reference_type",manualField=c.key+"_manual_price";
 const pct=r[pctField]??"",ref=r[refField]||c.defaultRef,manual=r[manualField]??"";
 const researchRow=latest(p,ref==="uk_new"?"uk_new":"uk_used"),base=researchRow?.observed_price??null;
 const amount=pct!==""&&base!==null?Number(base)*Number(pct)/100:null,hasManual=manual!==""&&manual!==null;
 const active=hasManual?money(manual):(amount!==null?money(amount):"Manual quote / valuation");
 return '<td class="condition-cell"><div class="condition-name">'+c.label+'</div>'+
 '<div class="active-price '+(hasManual?"manual-active":"automatic-active")+'" data-active="'+p.id+"-"+c.key+'"><span class="active-label">'+(hasManual?"ACTIVE BUYING PRICE — MANUAL":"ACTIVE BUYING PRICE")+'</span><strong>'+active+'</strong></div>'+
 '<div class="pricing-label">Automatic price basis</div><select class="reference-select" data-product="'+p.id+'" data-field="'+refField+'"><option value="uk_new" '+(ref==="uk_new"?"selected":"")+'>UK New research</option><option value="uk_used" '+(ref==="uk_used"?"selected":"")+'>UK Used research</option></select>'+
 '<div class="pricing-label">Automatic percentage</div><input class="pct" data-product="'+p.id+'" data-field="'+pctField+'" type="number" min="0" max="100" step="0.01" value="'+esc(pct)+'" placeholder="%">'+
 '<div class="automatic-result" data-calc="'+p.id+"-"+c.key+'">'+(amount!==null?"Automatic would be "+money(amount):'<span class="not-set">No automatic price — manual quote / valuation</span>')+'</div>'+
 '<div class="pricing-help">'+(base!==null?money(base)+" current "+(ref==="uk_new"?"UK New":"UK Used")+" reference":"No "+(ref==="uk_new"?"UK New":"UK Used")+" research found")+'</div>'+
 '<div class="pricing-label">Manual override <span class="field-hint">(leave blank for automatic)</span></div><input class="manual-price" data-product="'+p.id+'" data-field="'+manualField+'" type="number" min="0" step="0.01" value="'+esc(manual)+'" placeholder="Exact buying price £">'+
 '<div class="manual-result '+(hasManual?"manual-active-text":"")+'" data-manual="'+p.id+"-"+c.key+'">'+(hasManual?"Manual override active — "+money(manual):"No manual override")+'</div></td>';
}
function renderMatrix(){
 const visible=activeFiltered();
 $("active-count").textContent=products.length+" active";
 const body=$("matrix-body");
 if(!visible.length){body.innerHTML='<tr><td colspan="9" class="empty">No active buying products match these filters.</td></tr>';return}
 body.innerHTML=visible.map(p=>{const n=latest(p,"uk_new"),u=latest(p,"uk_used");return'<tr><td class="select-col"><input class="active-check" type="checkbox" data-active-product="'+p.id+'" '+(activeSelected.has(p.id)?"checked":"")+'></td><td class="product-cell"><strong>'+esc(p.manufacturer+" "+p.model)+'</strong><span>'+esc(p.package_name||"")+" · "+esc(catName(p.category_id))+" → "+esc(branchName(p.branch_id))+'</span></td><td class="ref-cell">'+refHtml(n)+'</td><td class="ref-cell">'+refHtml(u)+'</td>'+conditions.map(c=>conditionCell(p,c)).join("")+'</tr>'}).join("");
 document.querySelectorAll(".active-check").forEach(i=>i.addEventListener("change",()=>{i.checked?activeSelected.add(i.dataset.activeProduct):activeSelected.delete(i.dataset.activeProduct);updateActiveSelectAll()}));
 bindPricingInputs();updateActiveSelectAll();
}
function updateActiveSelectAll(){
 const visible=activeFiltered(),chosen=visible.filter(p=>activeSelected.has(p.id)),box=$("select-all-active");
 box.checked=visible.length>0&&chosen.length===visible.length;box.indeterminate=chosen.length>0&&chosen.length<visible.length;
}
function bindPricingInputs(){
 document.querySelectorAll(".pct,.reference-select").forEach(i=>{i.addEventListener("input",updatePricingCell);i.addEventListener("change",updatePricingCell)});
 document.querySelectorAll(".manual-price").forEach(i=>i.addEventListener("input",updatePricingCell));
}
function updatePricingCell(e){
 const productId=e.target.dataset.product,field=e.target.dataset.field||"",c=conditions.find(x=>field.startsWith(x.key+"_"));if(!c)return;
 const ref=document.querySelector('[data-product="'+productId+'"][data-field="'+c.key+'_reference_type"]')?.value||c.defaultRef;
 const pct=document.querySelector('[data-product="'+productId+'"][data-field="'+c.key+'_percentage"]')?.value||"";
 const manual=document.querySelector('[data-product="'+productId+'"][data-field="'+c.key+'_manual_price"]')?.value||"";
 const p=products.find(x=>x.id===productId),r=p?latest(p,ref==="uk_new"?"uk_new":"uk_used"):null,base=r?.observed_price??null,amount=pct!==""&&base!==null?Number(base)*Number(pct)/100:null;
 const active=document.querySelector('[data-active="'+productId+"-"+c.key+'"]');
 if(active){const hm=manual!=="";active.className="active-price "+(hm?"manual-active":"automatic-active");active.innerHTML='<span class="active-label">'+(hm?"ACTIVE BUYING PRICE — MANUAL":"ACTIVE BUYING PRICE")+'</span><strong>'+(hm?money(manual):(amount!==null?money(amount):"Manual quote / valuation"))+'</strong>'}
 const calc=document.querySelector('[data-calc="'+productId+"-"+c.key+'"]');if(calc)calc.innerHTML=amount!==null?"Automatic would be "+money(amount):'<span class="not-set">No automatic price — manual quote / valuation</span>';
 const help=calc?.nextElementSibling;if(help)help.textContent=base!==null?money(base)+" current "+(ref==="uk_new"?"UK New":"UK Used")+" reference":"No "+(ref==="uk_new"?"UK New":"UK Used")+" research found";
 const mb=document.querySelector('[data-manual="'+productId+"-"+c.key+'"]');if(mb)mb.textContent=manual!==""?"Manual override active — "+money(manual):"No manual override";
}
async function saveAll(){
 const payload=[];
 document.querySelectorAll(".pct,.reference-select,.manual-price").forEach(i=>{
  let row=payload.find(x=>x.buying_product_id===i.dataset.product);if(!row){row={tenant_id:tenantId,buying_product_id:i.dataset.product};payload.push(row)}
  row[i.dataset.field]=i.value===""?null:(i.classList.contains("pct")||i.classList.contains("manual-price")?Number(i.value):i.value);
 });
 if(!payload.length)return msg("There are no active products to save.","error");
 try{
  await api("/rest/v1/tenant_buying_condition_rules?on_conflict=tenant_id,buying_product_id",{method:"POST",headers:{Prefer:"resolution=merge-duplicates,return=minimal"},body:JSON.stringify(payload)});
  await loadActiveProducts();msg("Buying prices saved. Any product/condition without a usable automatic price or manual override remains manual valuation / quote.","success");
 }catch(e){msg(e.message||String(e),"error")}
}
async function resetSelectedPrices(){
 const ids=[...activeSelected];if(!ids.length)return msg("Select at least one active buying product first.","error");
 const btn=$("reset-selected-prices");
 if(!resetArmed){resetArmed=true;btn.classList.add("armed");btn.textContent="Click again to confirm reset";if(resetTimer)clearTimeout(resetTimer);resetTimer=setTimeout(()=>{resetArmed=false;btn.classList.remove("armed");btn.textContent="Reset selected prices"},5000);return msg("Warning: this clears condition percentages, reference choices and manual overrides for the selected products. Click again within 5 seconds to confirm.","error")}
 resetArmed=false;if(resetTimer)clearTimeout(resetTimer);btn.disabled=true;btn.textContent="Resetting…";
 try{
  const list=ids.join(",");
  await api("/rest/v1/tenant_buying_condition_rules?tenant_id=eq."+encodeURIComponent(tenantId)+"&buying_product_id=in.("+list+")",{method:"DELETE",headers:{Prefer:"return=minimal"}});
  await api("/rest/v1/tenant_buying_products?tenant_id=eq."+encodeURIComponent(tenantId)+"&id=in.("+list+")",{method:"PATCH",headers:{Prefer:"return=minimal"},body:JSON.stringify({automatic_percentage:null,manual_offer_price:null})});
  activeSelected.clear();await loadActiveProducts();msg("Selected prices reset. The products remain active for Buying but now require manual valuation / quote until pricing is configured.","success");
 }catch(e){msg(e.message||String(e),"error")}
 finally{btn.disabled=false;btn.classList.remove("armed");btn.textContent="Reset selected prices"}
}

$("master-category").addEventListener("change",()=>{masterPage=1;populateMasterFilters();renderMaster()});
$("master-branch").addEventListener("change",()=>{masterPage=1;populateMasterBranches($("master-branch").value,$("master-manufacturer").value);renderMaster()});
$("master-manufacturer").addEventListener("change",()=>{masterPage=1;renderMaster()});
$("master-search").addEventListener("input",()=>{masterPage=1;renderMaster()});
$("select-visible").addEventListener("click",()=>{masterFiltered().forEach(p=>masterSelected.add(p.product_id));renderMaster()});
$("clear-selected").addEventListener("click",()=>{masterSelected.clear();renderMaster()});
$("master-select-all").addEventListener("change",e=>{masterFiltered().forEach(p=>e.target.checked?masterSelected.add(p.product_id):masterSelected.delete(p.product_id));renderMaster()});
$("activate-buying").addEventListener("click",()=>activate([...masterSelected],true,false));
$("activate-both").addEventListener("click",()=>activate([...masterSelected],true,true));
$("turn-off").addEventListener("click",()=>activate([...masterSelected],false,false));
$("active-category").addEventListener("change",()=>{populateActiveFilters();renderMatrix()});
$("active-branch").addEventListener("change",()=>{populateActiveFilters();renderMatrix()});
$("active-manufacturer").addEventListener("change",()=>{populateActiveFilters();renderMatrix()});
$("active-model").addEventListener("change",renderMatrix);
$("select-all-active").addEventListener("change",e=>{activeFiltered().forEach(p=>e.target.checked?activeSelected.add(p.id):activeSelected.delete(p.id));renderMatrix()});
$("save-all").addEventListener("click",saveAll);
$("reset-selected-prices").addEventListener("click",resetSelectedPrices);
$("prev-page").addEventListener("click",()=>{if(masterPage>1){masterPage--;renderMaster()}});
$("next-page").addEventListener("click",()=>{if(masterPage<Math.ceil(masterFiltered().length/pageSize)){masterPage++;renderMaster()}});
$("sign-out").addEventListener("click",()=>{if(window.tradeflowSubscriberSignOut)window.tradeflowSubscriberSignOut();else{localStorage.removeItem("tradeflow_subscriber_session");location.href="subscriber-login.html"}});
if(window.tradeflowSubscriberAuthReady)window.tradeflowSubscriberAuthReady.then(init).catch(e=>msg(e.message||String(e),"error"));else msg("Subscriber authentication layer did not load.","error");
