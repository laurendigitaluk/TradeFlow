const SUPABASE_URL='https://twfbmjwwqzxdxvclxbun.supabase.co';
const KEY='sb_publishable_AvcMgtUKV0O5k8H6k94mZQ_qH4pEIS9';
const params=new URLSearchParams(location.search);
const tenantId=params.get('tenant_id');
const page=params.get('page')||'home';
const preview=params.get('preview')==='draft';
const hostname=location.hostname;
const $=id=>document.getElementById(id);

async function api(path){
 if(!KEY)throw new Error('TradeFlow connection is not configured.');
 const response=await fetch(SUPABASE_URL+path,{headers:{apikey:KEY,'Content-Type':'application/json'}});
 const text=await response.text();
 let body=null;
 try{body=text?JSON.parse(text):null}catch{body=text}
 if(!response.ok)throw new Error(body?.message||body?.msg||body?.error||text||('HTTP '+response.status));
 return body;
}
function esc(v){return String(v??'').replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]||c));}
function customerUrl(extra){
 const base=tenantId?'customer-dashboard.html?tenant_id='+encodeURIComponent(tenantId):'customer-dashboard.html';
 return extra?base+'&'+extra:base;
}
function pageUrl(slug,extra){
 let u='public-site.html?tenant_id='+encodeURIComponent(tenantId||'')+'&page='+encodeURIComponent(slug);
 if(preview)u+='&preview=draft';
 if(extra)u+='&'+extra;
 return u;
}
function money(value,currency){
 try{return new Intl.NumberFormat('en-GB',{style:'currency',currency:currency||'GBP'}).format(Number(value));}
 catch{return (currency||'GBP')+' '+value;}
}

function renderPublicNav(site,catalogue){
 const name=site.name||'Your business';
 const logoUrl=site.branding?.logo_url||site.logo_url||'';
 const logo=logoUrl?'<img src="'+esc(logoUrl)+'" alt="'+esc(name)+'">':'<span>'+esc(name)+'</span>';
 const cats=Array.isArray(catalogue?.categories)?catalogue.categories:[];
 const pages=Array.isArray(site.pages)?site.pages:[];
 const headerLinks=Array.isArray(site.header?.links)?site.header.links:['home','buying','shop','about','contact'];
 const titleFor=slug=>slug==='home'?'Home':slug==='buying'?'What We Buy':slug==='shop'?'What We Sell':(pages.find(p=>p.slug===slug)?.title||slug);
 const links=headerLinks.filter(slug=>slug==='home'||pages.some(p=>p.slug===slug&&p.enabled!==false));
 const categoryLinks=cats.map(cat=>'<a href="'+pageUrl('buying','category='+encodeURIComponent(cat.id))+'"><strong>'+esc(cat.name)+'</strong><span>'+(Number(cat.product_count)||0)+' products</span></a>').join('');
 const buying='<details class="public-nav-dropdown"><summary>What We Buy</summary><div class="public-buy-menu"><div><b>WHAT WE BUY</b><p>Select a category to see the products currently being sought.</p><a class="menu-all" href="'+pageUrl('buying')+'">View all buying categories →</a></div><div class="public-buy-menu-cats">'+(categoryLinks||'<span class="menu-empty">Buying categories will appear here when selected.</span>')+'</div></div></details>';
 const normal=links.filter(slug=>slug!=='buying'&&slug!=='shop').map(slug=>'<a href="'+pageUrl(slug)+'">'+esc(titleFor(slug))+'</a>').join('');
 return '<header class="public-header"><div class="public-nav"><a class="public-brand" href="'+pageUrl('home')+'">'+logo+'</a><div class="public-nav-links">'+normal+buying+'<a class="public-sell-link" href="'+pageUrl('shop')+'">What We Sell</a><a class="public-account-link" href="'+customerUrl()+'">Customer Login</a></div></div></header>';
}

function heroImage(url,alt,cls){
 if(url)return '<img class="'+(cls||'')+'" src="'+esc(url)+'" alt="'+esc(alt||'')+'" loading="lazy">';
 return '<div class="public-demo-image '+(cls||'')+'">Add main image</div>';
}

function renderHero(site){
 const home=site.homepage||{};
 const t=site.template||'editorial';
 const name=site.name||'Your business';
 const headline=home.headline||'A clear way to buy and sell';
 const intro=home.intro||'Make it simple for customers to see what you buy, what you sell and how to get started.';
 const copy=site.template_copy||{};
 const defaults={
  editorial:{kicker:'YOUR BUSINESS',cta1:'What we buy',cta2:'What we sell'},
  classic:{kicker:'ESTABLISHED SERVICE',cta1:'Sell to us',cta2:'Browse the shop'},
  grid:{kicker:'BUY / SELL / TRADE',cta1:'01 / WHAT WE BUY',cta2:'02 / WHAT WE SELL'},
  studio:{kicker:'YOUR BUSINESS',cta1:'Sell to us',cta2:'Explore the shop'},
  horizon:{kicker:'BUYING / SELLING',cta1:'What we buy',cta2:'What we sell'},
  field:{kicker:'BUYING / SELLING',cta1:'Sell your items',cta2:'Browse products'},
  business:{kicker:'BUSINESS INFORMATION',cta1:'What we buy',cta2:'What we sell'},
  luxe:{kicker:'PRIVATE SERVICE',cta1:'Sell to us',cta2:'Shop products'},
  commerce:{kicker:'BUY / SELL',cta1:'Start selling',cta2:'Shop products'},
  impact:{kicker:'BUY · SELL · TRADE',cta1:'What we buy',cta2:'What we sell'}
 };
 const d=defaults[t]||defaults.editorial;
 const kicker=esc(copy.kicker||d.kicker);
 const cta1=esc(copy.cta1||d.cta1);
 const cta2=esc(copy.cta2||d.cta2);
 const a1='<a href="'+pageUrl('buying')+'">'+cta1+'</a>';
 const a2='<a href="'+pageUrl('shop')+'">'+cta2+'</a>';
 const i1=heroImage(home.image_url,name+' main image');
 const i2=home.image_url2?heroImage(home.image_url2,name+' second image'):'<div class="public-demo-image">Add second image</div>';
 const h=esc(headline),p=esc(intro);
 switch(t){
 case 'editorial':return '<section class="tpl-hero editorial-hero"><div class="editorial-copy"><span class="tpl-eyebrow">'+kicker+'</span><h1>'+h+'</h1><p>'+p+'</p><div class="tpl-actions">'+a1+a2+'</div></div><div class="editorial-images">'+i1+i2+'</div></section>';
 case 'classic':return '<section class="tpl-hero classic-hero"><div class="classic-copy"><span class="tpl-eyebrow">'+kicker+'</span><h1>'+h+'</h1><p>'+p+'</p><div class="tpl-actions">'+a1+a2+'</div></div><div class="classic-frame">'+i1+'</div></section>';
 case 'grid':return '<section class="tpl-hero grid-hero"><div><span class="tpl-code">'+kicker+'</span><h1>'+h+'</h1><p>'+p+'</p><div class="grid-cta-row">'+a1+a2+'</div></div><div class="grid-image">'+i1+'</div></section>';
 case 'studio':return '<section class="tpl-hero studio-hero"><div class="studio-image">'+i1+'</div><div class="studio-copy"><span class="tpl-eyebrow">'+kicker+'</span><h1>'+h+'</h1><p>'+p+'</p><div class="tpl-actions">'+a1+a2+'</div></div></section>';
 case 'horizon':return '<section class="tpl-hero horizon-hero"><div class="horizon-copy"><span class="tpl-eyebrow">'+kicker+'</span><h1>'+h+'</h1><p>'+p+'</p><div class="tpl-actions">'+a1+a2+'</div></div><div class="horizon-image">'+i1+'</div></section>';
 case 'field':return '<section class="tpl-hero field-hero"><div class="field-image">'+i1+'</div><div class="field-overlay"><span class="tpl-eyebrow">'+kicker+'</span><h1>'+h+'</h1><p>'+p+'</p><div class="tpl-actions">'+a1+a2+'</div></div></section>';
 case 'business':return '<section class="tpl-hero business-hero"><div class="business-copy"><span class="tpl-eyebrow">'+kicker+'</span><h1>'+h+'</h1><p>'+p+'</p><div class="tpl-actions">'+a1+a2+'</div></div><div class="business-facts"><strong>BUYING</strong><span>Selected categories</span><strong>SELLING</strong><span>Published products</span></div></section>';
 case 'luxe':return '<section class="tpl-hero luxe-hero"><div class="luxe-copy"><span class="tpl-eyebrow">'+kicker+'</span><h1>'+h+'</h1><p>'+p+'</p><div class="tpl-actions">'+a1+a2+'</div></div><div class="luxe-image">'+i1+'</div></section>';
 case 'commerce':return '<section class="tpl-hero commerce-hero"><div class="commerce-copy"><span class="tpl-eyebrow">'+kicker+'</span><h1>'+h+'</h1><p>'+p+'</p><div class="commerce-actions">'+a1+a2+'</div></div><div class="commerce-panel"><b>CONNECTED CATALOGUE</b><strong>Buying and selling stay current.</strong><span>Categories and published products update from TradeFlow.</span></div></section>';
 default:return '<section class="tpl-hero impact-hero"><div class="impact-word">BUY.<br>SELL.</div><div class="impact-copy"><span class="tpl-eyebrow">'+kicker+'</span><h1>'+h+'</h1><p>'+p+'</p><div class="tpl-actions">'+a1+a2+'</div></div><div class="impact-image">'+i1+'</div></section>';
 }
}

function renderBuyingSection(site,catalogue){
 const home=site.homepage||{};
 const cats=Array.isArray(catalogue?.categories)?catalogue.categories:[];
 const products=Array.isArray(catalogue?.products)?catalogue.products:[];
 const heading=home.buy_heading||'What we buy';
 const intro=home.buy_intro||'Show customers the categories and products you are currently looking for.';
 const cards=cats.slice(0,8).map(cat=>{
   const items=products.filter(p=>p.category_id===cat.id);
   return '<article class="buy-category-card"><div><span>WHAT WE BUY</span><h3>'+esc(cat.name)+'</h3></div><strong>'+items.length+' '+(items.length===1?'product':'products')+'</strong><p>'+esc(cat.description||'Selected products from our current buying list.')+'</p><a href="'+pageUrl('buying','category='+encodeURIComponent(cat.id))+'">See '+esc(cat.name)+' →</a></article>';
 }).join('');
 return '<section class="public-section buying-section"><div class="section-intro"><span>01 / WHAT WE BUY</span><h2>'+esc(heading)+'</h2><p>'+esc(intro)+'</p><a class="section-primary" href="'+pageUrl('buying')+'">View all categories</a></div><div class="buy-category-grid">'+(cards||'<div class="connected-empty">No buying categories are published yet. Add products in the Buying Catalogue and they will appear here automatically.</div>')+'</div></section>';
}

function renderSellingSection(site,listings){
 const home=site.homepage||{};
 const heading=home.sell_heading||'What we sell';
 const intro=home.sell_intro||'Browse the products currently published by this business.';
 const list=Array.isArray(listings)?listings:[];
 const cards=list.slice(0,6).map(p=>'<article class="sell-product-card"><div class="sell-photo">'+(p.image_url?'<img src="'+esc(p.image_url)+'" alt="'+esc(p.title||'Product')+'">':'<span>Product image</span>')+'</div><span>'+esc(p.category_name||'Product')+'</span><h3>'+esc(p.title||'Product')+'</h3><strong>'+esc(p.asking_price!=null?money(p.asking_price,p.currency):'View product')+'</strong><a href="'+customerUrl()+'">View &amp; buy</a></article>').join('');
 return '<section class="public-section selling-section"><div class="section-intro"><span>02 / WHAT WE SELL</span><h2>'+esc(heading)+'</h2><p>'+esc(intro)+'</p><a class="section-primary" href="'+pageUrl('shop')+'">View all products</a></div><div class="sell-product-grid">'+(cards||'<div class="connected-empty">No retail products are published yet. Add products in Inventory → Selling and they will appear here automatically.</div>')+'</div></section>';
}

function renderTrust(){
 return '<section class="trust-row"><div><b>What We Buy</b><span>Customers can move from a category directly into the buying journey.</span></div><div><b>What We Sell</b><span>Published inventory appears automatically as your range grows.</span></div><div><b>TradeFlow connection</b><span>Buying categories, pricing and retail products stay connected to the business system.</span></div></section>';
}

function renderFooter(site){
 const name=site.name||'Your business';
 const footer=site.footer||{};
 const pages=Array.isArray(site.pages)?site.pages:[];
 const links=Array.isArray(footer.links)?footer.links:['home','buying','shop','about','contact'];
 const titleFor=slug=>slug==='home'?'Home':slug==='buying'?'What We Buy':slug==='shop'?'What We Sell':(pages.find(p=>p.slug===slug)?.title||slug);
 const out=links.filter(slug=>slug==='home'||pages.some(p=>p.slug===slug&&p.enabled!==false)).map(slug=>'<a href="'+pageUrl(slug)+'">'+esc(titleFor(slug))+'</a>').join('');
 return '<footer class="public-footer"><div><strong>'+esc(name)+'</strong><p>'+esc(footer.text||'')+'</p></div><nav>'+out+'</nav><small>Powered by TradeFlow</small></footer>';
}

function renderBusinessExtras(site){
 const box=$('site-extras');if(!box)return;
 const social=site.social||{},reviews=Array.isArray(site.reviews)?site.reviews:[];
 const safe=v=>{try{const u=new URL(String(v||''),location.href);return ['http:','https:'].includes(u.protocol)?u.href:''}catch{return''}};
 const items=[['facebook','Facebook'],['instagram','Instagram'],['linkedin','LinkedIn'],['youtube','YouTube'],['tiktok','TikTok'],['x','X']].map(x=>{const u=safe(social[x[0]]);return u?'<a href="'+esc(u)+'" target="_blank" rel="noopener noreferrer">'+x[1]+'</a>':''}).filter(Boolean);
 const reviewItems=reviews.map(r=>{const u=safe(r.url);return u&&r.label?'<a href="'+esc(u)+'" target="_blank" rel="noopener noreferrer">Reviews: '+esc(r.label)+'</a>':''}).filter(Boolean);
 if(items.length||reviewItems.length)box.hidden=false,box.innerHTML='<div class="extras-inner">'+(items.length?'<strong>Follow us</strong>'+items.join(''):'')+(reviewItems.length?'<strong>Reviews</strong>'+reviewItems.join(''):'')+'</div>';
}

function renderHome(site,catalogue,listings){
 const sections=Object.assign({hero:true,dual:true,buy:true,sell:true,trust:true,shop:true},site.homepage?.sections||{});
 let out=renderPublicNav(site,catalogue);
 if(sections.hero!==false)out+=renderHero(site);
 if(sections.buy!==false)out+=renderBuyingSection(site,catalogue);
 if(sections.sell!==false)out+=renderSellingSection(site,listings);
 if(sections.trust!==false)out+=renderTrust();
 return out+renderFooter(site);
}

function renderBuyingPage(site,catalogue){
 const cats=Array.isArray(catalogue?.categories)?catalogue.categories:[];
 const products=Array.isArray(catalogue?.products)?catalogue.products:[];
 const selectedId=new URLSearchParams(location.search).get('category');
 const shown=selectedId?cats.filter(c=>String(c.id)===String(selectedId)):cats;
 const selector='<div class="public-filter"><label><span>Choose a category</span><select onchange="if(this.value)location.href=this.value"><option value="">All categories</option>'+cats.map(c=>'<option value="'+esc(pageUrl('buying','category='+encodeURIComponent(c.id)))+'" '+(String(c.id)===String(selectedId)?'selected':'')+'>'+esc(c.name)+'</option>').join('')+'</select></label></div>';
 const cards=shown.map(cat=>{
   const items=products.filter(p=>p.category_id===cat.id);
   const grouped=items.reduce((m,p)=>{const k=p.manufacturer||'Other';(m[k]??=[]).push(p);return m},{});
   const groups=Object.entries(grouped).map(([maker,list])=>'<div class="manufacturer-group"><h3>'+esc(maker)+'</h3><div class="product-list">'+list.map(p=>'<article><strong>'+esc(p.model||'Product')+'</strong>'+(p.package_name?'<span>'+esc(p.package_name)+'</span>':'')+(p.branch_name?'<small>'+esc(p.branch_name)+'</small>':'')+'</article>').join('')+'</div></div>').join('');
   return '<section class="buying-category-page"><div class="category-page-head"><div><span>WHAT WE BUY</span><h2>'+esc(cat.name)+'</h2></div><strong>'+items.length+' '+(items.length===1?'product':'products')+'</strong></div><p>'+esc(cat.description||'')+'</p>'+groups+'<a class="start-selling" href="'+customerUrl('selling_category='+encodeURIComponent(cat.id))+'">Start selling this category →</a></section>';
 }).join('');
 return renderPublicNav(site,catalogue)+'<main class="public-page"><div class="page-title-block"><span>WHAT WE BUY</span><h1>Sell your items to us</h1><p>Choose a category, see what we are currently looking for, then start your selling request.</p></div>'+selector+(cards||'<div class="connected-empty">This business has not published a buying list yet.</div>')+'</main>'+renderFooter(site);
}

function renderShopPage(site,listings){
 const list=Array.isArray(listings)?listings:[];
 const cards=list.map(p=>'<article class="shop-product"><div class="shop-photo">'+(p.image_url?'<img src="'+esc(p.image_url)+'" alt="'+esc(p.title||'Product')+'">':'<span>Product image</span>')+'</div><span>'+esc(p.category_name||'Product')+'</span><h2>'+esc(p.title||'Product')+'</h2><p>'+esc(p.description||'Available from this business.')+'</p><strong>'+esc(p.asking_price!=null?money(p.asking_price,p.currency):'Contact us')+'</strong><a href="'+customerUrl()+'">View &amp; buy</a></article>').join('');
 return renderPublicNav(site,window.__tradeflowBuyingCatalogue||{})+'<main class="public-page"><div class="page-title-block"><span>WHAT WE SELL</span><h1>'+(esc(site.pages?.find(p=>p.slug==='shop')?.title||'What We Sell'))+'</h1><p>'+esc(site.pages?.find(p=>p.slug==='shop')?.body||'Browse our current retail range.')+'</p></div><div class="shop-grid">'+(cards||'<div class="connected-empty">No products are currently published.</div>')+'</div></main>'+renderFooter(site);
}

function renderContentPage(site,p){
 const image=p.image_url?'<img class="content-page-image" src="'+esc(p.image_url)+'" alt="'+esc(p.image_alt||p.title||'Page image')+'">':'';
 return renderPublicNav(site,window.__tradeflowBuyingCatalogue||{})+'<main class="public-page"><div class="page-title-block"><span>YOUR BUSINESS</span><h1>'+esc(p.title||'Page')+'</h1><div class="content-body">'+esc(p.body||'').replace(/\n/g,'<br>')+'</div>'+image+'</div></main>'+renderFooter(site);
}

function applyContent(content){
 window.__tradeflowSiteContent=content;
 const site=content?.site||{};
 const theme=site.theme||{};
 const typography=Object.assign({font:'Inter',hero:'large',section:'large',body:'standard',nav:'standard',button:'solid'},theme.typography||{});
 document.documentElement.style.setProperty('--accent',theme.accent||'#c46a2b');
 document.documentElement.style.setProperty('--page-bg',theme.page_bg||'#f5f6f8');
 document.documentElement.style.setProperty('--text-color',theme.text||'#17202a');
 document.documentElement.style.setProperty('--header-bg',theme.header_bg||'#fff');
 document.documentElement.style.setProperty('--buy-bg',theme.buy_bg||'#fff');
 document.documentElement.style.setProperty('--sell-bg',theme.sell_bg||'#f4f6f7');
 document.documentElement.style.setProperty('--footer-bg',theme.footer_bg||'#17202a');
 document.documentElement.style.setProperty('--font-family',typography.font||'Inter');
 document.body.dataset.template=site.template||'editorial';
 document.body.dataset.font=typography.font||'Inter';
 document.body.dataset.heroSize=typography.hero||'large';
 document.title=site.name||'Your business';
 const catalogue=window.__tradeflowBuyingCatalogue||{categories:[],products:[]};
 const listings=window.__tradeflowListings||[];
 let html='';
 if(page==='home')html=renderHome(site,catalogue,listings);
 else if(page==='buying')html=renderBuyingPage(site,catalogue);
 else if(page==='shop')html=renderShopPage(site,listings);
 else {
   const p=(Array.isArray(site.pages)?site.pages:[]).find(x=>x.slug===page&&x.enabled!==false);
   html=p?renderContentPage(site,p):renderHome(site,catalogue,listings);
 }
 $('app').innerHTML=html;
 renderBusinessExtras(site);
}

async function loadBuyingCatalogue(tenant){
 if(!tenant)return {categories:[],products:[]};
 const rows=await api('/rest/v1/rpc/get_public_buying_catalogue?p_tenant_id='+encodeURIComponent(tenant));
 const products=Array.isArray(rows)?rows:[];
 const map=new Map();
 for(const p of products){
   if(!map.has(p.category_id))map.set(p.category_id,{id:p.category_id,name:p.category_name,slug:p.category_slug,description:p.category_description||'',product_count:0});
   map.get(p.category_id).product_count++;
 }
 return {categories:Array.from(map.values()),products};
}

async function loadListings(tenant){
 if(!tenant)return;
 try{
   const rows=await api('/rest/v1/rpc/get_published_store_listings?p_tenant_id='+encodeURIComponent(tenant));
   window.__tradeflowListings=Array.isArray(rows)?rows:[];
 }catch(e){console.warn('TradeFlow retail listings unavailable:',e);window.__tradeflowListings=[];}
}

async function loadDraftPreview(){
 if(!tenantId)throw new Error('No subscriber tenant was supplied for preview.');
 let subscriberSession=null;
 try{subscriberSession=JSON.parse(localStorage.getItem('tradeflow_subscriber_session')||'null')}catch{}
 if(!subscriberSession?.access_token)throw new Error('Sign in to TradeFlow to preview the current draft website.');
 const headers={apikey:KEY,'Content-Type':'application/json',Authorization:'Bearer '+subscriberSession.access_token};
 const stateResponse=await fetch(SUPABASE_URL+'/rest/v1/tenant_site_state?select=draft_revision_id&tenant_id=eq.'+encodeURIComponent(tenantId),{headers});
 const stateText=await stateResponse.text();
 if(!stateResponse.ok)throw new Error(stateText||'Unable to load the website draft.');
 const states=stateText?JSON.parse(stateText):[];
 if(!Array.isArray(states)||states.length!==1)throw new Error('The subscriber website draft is not initialised.');
 const draftId=states[0].draft_revision_id;
 const draftResponse=await fetch(SUPABASE_URL+'/rest/v1/site_revisions?select=id,revision_number,status,content&tenant_id=eq.'+encodeURIComponent(tenantId)+'&id=eq.'+encodeURIComponent(draftId)+'&status=eq.draft',{headers});
 const draftText=await draftResponse.text();
 if(!draftResponse.ok)throw new Error(draftText||'Unable to load the website draft revision.');
 const drafts=draftText?JSON.parse(draftText):[];
 if(!Array.isArray(drafts)||drafts.length!==1)throw new Error('The current website draft revision could not be loaded.');
 window.__tradeflowBuyingCatalogue=await loadBuyingCatalogue(tenantId);
 await loadListings(tenantId);
 applyContent(drafts[0].content);
}

async function loadByTenant(){
 if(!tenantId)throw new Error('No subscriber tenant was supplied. Open the public site with its tenant_id or active domain.');
 if(preview)return loadDraftPreview();
 const rows=await api('/rest/v1/rpc/get_published_sites');
 const selected=Array.isArray(rows)?rows.find(r=>r.tenant_id===tenantId):null;
 if(!selected)throw new Error('No published website was found for this subscriber.');
 try{window.__tradeflowBuyingCatalogue=await loadBuyingCatalogue(tenantId)}catch(e){console.warn('TradeFlow buying catalogue unavailable:',e);window.__tradeflowBuyingCatalogue={categories:[],products:[]};}
 await loadListings(tenantId);
 applyContent(selected.content);
}

async function loadByHostname(){
 if(tenantId)return loadByTenant();
 if(!hostname||hostname==='localhost')return loadByTenant();
 const rows=await api('/rest/v1/published_site_index?select=tenant_id,hostname,revision_number,content,published_at&hostname=eq.'+encodeURIComponent(hostname)+'&limit=1');
 if(!Array.isArray(rows)||rows.length!==1)throw new Error('This domain is not connected to a published TradeFlow subscriber website.');
 const siteTenantId=rows[0].tenant_id;
 try{window.__tradeflowBuyingCatalogue=await loadBuyingCatalogue(siteTenantId)}catch(e){console.warn('TradeFlow buying catalogue unavailable:',e);window.__tradeflowBuyingCatalogue={categories:[],products:[]};}
 await loadListings(siteTenantId);
 applyContent(rows[0].content);
}

(async()=>{
 try{
   $('loading-title').textContent='Loading website…';
   $('loading-message').textContent='Please wait while the subscriber website loads.';
   await Promise.race([loadByHostname(),new Promise((_,reject)=>setTimeout(()=>reject(new Error('Website loading timed out. Refresh the page and try again.')),20000))]);
 }catch(error){
   $('loading-title').textContent='Website unavailable';
   $('loading-message').textContent=error.message||String(error);
   $('status').textContent='Unable to load subscriber website';
   $('status').style.display='block';
 }
})();