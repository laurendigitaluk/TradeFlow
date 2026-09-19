const SUPABASE_URL="https://twfbmjwwqzxdxvclxbun.supabase.co";
const $=id=>document.getElementById(id);
let key=null,token=null,tenantId=null;
let master=[],facets={categories:[],branches:[],manufacturers:[]};
let masterPage=1,totalProducts=0;
const pageSize=50;
let searchTimer=null;
let buyingSelectionAllMatching=false;

function esc(v){return String(v??"").replace(/[&<>"']/g,c=>({"&":"&amp;","<":"&lt;",">":"&gt;","\"":"&quot;","'":"&#39;"}[c]||c))}
function money(v,c="GBP"){if(v===null||v===undefined||v==="")return"—";try{return new Intl.NumberFormat("en-GB",{style:"currency",currency:c||"GBP"}).format(Number(v))}catch{return(c||"")+" "+v}}
function msg(t,type=""){const e=$("message");if(e){e.textContent=t||"";e.className="message "+type}}
async function api(path,options={}){
 const h=new Headers(options.headers||{});h.set("apikey",key);h.set("Authorization","Bearer "+token);
 if(options.body)h.set("Content-Type","application/json");
 const timeoutMs=Number(options.timeoutMs)||30000,controller=new AbortController(),timer=setTimeout(()=>controller.abort(),timeoutMs);
 try{
  const r=await fetch(SUPABASE_URL+path,{...options,headers:h,signal:controller.signal});
  const text=await r.text();let b=null;try{b=text?JSON.parse(text):null}catch{b=text}
  if(!r.ok){const detail=b?.message||b?.msg||b?.error||text||("HTTP "+r.status);throw Error("Catalogue request failed ("+r.status+") at "+path+": "+detail)}
  return b;
 }catch(e){if(e.name==="AbortError")throw Error("TradeFlow catalogue request timed out. Please refresh and try again.");throw e}
 finally{clearTimeout(timer)}
}
window.buyingSelected=new Set();
async function init(){
 try{
  const auth=await window.tradeflowSubscriberAuthReady;
  if(!auth?.session?.access_token||!auth.tenantId)throw Error("Subscriber sign-in required.");
  key=auth.key;token=auth.session.access_token;tenantId=auth.tenantId;
  $("business-name").textContent=auth.tenants?.[tenantId]||"Buying Pricing";
  await loadCatalogue();
 }catch(e){msg(e.message||String(e),"error")}
}
async function loadCatalogue(){
 msg("Loading catalogue filters…");
 await loadFacets();
 await loadPage();
 msg("Catalogue ready. Select a product to add it to this subscriber's Buying Catalogue.","success");
}
async function loadFacets(){
 const cat=$("master-category").value||null,branch=$("master-branch").value||null;
 const data=await api("/rest/v1/rpc/get_master_buying_catalogue_facets",{method:"POST",body:JSON.stringify({p_tenant_id:tenantId,p_category_id:cat,p_branch_id:branch})});
 facets=data||{categories:[],branches:[],manufacturers:[]};
 populateFilters();
}
async function loadPage(){
 const cat=$("master-category").value||null,branch=$("master-branch").value||null,man=$("master-manufacturer").value||null,q=($("master-search").value||"").trim()||null;
 if(!man&&!q){
  master=[];totalProducts=0;
  $("catalogue-status").textContent="Choose a manufacturer or search";
  $("catalogue-status").classList.remove("live");
  $("catalogue-help").textContent="No product records are downloaded until you choose a manufacturer or enter a product search. Category and branch selections only narrow the available choices.";
  renderMaster();
  return;
 }
 const data=await api("/rest/v1/rpc/get_master_buying_catalogue_page",{method:"POST",body:JSON.stringify({
  p_tenant_id:tenantId,p_category_id:cat,p_branch_id:branch,p_manufacturer_id:man,p_search:q,p_page:masterPage,p_page_size:pageSize
 }),timeoutMs:45000});
 master=Array.isArray(data?.products)?data.products:[];
 totalProducts=Number(data?.total||0);
 const pages=Math.max(1,Math.ceil(totalProducts/pageSize));if(masterPage>pages){masterPage=pages;return loadPage()}
 $("catalogue-status").textContent=totalProducts+" matching products";
 $("catalogue-status").classList.add("live");
 $("catalogue-help").textContent="TradeFlow only loads the current result page. Products are added to your Buying Catalogue when you choose them.";
 renderMaster();
}
function fillSelect(id,items,placeholder,old){
 const e=$(id);e.innerHTML='<option value="">'+placeholder+"</option>"+(items||[]).map(x=>'<option value="'+esc(x.id)+'">'+esc(x.name)+" ("+x.count+")</option>").join("");
 if((items||[]).some(x=>String(x.id)===String(old)))e.value=old;
}
function populateFilters(){
 const cat=$("master-category").value||"",branch=$("master-branch").value||"",man=$("master-manufacturer").value||"";
 fillSelect("master-category",facets.categories,"All categories",cat);
 fillSelect("master-branch",facets.branches,"All branches",branch);
 fillSelect("master-manufacturer",facets.manufacturers,"All manufacturers",man);
}
function stateFor(p){
 if(!p?.buying_enabled||!p?.selection_active||!p?.buying_product_active)return {key:"inactive",label:"Inactive",product:p,rule:p?.rule_id?true:null};
 if(p.manual_offer_price!==null&&p.manual_offer_price!==undefined)return {key:"manual",label:"Manual price / override",product:p,rule:p.rule_id?true:null};
 if(p.rule_id)return {key:"auto",label:"Automatic pricing",product:p,rule:p};
 return {key:"valuation",label:"Manual valuation",product:p,rule:null};
}
function refSummary(p){
 if(!p||stateFor(p).key==="inactive")return '<div class="ref-summary">Not active for Buying. Select the product to add it.</div>';
 if(p.manual_offer_price!==null&&p.manual_offer_price!==undefined)return '<div class="ref-summary"><strong>Manual price / override:</strong> '+money(p.manual_offer_price)+(p.rule_id?'<br><span class="muted">Automatic rule retained as fallback.</span>':'')+'</div>';
 if(p.rule_id)return '<div class="ref-summary"><strong>Automatic rule:</strong><br>Sealed '+(p.sealed_percentage??"—")+"% · Opened "+(p.opened_never_used_percentage??"—")+"% · Excellent "+(p.excellent_percentage??"—")+"% · Good "+(p.good_percentage??"—")+"% · Poor "+(p.poor_percentage??"—")+"%</div>";
 return '<div class="ref-summary">Manual valuation — no fixed price or automatic rule configured.</div>';
}
function editorHtml(p,s){
 if(s.key==="inactive")return '<button class="save-price add-product" data-add-product="'+p.product_id+'">Add to Buying Catalogue</button><div class="price-help">Selecting this product automatically creates/links its category, branch and manufacturer for this subscriber.</div>';
 if(s.key==="manual")return '<div class="price-editor"><label class="price-help">Buying price / override (£)</label><input class="manual-input" data-master="'+p.product_id+'" type="number" min="0" step="0.01" value="'+esc(p.manual_offer_price??"")+'" placeholder="Enter price you are willing to pay"><button class="save-price" data-save-manual="'+p.product_id+'">Save price</button><div class="price-help">This fixed price overrides automatic pricing for this product.</div></div>';
 if(s.key==="auto")return '<div class="price-editor"><div class="price-grid">'+
  [["Sealed","sealed_percentage"],["Opened","opened_never_used_percentage"],["Excellent","excellent_percentage"],["Good","good_percentage"],["Poor","poor_percentage"]].map(([l,f])=>'<label>'+l+' %<input class="auto-input" data-master="'+p.product_id+'" data-field="'+f+'" type="number" min="0" max="100" step="0.01" value="'+esc(p[f]??"")+'" placeholder="%"></label>').join("")+
  '</div><label class="price-help" style="display:block;margin-top:10px">Optional fixed buying price / override (£)<input class="manual-input auto-override-input" data-master="'+p.product_id+'" type="number" min="0" step="0.01" value="'+esc(p.manual_offer_price??"")+'" placeholder="Leave blank to use automatic pricing"></label><button class="save-price" data-save-auto="'+p.product_id+'">Save automatic rule</button><div class="price-help">Leave the override blank to calculate from research. Enter a price to override the calculated price for this product. Sealed and Opened use UK New; Excellent, Good and Poor use UK Used by default.</div></div>';
 return "";
}
function renderMaster(){
 const pages=Math.max(1,Math.ceil(totalProducts/pageSize));
 const inactiveIds=master.filter(p=>stateFor(p).key==="inactive").map(p=>p.product_id);
 const selectedIds=window.buyingSelected||new Set();
 const selectableCount=inactiveIds.length;
 const selectedCount=inactiveIds.filter(id=>selectedIds.has(id)).length;
 const bulkAll=buyingSelectionAllMatching;
 const selectAll=$("select-all-products");
 if(selectAll){
  selectAll.checked=bulkAll||(selectableCount>0&&selectedCount===selectableCount);
  selectAll.indeterminate=!bulkAll&&selectedCount>0&&selectedCount<selectableCount;
 }
 $("selected-count").textContent=bulkAll?"All "+totalProducts+" matching products selected":(selectedCount?selectedCount+" selected":"");
 $("bulk-add").disabled=!(bulkAll||selectedCount>0);
 const allMatching=$("select-all-matching");
 if(allMatching){allMatching.textContent=bulkAll?"Clear all matching":"Select all "+totalProducts+" matching";allMatching.disabled=totalProducts===0;}

 $("master-count").textContent=totalProducts+" matching products";
 const start=(masterPage-1)*pageSize;
 $("page-info").textContent="Showing "+(master.length?start+1:0)+"–"+(start+master.length)+" of "+totalProducts+" · page "+masterPage+" of "+pages;
 $("master-body").innerHTML=master.length?master.map(p=>{
  const s=stateFor(p);
  const mode=s.key==="inactive"?"":'<select class="mode-select" data-mode="'+p.product_id+'"><option value="manual" '+(s.key==="manual"||s.key==="valuation"?"selected":"")+'>Manual</option><option value="automatic" '+(s.key==="auto"?"selected":"")+'>Automatic</option></select>';
  return '<tr class="status-'+s.key+'">'+
   '<td class="select-cell"><input type="checkbox" class="product-select" data-product-id="'+p.product_id+'" '+(s.key!=="inactive"?"disabled":"")+' '+(selectedIds.has(p.product_id)?"checked":"")+' aria-label="Select '+esc(p.manufacturer_name+" "+p.model)+'"></td>'+
   '<td class="product-name"><strong>'+esc(p.manufacturer_name+" "+p.model)+'</strong><small>'+esc(p.package_name)+(p.product_type?" · "+esc(p.product_type):"")+(p.notes?"<br>"+esc(p.notes):"")+'</small></td>'+
   '<td>'+esc(p.category_name)+'</td><td>'+esc(p.branch_name||"—")+'</td><td>'+esc(p.manufacturer_name)+'</td>'+
   '<td><div class="state '+s.key+'">'+esc(s.label)+'</div>'+mode+editorHtml(p,s)+(s.key!=="inactive"?'<button class="reset-link" data-reset="'+p.product_id+'">Reset / turn off</button>':"")+'</td>'+
   '<td>'+refSummary(p)+'</td></tr>';
 }).join(""):'<tr><td colspan="6" class="empty">No master catalogue products match these filters.</td></tr>';
 document.querySelectorAll(".mode-select").forEach(e=>e.addEventListener("change",()=>changeMode(e.dataset.mode,e.value)));
 document.querySelectorAll("[data-add-product]").forEach(e=>e.addEventListener("click",()=>addProduct(e.dataset.addProduct,e)));
 document.querySelectorAll("[data-save-manual]").forEach(e=>e.addEventListener("click",()=>saveManual(e.dataset.saveManual,e)));
 document.querySelectorAll("[data-save-auto]").forEach(e=>e.addEventListener("click",()=>saveAuto(e.dataset.saveAuto,e)));
 document.querySelectorAll("[data-reset]").forEach(e=>e.addEventListener("click",()=>resetProduct(e.dataset.reset)));
 document.querySelectorAll(".product-select").forEach(e=>e.addEventListener("change",()=>{window.buyingSelected=window.buyingSelected||new Set();buyingSelectionAllMatching=false;if(e.checked)window.buyingSelected.add(e.dataset.productId);else window.buyingSelected.delete(e.dataset.productId);renderMaster();}));
}
async function addSelectedProducts(){
 const ids=Array.from(window.buyingSelected||[]);
 if(!buyingSelectionAllMatching&&!ids.length)return;
 const mode=$("bulk-mode")?.value||"manual";
 const button=$("bulk-add");button.disabled=true;
 const payload={p_tenant_id:tenantId,p_mode:mode};
 if(mode==="automatic"){
  const fields=["sealed_percentage","opened_never_used_percentage","excellent_percentage","good_percentage","poor_percentage"];
  for(const field of fields){const raw=$("bulk-"+field)?.value||"";const value=Number(raw);if(raw===""||!Number.isFinite(value)||value<0||value>100){button.disabled=false;return msg("Enter all five automatic percentages between 0 and 100 before adding products automatically.","error")}payload["p_"+field]=value}
 }
 try{
  let result;
  if(buyingSelectionAllMatching){
   const cat=$("master-category").value||null,branch=$("master-branch").value||null,man=$("master-manufacturer").value||null,q=($("master-search").value||"").trim()||null;
   result=await api("/rest/v1/rpc/configure_master_catalogue_buying_products_filtered",{method:"POST",body:JSON.stringify({...payload,p_category_id:cat,p_branch_id:branch,p_manufacturer_id:man,p_search:q}),timeoutMs:45000});
  }else{
   result=await api("/rest/v1/rpc/configure_master_catalogue_buying_products_bulk",{method:"POST",body:JSON.stringify({...payload,p_master_product_ids:ids}),timeoutMs:45000});
  }
  window.buyingSelected=new Set();buyingSelectionAllMatching=false;
  await loadPage();
  msg((result?.added||0)+" product(s) added to your Buying Catalogue as "+(mode==="automatic"?"Automatic pricing":"Manual valuation")+((result?.skipped||0)?"; "+result.skipped+" already active and skipped.":".")+" You can now configure their pricing individually.","success");
 }catch(e){msg(e.message||String(e),"error");button.disabled=false;renderMaster()}
}
async function addProduct(masterId,button){
 const p=master.find(x=>x.product_id===masterId);if(!p)return;
 button.disabled=true;
 try{
  await api("/rest/v1/rpc/configure_master_catalogue_buying_product",{method:"POST",body:JSON.stringify({p_tenant_id:tenantId,p_master_product_id:masterId,p_mode:"manual",p_manual_price:null})});
  await loadPage();msg("Product added. It is now Manual valuation until you enter a fixed price or configure Automatic pricing.","success");
 }catch(e){button.disabled=false;msg(e.message||String(e),"error")}
}
async function changeMode(masterId,mode){
 const p=master.find(x=>x.product_id===masterId);if(!p)return;
 if(mode==="automatic"){
  const values={sealed_percentage:p.sealed_percentage,opened_never_used_percentage:p.opened_never_used_percentage,excellent_percentage:p.excellent_percentage,good_percentage:p.good_percentage,poor_percentage:p.poor_percentage};
  try{
   await api("/rest/v1/rpc/configure_master_catalogue_buying_product",{method:"POST",body:JSON.stringify({p_tenant_id:tenantId,p_master_product_id:masterId,p_mode:"automatic",p_sealed_percentage:values.sealed_percentage,p_opened_never_used_percentage:values.opened_never_used_percentage,p_excellent_percentage:values.excellent_percentage,p_good_percentage:values.good_percentage,p_poor_percentage:values.poor_percentage,p_manual_price:p.manual_offer_price??null})});
   await loadPage();msg("Automatic pricing mode enabled. Set the percentages and optional override below.","success");
  }catch(e){renderMaster();msg(e.message||String(e),"error")}
  return;
 }
 try{
  await api("/rest/v1/rpc/configure_master_catalogue_buying_product",{method:"POST",body:JSON.stringify({p_tenant_id:tenantId,p_master_product_id:masterId,p_mode:"manual",p_manual_price:p.manual_offer_price??null})});
  await loadPage();msg("Manual mode enabled. Leave the price blank for Manual valuation or enter a fixed buying price.","success");
 }catch(e){renderMaster();msg(e.message||String(e),"error")}
}
async function saveManual(masterId,button){
 const input=document.querySelector('[data-master="'+masterId+'"].manual-input');if(!input)return;
 const value=input.value===""?null:Number(input.value);if(value!==null&&(!Number.isFinite(value)||value<0))return msg("Enter a valid manual buying price.","error");
 button.disabled=true;try{
  await api("/rest/v1/rpc/configure_master_catalogue_buying_product",{method:"POST",body:JSON.stringify({p_tenant_id:tenantId,p_master_product_id:masterId,p_mode:"manual",p_manual_price:value})});
  await loadPage();msg(value===null?"Manual valuation enabled. A staff member can value this product when a customer request arrives.":"Manual buying price saved. The fixed price now takes precedence over automatic pricing if a rule is retained.","success");
 }catch(e){msg(e.message||String(e),"error")}finally{button.disabled=false}
}
async function saveAuto(masterId,button){
 const p=master.find(x=>x.product_id===masterId);if(!p)return;
 const values={};document.querySelectorAll('.auto-input[data-master="'+masterId+'"]').forEach(i=>values[i.dataset.field]=i.value===""?null:Number(i.value));
 for(const v of Object.values(values))if(v!==null&&(!Number.isFinite(v)||v<0||v>100))return msg("Automatic percentages must be between 0 and 100.","error");
 const override=document.querySelector('.auto-override-input[data-master="'+masterId+'"]');
 const manualPrice=(override?.value||"")===""?null:Number(override.value);
 if(manualPrice!==null&&(!Number.isFinite(manualPrice)||manualPrice<0))return msg("Enter a valid fixed buying price or leave the override blank.","error");
 button.disabled=true;try{
  await api("/rest/v1/rpc/configure_master_catalogue_buying_product",{method:"POST",body:JSON.stringify({p_tenant_id:tenantId,p_master_product_id:masterId,p_mode:"automatic",p_sealed_percentage:values.sealed_percentage,p_opened_never_used_percentage:values.opened_never_used_percentage,p_excellent_percentage:values.excellent_percentage,p_good_percentage:values.good_percentage,p_poor_percentage:values.poor_percentage,p_manual_price:manualPrice})});
  await loadPage();msg("Automatic buying rule saved. Research remains separate and read-only.","success");
 }catch(e){msg(e.message||String(e),"error")}finally{button.disabled=false}
}
async function resetProduct(masterId){
 const p=master.find(x=>x.product_id===masterId);if(!p)return;
 if(!confirm("Reset this product to Inactive Buying? This clears the subscriber's buying price configuration."))return;
 try{
  await api("/rest/v1/rpc/configure_master_catalogue_buying_product",{method:"POST",body:JSON.stringify({p_tenant_id:tenantId,p_master_product_id:masterId,p_mode:"off"})});
  await loadPage();msg("Product reset to Inactive. It remains in the master catalogue but is no longer active for this subscriber.","success");
 }catch(e){msg(e.message||String(e),"error")}
}
async function refreshForCategory(){
 masterPage=1;
 $("master-branch").value="";
 $("master-manufacturer").value="";
 await loadFacets();
 await loadPage();
}
$("select-all-products").addEventListener("change",toggleSelectAll);
$("bulk-add").addEventListener("click",addSelectedProducts);
$("master-category").addEventListener("change",refreshForCategory);
$("master-branch").addEventListener("change",async()=>{masterPage=1;$("master-manufacturer").value="";await loadFacets();await loadPage()});
$("master-manufacturer").addEventListener("change",async()=>{masterPage=1;await loadPage()});
$("master-search").addEventListener("input",()=>{clearTimeout(searchTimer);searchTimer=setTimeout(()=>{masterPage=1;loadPage().catch(e=>msg(e.message||String(e),"error"))},350)});
$("prev-page").addEventListener("click",async()=>{if(masterPage>1){masterPage--;await loadPage()}});
$("next-page").addEventListener("click",async()=>{if(masterPage<Math.ceil(totalProducts/pageSize)){masterPage++;await loadPage()}});
$("sign-out").addEventListener("click",()=>{if(window.tradeflowSubscriberSignOut)window.tradeflowSubscriberSignOut();else{localStorage.removeItem("tradeflow_subscriber_session");location.href="subscriber-login.html"}});
if(window.tradeflowSubscriberAuthReady)window.tradeflowSubscriberAuthReady.then(init).catch(e=>msg(e.message||String(e),"error"));else msg("Subscriber authentication layer did not load.","error");function toggleSelectAll(){
 window.buyingSelected=window.buyingSelected||new Set();
 buyingSelectionAllMatching=false;
 const selectable=master.filter(p=>stateFor(p).key==="inactive").map(p=>p.product_id);
 const allSelected=selectable.length&&selectable.every(id=>window.buyingSelected.has(id));
 selectable.forEach(id=>allSelected?window.buyingSelected.delete(id):window.buyingSelected.add(id));
 renderMaster();
}
function toggleAllMatching(){
 buyingSelectionAllMatching=!buyingSelectionAllMatching;
 window.buyingSelected=new Set();
 renderMaster();
}
function toggleBulkMode(){
 const automatic=$("bulk-mode")?.value==="automatic";
 $("bulk-automatic-fields")?.classList.toggle("hidden",!automatic);
}
async function addProduct(masterId,button){
 const p=master.find(x=>x.product_id===masterId);if(!p)return;
 button.disabled=true;
 try{
  await api("/rest/v1/rpc/configure_master_catalogue_buying_product",{method:"POST",body:JSON.stringify({p_tenant_id:tenantId,p_master_product_id:masterId,p_mode:"manual",p_manual_price:null})});
  await loadPage();msg("Product added. It is now Manual valuation until you enter a fixed price or configure Automatic pricing.","success");
 }catch(e){button.disabled=false;msg(e.message||String(e),"error")}
}
async function changeMode(masterId,mode){
 const p=master.find(x=>x.product_id===masterId);if(!p)return;
 if(mode==="automatic"){
  const values={sealed_percentage:p.sealed_percentage,opened_never_used_percentage:p.opened_never_used_percentage,excellent_percentage:p.excellent_percentage,good_percentage:p.good_percentage,poor_percentage:p.poor_percentage};
  try{
   await api("/rest/v1/rpc/configure_master_catalogue_buying_product",{method:"POST",body:JSON.stringify({p_tenant_id:tenantId,p_master_product_id:masterId,p_mode:"automatic",p_sealed_percentage:values.sealed_percentage,p_opened_never_used_percentage:values.opened_never_used_percentage,p_excellent_percentage:values.excellent_percentage,p_good_percentage:values.good_percentage,p_poor_percentage:values.poor_percentage,p_manual_price:p.manual_offer_price??null})});
   await loadPage();msg("Automatic pricing mode enabled. Set the percentages and optional override below.","success");
  }catch(e){renderMaster();msg(e.message||String(e),"error")}
  return;
 }
 try{
  await api("/rest/v1/rpc/configure_master_catalogue_buying_product",{method:"POST",body:JSON.stringify({p_tenant_id:tenantId,p_master_product_id:masterId,p_mode:"manual",p_manual_price:p.manual_offer_price??null})});
  await loadPage();msg("Manual mode enabled. Leave the price blank for Manual valuation or enter a fixed buying price.","success");
 }catch(e){renderMaster();msg(e.message||String(e),"error")}
}
async function saveManual(masterId,button){
 const input=document.querySelector('[data-master="'+masterId+'"].manual-input');if(!input)return;
 const value=input.value===""?null:Number(input.value);if(value!==null&&(!Number.isFinite(value)||value<0))return msg("Enter a valid manual buying price.","error");
 button.disabled=true;try{
  await api("/rest/v1/rpc/configure_master_catalogue_buying_product",{method:"POST",body:JSON.stringify({p_tenant_id:tenantId,p_master_product_id:masterId,p_mode:"manual",p_manual_price:value})});
  await loadPage();msg(value===null?"Manual valuation enabled. A staff member can value this product when a customer request arrives.":"Manual buying price saved. The fixed price now takes precedence over automatic pricing if a rule is retained.","success");
 }catch(e){msg(e.message||String(e),"error")}finally{button.disabled=false}
}
async function saveAuto(masterId,button){
 const p=master.find(x=>x.product_id===masterId);if(!p)return;
 const values={};document.querySelectorAll('.auto-input[data-master="'+masterId+'"]').forEach(i=>values[i.dataset.field]=i.value===""?null:Number(i.value));
 for(const v of Object.values(values))if(v!==null&&(!Number.isFinite(v)||v<0||v>100))return msg("Automatic percentages must be between 0 and 100.","error");
 const override=document.querySelector('.auto-override-input[data-master="'+masterId+'"]');
 const manualPrice=(override?.value||"")===""?null:Number(override.value);
 if(manualPrice!==null&&(!Number.isFinite(manualPrice)||manualPrice<0))return msg("Enter a valid fixed buying price or leave the override blank.","error");
 button.disabled=true;try{
  await api("/rest/v1/rpc/configure_master_catalogue_buying_product",{method:"POST",body:JSON.stringify({p_tenant_id:tenantId,p_master_product_id:masterId,p_mode:"automatic",p_sealed_percentage:values.sealed_percentage,p_opened_never_used_percentage:values.opened_never_used_percentage,p_excellent_percentage:values.excellent_percentage,p_good_percentage:values.good_percentage,p_poor_percentage:values.poor_percentage,p_manual_price:manualPrice})});
  await loadPage();msg("Automatic buying rule saved. Research remains separate and read-only.","success");
 }catch(e){msg(e.message||String(e),"error")}finally{button.disabled=false}
}
async function resetProduct(masterId){
 const p=master.find(x=>x.product_id===masterId);if(!p)return;
 if(!confirm("Reset this product to Inactive Buying? This clears the subscriber's buying price configuration."))return;
 try{
  await api("/rest/v1/rpc/configure_master_catalogue_buying_product",{method:"POST",body:JSON.stringify({p_tenant_id:tenantId,p_master_product_id:masterId,p_mode:"off"})});
  await loadPage();msg("Product reset to Inactive. It remains in the master catalogue but is no longer active for this subscriber.","success");
 }catch(e){msg(e.message||String(e),"error")}
}
async function refreshForCategory(){
 masterPage=1;
 $("master-branch").value="";
 $("master-manufacturer").value="";
 await loadFacets();
 await loadPage();
}
$("select-all-products").addEventListener("change",toggleSelectAll);
$("bulk-add").addEventListener("click",addSelectedProducts);
$("master-category").addEventListener("change",refreshForCategory);
$("master-branch").addEventListener("change",async()=>{masterPage=1;$("master-manufacturer").value="";await loadFacets();await loadPage()});
$("master-manufacturer").addEventListener("change",async()=>{masterPage=1;await loadPage()});
$("master-search").addEventListener("input",()=>{clearTimeout(searchTimer);searchTimer=setTimeout(()=>{masterPage=1;loadPage().catch(e=>msg(e.message||String(e),"error"))},350)});
$("prev-page").addEventListener("click",async()=>{if(masterPage>1){masterPage--;await loadPage()}});
$("next-page").addEventListener("click",async()=>{if(masterPage<Math.ceil(totalProducts/pageSize)){masterPage++;await loadPage()}});
$("sign-out").addEventListener("click",()=>{if(window.tradeflowSubscriberSignOut)window.tradeflowSubscriberSignOut();else{localStorage.removeItem("tradeflow_subscriber_session");location.href="subscriber-login.html"}});
if(window.tradeflowSubscriberAuthReady)window.tradeflowSubscriberAuthReady.then(init).catch(e=>msg(e.message||String(e),"error"));else msg("Subscriber authentication layer did not load.","error");
