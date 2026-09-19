const SUPABASE_URL="https://twfbmjwwqzxdxvclxbun.supabase.co";
const $=id=>document.getElementById(id);
let key=null,token=null,tenantId=null,categories=[],branches=[],manufacturers=[],products=[],research=[],rules=[],selectedCategory=null,selectedBranch=null,selectedProductIds=new Set();

const conditions=[
 {key:"sealed",label:"Sealed",base:"new",defaultRef:"uk_new"},
 {key:"opened_never_used",label:"Opened, Never Used",base:"new",defaultRef:"uk_new"},
 {key:"excellent",label:"Excellent",base:"used",defaultRef:"uk_used"},
 {key:"good",label:"Good",base:"used",defaultRef:"uk_used"},
 {key:"poor",label:"Poor",base:"used",defaultRef:"uk_used"}
];

function esc(v){return String(v??"").replace(/[&<>"']/g,c=>({"&":"&amp;","<":"&lt;",">":"&gt;","\"":"&quot;","'":"&#39;"}[c]||c))}
function money(v,c="GBP"){if(v===null||v===undefined||v==="")return"—";try{return new Intl.NumberFormat("en-GB",{style:"currency",currency:c||"GBP"}).format(Number(v))}catch{return(c||"")+" "+v}}
function msg(t,type=""){const el=$("message");if(el){el.textContent=t||"";el.className="message "+type}}
async function api(path,options={}){
 const h=new Headers(options.headers||{});h.set("apikey",key);h.set("Authorization","Bearer "+token);
 if(options.body)h.set("Content-Type","application/json");
 const timeoutMs=Number(options.timeoutMs)||15000;
 const fetchOptions={...options};delete fetchOptions.timeoutMs;
 const controller=new AbortController(),timer=setTimeout(()=>controller.abort(),timeoutMs);
 try{
  const r=await fetch(SUPABASE_URL+path,{...fetchOptions,headers:h,signal:controller.signal});
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
  $("business-name").textContent=auth.tenants?.[tenantId]||"What We Buy";
  await seedCatalogueIfEnabled();
  await loadCategories();
 }catch(e){msg(e.message||String(e),"error")}
}
let resetArmed=false,resetTimer=null;

async function seedCatalogueIfEnabled(){
 try{
  const result=await api("/rest/v1/rpc/seed_tenant_master_catalogue",{
   method:"POST",timeoutMs:60000,
   body:JSON.stringify({p_tenant_id:tenantId})
  });
  if(result?.products){
   msg((result.already_seeded?"TradeFlow master catalogue is already loaded.":"TradeFlow master catalogue loaded.")+" — "+result.products+" products available.","success");
  }
 }catch(e){
  const text=String(e.message||e);
  if(/pre-filled catalogue is not enabled for this subscription/i.test(text))return;
  throw e;
 }
}

async function armOrResetSelectedPrices(){
 const ids=[...selectedProductIds];
 if(!ids.length)return msg("Select at least one product first.","error");
 const btn=$("reset-selected-prices");
 if(!resetArmed){
  resetArmed=true;
  btn.classList.add("armed");
  btn.textContent="Click again to confirm reset";
  if(resetTimer)clearTimeout(resetTimer);
  resetTimer=setTimeout(()=>{
   resetArmed=false;
   btn.classList.remove("armed");
   btn.textContent="Reset selected prices";
  },5000);
  return msg("Warning: the selected products' condition pricing rules and manual/automatic base prices will be cleared. Click Reset selected prices again within 5 seconds to confirm.","error");
 }
 resetArmed=false;
 if(resetTimer)clearTimeout(resetTimer);
 btn.disabled=true;
 btn.textContent="Resetting…";
 try{
  const idList=ids.join(",");
  await api("/rest/v1/tenant_buying_condition_rules?tenant_id=eq."+encodeURIComponent(tenantId)+"&buying_product_id=in.("+idList+")",{
   method:"DELETE",headers:{Prefer:"return=minimal"}
  });
  await api("/rest/v1/tenant_buying_products?tenant_id=eq."+encodeURIComponent(tenantId)+"&id=in.("+idList+")",{
   method:"PATCH",headers:{Prefer:"return=minimal"},
   body:JSON.stringify({automatic_percentage:null,manual_offer_price:null})
  });
  msg("Reset complete for "+ids.length+" selected product"+(ids.length===1?"":"s")+". Automatic condition pricing has been cleared and the products now require manual quote/valuation until pricing is configured again.","success");
  selectedProductIds.clear();
  await loadMatrix();
 }catch(e){
  msg(e.message||String(e),"error");
 }finally{
  btn.disabled=false;
  btn.classList.remove("armed");
  btn.textContent="Reset selected prices";
 }
}

async function loadCategories(){
 try{
  // Load shared manufacturers first so the manufacturer filter is available independently.
  manufacturers=await api("/rest/v1/tenant_buying_manufacturers?select=id,name,active&tenant_id=eq."+encodeURIComponent(tenantId)+"&active=eq.true&order=name")||[];
  populateManufacturers();
  categories=await api("/rest/v1/categories?select=id,name,slug,description,active,buying_enabled,selling_enabled,sort_order&tenant_id=eq."+encodeURIComponent(tenantId)+"&buying_enabled=eq.true&active=eq.true&order=sort_order,name")||[];
  const sel=$("category-select");
  sel.innerHTML=categories.length?categories.map(c=>"<option value=\""+c.id+"\">"+esc(c.name)+"</option>").join(""):"<option value=\"\">No Buying categories</option>";
  if(categories.length){
   selectedCategory=categories[0].id;
   sel.value=selectedCategory;
   renderCategoryList();
   updateBuilderContext();
   await loadBranches();
  }else{
   selectedCategory=null;selectedBranch=null;renderCategoryList();renderBranchTabs();renderEmpty("Create a Buying category first.");updateBuilderContext();
  }
 }catch(e){msg("Could not load the Buying catalogue: "+(e.message||String(e)),"error")}
}
async function loadBranches(){
 branches=await api("/rest/v1/category_branches?select=id,category_id,name,slug,description,active,buying_enabled,selling_enabled,sort_order&tenant_id=eq."+encodeURIComponent(tenantId)+"&category_id=eq."+encodeURIComponent(selectedCategory)+"&buying_enabled=eq.true&active=eq.true&order=sort_order,name")||[];
 const sel=$("branch-select");
 sel.innerHTML=branches.length?branches.map(b=>"<option value=\""+b.id+"\">"+esc(b.name)+"</option>").join(""):"<option value=\"\">No Buying branches</option>";
 if(branches.length){
  selectedBranch=branches[0].id;sel.value=selectedBranch;renderBranchTabs();renderBranchList();updateBuilderContext();
  loadMatrix().catch(e=>msg("Products or research could not be loaded: "+(e.message||String(e)),"error"));
 }else{
  selectedBranch=null;renderBranchTabs();renderBranchList();renderEmpty("No Buying branches have been created for this category yet.");updateBuilderContext();
 }
}
function renderBranchTabs(){
 const box=$("branch-tabs");box.innerHTML=branches.map(b=>"<button type=\"button\" class=\"branch-tab "+(b.id===selectedBranch?"active":"")+"\" data-branch=\""+b.id+"\">"+esc(b.name)+"</button>").join("");
 box.querySelectorAll("[data-branch]").forEach(b=>b.onclick=async()=>{selectedBranch=b.dataset.branch;$("branch-select").value=selectedBranch;renderBranchTabs();await loadMatrix()});
}
async function loadMatrix(){
 if(!selectedBranch)return;
 msg("Loading researched prices and buying rules…");
 products=await api("/rest/v1/tenant_buying_products?select=id,category_id,branch_id,manufacturer,model,package_name,active&tenant_id=eq."+encodeURIComponent(tenantId)+"&branch_id=eq."+encodeURIComponent(selectedBranch)+"&active=eq.true&order=manufacturer,model")||[];
 const ids=products.map(p=>p.id);
 research=ids.length?await api("/rest/v1/tenant_buying_research?select=id,buying_product_id,evidence_type,source_name,source_url,observed_price,price_currency,item_condition,checked_at&tenant_id=eq."+encodeURIComponent(tenantId)+"&buying_product_id=in.("+ids.join(",")+")&order=checked_at.desc")||[]:[];
 rules=ids.length?await api("/rest/v1/tenant_buying_condition_rules?select=id,buying_product_id,sealed_percentage,opened_never_used_percentage,excellent_percentage,good_percentage,poor_percentage,sealed_reference_type,opened_never_used_reference_type,excellent_reference_type,good_reference_type,poor_reference_type,sealed_manual_price,opened_never_used_manual_price,excellent_manual_price,good_manual_price,poor_manual_price&tenant_id=eq."+encodeURIComponent(tenantId)+"&buying_product_id=in.("+ids.join(",")+")")||[]:[];
 populateManufacturers();renderMatrix();msg("Research prices loaded. Enter your percentages and save when ready.","success");
}
function latest(p,type){return research.find(r=>r.buying_product_id===p.id&&r.evidence_type===type&&r.observed_price!==null&&String(r.price_currency||"GBP").toUpperCase()==="GBP")||null}
function ruleFor(p){return rules.find(r=>r.buying_product_id===p.id)||{buying_product_id:p.id}}
function refPrice(p,base){const r=latest(p,base==="new"?"uk_new":"uk_used");return r?.observed_price??null}
function refHtml(r){if(!r)return'<div class="ref-price">—</div><div class="ref-source">No research yet</div>';return'<div class="ref-price">'+money(r.observed_price,r.price_currency)+'</div><div class="ref-source">'+(r.source_url?'<a href="'+esc(r.source_url)+'" target="_blank" rel="noopener">'+esc(r.source_name||"Source")+"</a>":esc(r.source_name||"Research"))+"<br>"+new Date(r.checked_at).toLocaleDateString("en-GB")+"</div>"}
function conditionCell(p,c){
 const rule=ruleFor(p);
 const pctField=c.key+"_percentage", refField=c.key+"_reference_type", manualField=c.key+"_manual_price";
 const value=rule[pctField]??"", ref=rule[refField]||c.defaultRef, manual=rule[manualField]??"";
 const base=refPrice(p,ref==="uk_new"?"new":"used");
 const amount=value!==""&&base!==null?(Number(base)*Number(value)/100):null;
 const hasManual=manual!==""&&manual!==null;
 return '<td class="condition-cell">'+
   '<div class="condition-name">'+c.label+'</div>'+
   '<div class="active-price '+(hasManual?'manual-active':'automatic-active')+'" data-active="'+p.id+"-"+c.key+'">'+
     '<span class="active-label">'+(hasManual?'ACTIVE BUYING PRICE — MANUAL':'ACTIVE BUYING PRICE — AUTOMATIC')+'</span>'+
     '<strong>'+(hasManual?money(manual):(amount!==null?money(amount):'Not available'))+'</strong>'+
   '</div>'+
   '<div class="pricing-label">Automatic price basis</div>'+
   '<select class="reference-select" data-product="'+p.id+'" data-field="'+refField+'">'+
     '<option value="uk_new" '+(ref==="uk_new"?"selected":"")+'>UK New research</option>'+
     '<option value="uk_used" '+(ref==="uk_used"?"selected":"")+'>UK Used research</option>'+
   '</select>'+
   '<div class="pricing-label">Automatic percentage</div>'+
   '<input class="pct" data-product="'+p.id+'" data-field="'+pctField+'" type="number" min="0" max="100" step="0.01" value="'+esc(value)+'" placeholder="%">'+
   '<div class="automatic-result" data-calc="'+p.id+"-"+c.key+'">'+(amount!==null?'Automatic would be '+money(amount):'<span class="not-set">Automatic price unavailable</span>')+'</div>'+
   '<div class="pricing-help">'+(base!==null?money(base)+" current "+(ref==="uk_new"?"UK New":"UK Used")+" reference": "No "+(ref==="uk_new"?"UK New":"UK Used")+" research found")+'</div>'+
   '<div class="pricing-label">Manual override <span class="field-hint">(leave blank to use automatic)</span></div>'+
   '<input class="manual-price" data-product="'+p.id+'" data-field="'+manualField+'" type="number" min="0" step="0.01" value="'+esc(manual)+'" placeholder="Exact buying price £">'+
   '<div class="manual-result '+(hasManual?'manual-active-text':'')+'" data-manual="'+p.id+"-"+c.key+'">'+(hasManual?'Manual override active — '+money(manual)+'. Clear this field to return to automatic pricing.':'No manual override — automatic pricing is active.')+'</div>'+
   '</td>';
}
function visibleProducts(){
 const manufacturer=$("manufacturer-select").value||"",filter=($("model-filter").value||"").trim().toLowerCase();
 return products.filter(p=>(!manufacturer||p.manufacturer===manufacturer)&&(!filter||((p.model||"")+" "+(p.package_name||"")).toLowerCase().includes(filter)));
}
function renderMatrix(){
 const visible=visibleProducts();
 const branch=branches.find(b=>b.id===selectedBranch);
 $("matrix-title").textContent=(categories.find(c=>c.id===selectedCategory)?.name||"Buying")+" / "+(branch?.name||"");
 $("row-count").textContent=visible.length+" product"+(visible.length===1?"":"s");
 const body=$("matrix-body");
 if(!visible.length){body.innerHTML='<tr><td colspan="9" class="empty">No products match this view. Add products below or change the manufacturer/search filter.</td></tr>';updateSelectionUI();return}
 body.innerHTML=visible.map(p=>{const n=latest(p,"uk_new"),u=latest(p,"uk_used");return"<tr><td class=\"select-col\"><input class=\"product-select\" type=\"checkbox\" data-product-select=\""+p.id+"\" "+(selectedProductIds.has(p.id)?"checked":"")+"></td><td class=\"product-cell\"><strong>"+esc(p.manufacturer)+" "+esc(p.model)+"</strong><span>"+esc(p.package_name||"")+"</span></td><td class=\"ref-cell\">"+refHtml(n)+"</td><td class=\"ref-cell\">"+refHtml(u)+"</td>"+conditions.map(c=>conditionCell(p,c)).join("")+"</tr>"}).join("");
 bindPercentInputs();
 bindProductSelection();
 bindHeaderSelection();
 updateSelectionUI();
}
function bindProductSelection(){
 document.querySelectorAll("[data-product-select]").forEach(cb=>cb.addEventListener("change",()=>{
   if(cb.checked)selectedProductIds.add(cb.dataset.product);else selectedProductIds.delete(cb.dataset.product);
   updateSelectionUI();
 }));
}
function bindHeaderSelection(){const h=$("select-all-header");if(h)h.addEventListener("change",e=>{visibleProducts().forEach(p=>e.target.checked?selectedProductIds.add(p.id):selectedProductIds.delete(p.id));renderMatrix()})}
function updateSelectionUI(){
 const visible=visibleProducts();
 const selectedVisible=visible.filter(p=>selectedProductIds.has(p.id));
 const count=$("selected-count");if(count)count.textContent=selectedProductIds.size;
 const header=$("select-all-header");
 if(header){header.checked=visible.length>0&&selectedVisible.length===visible.length;header.indeterminate=selectedVisible.length>0&&selectedVisible.length<visible.length}
}
function bindPercentInputs(){
 document.querySelectorAll(".pct,.reference-select").forEach(input=>input.addEventListener("input",updatePricingCell));
 document.querySelectorAll(".pct,.reference-select").forEach(input=>input.addEventListener("change",updatePricingCell));
 document.querySelectorAll(".manual-price").forEach(input=>input.addEventListener("input",()=>{
   const box=document.querySelector('[data-manual="'+input.dataset.product+"-"+input.dataset.field.replace("_manual_price","")+'"]');
   if(box)box.innerHTML=input.value!==""?money(input.value)+" manual override":'<span class="not-set">No manual override</span>';
 }));
}
function updatePricingCell(e){
 const productId=e.target.dataset.product;
 const field=e.target.dataset.field||"";
 const c=conditions.find(x=>x.key===field.replace("_percentage","").replace("_reference_type",""));
 if(!c)return;
 const ref=document.querySelector('[data-product="'+productId+'"][data-field="'+c.key+'_reference_type"]')?.value||c.defaultRef;
 const pct=document.querySelector('[data-product="'+productId+'"][data-field="'+c.key+'_percentage"]')?.value||"";
 const manual=document.querySelector('[data-product="'+productId+'"][data-field="'+c.key+'_manual_price"]')?.value||"";
 const p=products.find(x=>x.id===productId),base=p?refPrice(p,ref==="uk_new"?"new":"used"):null;
 const amount=pct!==""&&base!==null?Number(base)*Number(pct)/100:null;
 const active=document.querySelector('[data-active="'+productId+"-"+c.key+'"]');
 if(active){
   const hasManual=manual!=="";
   active.className="active-price "+(hasManual?"manual-active":"automatic-active");
   active.innerHTML='<span class="active-label">'+(hasManual?'ACTIVE BUYING PRICE — MANUAL':'ACTIVE BUYING PRICE — AUTOMATIC')+'</span><strong>'+(hasManual?money(manual):(amount!==null?money(amount):'Not available'))+'</strong>';
 }
 const box=document.querySelector('[data-calc="'+productId+"-"+c.key+'"]');
 if(box)box.innerHTML=amount!==null?'Automatic would be '+money(amount):'<span class="not-set">Automatic price unavailable</span>';
 const help=box?.nextElementSibling;
 if(help)help.textContent=base!==null?money(base)+" current "+(ref==="uk_new"?"UK New":"UK Used")+" reference":"No "+(ref==="uk_new"?"UK New":"UK Used")+" research found";
 const manualBox=document.querySelector('[data-manual="'+productId+"-"+c.key+'"]');
 if(manualBox)manualBox.textContent=manual!==""?'Manual override active — '+money(manual)+'. Clear this field to return to automatic pricing.':'No manual override — automatic pricing is active.';
}
function populateManufacturers(){
 const current=$("manufacturer-select").value;
 const names=manufacturers.map(m=>m.name).sort((a,b)=>a.localeCompare(b));
 $("manufacturer-select").innerHTML='<option value="">All manufacturers</option>'+names.map(n=>'<option value="'+esc(n)+'">'+esc(n)+"</option>").join("");
 if(names.includes(current))$("manufacturer-select").value=current;
 renderManufacturerList();
}
function renderEmpty(text){$("matrix-body").innerHTML='<tr><td colspan="8" class="empty">'+esc(text)+"</td></tr>";$("row-count").textContent=""}
const pricingProfiles={
 "70":{sealed:70,opened_never_used:65,excellent:60,good:50,poor:40},
 "60":{sealed:60,opened_never_used:55,excellent:50,good:40,poor:30},
 "50":{sealed:50,opened_never_used:45,excellent:40,good:30,poor:20},
 "40":{sealed:40,opened_never_used:35,excellent:30,good:20,poor:10}
};
function renderPricingProfile(){
 const key=$("pricing-profile")?.value||"70",p=pricingProfiles[key];if(!p)return;
 const labels={sealed:"Sealed",opened_never_used:"Opened, Never Used",excellent:"Excellent",good:"Good",poor:"Poor"};
 const box=$("pricing-rule-preview");if(!box)return;
 box.innerHTML=Object.entries(p).map(([k,v])=>'<div class="rule-chip"><strong>'+v+'%</strong><small>'+labels[k]+'</small></div>').join("");
}
async function applyPricingProfile(){
 const profile=pricingProfiles[$("pricing-profile").value||"70"];
 if(!profile)return;
 if(!selectedBranch)return msg("Select a branch before applying a pricing profile.","error");
 if(!products.length)return msg("There are no products in this branch to update.","error");
 const rows=products.map(p=>({
   tenant_id:tenantId,buying_product_id:p.id,
   sealed_percentage:profile.sealed,
   opened_never_used_percentage:profile.opened_never_used,
   excellent_percentage:profile.excellent,
   good_percentage:profile.good,
   poor_percentage:profile.poor
 }));
 const btn=$("apply-pricing-profile");btn.disabled=true;btn.textContent="Updating…";
 try{
   await api("/rest/v1/tenant_buying_condition_rules?on_conflict=tenant_id,buying_product_id",{method:"POST",headers:{Prefer:"resolution=merge-duplicates,return=minimal"},body:JSON.stringify(rows)});
   msg("Pricing profile applied to all "+products.length+" products in this branch. Manual overrides and research were left unchanged.","success");
   await loadMatrix();
 }catch(e){msg(e.message||String(e),"error")}
 finally{btn.disabled=false;btn.textContent="Update all products"}
}

function slugify(v){return String(v||"").trim().toLowerCase().replace(/[^a-z0-9]+/g,"-").replace(/^-+|-+$/g,"")||crypto.randomUUID()}
function toggleManagement(){
 const p=$("management-panel");p.hidden=!p.hidden;
 if(!p.hidden){renderCategoryList();renderBranchList();renderManufacturerList();updateBuilderContext()}
}
function updateBuilderContext(){
 const cat=categories.find(c=>c.id===selectedCategory);
 const branch=branches.find(b=>b.id===selectedBranch);
 $("branch-builder-title").textContent=cat?"Branches / Types in "+cat.name:"Branches / Types";
 $("branch-builder-help").textContent=cat?"Select a branch to see exactly where you are building.":"Select a category first";
 $("manufacturer-builder-title").textContent=branch?"Manufacturers in "+(cat?.name||"")+" → "+branch.name:"Manufacturers";
 $("manufacturer-builder-help").textContent=branch?"Manufacturers are shared; products are assigned to this category and branch.":"Shared manufacturer list";
 $("new-branch-name").placeholder=cat?"e.g. Digital, Lenses, Tripods":"Select a category first";
 $("add-branch-button").disabled=!cat;
}
function renderCategoryList(){
 const box=$("category-list");if(!box)return;
 box.innerHTML=categories.map(c=>'<div class="manage-row '+(c.id===selectedCategory?"selected":"")+'"><button type="button" class="select-row" data-select-cat="'+c.id+'"><div class="row-info"><strong>'+esc(c.name)+'</strong><small>'+(branches.filter(b=>b.category_id===c.id).length)+' branch'+(branches.filter(b=>b.category_id===c.id).length===1?"":"es")+'</small></div></button><div class="row-actions"><button type="button" class="mini" data-save-cat="'+c.id+'">Save</button></div></div>').join("")||'<div class="muted">No categories.</div>';
 box.querySelectorAll("[data-select-cat]").forEach(b=>b.onclick=async()=>{selectedCategory=b.dataset.selectCat;await loadBranches();renderCategoryList();updateBuilderContext()});
 box.querySelectorAll("[data-save-cat]").forEach(b=>b.onclick=()=>saveCategory(b.dataset.saveCat));
}
function renderBranchList(){
 const box=$("branch-list");if(!box)return;
 const cat=categories.find(c=>c.id===selectedCategory);
 box.innerHTML=branches.map(b=>'<div class="manage-row '+(b.id===selectedBranch?"selected":"")+'"><button type="button" class="select-row" data-select-branch="'+b.id+'"><div class="row-info"><strong>'+esc(b.name)+'</strong><small>'+esc(cat?.name||"Category")+' → '+esc(b.name)+'</small></div></button><div class="row-actions"><button type="button" class="mini" data-save-branch="'+b.id+'">Save</button></div></div>').join("")||'<div class="muted">'+(cat?"No branches in "+esc(cat.name)+" yet.":"Select a category to see its branches.")+'</div>';
 box.querySelectorAll("[data-select-branch]").forEach(b=>b.onclick=async()=>{selectedBranch=b.dataset.selectBranch;$("branch-select").value=selectedBranch;renderBranchTabs();await loadMatrix();renderBranchList();updateBuilderContext()});
 box.querySelectorAll("[data-save-branch]").forEach(b=>b.onclick=()=>saveBranch(b.dataset.saveBranch));
}
function renderManufacturerList(){
 const box=$("manufacturer-list");if(!box)return;
 const cat=categories.find(c=>c.id===selectedCategory),branch=branches.find(b=>b.id===selectedBranch);
 const names=manufacturers.filter(m=>!branch||products.some(p=>p.branch_id===branch.id&&p.manufacturer===m.name));
 box.innerHTML=names.map(m=>'<div class="manage-row"><div class="row-info"><strong>'+esc(m.name)+'</strong><small>'+(branch?("Used in "+esc(cat?.name||"")+" → "+esc(branch.name)):"Available to the catalogue")+'</small></div><div class="row-actions"><button type="button" class="mini" data-save-manufacturer="'+m.id+'">Save</button></div></div>').join("")||'<div class="muted">'+(branch?"No products from a manufacturer have been added to this branch yet.":"No manufacturers yet.")+'</div>';
 box.querySelectorAll("[data-save-manufacturer]").forEach(b=>b.onclick=()=>saveManufacturer(b.dataset.saveManufacturer));
}
async function saveCategory(id){
 const input=document.querySelector('[data-cat="'+id+'"]'),name=input?.value.trim();if(!name)return msg("Enter a category name.","error");
 try{await api("/rest/v1/categories?id=eq."+encodeURIComponent(id)+"&tenant_id=eq."+encodeURIComponent(tenantId),{method:"PATCH",headers:{Prefer:"return=minimal"},body:JSON.stringify({name,slug:slugify(name),updated_at:new Date().toISOString()})});msg("Category updated.","success");await loadCategories();updateBuilderContext()}catch(e){msg(e.message||String(e),"error")}
}
async function addCategory(e){
 e.preventDefault();const name=$("new-category-name").value.trim();if(!name)return;
 try{await api("/rest/v1/categories",{method:"POST",headers:{Prefer:"return=representation"},body:JSON.stringify({tenant_id:tenantId,name,slug:slugify(name),description:$("new-category-description").value.trim()||null,active:true,buying_enabled:true,selling_enabled:true,sort_order:categories.length})});$("new-category-name").value="";$("new-category-description").value="";msg("Category added.","success");await loadCategories();updateBuilderContext()}catch(e){msg(e.message||String(e),"error")}
}
async function saveBranch(id){
 const input=document.querySelector('[data-branch-name="'+id+'"]'),name=input?.value.trim();if(!name)return msg("Enter a branch name.","error");
 try{await api("/rest/v1/category_branches?id=eq."+encodeURIComponent(id)+"&tenant_id=eq."+encodeURIComponent(tenantId),{method:"PATCH",headers:{Prefer:"return=minimal"},body:JSON.stringify({name,slug:slugify(name),updated_at:new Date().toISOString()})});msg("Branch updated.","success");await loadBranches();updateBuilderContext()}catch(e){msg(e.message||String(e),"error")}
}
async function addBranch(e){
 e.preventDefault();if(!selectedCategory)return msg("Select a category first.","error");const name=$("new-branch-name").value.trim();if(!name)return;
 try{await api("/rest/v1/category_branches",{method:"POST",headers:{Prefer:"return=representation"},body:JSON.stringify({tenant_id:tenantId,category_id:selectedCategory,name,slug:slugify(name),description:$("new-branch-description").value.trim()||null,active:true,buying_enabled:true,selling_enabled:true,sort_order:branches.length})});$("new-branch-name").value="";$("new-branch-description").value="";msg("Branch added.","success");await loadBranches();updateBuilderContext()}catch(e){msg(e.message||String(e),"error")}
}
async function saveManufacturer(id){
 const input=document.querySelector('[data-manufacturer-name="'+id+'"]'),name=input?.value.trim();if(!name)return msg("Enter a manufacturer name.","error");
 const old=manufacturers.find(m=>m.id===id);if(!old||old.name===name)return;
 try{
  await api("/rest/v1/tenant_buying_manufacturers?id=eq."+encodeURIComponent(id)+"&tenant_id=eq."+encodeURIComponent(tenantId),{method:"PATCH",headers:{Prefer:"return=minimal"},body:JSON.stringify({name,updated_at:new Date().toISOString()})});
  await api("/rest/v1/tenant_buying_products?tenant_id=eq."+encodeURIComponent(tenantId)+"&manufacturer=eq."+encodeURIComponent(old.name),{method:"PATCH",headers:{Prefer:"return=minimal"},body:JSON.stringify({manufacturer:name,updated_at:new Date().toISOString()})});
  msg("Manufacturer updated and linked products renamed.","success");await loadMatrix();renderManufacturerList();updateBuilderContext();
 }catch(e){msg(e.message||String(e),"error")}
}
async function addManufacturer(e){
 e.preventDefault();const name=$("new-manufacturer-name").value.trim();if(!name)return;
 try{await api("/rest/v1/tenant_buying_manufacturers",{method:"POST",headers:{Prefer:"return=representation"},body:JSON.stringify({tenant_id:tenantId,name,active:true})});$("new-manufacturer-name").value="";msg("Manufacturer added.","success");manufacturers=await api("/rest/v1/tenant_buying_manufacturers?select=id,name,active&tenant_id="+encodeURIComponent(tenantId)+"&active=eq.true&order=name")||[];populateManufacturers();renderManufacturerList();updateBuilderContext()}catch(e){msg(e.message||String(e),"error")}
}
function previewBulkReference(){
 const ref=document.querySelector('input[name="bulk-reference"]:checked')?.value||"uk_new";
 const ids=new Set(selectedProductIds);
 ids.forEach(id=>{
   const p=products.find(x=>x.id===id); if(!p)return;
   conditions.forEach(c=>{
     const sel=document.querySelector('[data-product="'+id+'"][data-field="'+c.key+'_reference_type"]');
     if(sel)sel.value=ref;
     const pct=document.querySelector('[data-product="'+id+'"][data-field="'+c.key+'_percentage"]')?.value||"";
     const manual=document.querySelector('[data-product="'+id+'"][data-field="'+c.key+'_manual_price"]')?.value||"";
     const base=refPrice(p,ref==="uk_new"?"new":"used");
     const amount=pct!==""&&base!==null?Number(base)*Number(pct)/100:null;
     const active=document.querySelector('[data-active="'+id+"-"+c.key+'"]');
     if(active){
       active.className="active-price "+(manual!==""?"manual-active":"automatic-active");
       active.innerHTML='<span class="active-label">'+(manual!==""?"ACTIVE BUYING PRICE — MANUAL":"ACTIVE BUYING PRICE — AUTOMATIC")+'</span><strong>'+(manual!==""?money(manual):(amount!==null?money(amount):"Not available"))+'</strong>';
     }
     const box=document.querySelector('[data-calc="'+id+"-"+c.key+'"]');
     if(box)box.innerHTML=amount!==null?'Automatic would be '+money(amount):'<span class="not-set">Automatic price unavailable — manual quote/valuation required</span>';
     const help=box?.nextElementSibling;
     if(help)help.textContent=base!==null?money(base)+" current "+(ref==="uk_new"?"UK New":"UK Used")+" reference":"No "+(ref==="uk_new"?"UK New":"UK Used")+" research found";
   });
 });
}
async function applySelectedReference(){
 const ids=[...selectedProductIds];
 if(!ids.length)return msg("Select at least one product first.","error");
 const ref=document.querySelector('input[name="bulk-reference"]:checked')?.value||"uk_new";
 const profile=pricingProfiles[$("bulk-pricing-profile")?.value||"70"];
 const rows=ids.map(id=>({tenant_id:tenantId,buying_product_id:id,
   sealed_reference_type:ref,opened_never_used_reference_type:ref,excellent_reference_type:ref,good_reference_type:ref,poor_reference_type:ref,
   sealed_percentage:profile.sealed,opened_never_used_percentage:profile.opened_never_used,excellent_percentage:profile.excellent,good_percentage:profile.good,poor_percentage:profile.poor
 }));
 const btn=$("apply-selected-reference");btn.disabled=true;btn.textContent="Applying…";
 try{
   await api("/rest/v1/tenant_buying_condition_rules?on_conflict=tenant_id,buying_product_id",{method:"POST",headers:{Prefer:"resolution=merge-duplicates,return=minimal"},body:JSON.stringify(rows)});
   msg("Pricing applied to "+ids.length+" selected product"+(ids.length===1?"":"s")+": "+(ref==="uk_new"?"UK New":"UK Used")+" research with the selected percentage profile. Manual overrides and research were preserved.","success");
   await loadMatrix();
 }catch(e){msg(e.message||String(e),"error")}
 finally{btn.disabled=false;btn.textContent="Apply pricing to selected"}
}
async function saveAll(){
 const payload=[];
document.querySelectorAll(".pct,.reference-select,.manual-price").forEach(i=>{
 let row=payload.find(x=>x.buying_product_id===i.dataset.product);
 if(!row){row={tenant_id:tenantId,buying_product_id:i.dataset.product};payload.push(row)}
 if(i.classList.contains("pct"))row[i.dataset.field]=i.value===""?null:Number(i.value);
 else if(i.classList.contains("manual-price"))row[i.dataset.field]=i.value===""?null:Number(i.value);
 else row[i.dataset.field]=i.value;
});
 if(!payload.length)return msg("There are no products to save.","error");
 try{await api("/rest/v1/tenant_buying_condition_rules?on_conflict=tenant_id,buying_product_id",{method:"POST",headers:{Prefer:"resolution=merge-duplicates,return=minimal"},body:JSON.stringify(payload)});msg("Buying prices saved. Automatic offer calculations can now use the configured condition rules.","success");await loadMatrix()}catch(e){msg(e.message||String(e),"error")}
}
async function addProduct(e){
 e.preventDefault();if(!selectedBranch)return msg("Select a Buying branch first.","error");
 const manufacturer=$("manufacturer").value.trim(),model=$("model").value.trim();if(!manufacturer||!model)return;
 try{
  const existing=manufacturers.find(m=>m.name.toLowerCase()===manufacturer.toLowerCase());
  if(!existing)await api("/rest/v1/tenant_buying_manufacturers",{method:"POST",headers:{Prefer:"return=minimal"},body:JSON.stringify({tenant_id:tenantId,name:manufacturer,active:true})});
  await api("/rest/v1/tenant_buying_products",{method:"POST",headers:{Prefer:"return=representation"},body:JSON.stringify({tenant_id:tenantId,category_id:selectedCategory,branch_id:selectedBranch,manufacturer,model,package_name:$("package").value.trim()||null,active:true,automatic_percentage:null,manual_offer_price:null})});
  $("manufacturer").value="";$("model").value="";$("package").value="";msg("Product added. Research can now populate its New and Used reference prices.","success");manufacturers=await api("/rest/v1/tenant_buying_manufacturers?select=id,name,active&tenant_id=eq."+encodeURIComponent(tenantId)+"&active=eq.true&order=name")||[];await loadMatrix();
 }catch(e){msg(e.message||String(e),"error")}
}

document.querySelectorAll('input[name="bulk-reference"]').forEach(r=>r.addEventListener("change",previewBulkReference));
$("select-all-visible").addEventListener("click",()=>{visibleProducts().forEach(p=>selectedProductIds.add(p.id));renderMatrix()});
$("clear-selection").addEventListener("click",()=>{selectedProductIds.clear();renderMatrix()});
$("reset-selected-prices").addEventListener("click",armOrResetSelectedPrices);
$("apply-selected-reference").addEventListener("click",applySelectedReference);
$("pricing-profile").addEventListener("change",renderPricingProfile);$("apply-pricing-profile").addEventListener("click",applyPricingProfile);renderPricingProfile();
$("manage-categories").addEventListener("click",toggleManagement);
$("manage-branches").addEventListener("click",toggleManagement);
$("manage-manufacturers").addEventListener("click",toggleManagement);
$("category-form").addEventListener("submit",addCategory);
$("branch-form").addEventListener("submit",addBranch);
$("manufacturer-form").addEventListener("submit",addManufacturer);
$("category-select").addEventListener("change",async e=>{selectedCategory=e.target.value;await loadBranches()});
$("branch-select").addEventListener("change",async e=>{selectedBranch=e.target.value;renderBranchTabs();await loadMatrix()});
$("manufacturer-select").addEventListener("change",()=>{renderMatrix();});
$("model-filter").addEventListener("input",renderMatrix);
$("save-all").addEventListener("click",saveAll);
$("add-product-form").addEventListener("submit",addProduct);
$("sign-out").addEventListener("click",()=>{localStorage.removeItem("tradeflow_subscriber_session");location.href="subscriber-login.html"});
if(window.tradeflowSubscriberAuthReady)window.tradeflowSubscriberAuthReady.then(init).catch(e=>msg(e.message||String(e),"error"));else msg("Subscriber authentication layer did not load.","error");
