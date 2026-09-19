const SUPABASE_URL='https://twfbmjwwqzxdxvclxbun.supabase.co';
const KEY_STORAGE='tradeflow_subscriber_publishable_key';
let supabaseKey=localStorage.getItem(KEY_STORAGE)||null,session=null,tenantId=null,draftRevisionId=null,currentTemplate='business';
let selectedPage='home',dirty=false;
let siteName='Your Business',headline='Buy, sell and trade with us',intro='A clear introduction to your business appears here.',accent='#c46a2b',homeImageUrl='',homeImageUrl2='',logoUrl='';
let homepageTileCount=8,homeBuyHeading='What we buy',homeBuyIntro='Tell customers the types of products, equipment or services you are looking to buy.',homeSellHeading='What we sell',homeSellIntro='Showcase the products and collections customers can browse and buy.';
let homepageTiles=[];
let themeColors={accent:'#c46a2b',page_bg:'#f5f6f8',text:'#17202a',header_bg:'#ffffff',buy_bg:'#ffffff',sell_bg:'#f4f6f7',footer_bg:'#17202a'};
let socialLinks={facebook:'',instagram:'',linkedin:'',youtube:'',tiktok:'',x:'',show_share:true};
let reviewLinks=[];
let typography={font:'Inter',hero:'large',section:'large',body:'standard',nav:'standard',button:'solid',header:'standard',footer:'simple'};
let homepageSections={hero:true,dual:true,buy:true,sell:true,trust:true,shop:true};
function defaultHomepageTiles(){return [
 {id:'buy-1',side:'buy',title:'Cameras & Photography',body:'Tell customers what cameras and photography equipment you are looking for.',image_url:'',image_alt:'',cta:'Sell to us'},
 {id:'buy-2',side:'buy',title:'Lenses & Accessories',body:'Show the types of lenses, lighting and accessories you purchase.',image_url:'',image_alt:'',cta:'Sell to us'},
 {id:'buy-3',side:'buy',title:'Professional Equipment',body:'Highlight specialist equipment your business is interested in buying.',image_url:'',image_alt:'',cta:'Sell to us'},
 {id:'buy-4',side:'buy',title:'What else do we buy?',body:'Add another category or buying opportunity that matters to your business.',image_url:'',image_alt:'',cta:'Sell to us'},
 {id:'sell-1',side:'sell',title:'Featured product',body:'Use this space for a product or collection you want customers to notice.',image_url:'',image_alt:'',cta:'View shop'},
 {id:'sell-2',side:'sell',title:'Latest products',body:'Highlight another product, collection or category from your retail shop.',image_url:'',image_alt:'',cta:'View shop'},
 {id:'sell-3',side:'sell',title:'Popular products',body:'Use this tile to showcase another part of your retail offering.',image_url:'',image_alt:'',cta:'View shop'},
 {id:'sell-4',side:'sell',title:'Explore the shop',body:'Invite customers to browse your full range of published products.',image_url:'',image_alt:'',cta:'View shop'},
 {id:'buy-5',side:'buy',title:'Specialist items',body:'Add another buying category if your business needs it.',image_url:'',image_alt:'',cta:'Sell to us'},
 {id:'sell-5',side:'sell',title:'New in',body:'Highlight new products as your inventory grows.',image_url:'',image_alt:'',cta:'View shop'}
]};
homepageTiles=defaultHomepageTiles();
const params=new URLSearchParams(location.search),requestedTemplate=params.get('template'),requestedPage=params.get('page');
const $=id=>document.getElementById(id);

const templates=[
 {id:'business',name:'Business',desc:'Balanced and professional'},
 {id:'premium',name:'Premium Marketplace',desc:'High-end two-sided buying & selling'},
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
 business:'A better way to buy and sell',premium:'Buy, sell and trade with confidence',marketplace:'Buy, sell and trade with confidence',
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
   image_url:'',image_alt:'',image_url2:'',image_alt2:'',seo_title:'',seo_description:''
 }));
}
let pages=defaultPages();

function esc(v){return String(v==null?'':v).replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]||c))}
function setStatus(text,type){const el=$('status');if(el){el.textContent=text||'';el.dataset.type=type||''}}
function markDirty(){dirty=true;const el=$('save-state');if(el)el.textContent='Unsaved changes';}
function pageDef(slug){return pageDefinitions.find(p=>p.slug===slug)||{slug:slug,title:slug,hint:'Optional',enabled:true,prompt:'Add the information customers need on this page.'}}
function validPageSlug(slug){return slug==='home'||pages.some(p=>p.slug===slug)}
function currentPage(){return selectedPage==='home'?{slug:'home',title:'Home page'}:(pages.find(p=>p.slug===selectedPage)||pages[0])}

function renderPageList(){
 const box=$('page-list');if(!box)return;
 const items=[{slug:'home',title:'Home page',hint:'Main landing page',enabled:true},...pages.map(p=>({slug:p.slug,title:p.title,hint:p.slug==='shop'?'Retail selling page':p.slug==='buying'?'Buying page':pageDef(p.slug).hint,enabled:p.enabled}))];
 box.innerHTML=items.map(p=>'<button type="button" class="page-link '+(p.slug===selectedPage?'selected':'')+'" data-page="'+esc(p.slug)+'"><span class="page-link-icon">'+(p.slug==='home'?'HOME':p.slug==='shop'?'SHOP':p.slug==='buying'?'BUY':'PAGE')+'</span><span><b>'+esc(p.title)+'</b><small>'+esc(p.enabled===false?'Hidden from website':p.hint)+'</small></span></button>').join('');
 box.querySelectorAll('[data-page]').forEach(b=>b.addEventListener('click',()=>selectPage(b.dataset.page)));
}

function renderHomepageControls(){
 const box=$('homepage-controls');if(!box)return;
 box.innerHTML='<div class="tile-count-title">Homepage tile layout</div><div class="tile-counts">'+[6,8,10].map(n=>'<button type="button" class="tile-count '+(homepageTileCount===n?'selected':'')+'" data-tile-count="'+n+'">'+n+' tiles</button>').join('')+'</div><small>Choose how many visual tiles appear on your premium homepage. You can edit every tile directly on the page.</small>';
 box.querySelectorAll('[data-tile-count]').forEach(b=>b.addEventListener('click',()=>{homepageTileCount=Number(b.dataset.tileCount);renderHomepageControls();renderEditor();markDirty();}));
}
function renderDesignControls(){
 const box=$('design-controls');if(!box)return;
 const colors=[['accent','Brand / accent'],['text','Text'],['page_bg','Page background'],['header_bg','Header / navigation'],['buy_bg','Buying section'],['sell_bg','Selling section'],['footer_bg','Footer']];
 box.innerHTML='<div class="control-title">Brand colours</div><small>Change the main colours of your customer-facing website. The selected design still controls layout and typography.</small><div class="color-grid">'+colors.map(([key,label])=>'<label class="color-control"><span>'+label+'</span><input type="color" data-color="'+key+'" value="'+esc(themeColors[key])+'"><code>'+esc(themeColors[key])+'</code></label>').join('')+'</div><div class="preset-row"><span>Quick palettes</span><button type="button" data-palette="professional">Professional</button><button type="button" data-palette="warm">Warm</button><button type="button" data-palette="dark">Dark</button><button type="button" data-palette="clean">Clean</button></div>';
 box.querySelectorAll('[data-color]').forEach(input=>input.addEventListener('input',()=>{themeColors[input.dataset.color]=input.value;renderEditor();renderDesignControls();markDirty();}));
 const palettes={professional:{accent:'#c46a2b',text:'#17202a',page_bg:'#f5f6f8',header_bg:'#ffffff',buy_bg:'#ffffff',sell_bg:'#eef1f4',footer_bg:'#17202a'},warm:{accent:'#a84f2d',text:'#2b211d',page_bg:'#fbf7f2',header_bg:'#fffaf5',buy_bg:'#fffdf9',sell_bg:'#f3e7dc',footer_bg:'#3a2b25'},dark:{accent:'#d79a55',text:'#f2f4f5',page_bg:'#151b20',header_bg:'#101419',buy_bg:'#182027',sell_bg:'#202a32',footer_bg:'#0b0f12'},clean:{accent:'#1769aa',text:'#17202a',page_bg:'#f7f9fb',header_bg:'#ffffff',buy_bg:'#ffffff',sell_bg:'#edf3f8',footer_bg:'#172b3a'}};
 box.querySelectorAll('[data-palette]').forEach(b=>b.addEventListener('click',()=>{themeColors={...palettes[b.dataset.palette]};renderDesignControls();renderEditor();markDirty();}));
}
function renderBusinessExtras(){
 const box=$('business-extras');if(!box)return;
 const socials=[['facebook','Facebook'],['instagram','Instagram'],['linkedin','LinkedIn'],['youtube','YouTube'],['tiktok','TikTok'],['x','X']];
 box.innerHTML='<div class="control-title">Social media & reviews</div><small>Add your own profile links. Leave a field blank if you do not use it.</small><div class="social-grid">'+socials.map(([key,label])=>'<label><span>'+label+'</span><input type="url" data-social="'+key+'" value="'+esc(socialLinks[key]||'')+'" placeholder="https://"></label>').join('')+'</div><label class="check-control"><input type="checkbox" data-share-toggle '+(socialLinks.show_share!==false?'checked':'')+'> Show website share buttons</label><div class="review-editor"><strong>Review sites</strong><small>Add up to four review profiles, such as Google, Trustpilot or another review service.</small><div id="review-list">'+[0,1,2,3].map(i=>{const r=reviewLinks[i]||{};return '<div class="review-row"><input type="text" data-review-label="'+i+'" value="'+esc(r.label||'')+'" placeholder="Review site name"><input type="url" data-review-url="'+i+'" value="'+esc(r.url||'')+'" placeholder="https://"></div>'}).join('')+'</div></div>';
 box.querySelectorAll('[data-social]').forEach(input=>input.addEventListener('change',()=>{socialLinks[input.dataset.social]=input.value.trim();markDirty();}));
 const share=box.querySelector('[data-share-toggle]');if(share)share.addEventListener('change',()=>{socialLinks.show_share=share.checked;markDirty();});
 box.querySelectorAll('[data-review-label],[data-review-url]').forEach(input=>input.addEventListener('change',()=>{const i=Number(input.dataset.reviewLabel??input.dataset.reviewUrl);reviewLinks[i]={label:box.querySelector('[data-review-label="'+i+'"]').value.trim(),url:box.querySelector('[data-review-url="'+i+'"]').value.trim()};reviewLinks=reviewLinks.filter(r=>r.label||r.url);markDirty();}));
}

function renderTypographyControls(){
 const box=$('typography-controls');if(!box)return;
 const fonts=[['Inter','Modern'],['Arial','Clean'],['Georgia','Editorial'],['Trebuchet MS','Friendly'],['Verdana','Classic']];
 const sizes=[['small','Small'],['standard','Standard'],['large','Large'],['xlarge','Extra large']];
 const options=(items,key)=>items.map(([v,l])=>'<option value="'+esc(v)+'" '+(typography[key]===v?'selected':'')+'>'+esc(l)+'</option>').join('');
 box.innerHTML='<div class="control-title">Typography & layout</div><small>Choose professional type styles and simple size levels. TradeFlow keeps the design consistent across the site.</small><label class="select-control"><span>Font style</span><select data-type-key="font">'+options(fonts,'font')+'</select></label><label class="select-control"><span>Hero heading</span><select data-type-key="hero">'+options(sizes,'hero')+'</select></label><label class="select-control"><span>Section headings</span><select data-type-key="section">'+options(sizes,'section')+'</select></label><label class="select-control"><span>Body text</span><select data-type-key="body">'+options(sizes,'body')+'</select></label><label class="select-control"><span>Navigation</span><select data-type-key="nav">'+options(sizes,'nav')+'</select></label><label class="select-control"><span>Buttons</span><select data-type-key="button">'+[['solid','Solid'],['outline','Outline'],['rounded','Rounded']].map(([v,l])=>'<option value="'+v+'" '+(typography.button===v?'selected':'')+'>'+l+'</option>').join('')+'</select></label><label class="select-control"><span>Header</span><select data-type-key="header">'+[['standard','Standard'],['compact','Compact'],['centred','Centred logo'],['large','Large']].map(([v,l])=>'<option value="'+v+'" '+(typography.header===v?'selected':'')+'>'+l+'</option>').join('')+'</select></label><label class="select-control"><span>Footer</span><select data-type-key="footer">'+[['simple','Simple'],['business','Business'],['social','Social'],['full','Full']].map(([v,l])=>'<option value="'+v+'" '+(typography.footer===v?'selected':'')+'>'+l+'</option>').join('')+'</select></label>';
 box.querySelectorAll('[data-type-key]').forEach(el=>el.addEventListener('change',()=>{typography[el.dataset.typeKey]=el.value;renderTypographyControls();renderEditor();markDirty();}));
}
function renderSectionControls(){
 const box=$('section-controls');if(!box)return;
 const items=[['hero','Hero'],['dual','Buying & selling introduction'],['buy','What we buy tiles'],['sell','What we sell tiles'],['trust','Trust strip'],['shop','Retail shop']];
 box.innerHTML='<div class="control-title">Website sections</div><small>Show or hide sections without deleting your content. Hidden sections can be switched back on later.</small>'+items.map(([k,l])=>'<label class="check-control section-toggle"><input type="checkbox" data-section="'+k+'" '+(homepageSections[k]!==false?'checked':'')+'><span>'+l+'</span></label>').join('');
 box.querySelectorAll('[data-section]').forEach(el=>el.addEventListener('change',()=>{homepageSections[el.dataset.section]=el.checked;renderEditor();markDirty();}));
}

function renderTemplates(){
 const box=$('templates');if(!box)return;
 box.innerHTML=templates.map(t=>'<button type="button" class="template-card '+(t.id===currentTemplate?'selected':'')+'" data-template="'+t.id+'"><span class="template-mini template-mini-'+t.id+'"><i></i><b></b><em></em><u></u></span><strong>'+esc(t.name)+'</strong><small>'+esc(t.desc)+'</small></button>').join('');
 box.querySelectorAll('[data-template]').forEach(b=>b.addEventListener('click',()=>applyTemplate(b.dataset.template)));
}

function navMarkup(){
 const enabled=pages.filter(p=>p.enabled&&p.slug!=='customer-account');
 const links=enabled.map(p=>'<button type="button" class="preview-nav-link" data-nav-page="'+esc(p.slug)+'">'+esc(p.title)+'</button>').join('');
 return '<nav class="editor-nav"><div class="editor-brand">'+(logoUrl?'<img src="'+esc(logoUrl)+'" alt="">':'')+'<span contenteditable="true" data-edit="site-name" data-placeholder="Your business name">'+esc(siteName)+'</span></div><div class="editor-nav-links"><button type="button" data-nav-page="home">Home</button>'+links+'<span class="managed-login">Customer Login</span></div></nav>';
}

function imageBlock(url,kind,label,alt){
 if(url)return '<div class="visual-image"><img src="'+esc(url)+'" alt="'+esc(alt||'')+'"><div class="image-tools"><button type="button" data-image-action="replace" data-image-target="'+esc(kind)+'">Replace image</button><button type="button" data-image-action="remove" data-image-target="'+esc(kind)+'">Remove</button></div></div>';
 return '<div class="image-drop"><button type="button" data-image-action="add" data-image-target="'+esc(kind)+'">Add image</button><span>'+esc(label)+'</span><small>PNG, JPEG or WebP · maximum 5 MB</small></div>';
}

function renderHome(){
 const buyCount=Math.ceil(homepageTileCount/2),sellCount=Math.floor(homepageTileCount/2);
 const buyTiles=homepageTiles.filter(t=>t.side==='buy').slice(0,buyCount),sellTiles=homepageTiles.filter(t=>t.side==='sell').slice(0,sellCount);
 const tileMarkup=t=>'<article class="home-tile '+t.side+'"><div class="home-tile-image">'+(t.image_url?'<img src="'+esc(t.image_url)+'" alt="'+esc(t.image_alt||t.title)+'"><div class="tile-image-tools"><button type="button" data-image-action="replace" data-image-target="tile:'+esc(t.id)+'">Replace image</button><button type="button" data-image-action="remove" data-image-target="tile:'+esc(t.id)+'">Remove</button></div>':'<button type="button" class="tile-add-image" data-image-action="add" data-image-target="tile:'+esc(t.id)+'">Add image</button>')+'</div><h3 class="editable-tile-title" contenteditable="true" data-tile-field="title" data-tile-id="'+esc(t.id)+'" data-placeholder="Add a title">'+esc(t.title)+'</h3><p class="editable-tile-body" contenteditable="true" data-tile-field="body" data-tile-id="'+esc(t.id)+'" data-placeholder="Add a short description">'+esc(t.body)+'</p><span class="tile-cta">'+esc(t.cta)+'</span></article>';
 const hero=homepageSections.hero?'<section class="premium-hero"><div class="premium-hero-copy"><div class="edit-label">PREMIUM MARKETPLACE HOMEPAGE</div><p class="editable-kicker">YOUR BUSINESS</p><h1 class="editable-title" contenteditable="true" data-edit="headline" data-placeholder="Write your main headline">'+esc(headline)+'</h1><div class="editable-body hero-copy" contenteditable="true" data-edit="intro" data-placeholder="Explain in one or two sentences what you buy, what you sell and why customers should use your business.">'+esc(intro)+'</div><div class="hero-actions"><span>Browse what we sell</span><span>See what we buy</span></div></div><div class="premium-hero-visual"><div class="image-pair">'+imageBlock(homeImageUrl,'home','Add your main brand image, shop image or business photograph.',siteName)+imageBlock(homeImageUrl2,'home2','Add a second image if you want a two-image hero.',siteName+' second image')+'</div></div></section>':'';
 const dual=homepageSections.dual?'<section class="dual-intro"><div><p class="section-kicker">BUYING</p><h2 class="editable-section-title" contenteditable="true" data-home-field="buyHeading">'+esc(homeBuyHeading)+'</h2><p class="editable-section-body" contenteditable="true" data-home-field="buyIntro">'+esc(homeBuyIntro)+'</p></div><div><p class="section-kicker sell-kicker">SELLING</p><h2 class="editable-section-title" contenteditable="true" data-home-field="sellHeading">'+esc(homeSellHeading)+'</h2><p class="editable-section-body" contenteditable="true" data-home-field="sellIntro">'+esc(homeSellIntro)+'</p></div></section>':'';
 const buy=homepageSections.buy?'<section class="home-tile-section buy-section"><div class="section-head"><div><span>What we buy</span><h2>Make your buying categories visual</h2></div><p>Use these tiles to show visitors exactly what you are looking for.</p></div><div class="home-tile-grid count-'+homepageTileCount+'">'+buyTiles.map(tileMarkup).join('')+'</div></section>':'';
 const sell=homepageSections.sell?'<section class="home-tile-section sell-section"><div class="section-head"><div><span>What we sell</span><h2>Showcase your retail business</h2></div><p>Use images and short descriptions to make your products and collections stand out.</p></div><div class="home-tile-grid count-'+homepageTileCount+'">'+sellTiles.map(tileMarkup).join('')+'</div></section>':'';
 const trust=homepageSections.trust?'<section class="premium-trust"><div><b>Buy from us</b><span>Clear buying categories and a straightforward selling request.</span></div><div><b>Sell with confidence</b><span>Your published products are connected to TradeFlow Inventory and Selling.</span></div><div><b>Customer account</b><span>Orders, selling requests and returns stay connected to TradeFlow.</span></div></section>':'';
 return navMarkup()+hero+dual+buy+sell+trust;
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
 $('site-editor').className='site-editor template-'+currentTemplate;$('site-editor').dataset.font=typography.font;$('site-editor').dataset.heroSize=typography.hero;$('site-editor').dataset.sectionSize=typography.section;$('site-editor').dataset.bodySize=typography.body;$('site-editor').dataset.navSize=typography.nav;$('site-editor').dataset.buttonStyle=typography.button;$('site-editor').dataset.headerStyle=typography.header;$('site-editor').dataset.footerStyle=typography.footer;
 $('site-editor').innerHTML=p.slug==='home'?renderHome():renderPage(p);
 $('site-editor').style.setProperty('--accent',themeColors.accent);$('site-editor').style.setProperty('--page-bg',themeColors.page_bg);$('site-editor').style.setProperty('--text-color',themeColors.text);$('site-editor').style.setProperty('--header-bg',themeColors.header_bg);$('site-editor').style.setProperty('--buy-bg',themeColors.buy_bg);$('site-editor').style.setProperty('--sell-bg',themeColors.sell_bg);$('site-editor').style.setProperty('--footer-bg',themeColors.footer_bg);
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
     if(el.dataset.tileField){const tile=homepageTiles.find(t=>t.id===el.dataset.tileId);if(tile)tile[el.dataset.tileField]=el.innerText.trim();}
     if(el.dataset.homeField){const fieldMap={buyHeading:'homeBuyHeading',buyIntro:'homeBuyIntro',sellHeading:'homeSellHeading',sellIntro:'homeSellIntro'};const key=fieldMap[el.dataset.homeField];if(key){if(key==='homeBuyHeading')homeBuyHeading=el.innerText.trim();if(key==='homeBuyIntro')homeBuyIntro=el.innerText.trim();if(key==='homeSellHeading')homeSellHeading=el.innerText.trim();if(key==='homeSellIntro')homeSellIntro=el.innerText.trim();}}
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
 if(!validPageSlug(slug))return;
 selectedPage=slug;
 const next=new URL(location.href);
 next.searchParams.set('page',slug);
 history.replaceState(null,'',next.toString());
 renderPageList();renderEditor();window.scrollTo({top:0,behavior:'smooth'});
}

function applyTemplate(template){
 if(!templateHeadlines[template])return;
 currentTemplate=template;
 if(!headline||headline===templateHeadlines.business||Object.values(templateHeadlines).includes(headline))headline=templateHeadlines[template];
 renderTemplates();renderHomepageControls();renderEditor();markDirty();
 setStatus(template+' design selected. Your website content has been kept.','success');
}

function buildContent(){
 return {schema_version:2,site:{
   name:siteName.trim()||'Your Business',
   pages:pages,
   theme:{accent:themeColors.accent||accent||'#c46a2b',page_bg:themeColors.page_bg,text:themeColors.text,header_bg:themeColors.header_bg,buy_bg:themeColors.buy_bg,sell_bg:themeColors.sell_bg,footer_bg:themeColors.footer_bg,typography:typography},
   social:socialLinks,
   reviews:reviewLinks,
   branding:{logo_url:logoUrl||''},
   homepage:{headline:headline.trim()||'Buy, sell and trade with us',intro:intro.trim()||null,image_url:homeImageUrl||'',image_alt:siteName||'Homepage image',image_url2:homeImageUrl2||'',image_alt2:siteName+' second image',sections:homepageSections,tile_count:homepageTileCount,buy_heading:homeBuyHeading,buy_intro:homeBuyIntro,sell_heading:homeSellHeading,sell_intro:homeSellIntro,tiles:homepageTiles},
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
 typography=Object.assign({font:'Inter',hero:'large',section:'large',body:'standard',nav:'standard',button:'solid',header:'standard',footer:'simple'},s.theme?.typography||{});homepageSections=Object.assign({hero:true,dual:true,buy:true,sell:true,trust:true,shop:true},s.homepage?.sections||{});
 themeColors={accent:accent,page_bg:s.theme?.page_bg||'#f5f6f8',text:s.theme?.text||'#17202a',header_bg:s.theme?.header_bg||'#ffffff',buy_bg:s.theme?.buy_bg||'#ffffff',sell_bg:s.theme?.sell_bg||'#f4f6f7',footer_bg:s.theme?.footer_bg||'#17202a'};
 socialLinks=Object.assign({facebook:'',instagram:'',linkedin:'',youtube:'',tiktok:'',x:'',show_share:true},s.social||{});
 reviewLinks=Array.isArray(s.reviews)?s.reviews.map(r=>({label:r.label||'',url:r.url||''})).slice(0,4):[];
 logoUrl=s.branding?.logo_url||s.logo_url||'';
 homeImageUrl=s.homepage?.image_url||'';homeImageUrl2=s.homepage?.image_url2||'';
 homeBuyHeading=s.homepage?.buy_heading||'What we buy';homeBuyIntro=s.homepage?.buy_intro||'Tell customers the types of products, equipment or services you are looking to buy.';homeSellHeading=s.homepage?.sell_heading||'What we sell';homeSellIntro=s.homepage?.sell_intro||'Showcase the products and collections customers can browse and buy.';homepageTileCount=[6,8,10].includes(Number(s.homepage?.tile_count))?Number(s.homepage.tile_count):8;homepageTiles=Array.isArray(s.homepage?.tiles)&&s.homepage.tiles.length?s.homepage.tiles:defaultHomepageTiles();
 currentTemplate=templateHeadlines[s.template]?s.template:'premium';
 pages=Array.isArray(s.pages)&&s.pages.length?s.pages.map(p=>Object.assign({},p,{
   enabled:p.enabled!==false,
   title:p.slug==='shop'&&(!p.title||p.title==='Shop')?'Retail Shop':(p.title||p.slug),
   body:p.body||'',image_url:p.image_url||'',image_alt:p.image_alt||'',image_url2:p.image_url2||'',image_alt2:p.image_alt2||'',seo_title:p.seo_title||'',seo_description:p.seo_description||''
 })):defaultPages();
 selectedPage=validPageSlug(requestedPage)?requestedPage:'home';dirty=false;
 renderPageList();renderTemplates();renderHomepageControls();renderDesignControls();renderBusinessExtras();renderEditor();
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
 else if(target==='home2')homeImageUrl2=url;
 else if(target==='logo')logoUrl=url;
 else if(target.endsWith(':image2')){const p=pages.find(x=>x.slug===target.split(':')[0]);if(p){p.image_url2=url;p.image_alt2=p.title+' second image';}}
 else if(target.startsWith('tile:')){const tile=homepageTiles.find(x=>x.id===target.slice(5));if(tile){tile.image_url=url;tile.image_alt=tile.title;}}
 else if(target.includes(':image2')){const p=pages.find(x=>x.slug===target.split(':')[0]);if(p){p.image_url2='';p.image_alt2='';}}
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
 else if(target==='home2')homeImageUrl2='';
 else if(target==='logo')logoUrl='';
 else if(target.startsWith('tile:')){const tile=homepageTiles.find(x=>x.id===target.slice(5));if(tile){tile.image_url='';tile.image_alt='';}}
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
 if(validPageSlug(requestedPage))selectedPage=requestedPage;
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
 renderDesignControls();
 renderTypographyControls();
 renderSectionControls();
 renderBusinessExtras();
 $('image-file-input').addEventListener('change',e=>{
   const file=e.target.files?.[0],target=e.target.dataset.target;
   if(file)uploadImage(file,target).catch(err=>setStatus(err.message||String(err),'error'));
 });
 $('save-draft').addEventListener('click',()=>saveDraft().catch(e=>setStatus(e.message||String(e),'error')));
 $('publish').addEventListener('click',()=>publish().catch(e=>setStatus(e.message||String(e),'error')));
 $('preview-customer').addEventListener('click',()=>location.href='customer-dashboard-preview.html'+(tenantId?'?tenant_id='+encodeURIComponent(tenantId):''));
 $('preview-site').addEventListener('click',e=>{
   e.currentTarget.href='public-site.html?preview=draft'+(tenantId?'&tenant_id='+encodeURIComponent(tenantId):'');
 });
 (async()=>{const saveState=$('save-state');try{if(saveState)saveState.textContent='Connecting to your website…';await Promise.race([restoreSession(),new Promise((_,reject)=>setTimeout(()=>reject(new Error('Subscriber session timed out. Please refresh and sign in again.')),15000))]);if(saveState)saveState.textContent='Loading website draft…';await Promise.race([loadDraft(),new Promise((_,reject)=>setTimeout(()=>reject(new Error('Website draft loading timed out. Please refresh the builder.')),20000))]);if(saveState)saveState.textContent='Website loaded';}catch(error){if(saveState)saveState.textContent='Website could not be loaded';setStatus(error.message||String(error),'error');console.error('TradeFlow Website Builder load error',error)}})();
}
if(document.readyState==='loading')document.addEventListener('DOMContentLoaded',initBuilder);else initBuilder();
