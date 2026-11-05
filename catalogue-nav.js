(()=> {
  const URL="https://nnsshnfkjcflucjrftzi.supabase.co";
  const KEY="sb_publishable_T_6zeNcVL8WlCWS521n4xw_Nh9ILPBQ";
  const RPC=URL+"/rest/v1/rpc/platform_public_catalogue_browse";
  const $=id=>document.getElementById(id);
  const esc=v=>String(v??"").replace(/[&<>"']/g,c=>({"&":"&amp;","<":"&lt;",">":"&gt;",'"':"&quot;","'":"&#39;"}[c]));
  const state={page:1,pages:0,total:0,query:"",category:new URLSearchParams(location.search).get("category")||"",timer:null,refreshing:false};

  function renderCategories(categories){
    const items=Array.isArray(categories)?categories:[];
    const previous=state.category;
    if(state.category&&!items.some(c=>c.slug===state.category))state.category="";
    const select=$("public-catalogue-category");
    if(select){
      select.innerHTML='<option value="">All product categories</option>'+items.map(c=>'<option value="'+esc(c.slug)+'">'+esc(c.name)+' ('+Number(c.product_count||0).toLocaleString("en-GB")+')</option>').join("");
      select.value=state.category;
    }
    const menu=$("catalogue-mega-grid");
    if(menu){
      menu.innerHTML=items.map(c=>'<a href="catalogue-research.html?category='+encodeURIComponent(c.slug)+'#browse-catalogue"><span>'+esc(c.name)+'</span><small>'+Number(c.product_count||0).toLocaleString("en-GB")+'</small></a>').join("")||'<span class="catalogue-mega-loading">No published categories yet.</span>';
    }
    return previous!==state.category;
  }

  async function requestCatalogue(payload){
    const response=await fetch(RPC,{method:"POST",headers:{apikey:KEY,"Content-Type":"application/json"},body:JSON.stringify(payload),cache:"no-store"});
    if(!response.ok)throw new Error("Catalogue request failed ("+response.status+")");
    return response.json();
  }

  async function browse(page=1){
    state.page=page;
    const results=$("public-catalogue-results"),count=$("public-catalogue-count");
    if(!results)return;
    results.innerHTML='<div class="public-catalogue-loading">Searching the catalogue…</div>';
    try{
      const data=await requestCatalogue({p_query:state.query||null,p_category_slug:state.category||null,p_page:state.page,p_page_size:24});
      const categoryChanged=renderCategories(data.categories);
      if(categoryChanged)return browse(1);
      state.total=Number(data.total||0);
      state.pages=Number(data.total_pages||0);
      const products=Array.isArray(data.products)?data.products:[];
      results.innerHTML=products.length?products.map(p=>'<article class="public-product-card"><span class="product-category">'+esc(p.category)+'</span><h3>'+esc(p.manufacturer)+' '+esc(p.model)+'</h3><p>'+esc(p.product_type||p.branch||"Product")+'</p><span class="product-package">'+esc(p.package||"Standard product")+'</span></article>').join(""):'<div class="public-catalogue-empty">No matching products found. Try another search or category.</div>';
      if(count)count.textContent=state.total.toLocaleString("en-GB")+" matching products";
      $("public-catalogue-page").textContent=state.pages?"Page "+state.page+" of "+state.pages:"No pages";
      $("public-catalogue-prev").disabled=state.page<=1;
      $("public-catalogue-next").disabled=state.page>=state.pages||state.pages===0;
    }catch(error){
      results.innerHTML='<div class="public-catalogue-empty">The catalogue could not be loaded just now. Please refresh and try again.</div>';
      if(count)count.textContent="Catalogue temporarily unavailable";
      $("public-catalogue-prev").disabled=true;
      $("public-catalogue-next").disabled=true;
      console.error(error);
    }
  }

  async function refreshCategories(){
    if(state.refreshing)return;
    state.refreshing=true;
    try{
      const data=await requestCatalogue({p_page:1,p_page_size:1});
      const changed=renderCategories(data.categories);
      if(changed&&$("public-catalogue-results"))await browse(1);
    }catch(error){console.warn("TradeFlow category refresh failed",error)}
    finally{state.refreshing=false}
  }

  function init(){
    const results=$("public-catalogue-results");
    if(results){
      const search=$("public-catalogue-search"),select=$("public-catalogue-category");
      search?.addEventListener("input",()=>{
        clearTimeout(state.timer);
        state.timer=setTimeout(()=>{state.query=search.value.trim();browse(1)},250);
      });
      select?.addEventListener("change",()=>{state.category=select.value;browse(1)});
      $("public-catalogue-prev")?.addEventListener("click",()=>browse(Math.max(1,state.page-1)));
      $("public-catalogue-next")?.addEventListener("click",()=>browse(Math.min(state.pages,state.page+1)));
      browse(1);
    }else{
      refreshCategories();
    }
    // Categories added while this tab is open appear when the visitor returns,
    // and are also checked periodically without requiring a full page reload.
    window.addEventListener("focus",refreshCategories);
    document.addEventListener("visibilitychange",()=>{if(!document.hidden)refreshCategories()});
    window.setInterval(refreshCategories,180000);
  }
  if(document.readyState==="loading")document.addEventListener("DOMContentLoaded",init);else init();
})();