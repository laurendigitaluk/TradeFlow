const SUPABASE_URL='https://twfbmjwwqzxdxvclxbun.supabase.co';
const KEY_STORAGE='tradeflow_subscriber_publishable_key';
let supabaseKey=localStorage.getItem(KEY_STORAGE)||null,session=null,tenantId=null,draftRevisionId=null,currentTemplate='business';
const params=new URLSearchParams(location.search),requestedTemplate=params.get('template');
const $=id=>document.getElementById(id);

const templateHeadlines={business:'A better way to buy and sell',marketplace:'Buy, sell and trade with confidence',services:'Professional service, made simple',editorial:'Good products. Properly presented.',minimal:'Quality products, simply presented.',retail:'Shop, sell and trade in one place',professional:'Trusted service. Clear information. Straightforward business.',bold:'Make your business stand out.',classic:'Established service with a personal approach.',local:'Local service. Clear advice. People you can talk to.'};

const pageDefinitions=[
{slug:'about',title:'About us',hint:'Recommended',enabled:true,prompt:'Explain who you are, what the business does, your experience, values or the story behind the business.'},
{slug:'business-information',title:'Business Information',hint:'Recommended',enabled:true,prompt:'Add the important facts customers may need: business name, company or registration details where relevant, trading address, service area, opening hours and other useful business information.'},
{slug:'contact',title:'Contact',hint:'Recommended',enabled:true,prompt:'Add your phone, email, address, opening hours and preferred contact methods.'},
{slug:'terms',title:'Terms & Conditions',hint:'Recommended',enabled:true,prompt:'Set out the terms governing purchases, selling requests, services, payments, cancellations and use of the website. Obtain appropriate legal advice for your business.'},
{slug:'privacy',title:'Privacy Policy',hint:'Recommended',enabled:true,prompt:'Explain what customer information you collect, why you use it, how you protect and retain it, and how customers can contact you about their data.'},
{slug:'cookies',title:'Cookie Policy',hint:'Recommended',enabled:true,prompt:'Explain which cookies or similar technologies the website uses, what they do and how visitors can manage them.'},
{slug:'delivery-returns',title:'Delivery & Returns',hint:'Recommended',enabled:true,prompt:'Explain delivery areas, times, costs, collection options, cancellations and your returns process.'},
{slug:'buying',title:'Sell to us',hint:'Recommended',enabled:true,prompt:'Explain what you buy, what customers should provide, how valuations work and what happens after an item is submitted.'},
{slug:'how-it-works',title:'How it works',hint:'Optional',enabled:false,prompt:'Give customers a simple step-by-step explanation of buying from you, selling to you, ordering and receiving their item.'},
{slug:'faq',title:'Frequently Asked Questions',hint:'Optional',enabled:false,prompt:'Answer common questions about buying, selling, delivery, payments, returns, warranties and support.'},
{slug:'payments',title:'Payments',hint:'Optional',enabled:false,prompt:'Explain accepted payment methods, when payment is taken, refunds and any payment restrictions relevant to your business.'},
{slug:'warranty',title:'Warranty & Guarantees',hint:'Optional',enabled:false,prompt:'Explain any warranties, guarantees or condition assurances you provide, including exclusions and how customers make a claim.'},
{slug:'complaints',title:'Complaints',hint:'Optional',enabled:false,prompt:'Explain how customers can raise a complaint, what information they should provide and how you will handle it.'},
{slug:'shop',title:'Shop',hint:'Built in',enabled:true,prompt:'Published products appear here automatically from Inventory and Selling. No manual product list is required in this page editor.'},
{slug:'customer-account',title:'Customer account',hint:'Built in',enabled:true,prompt:'Customers use this area to sign in, view orders, submit selling requests and manage returns.'}
];

function defaultPages(){return pageDefinitions.map(function(p){return{slug:p.slug,title:p.title,enabled:p.enabled,body:p.slug==='shop'?'Welcome to our shop. Browse our current products below.':p.slug==='customer-account'?'':p.slug==='contact'?'Add your contact details here.':'',image_url:'',image_alt:'',seo_title:'',seo_description:''}})}
let pages=defaultPages();

function esc(v){return String(v==null?'':v).replace(/[&<>"']/g,function(c){return{'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]||c})}
function setStatus(text,type){var el=$('status');if(el){el.textContent=text||'';el.dataset.type=type||''}}

function renderPageIndex(){
 var box=$('page-index');if(!box)return;
 box.innerHTML=pages.map(function(p,i){
   var d=pageDefinitions.find(function(x){return x.slug===p.slug})||{title:p.title,hint:'Optional'};
   return '<div class="page-index-card"><div><strong>'+esc(d.title)+'</strong><span>'+esc(d.hint)+'</span><small>'+(p.enabled?'Shown in navigation':'Available to edit · not shown in navigation')+'</small></div><a href="#page-edit-'+i+'">Edit page</a></div>';
 }).join('');
}

function renderPageEditor(){
 var box=$('page-editor');if(!box)return;
 box.innerHTML=pages.map(function(p,i){
   var d=pageDefinitions.find(function(x){return x.slug===p.slug})||{title:p.title,hint:'Optional',prompt:'Add the information customers need on this page.'};
   var builtIn=['shop','customer-account'].includes(p.slug);
   return '<details class="page-editor" id="page-edit-'+i+'"><summary><span><strong>'+esc(d.title)+'</strong><small>'+esc(d.hint)+' · '+esc(d.prompt)+'</small></span><span class="page-status">'+(p.enabled?'Shown':'Hidden')+'</span></summary><div class="page-fields">'+
   '<label><input type="checkbox" data-page-enabled="'+i+'" '+(p.enabled?'checked ':'')+(builtIn?'disabled':'')+'> Show this page in the website navigation '+(builtIn?'<small>Built-in TradeFlow page.</small>':'')+'</label>'+
   '<label>Page title<input data-page-title="'+i+'" value="'+esc(p.title)+'" '+(builtIn?'disabled':'')+'></label>'+
   '<label>What to put on this page<textarea data-page-body="'+i+'" rows="8" placeholder="'+esc(d.prompt)+'">'+esc(p.body||'')+'</textarea></label>'+
   '<label>Page image <input type="file" accept="image/png,image/jpeg,image/webp" data-page-image="'+i+'"><small>Optional branded image for this page. Maximum 5 MB.</small></label>'+ (p.image_url?'<div class="page-image-current"><img src="'+esc(p.image_url)+'" alt="'+esc(p.image_alt||'')+'"><button type="button" data-page-image-remove="'+i+'">Remove image</button></div>':'')+
   '<label>SEO title <small>Optional browser/search title.</small><input data-page-seo-title="'+i+'" value="'+esc(p.seo_title||'')+'" placeholder="'+esc(p.title)+'"></label>'+
   '<label>SEO description <small>Optional short description for search engines.</small><textarea data-page-seo-description="'+i+'" rows="2" placeholder="Describe this page in one or two sentences.">'+esc(p.seo_description||'')+'</textarea></label>'+
   '</div></details>';
 }).join('');

 box.querySelectorAll('[data-page-enabled]').forEach(function(e){e.onchange=function(){var i=Number(e.dataset.pageEnabled);pages[i].enabled=e.checked;renderPageIndex();renderPageEditor();render();var d=document.getElementById('page-edit-'+i);if(d)d.open=true}});
 box.querySelectorAll('[data-page-title]').forEach(function(e){e.oninput=function(){pages[Number(e.dataset.pageTitle)].title=e.value}});
 box.querySelectorAll('[data-page-body]').forEach(function(e){e.oninput=function(){pages[Number(e.dataset.pageBody)].body=e.value}});
 box.querySelectorAll('[data-page-image]').forEach(function(e){e.onchange=function(){var i=Number(e.dataset.pageImage);if(e.files&&e.files[0])uploadImage(e.files[0],pages[i].slug,i).catch(function(err){setStatus(err.message||String(err),'error')})}});
 box.querySelectorAll('[data-page-image-remove]').forEach(function(e){e.onclick=function(){var i=Number(e.dataset.pageImageRemove);pages[i].image_url='';pages[i].image_alt='';renderPageEditor();render();}});
 box.querySelectorAll('[data-page-seo-title]').forEach(function(e){e.oninput=function(){pages[Number(e.dataset.pageSeoTitle)].seo_title=e.value}});
 box.querySelectorAll('[data-page-seo-description]').forEach(function(e){e.oninput=function(){pages[Number(e.dataset.pageSeoDescription)].seo_description=e.value}});
}

function render(){
 var name=$('builder-business-name'),headline=$('headline'),intro=$('intro'),accent=$('accent');
 $('preview-brand').textContent=name&&name.value||'Your Business';
 $('preview-headline').textContent=headline&&headline.value||'Buy, sell and trade with us';
 $('preview-intro').textContent=intro&&intro.value||'A clear introduction to your business appears here.';
 var hi=$('preview-hero-image-wrap'),him=$('preview-hero-image');if(hi&&him){him.src=window.__homeImageUrl||'';hi.hidden=!window.__homeImageUrl;him.alt='Homepage image';}
 document.documentElement.style.setProperty('--accent',accent&&accent.value||'#c46a2b');
 $('site').className='site template-'+currentTemplate;
 var pageUrl=function(slug){return 'public-site.html?tenant_id='+encodeURIComponent(tenantId||'')+'&page='+encodeURIComponent(slug)};
 var login=$('preview-login');if(login)login.href='customer-dashboard-preview.html'+(tenantId?'?tenant_id='+encodeURIComponent(tenantId):'');
 var preview=$('preview-site');if(preview)preview.href='public-site.html'+(tenantId?'?tenant_id='+encodeURIComponent(tenantId):'');
 var nav=$('preview-nav');
 if(nav){
   nav.querySelectorAll('a[data-dynamic-preview]').forEach(function(e){e.remove()});
   pages.filter(function(p){return p.enabled&&p.slug!=='home'&&p.slug!=='shop'&&p.slug!=='buying'&&p.slug!=='customer-account'}).forEach(function(p){
     var a=document.createElement('a');a.dataset.dynamicPreview='1';a.textContent=p.title;a.href=pageUrl(p.slug);nav.insertBefore(a,login||null);
   });
   var home=nav.querySelector('[data-home-preview]'),shop=nav.querySelector('[data-shop-preview]'),buying=nav.querySelector('[data-buying-preview]');
   if(home)home.href=pageUrl('home');if(shop)shop.href=pageUrl('shop');if(buying)buying.href=pageUrl('buying');
 }
}

function applyTemplate(template){
 currentTemplate=templateHeadlines[template]?template:'business';
 $('headline').value=templateHeadlines[currentTemplate];
 render();
 document.querySelectorAll('[data-template]').forEach(function(b){b.classList.toggle('selected',b.dataset.template===currentTemplate)});
 var label=document.querySelector('[data-template="'+currentTemplate+'"] strong');
 setStatus((label?label.textContent:'Template')+' selected. Your page text and business details have been kept. Continue with the Website Pages section.','success');
}

function buildContent(){
 return {schema_version:2,site:{
   name:$('builder-business-name').value.trim()||'Your Business',
   pages:pages,
   theme:{accent:$('accent').value||'#c46a2b'},
   homepage:{headline:$('headline').value.trim()||'Buy, sell and trade with us',intro:$('intro').value.trim()||null,image_url:window.__homeImageUrl||'',image_alt:'Homepage image'},
   navigation:pages.filter(function(p){return p.enabled}).map(function(p){return{label:p.title,path:'?page='+p.slug}}),
   category_manifest:Array.isArray(window.__existingCategoryManifest)?window.__existingCategoryManifest:[],
   template:currentTemplate,
   contact:{text:(pages.find(function(p){return p.slug==='contact'})?.body||'').trim()||null}
 }};
}

function loadContent(content){
 var s=content&&content.site||{};
 window.__existingCategoryManifest=Array.isArray(s.category_manifest)?s.category_manifest:[];
 $('builder-business-name').value=s.name||'Your Business';
 $('headline').value=s.homepage&&s.homepage.headline||'Buy, sell and trade with us';
 $('intro').value=s.homepage&&s.homepage.intro||'';
 $('accent').value=s.theme&&s.theme.accent||'#c46a2b';
 currentTemplate=s.template&&templateHeadlines[s.template]?s.template:'business';
 window.__homeImageUrl=s.homepage?.image_url||'';
 window.__homeImageUrl=s.homepage?.image_url||'';
 pages=Array.isArray(s.pages)&&s.pages.length?s.pages.map(function(p){return Object.assign({},p,{enabled:p.enabled!==false,title:p.title||p.slug,body:p.body||'',image_url:p.image_url||'',image_alt:p.image_alt||'',seo_title:p.seo_title||'',seo_description:p.seo_description||''})}):defaultPages();
 renderPageIndex();renderPageEditor();render();
 document.querySelectorAll('[data-template]').forEach(function(b){b.classList.toggle('selected',b.dataset.template===currentTemplate)});
}

async function uploadImage(file,slug,index){
 if(!file)return;if(file.size>5242880)throw new Error('Image is larger than 5 MB.');if(!['image/png','image/jpeg','image/webp'].includes(file.type))throw new Error('Use PNG, JPEG or WebP images only.');
 if(!tenantId||!session?.access_token)throw new Error('Subscriber session is not ready.');
 setStatus('Uploading '+slug+' image…');
 var safe=(file.name||'image').toLowerCase().replace(/[^a-z0-9._-]+/g,'-');
 var path=tenantId+'/'+slug+'/'+Date.now()+'-'+safe;
 var r=await fetch(SUPABASE_URL+'/storage/v1/object/tradeflow-site-media/'+encodeURIComponent(path),{method:'POST',headers:{apikey:supabaseKey,Authorization:'Bearer '+session.access_token,'Content-Type':file.type,'x-upsert':'false'},body:file});
 var text=await r.text();if(!r.ok)throw new Error(text||'Image upload failed.');
 var url=SUPABASE_URL+'/storage/v1/object/public/tradeflow-site-media/'+path.split('/').map(encodeURIComponent).join('/');
 if(index===-1){window.__homeImageUrl=url;}else{pages[index].image_url=url;pages[index].image_alt=slug==='shop'?'Shop image':slug==='buying'?'Buying page image':pages[index].title;}
 try{await api('/rest/v1/media_assets',{method:'POST',headers:{Prefer:'return=minimal'},body:JSON.stringify({tenant_id:tenantId,storage_bucket:'tradeflow-site-media',storage_path:path,original_filename:file.name,mime_type:file.type,byte_size:file.size,status:'active',created_by:session.user?.id||null,asset_kind:'site_image',retention_policy:'permanent'})})}catch(e){console.warn('Site image metadata insert failed',e)}
 if(index===-1){render();}else{renderPageEditor();render();}
 setStatus('Image uploaded. Save the website draft to keep the change.','success');
}

async function api(path,options){
 options=options||{};if(!supabaseKey)throw new Error('TradeFlow is not connected. Open the TradeFlow subscriber sign-in page first.');
 var headers=new Headers(options.headers||{});headers.set('apikey',supabaseKey);headers.set('Content-Type','application/json');if(session&&session.access_token)headers.set('Authorization','Bearer '+session.access_token);
 var response=await fetch(SUPABASE_URL+path,Object.assign({},options,{headers:headers}));var text=await response.text();var body=null;try{body=text?JSON.parse(text):null}catch(e){body=text}
 if(!response.ok){var detail=body&& (body.msg||body.message||body.error_description||body.error)||text||('HTTP '+response.status);throw new Error(detail)}return body;
}

async function restoreSession(){
 if(!window.tradeflowSubscriberAuthReady)throw new Error('Subscriber authentication layer did not load.');
 var auth=await window.tradeflowSubscriberAuthReady;if(!auth||!auth.session||!auth.session.access_token)throw new Error('Subscriber authentication did not provide an access token.');
 supabaseKey=auth.key;session=auth.session;tenantId=auth.tenantId;if(!tenantId)throw new Error('Subscriber authentication did not provide a tenant.');return tenantId;
}
async function loadDraft(){
 var rows=await api('/rest/v1/tenant_site_state?select=tenant_id,draft_revision_id,published_revision_id&tenant_id=eq.'+encodeURIComponent(tenantId));if(!Array.isArray(rows)||rows.length!==1)throw new Error('Subscriber website state is not initialised.');
 draftRevisionId=rows[0].draft_revision_id;
 var drafts=await api('/rest/v1/site_revisions?select=id,revision_number,status,content&tenant_id=eq.'+encodeURIComponent(tenantId)+'&id=eq.'+encodeURIComponent(draftRevisionId)+'&status=eq.draft');if(!Array.isArray(drafts)||drafts.length!==1)throw new Error('The current website draft revision could not be loaded.');
 loadContent(drafts[0].content);if(requestedTemplate)applyTemplate(requestedTemplate);setStatus('Draft revision '+drafts[0].revision_number+' loaded.','success');
}
async function saveDraft(){
 if(!draftRevisionId)await loadDraft();setStatus('Saving website draft…');await api('/rest/v1/site_revisions?id=eq.'+encodeURIComponent(draftRevisionId)+'&tenant_id=eq.'+encodeURIComponent(tenantId),{method:'PATCH',headers:{Prefer:'return=minimal'},body:JSON.stringify({content:buildContent()})});setStatus('Website draft saved to TradeFlow.','success');
}
async function publish(){
 if(!draftRevisionId)await loadDraft();setStatus('Publishing website…');await api('/rest/v1/rpc/publish_site_revision',{method:'POST',body:JSON.stringify({p_tenant_id:tenantId,p_revision_id:draftRevisionId})});await loadDraft();setStatus('Website published. A new draft revision is now ready for further edits.','success');
}

function initBuilder(){
 ['builder-business-name','headline','intro','accent'].forEach(function(id){$(id).addEventListener('input',render)});
 $('home-image-file').addEventListener('change',function(e){if(e.target.files&&e.target.files[0])uploadImage(e.target.files[0],'home',-1).catch(function(err){setStatus(err.message||String(err),'error')})});
 $('templates').addEventListener('click',function(event){var button=event.target.closest('[data-template]');if(button)applyTemplate(button.dataset.template)});
 $('save-draft').addEventListener('click',function(){saveDraft().catch(function(e){setStatus(e.message||String(e),'error')})});
 $('publish').addEventListener('click',function(){publish().catch(function(e){setStatus(e.message||String(e),'error')})});
 $('preview-customer').addEventListener('click',function(){window.location.href='customer-dashboard-preview.html'+(tenantId?'?tenant_id='+encodeURIComponent(tenantId):'')});
 renderPageIndex();renderPageEditor();render();
 (async function(){try{await restoreSession();await loadDraft()}catch(error){setStatus(error.message||String(error),'error')}})();
}
if(document.readyState==='loading')document.addEventListener('DOMContentLoaded',initBuilder);else initBuilder();