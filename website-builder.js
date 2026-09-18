const SUPABASE_URL='https://twfbmjwwqzxdxvclxbun.supabase.co';
const KEY_STORAGE='tradeflow_subscriber_publishable_key';
let supabaseKey=localStorage.getItem(KEY_STORAGE)||null,session=null,tenantId=null,draftRevisionId=null,currentTemplate='business';
let selectedPage='home',dirty=false;
let siteName='Your Business',headline='Buy, sell and trade with us',intro='A clear introduction to your business appears here.',accent='#c46a2b',homeImageUrl='',logoUrl='';
const params=new URLSearchParams(location.search),requestedTemplate=params.get('template');
const $=id=>document.getElementById(id);

const templates=[
 {id:'business',name:'Business',desc:'Balanced and professional'},
 {id:'marketplace',name:'Buy & Sell',desc:'Product-led marketplace'},
 {id:'services',name:'Services',desc:'Service and enquiry focused'},
 {id:'editorial',name:'Editorial',desc:'Large, story-led presentation'},
 {id:'minimal',name:'Minimal',desc:'Clean and product-first'},
 {id:'retail',name:'Retail',desc:'Shop-focused storefront'},
 {id:'professional',name:'Professional',desc:'Structured and trust-led'},
 {id:'bold',name:'Bold',desc:'Strong visual hierarchy'},
 {id:'classic',name:'Classic',desc:'Traditional business style'},
 {id:'local',name:'Local Business',desc:'Friendly local presentation'}
];

const templateHeadlines={
 business:'A better way to buy and sell',marketplace:'Buy, sell and trade with confidence',
 services:'Professional service, made simple',editorial:'Good products. Properly presented.',
 minimal:'Quality products, simply presented.',retail:'Shop, sell and trade in one place',
 professional:'Trusted service. Clear information. Straightforward business.',
 bold:'Make your business stand out.',classic:'Established service with a personal approach.',
 local:'Local service. Clear advice. People you can talk to.'
};

const pageDefinitions=[
 {slug:'about',title:'About us',hint:'Recommended',enabled:true,prompt:'Explain who you are, what the business does, your experience, values or the story behind the business.'},
 {slug:'business-information',title:'Business Information',hint:'Recommended',enabled:true,prompt:'Add the important facts customers may need: business name, company or registration details where relevant, trading address, service area, opening hours and other useful business information.'},
 {slug:'contact',title:'Contact',hint:'Recommended',enabled:true,prompt:'Add your phone, email, address, opening hours and preferred contact methods.'},
 {slug:'terms',title:'Terms & Conditions',hint:'Recommended',enabled:true,prompt:'Set out the terms governing purchases, selling requests, services, payments, cancellations and use of the website. Obtain appropriate legal advice for your business.'},
 {slug:'privacy',title:'Privacy Policy',hint:'Recommended',enabled:true,prompt:'Explain what customer information you collect, why you use it, how you protect and retain it, and how customers can contact you about their data.'},
 {slug:'cookies',title:'Cookie Policy',hint:'Recommended',enabled:true,prompt:'Explain which cookies or similar technologies the website uses, what they do and how visitors can manage them.'},
 {slug:'delivery-returns',title:'Delivery & Returns',hint:'Recommended',enabled:true,prompt:'Explain delivery areas, times, costs, collection options, cancellations and your returns process.'},
 {slug:'buying',title:'Sell to us',hint:'Core page',enabled:true,prompt:'Explain what you buy, what customers should provide, how valuations work and what happens after an item is submitted.'},
 {slug:'how-it-works',title:'How it works',hint:'Optional',enabled:false,prompt:'Give customers a simple step-by-step explanation of buying from you, selling to you, ordering and receiving their item.'},
 {slug:'faq',title:'Frequently Asked Questions',hint:'Optional',enabled:false,prompt:'Answer common questions about buying, selling, delivery, payments, returns, warranties and support.'},
 {slug:'payments',title:'Payments',hint:'Optional',enabled:false,prompt:'Explain accepted payment methods, when payment is taken, refunds and any payment restrictions relevant to your business.'},
 {slug:'warranty',title:'Warranty & Guarantees',hint:'Optional',enabled:false,prompt:'Explain any warranties, guarantees or condition assurances you provide, including exclusions and how customers make a claim.'},
 {slug:'complaints',title:'Complaints',hint:'Optional',enabled:false,prompt:'Explain how customers can raise a complaint, what information they should provide and how you will handle it.'},
 {slug:'shop',title:'Retail Shop',hint:'Core page',enabled:true,prompt:'Build your retail selling page here. Introduce your shop, explain what customers can buy and add your own branded image. Products remain connected to Inventory and Selling.'},
 {slug:'customer-account',title:'Customer account',hint:'TradeFlow managed',enabled:true,prompt:'Customers use this area to sign in, view orders, submit selling requests and manage returns.'}
];

function defaultPages(){
 return pageDefinitions.map(p=>({
   slug:p.slug,title:p.title,enabled:p.enabled,
   body:p.slug==='shop'?'Welcome to our shop. Browse our current products below.':
        p.slug==='customer-account'?'':p.slug==='contact'?'Add your contact details here.':'',
   image_url:'',image_alt:'',seo_title:'',seo_description:''
 }));
}
let pages=defaultPages();

function esc(v){return String(v==null?'':v).replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]||c))}
function setStatus(text,type){const el=$('status');if(el){el.textContent=text||'';el.dataset.type=type||''}}
function markDirty(){dirty=true;const el=$('save-state');if(el)el.textContent='Unsaved changes';}
function pageDef(slug){return pageDefinitions.find(p=>p.slug===slug)||{slug:slug,title:slug,hint:'Optional',enabled:true,prompt:'Add the information customers need on this page.'}}
function currentPage(){return pages.find(p=>p.slug===selectedPage)||pages[0]}

function renderPageList(){
 const box=$('page-list');if(!box)return;
 const items=[{slug:'home',title:'Home page',hint:'Main landing page',enabled:true},...pages.map(p=>({slug:p.slug,title:p.title,hint:p.slug==='shop'?'Retail selling page':p.slug==='buying'?'Buying page':pageDef(p.slug).hint,enabled:p.enabled}))];
 box.innerHTML=items.map(p=>'<button type="button" class="page-link '+(p.slug===selectedPage?'selected':'')+'" data-page="'+esc(p.slug)+'"><span class="page-link-icon">'+(p.slug==='home'?'⌂':p.slug==='shop'?'🛒':p.slug==='buying'?'↗':'•')+'</span><span><b>'+esc(p.title)+'</b><small>'+esc(p.enabled===false?'Hidden from website':p.hint)+'</small></span></button>').join('');
 box.querySelectorAll('[data-page]').forEach(b=>b.addEventListener('click',()=>selectPage(b.dataset.page)));
}

function renderTemplates(){
 const box=$('templates');if(!box)return;
 box.innerHTML=templates.map(t=>'<button type="button" class="template-card '+(t.id===currentTemplate?'selected':'')+'" data-template="'+t.id"><span class="template-mini template-mini-'+t.id+'"><i></i><b></b><em></em><u></u></span><strong>'+esc(t.name)+'</strong><small>'+esc(t.desc)+'</small></button>').join('');
 box.querySelectorAll('[data-template]').forEach(b=>b.addEventListener('click',()=>applyTemplate(b.dataset.template)));
}

function navMarkup(){
 const enabled=pages.filter(p=>p.enabled&&p.slug!=='customer-account');
 const links=enabled.map(p=>'<button type="button" class="preview-nav-link" data-nav-page="'+esc(p.slug)+'">'+esc(p.title)+'</button>').join('');
 return '<nav class="editor-nav"><button type="button" class="editor-brand" data-edit="site-name">'+(logoUrl?'<img src="'+esc(logoUrl)+'" alt="">':'')+'<span contenteditable="true" data-edit="site-name" data-placeholder="Your business name">'+esc(siteName)+'</span></button><div class="editor-nav-links"><button type="button" data-nav-page="home">Home</button>'+links+'<span class="managed-login">Customer Login</span></div></nav>';
}

function imageBlock(url,kind,label,alt){
 if(url)return '<div class="visual-image"><img src="'+esc(url)+'" alt="'+esc(alt||'')+'"><div class="image-tools"><button type="button" data-image-action="replace" data-image-target="'+esc(kind)+'">Replace image</button><button type="button" data-image-action="remove" data-image-target="'+esc(kind)+'">Remove</button></div></div>';
 return '<div class="image-drop"><button type="button" data-image-action="add" data-image-target="'+esc(kind)+'">Add image</button><span>'+esc(label)+'</span><small>PNG, JPEG or WebP · maximum 5 MB</small></div>';
}

function renderHome(){
 return navMarkup()+
 '<section class="editor-hero"><div class="edit-label">HOME PAGE</div>'+
 imageBlock(homeImageUrl,'home','Add a large image to introduce your business.',siteName)+
 '<p class="editable-kicker">YOUR BUSINESS</p>'+
 '<h1 class="editable-title" contenteditable="true" data-edit="headline" data-placeholder="Write your main headline">'+esc(headline)+'</h1>'+
 '<div class="editable-body hero-copy" contenteditable="true" data-edit="intro" data-placeholder="Tell customers what your business does and why they should use you.">'+esc(intro)+'</div>'+
 '<div class="hero-actions"><span>Shop products</span><span>Sell to us</span></div></section>'+
 '<section class="editor-features"><article><b>Buy from us</b><p>Published products from your Inventory and Selling workflow.</p></article><article><b>Sell to us</b><p>Your customer-facing buying request page.</p></article><article><b>Your account</b><p>TradeFlow manages customer orders, requests and returns.</p></article></section>';
}

function renderPage(p){
 const managed=p.slug==='customer-account';
 const isShop=p.slug==='shop';
 const isBuying=p.slug==='buying';
 let extra='';
 if(isShop)extra='<div class="managed-area"><span>TRADEFLOW CONNECTED</span><h3>Your products appear here automatically</h3><p>Products published through Inventory → Selling are shown in this retail shop. You do not type product listings here.</p><div class="product-placeholder"><i></i><i></i><i></i></div></div>';
 if(isBuying)extra='<div class="workflow-note"><b>How this page connects</b><span>Customers use this page to start a selling request. TradeFlow then handles the request through Buying → Acquisitions → Valuation → Offer.</span></div>';
 return navMarkup()+
 '<section class="editor-page"><div class="page-hero-row"><div><div class="edit-label">'+esc(isShop?'RETAIL SELLING PAGE':isBuying?'BUYING PAGE':'WEBSITE PAGE')+'</div>'+
 (managed?'<h1>'+esc(p.title)+'</h1>':'<h1 class="editable-title page-title" contenteditable="true" data-edit="page-title" data-placeholder="Page title">'+esc(p.title)+'</h1>')+
 '<p class="page-instruction">'+esc(pageDef(p.slug).prompt)+'</p></div></div>'+
 imageBlock(p.image_url,p.slug,'Add a branded image to this page.',p.image_alt||p.title)+
 (managed?'<div class="managed-area"><span>TRADEFLOW MANAGED</span><h3>Customer account</h3><p>The customer account area is connected to TradeFlow and is not edited as a normal content page.</p></div>':
 '<div class="editable-body page-body" contenteditable="true" data-edit="page-body" data-placeholder="'+esc(pageDef(p.slug).prompt)+'">'+esc(p.body||'')+'</div>')+
 extra+'</section>';
}

function renderEditor(){
 const p=currentPage();
 $('editing-page-name').textContent=p.slug==='home'?'Home page':p.title;
 $('browser-label').textContent=siteName+' · '+(p.slug==='home'?'Home':p.title);
 $('site-editor').className='site-editor template-'+currentTemplate;
 $('site-editor').innerHTML=p.slug==='home'?renderHome():renderPage(p);
 $('site-editor').style.setProperty('--accent',accent);
 bindEditor();
}

function bindEditor(){
 const root=$('site-editor');
 root.querySelectorAll('[contenteditable="true"]').forEach(el=>{
   el.addEventListener('input',()=>{
     const field=el.dataset.edit;
     if(field==='site-name')siteName=el.innerText.trim();
     if(field==='headline')headline=el.innerText.trim();
     if(field==='intro')intro=el.innerText.trim();
     if(field==='page-title'){currentPage().title=el.innerText.trim()||pageDef(currentPage().slug).title;renderPageList();}
     if(field==='page-body')currentPage().body=el.innerText.replace(/\r/g,'').trim();
     markDirty();
   });
   el.addEventListener('focus',()=>el.classList.add('editing'));
   el.addEventListener('blur',()=>el.classList.remove('editing'));
 });
 root.querySelectorAll('[data-nav-page]').forEach(el=>el.addEventListener('click',e=>{e.preventDefault();selectPage(el.dataset.navPage)}));
 root.querySelectorAll('[data-image-action]').forEach(el=>el.addEventListener('click',()=>{
   const action=el.dataset.imageAction,target=el.dataset.imageTarget;
   if(action==='remove'){removeImage(target);return}
   const input=$('image-file-input');input.dataset.target=target;input.value='';input.click();
 }));
}

function selectPage(slug){
 if(slug!=='home'&&!pages.some(p=>p.slug===slug))return;
 selectedPage=slug;renderPageList();renderEditor();window.scrollTo({top:0,behavior:'smooth'});
}

function applyTemplate(template){
 if(!templateHeadlines[template])return;
 currentTemplate=template;
 if(!headline||headline===templateHeadlines.business||Object.values(templateHeadlines).includes(headline))headline=templateHeadlines[template];
 renderTemplates();renderEditor();markDirty();
 setStatus(template+' design selected. Your website content has been kept.','success');
}

function buildContent(){
 return {schema_version:2,site:{
   name:siteName.trim()||'Your Business',
   pages:pages,
   theme:{accent:accent||'#c46a2b'},
   branding:{logo_url:logoUrl||''},
   homepage:{headline:headline.trim()||'Buy, sell and trade with us',intro:intro.trim()||null,image_url:homeImageUrl||'',image_alt:siteName||'Homepage image'},
   navigation:[{label:'Home',path:'?page=home'}].concat(pages.filter(p=>p.enabled).map(p=>({label:p.title,path:'?page='+p.slug}))),
   category_manifest:Array.isArray(window.__existingCategoryManifest)?window.__existingCategoryManifest:[],
   template:currentTemplate,
   contact:{text:(pages.find(p=>p.slug==='contact')?.body||'').trim()||null}
 }};
}

function loadContent(content){
 const s=content?.site||{};
 window.__existingCategoryManifest=Array.isArray(s.category_manifest)?s.category_manifest:[];
 siteName=s.name||'Your Business';
 headline=s.homepage?.headline||'Buy, sell and trade with us';
 intro=s.homepage?.intro||'';
 accent=s.theme?.accent||'#c46a2b';
 logoUrl=s.branding?.logo_url||s.logo_url||'';
 homeImageUrl=s.homepage?.image_url||'';
 currentTemplate=templateHeadlines[s.template]?s.template:'business';
 pages=Array.isArray(s.pages)&&s.pages.length?s.pages.map(p=>Object.assign({},p,{
   enabled:p.enabled!==false,
   title:p.slug==='shop'&&(!p.title||p.title==='Shop')?'Retail Shop':(p.title||p.slug),
   body:p.body||'',image_url:p.image_url||'',image_alt:p.image_alt||'',seo_title:p.seo_title||'',seo_description:p.seo_description||''
 })):defaultPages();
 selectedPage='home';dirty=false;
 renderPageList();renderTemplates();renderEditor();
}

async function uploadImage(file,target){
 if(!file)return;
 if(file.size>5242880)throw new Error('Image is larger than 5 MB.');
 if(!['image/png','image/jpeg','image/webp'].includes(file.type))throw new Error('Use PNG, JPEG or WebP images only.');
 if(!tenantId||!session?.access_token)throw new Error('Subscriber session is not ready.');
 setStatus('Uploading image…');
 const slug=target==='home'?'home':target==='logo'?'logo':target;
 const safe=(file.name||'image').toLowerCase().replace(/[^a-z0-9._-]+/g,'-');
 const path=tenantId+'/'+slug+'/'+Date.now()+'-'+safe;
 const response=await fetch(SUPABASE_URL+'/storage/v1/object/tradeflow-site-media/'+path.split('/').map(encodeURIComponent).join('/'),{
   method:'POST',headers:{apikey:supabaseKey,Authorization:'Bearer '+session.access_token,'Content-Type':file.type,'x-upsert':'false'},body:file
 });
 const responseText=await response.text();
 if(!response.ok)throw new Error(responseText||'Image upload failed.');
 const url=SUPABASE_URL+'/storage/v1/object/public/tradeflow-site-media/'+path.split('/').map(encodeURIComponent).join('/');
 if(target==='home')homeImageUrl=url;
 else if(target==='logo')logoUrl=url;
 else {const p=pages.find(x=>x.slug===target);if(p){p.image_url=url;p.image_alt=p.title;}}
 try{
   await api('/rest/v1/media_assets',{method:'POST',headers:{Prefer:'return=minimal'},body:JSON.stringify({
     tenant_id:tenantId,storage_bucket:'tradeflow-site-media',storage_path:path,original_filename:file.name,
     mime_type:file.type,byte_size:file.size,status:'active',created_by:session.user?.id||null,
     asset_kind:target==='logo'?'site_logo':'site_image',retention_policy:'permanent'
   })});
 }catch(e){console.warn('Site image metadata insert failed',e)}
 dirty=true;renderEditor();renderPageList();setStatus('Image added. Save the draft to keep the website change.','success');
}

function removeImage(target){
 if(target==='home')homeImageUrl='';
 else if(target==='logo')logoUrl='';
 else {const p=pages.find(x=>x.slug===target);if(p){p.image_url='';p.image_alt='';}}
 markDirty();renderEditor();setStatus('Image removed from this draft. Save the draft to keep the change.','success');
}

async function api(path,options){
 options=options||{};
 if(!supabaseKey)throw new Error('TradeFlow is not connected. Open the TradeFlow subscriber sign-in page first.');
 const headers=new Headers(options.headers||{});
 headers.set('apikey',supabaseKey);headers.set('Content-Type','application/json');
 if(session?.access_token)headers.set('Authorization','Bearer '+session.access_token);
 const response=await fetch(SUPABASE_URL+path,Object.assign({},options,{headers}));
 const text=await response.text();let body=null;try{body=text?JSON.parse(text):null}catch{body=text}
 if(!response.ok){const detail=body&&(body.msg||body.message||body.error_description||body.error)||text||('HTTP '+response.status);throw new Error(detail)}
 return body;
}

async function restoreSession(){
 if(!window.tradeflowSubscriberAuthReady)throw new Error('Subscriber authentication layer did not load.');
 const auth=await window.tradeflowSubscriberAuthReady;
 if(!auth?.session?.access_token)throw new Error('Subscriber authentication did not provide an access token.');
 supabaseKey=auth.key;session=auth.session;tenantId=auth.tenantId;
 if(!tenantId)throw new Error('Subscriber authentication did not provide a tenant.');
 return tenantId;
}

async function loadDraft(){
 const rows=await api('/rest/v1/tenant_site_state?select=tenant_id,draft_revision_id,published_revision_id&tenant_id=eq.'+encodeURIComponent(tenantId));
 if(!Array.isArray(rows)||rows.length!==1)throw new Error('Subscriber website state is not initialised.');
 draftRevisionId=rows[0].draft_revision_id;
 const drafts=await api('/rest/v1/site_revisions?select=id,revision_number,status,content&tenant_id=eq.'+encodeURIComponent(tenantId)+'&id=eq.'+encodeURIComponent(draftRevisionId)+'&status=eq.draft');
 if(!Array.isArray(drafts)||drafts.length!==1)throw new Error('The current website draft revision could not be loaded.');
 loadContent(drafts[0].content);
 if(requestedTemplate)applyTemplate(requestedTemplate);
 setStatus('Website loaded. Click the page and edit directly on the preview.','success');
}

async function saveDraft(){
 if(!draftRevisionId)await loadDraft();
 setStatus('Saving website draft…');
 await api('/rest/v1/site_revisions?id=eq.'+encodeURIComponent(draftRevisionId)+'&tenant_id=eq.'+encodeURIComponent(tenantId),{
   method:'PATCH',headers:{Prefer:'return=minimal'},body:JSON.stringify({content:buildContent()})
 });
 dirty=false;const state=$('save-state');if(state)state.textContent='All changes saved';
 setStatus('Website draft saved to TradeFlow.','success');
}

async function publish(){
 if(!draftRevisionId)await loadDraft();
 if(dirty)await saveDraft();
 setStatus('Publishing website…');
 await api('/rest/v1/rpc/publish_site_revision',{method:'POST',body:JSON.stringify({p_tenant_id:tenantId,p_revision_id:draftRevisionId})});
 await loadDraft();
 setStatus('Website published. A new draft is ready for further edits.','success');
}

function initBuilder(){
 $('templates')&&renderTemplates();
 $('page-list')&&renderPageList();
 $('image-file-input').addEventListener('change',e=>{
   const file=e.target.files?.[0],target=e.target.dataset.target;
   if(file)uploadImage(file,target).catch(err=>setStatus(err.message||String(err),'error'));
 });
 $('save-draft').addEventListener('click',()=>saveDraft().catch(e=>setStatus(e.message||String(e),'error')));
 $('publish').addEventListener('click',()=>publish().catch(e=>setStatus(e.message||String(e),'error')));
 $('preview-customer').addEventListener('click',()=>location.href='customer-dashboard-preview.html'+(tenantId?'?tenant_id='+encodeURIComponent(tenantId):''));
 $('preview-site').addEventListener('click',e=>{
   e.currentTarget.href='public-site.html'+(tenantId?'?tenant_id='+encodeURIComponent(tenantId):'');
 });
 (async()=>{try{await restoreSession();await loadDraft()}catch(error){setStatus(error.message||String(error),'error');const s=$('save-state');if(s)s.textContent='Website could not be loaded'}})();
}
if(document.readyState==='loading')document.addEventListener('DOMContentLoaded',initBuilder);else initBuilder();
