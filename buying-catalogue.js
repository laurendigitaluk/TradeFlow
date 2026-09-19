const SUPABASE_URL="https://twfbmjwwqzxdxvclxbun.supabase.co";
const $=id=>document.getElementById(id);
let key=null,token=null,tenantId=null;
let master=[],selections=new Map(),products=[],rules=[];
let masterPage=1;
const pageSize=75;

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
  $("business-name").textContent=auth.tenants?.[tenantId]||"Buying Pricing";
  await loadAll();
 }catch(e){msg(e.message||String(e),"error")}
}
async function loadAll(){
 msg("Loading the standalone TradeFlow master catalogue…");
 const rows=await api("/rest/v1/rpc/get_master_catalogue_for_selection",{method:"POST",body:JSON.stringify({p_tenant_id:tenantId}),timeoutMs:45000});
 master=Array.isArray(rows)?rows:[];
 const [sel,prod]=await Promise.all([
  api("/rest/v1/tenant_catalogue_selections?select=master_product_id,buying_enabled,selling_enabled,active,category_id,branch_id,manufacturer,model,package_name&tenant_id=eq."+encodeURIComponent(tenantId)+"&active=eq.true"),
  api("/rest/v1/tenant_buying_products?select=id,category_id,branch_id,manufacturer,model,package_name,active,manual_offer_price&tenant_id=eq."+encodeURIComponent(tenantId))
 ]);
 selections=new Map((sel||[]).map(x=>[x.master_product_id,x]));
 products=Array.isArray(prod)?prod:[];
 const ids=products.map(p=>p.id);
 rules=ids.length?await api("/rest/v1/tenant_buying_condition_rules?select=id,buying_product_id,sealed_percentage,opened_never_used_percentage,excellent_percentage,good_percentage,poor_percentage,sealed_reference_type,opened_never_used_reference_type,excellent_reference_type,good_reference_type,poor_reference_type&tenant_id=eq."+encodeURIComponent(tenantId)+"&buying_product_id=in.("+ids.join(",")+")"):[]; 
 $("catalogue-status").textContent=master.length+" products available";
 $("catalogue-status").classList.add("live");
 $("catalogue-help").textContent="Standalone TradeFlow catalogue. Subscriber selections and prices are tenant-specific; GearCashOut is not queried by this page.";
 populateFilters();
 renderMaster();
 msg("Master catalogue loaded. Pricing is controlled from this page.","success");
}
function masterCategories(){
 const m=new Map();master.forEach(p=>{const n=p.category_name||"Uncategorised";if(!m.has(n))m.set(n,{id:n,name:n,count:0});m.get(n).count++});
 return [...m.values()].sort((a,b)=>a.name.localeCompare(b.name));
}
function masterBranches(){
 const cat=$("master-category").value||"",m=new Map();
 master.filter(p=>(!cat||p.category_name===cat)&&p.branch_name).forEach(p=>{if(!m.has(p.branch_name))m.set(p.branch_name,{id:p.branch_name,name:p.branch_name,count:0});m.get(p.branch_name).count++});
 return [...m.values()].sort((a,b)=>a.name.localeCompare(b.name));
}
function masterManufacturers(){
 const cat=$("master-category").value||"",branch=$("master-branch").value||"",m=new Map();
 master.filter(p=>(!cat||p.category_name===cat)&&(!branch||p.branch_name===branch)&&p.manufacturer_id).forEach(p=>{if(!m.has(p.manufacturer_id))m.set(p.manufacturer_id,{id:p.manufacturer_id,name:p.manufacturer_name,count:0});m.get(p.manufacturer_id).count++});
 return [...m.values()].sort((a,b)=>a.name.localeCompare(b.name));
}
function populateFilters(){
 const oldCat=$("master-category").value||"",oldBranch=$("master-branch").value||"",oldMan=$("master-manufacturer").value||"";
 const cats=masterCategories();
 $("master-category").innerHTML='<option value="">All categories</option>'+cats.map(x=>'<option value="'+esc(x.id)+'">'+esc(x.name)+" ("+x.count+")</option>").join("");
 if(cats.some(x=>x.id===oldCat))$("master-category").value=oldCat;
 const branches=masterBranches();
 $("master-branch").innerHTML='<option value="">All branches</option>'+branches.map(x=>'<option value="'+esc(x.id)+'">'+esc(x.name)+" ("+x.count+")</option>").join("");
 if(branches.some(x=>x.id===oldBranch))$("master-branch").value=oldBranch;
 const mans=masterManufacturers();
 $("master-manufacturer").innerHTML='<option value="">All manufacturers</option>'+mans.map(x=>'<option value="'+esc(x.id)+'">'+esc(x.name)+" ("+x.count+")</option>").join("");
 if(mans.some(x=>x.id===oldMan))$("master-manufacturer").value=oldMan;
}
function filteredMaster(){
 const cat=$("master-category").value||"",branch=$("master-branch").value||"",man=$("master-manufacturer").value||"",q=($("master-search").value||"").trim().toLowerCase();
 return master.filter(p=>
  (!cat||p.category_name===cat)&&(!branch||p.branch_name===branch)&&(!man||p.manufacturer_id===man)&&
  (!q||[p.model,p.package_name,p.product_type,p.catalogue_category,p.main_category,p.manufacturer_name,p.branch_name,p.category_name].some(v=>String(v||"").toLowerCase().includes(q)))
 );
}
function productForMaster(p){
 const s=selections.get(p.product_id);
 if(!s||!s.buying_enabled||!s.active)return null;
 return products.find(x=>x.active&&x.category_id===s.category_id&&x.branch_id===s.branch_id&&String(x.manufacturer||"").toLowerCase()===String(p.manufacturer_name||"").toLowerCase()&&String(x.model||"").toLowerCase()===String(p.model||"").toLowerCase()&&String(x.package_name||"").toLowerCase()===String(p.package_name||"").toLowerCase())||null;
}
function ruleFor(id){return rules.find(r=>r.buying_product_id===id)||null}
function stateFor(p){
 const s=selections.get(p.product_id),bp=productForMaster(p);
 if(!s||!s.buying_enabled||!s.active)return {key:"inactive",label:"Inactive",product:bp,rule:null};
 const r=bp?ruleFor(bp.id):null;
 if(bp?.manual_offer_price!==null&&bp?.manual_offer_price!==undefined)return {key:"manual",label:"Manual price / override",product:bp,rule:r};
 if(r)return {key:"auto",label:"Automatic pricing",product:bp,rule:r};
 return {key:"valuation",label:"Manual valuation",product:bp,rule:null};
}
function refSummary(bp){
 if(!bp)return '<div class="ref-summary">Not active for Buying.</div>';
 const rs=rules.find(r=>r.buying_product_id===bp.id);
 if(bp.manual_offer_price!==null&&bp.manual_offer_price!==undefined){
  return '<div class="ref-summary"><strong>Manual price / override:</strong> '+money(bp.manual_offer_price)+(rs?'<br><span class="muted">Automatic rule retained as fallback.</span>':'')+'</div>';
 }
 if(rs)return '<div class="ref-summary"><strong>Automatic rule:</strong><br>Sealed '+(rs.sealed_percentage??"—")+"% · Opened "+(rs.opened_never_used_percentage??"—")+"% · Excellent "+(rs.excellent_percentage??"—")+"% · Good "+(rs.good_percentage??"—")+"% · Poor "+(rs.poor_percentage??"—")+"%</div>";
 return '<div class="ref-summary">Manual valuation — no fixed price or automatic rule configured.</div>';
}
function editorHtml(p,s){
 const bp=s.product,r=s.rule;
 if(s.key==="manual")return '<div class="price-editor"><label class="price-help">Buying price / override (£)</label><input class="manual-input" data-master="'+p.product_id+'" type="number" min="0" step="0.01" value="'+esc(bp?.manual_offer_price??"")+'" placeholder="Enter price you are willing to pay"><button class="save-price" data-save-manual="'+p.product_id+'">Save price</button><div class="price-help">This fixed price overrides automatic pricing for this product.</div></div>';
 if(s.key==="auto")return '<div class="price-editor"><div class="price-grid">'+
  [['Sealed','sealed_percentage'],['Opened','opened_never_used_percentage'],['Excellent','excellent_percentage'],['Good','good_percentage'],['Poor','poor_percentage']].map(([l,f])=>'<label>'+l+' %<input class="auto-input" data-master="'+p.product_id+'" data-field="'+f+'" type="number" min="0" max="100" step="0.01" value="'+esc(r?.[f]??"")+'" placeholder="%"></label>').join("")+
  '</div><label class="price-help" style="display:block;margin-top:10px">Optional fixed buying price / override (£)<input class="manual-input auto-override-input" data-master="'+p.product_id+'" type="number" min="0" step="0.01" value="'+esc(bp?.manual_offer_price??"")+'" placeholder="Leave blank to use automatic pricing"></label><button class="save-price" data-save-auto="'+p.product_id+'">Save automatic rule</button><div class="price-help">Leave the override blank to calculate from research. Enter a price to override the calculated price for this product. Sealed and Opened use UK New; Excellent, Good and Poor use UK Used by default.</div></div>';
 return "";
}
function renderMaster(){
 const rows=filteredMaster(),pages=Math.max(1,Math.ceil(rows.length/pageSize));if(masterPage>pages)masterPage=pages;
 const start=(masterPage-1)*pageSize,visible=rows.slice(start,start+pageSize);
 $("master-count").textContent=rows.length+" matching products";
 $("page-info").textContent="Showing "+(visible.length?start+1:0)+"–"+(start+visible.length)+" of "+rows.length+" · page "+masterPage+" of "+pages;
 $("master-body").innerHTML=visible.length?visible.map(p=>{
  const s=stateFor(p);
  return '<tr class="status-'+s.key+'">'+
   '<td class="product-name"><strong>'+esc(p.manufacturer_name+" "+p.model)+'</strong><small>'+esc(p.package_name)+(p.product_type?" · "+esc(p.product_type):"")+(p.notes?"<br>"+esc(p.notes):"")+'</small></td>'+
   '<td>'+esc(p.category_name)+'</td><td>'+esc(p.branch_name||"—")+'</td><td>'+esc(p.manufacturer_name)+'</td>'+
   '<td><div class="state '+s.key+'">'+esc(s.label)+'</div><select class="mode-select" data-mode="'+p.product_id+'"><option value="off" '+(s.key==="inactive"?"selected":"")+'>Off</option><option value="manual" '+(s.key==="manual"?"selected":"")+'>Manual</option><option value="automatic" '+(s.key==="auto"?"selected":"")+'>Automatic</option></select>'+editorHtml(p,s)+(s.key!=="inactive"?'<button class="reset-link" data-reset="'+p.product_id+'">Reset / turn off</button>':"")+'</td>'+
   '<td>'+refSummary(s.product)+'</td></tr>';
 }).join(""):'<tr><td colspan="6" class="empty">No master catalogue products match these filters.</td></tr>';
 document.querySelectorAll(".mode-select").forEach(e=>e.addEventListener("change",()=>changeMode(e.dataset.mode,e.value)));
 document.querySelectorAll("[data-save-manual]").forEach(e=>e.addEventListener("click",()=>saveManual(e.dataset.saveManual,e)));
 document.querySelectorAll("[data-save-auto]").forEach(e=>e.addEventListener("click",()=>saveAuto(e.dataset.saveAuto,e)));
 document.querySelectorAll("[data-reset]").forEach(e=>e.addEventListener("click",()=>resetProduct(e.dataset.reset)));
}
async function changeMode(masterId,mode){
 const p=master.find(x=>x.product_id===masterId);if(!p)return;
 const current=stateFor(p);
 if(mode==="off"){
  if(!confirm("Turn off Buying for "+p.manufacturer_name+" "+p.model+"? This clears its buying price configuration but does not delete the master catalogue product.")){renderMaster();return}
 }
 try{
  await api("/rest/v1/rpc/configure_master_catalogue_buying_product",{method:"POST",body:JSON.stringify({
   p_tenant_id:tenantId,p_master_product_id:masterId,p_mode:mode,
   p_manual_price:mode==="manual"?(current.product?.manual_offer_price??null):null,
   p_sealed_percentage:mode==="automatic"?(current.rule?.sealed_percentage??null):null,
   p_opened_never_used_percentage:mode==="automatic"?(current.rule?.opened_never_used_percentage??null):null,
   p_excellent_percentage:mode==="automatic"?(current.rule?.excellent_percentage??null):null,
   p_good_percentage:mode==="automatic"?(current.rule?.good_percentage??null):null,
   p_poor_percentage:mode==="automatic"?(current.rule?.poor_percentage??null):null,
   p_manual_price:mode==="automatic"?(current.product?.manual_offer_price??null):null
  })});
  await loadAll();
  msg(mode==="off"?"Buying disabled and price configuration reset.":"Buying mode changed. The subscriber category, branch, manufacturer and buying product are now linked automatically.","success");
 }catch(e){renderMaster();msg(e.message||String(e),"error")}
}
async function saveManual(masterId,button){
 const p=master.find(x=>x.product_id===masterId),input=document.querySelector('[data-master="'+masterId+'"].manual-input');if(!p||!input)return;
 const value=input.value===""?null:Number(input.value);if(value!==null&&(!Number.isFinite(value)||value<0))return msg("Enter a valid manual buying price.","error");
 button.disabled=true;try{
  await api("/rest/v1/rpc/configure_master_catalogue_buying_product",{method:"POST",body:JSON.stringify({p_tenant_id:tenantId,p_master_product_id:masterId,p_mode:"manual",p_manual_price:value})});
  await loadAll();msg("Manual buying price saved. The product remains controlled from this page.","success");
 }catch(e){msg(e.message||String(e),"error")}finally{button.disabled=false}
}
async function saveAuto(masterId,button){
 const p=master.find(x=>x.product_id===masterId);if(!p)return;
 const values={};document.querySelectorAll('.auto-input[data-master="'+masterId+'"]').forEach(i=>values[i.dataset.field]=i.value===""?null:Number(i.value));
 for(const v of Object.values(values))if(v!==null&&(!Number.isFinite(v)||v<0||v>100))return msg("Automatic percentages must be between 0 and 100.","error");
 button.disabled=true;try{
  await api("/rest/v1/rpc/configure_master_catalogue_buying_product",{method:"POST",body:JSON.stringify({
   p_tenant_id:tenantId,p_master_product_id:masterId,p_mode:"automatic",
   p_sealed_percentage:values.sealed_percentage,p_opened_never_used_percentage:values.opened_never_used_percentage,
   p_excellent_percentage:values.excellent_percentage,p_good_percentage:values.good_percentage,p_poor_percentage:values.poor_percentage,
   p_manual_price:(document.querySelector('.auto-override-input[data-master="'+masterId+'"]')?.value||"") === "" ? null : Number(document.querySelector('.auto-override-input[data-master="'+masterId+'"]')?.value)
  })});
  await loadAll();msg("Automatic buying rule saved. Research remains separate and read-only.","success");
 }catch(e){msg(e.message||String(e),"error")}finally{button.disabled=false}
}
async function resetProduct(masterId){
 const p=master.find(x=>x.product_id===masterId);if(!p)return;
 if(!confirm("Reset "+p.manufacturer_name+" "+p.model+" to Inactive Buying? This clears the manual price/automatic rule for this subscriber only."))return;
 try{
  await api("/rest/v1/rpc/configure_master_catalogue_buying_product",{method:"POST",body:JSON.stringify({p_tenant_id:tenantId,p_master_product_id:masterId,p_mode:"off"})});
  await loadAll();msg("Product reset. It remains in the master catalogue but is no longer active for this subscriber's Buying workflow.","success");
 }catch(e){msg(e.message||String(e),"error")}
}
$("master-category").addEventListener("change",()=>{masterPage=1;populateFilters();renderMaster()});
$("master-branch").addEventListener("change",()=>{masterPage=1;populateFilters();renderMaster()});
$("master-manufacturer").addEventListener("change",()=>{masterPage=1;renderMaster()});
$("master-search").addEventListener("input",()=>{masterPage=1;renderMaster()});
$("prev-page").addEventListener("click",()=>{if(masterPage>1){masterPage--;renderMaster()}});
$("next-page").addEventListener("click",()=>{if(masterPage<Math.ceil(filteredMaster().length/pageSize)){masterPage++;renderMaster()}});
$("sign-out").addEventListener("click",()=>{if(window.tradeflowSubscriberSignOut)window.tradeflowSubscriberSignOut();else{localStorage.removeItem("tradeflow_subscriber_session");location.href="subscriber-login.html"}});
if(window.tradeflowSubscriberAuthReady)window.tradeflowSubscriberAuthReady.then(init).catch(e=>msg(e.message||String(e),"error"));else msg("Subscriber authentication layer did not load.","error");
