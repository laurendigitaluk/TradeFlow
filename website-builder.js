const SUPABASE_URL='https://gxsrajtqzdjvmceqcpgv.supabase.co';
const KEY_STORAGE='tradeflow_subscriber_publishable_key';
let supabaseKey=localStorage.getItem(KEY_STORAGE)||null,session=null,tenantId=null,draftRevisionId=null,currentTemplate='editorial';
let selectedPage='home',dirty=false;
let siteName='Your Business',headerTagline='',footerText='',headline='',intro='',accent='#c46a2b',homeImageUrl='',homeImageUrl2='',homeBuyImageUrl='',homeSellImageUrl='',logoUrl='',bannerUrl='',useBanner=true,bannerPosition='center';
let authoritativeBranding={logo_url:'',banner_url:''};
let templateCopy={},homepageTileCount=8,homepageTileColumns=4,homeBuyHeading='What we buy',homeBuyIntro='Tell customers the types of products, equipment or services you are looking to buy.',homeSellHeading='What we sell',homeSellIntro='Showcase the products and collections customers can browse and buy.';
let homepageTiles=[];
let layoutBlocks={heroTitle:{type:'text',x:0,y:0,width:100,aspect:2,image_url:'',text:''},heroImage:{type:'image',x:0,y:0,width:100,aspect:1.6,image_url:'',text:''},heroImage2:{type:'image',x:0,y:0,width:100,aspect:1.6,image_url:'',text:''},heroBanner:{type:'image',x:0,y:0,width:60,aspect:4,image_url:'',text:''}};
let editableHeroElements=[],selectedEditableHeroId=null,heroCanvasHeight=760;
let globalHeaderElements=[],selectedGlobalHeaderId=null,globalHeaderHeight=250;
function makeEditableHeroElement(type,overrides={}){
 const id='eh-'+Date.now().toString(36)+'-'+Math.random().toString(36).slice(2,7);
 const base=type==='image'?{id,type:'image',role:'image',x:5,y:8,width:38,aspect:1.5,image_url:'',text:''}:{id,type:'text',role:'text',x:8,y:42,width:62,aspect:1,text:'Edit this text',font:'inherit',fontSize:32,color:'#17202a',align:'left',vAlign:'center',lineHeight:'1.2',letterSpacing:'0'};
 return normalizeEditableHeroElement(Object.assign(base,overrides));
}
function normalizeEditableHeroElement(v){
 const d=Object.assign({id:'eh-'+Math.random().toString(36).slice(2,8),type:'text',role:'text',x:6,y:12,width:42,aspect:1.5,image_url:'',text:'',font:'inherit',fontSize:'auto',color:'#17202a',align:'left',vAlign:'center',lineHeight:'1.2',letterSpacing:'0',button_text:'Learn more',button_link_type:'internal',button_link:'home'},v||{});
 d.type=['image','button'].includes(d.type)?d.type:'text';
 d.role=String(d.role||d.type);
 d.x=Math.max(0,Math.min(92,Number(d.x)||0));d.y=Math.max(0,Math.min(92,Number(d.y)||0));
 d.width=Math.max(8,Math.min(92,Number(d.width)||42));d.height=Math.max(8,Math.min(90,Number(d.height)||28));d.aspect=Math.max(.35,Math.min(8,Number(d.aspect)||1.5));
 d.image_url=String(d.image_url||'');d.text=String(d.text||'');
 d.font=String(d.font||'inherit');d.fontSize=String(d.fontSize||'auto');
 d.color=/^#[0-9a-f]{6}$/i.test(String(d.color||''))?String(d.color):'#17202a';
 d.align=['left','center','right'].includes(d.align)?d.align:'left';
 d.vAlign=['top','center','bottom'].includes(d.vAlign)?d.vAlign:'center';
 d.lineHeight=String(d.lineHeight||'1.2');d.letterSpacing=String(d.letterSpacing||'0');
 d.button_text=String(d.button_text||'Learn more');d.button_link_type=d.button_link_type==='custom'?'custom':'internal';d.button_link=String(d.button_link||'home');
 return d;
}
function makeEditableHeroElement(type,overrides={}){
 const id='eh-'+Date.now().toString(36)+'-'+Math.random().toString(36).slice(2,7);
 const base=type==='image'?{id,type:'image',role:'image',x:52,y:16,width:40,height:34,aspect:1.45,image_url:'',text:''}:type==='button'?{id,type:'button',role:'button',x:8,y:55,width:24,aspect:4,text:'Learn more',button_text:'Learn more',button_link_type:'internal',button_link:'home'}:{id,type:'text',role:'text',x:8,y:12,width:42,aspect:1,text:headline||'Add your headline',font:'inherit',fontSize:40,color:'#17202a',align:'left',vAlign:'center',lineHeight:'1.2',letterSpacing:'0'};
 return normalizeEditableHeroElement(Object.assign(base,overrides));
}
function defaultEditableHeroElements(){
 return [
  makeEditableHeroElement('text',{id:'headline',role:'headline',x:7,y:18,width:42,text:headline||'Add your headline',fontSize:40}),
  makeEditableHeroElement('image',{id:'image-1',role:'image',x:55,y:14,width:38,height:34,aspect:1.45,image_url:''})
 ];
}
function loadEditableHeroElements(home){
 const raw=Array.isArray(home?.editable_elements)?home.editable_elements:[];
 editableHeroElements=raw.length?raw.map(normalizeEditableHeroElement):defaultEditableHeroElements();
 selectedEditableHeroId=null;
}
function editableHeroLinkOptions(selected){
 const internal=[{v:'home',l:'Home'},...pages.filter(p=>p.enabled!==false).map(p=>({v:p.slug,l:p.title||p.slug}))];
 return internal.map(o=>'<option value="'+esc(o.v)+'" '+(selected===o.v?'selected':'')+'>'+esc(o.l)+'</option>').join('');
}
function editableHeroElementMarkup(el,editable=true){
 const b=normalizeEditableHeroElement(el);
 const style='left:'+b.x+'%;top:'+b.y+'%;width:'+b.width+'%;height:'+b.height+'%;--gh-font:'+esc(b.font)+';--gh-size:'+esc(b.fontSize==='auto'?'inherit':(Number(b.fontSize)||16)+'px')+';--gh-color:'+esc(b.color)+';--gh-align:'+esc(b.align)+';--gh-valign:'+esc(b.vAlign)+';--gh-line:'+esc(b.lineHeight)+';--gh-letter:'+esc(b.letterSpacing)+'px;';
 let body='';
 if(b.type==='image'){
   body=(b.image_url||b.preview_url)
    ?'<div class="editable-hero-image-wrap"><img src="'+esc(b.preview_url||b.image_url)+'" alt="Website image"></div><div class="editable-hero-image-tools"><button type="button" data-image-action="replace" data-image-target="hero-element:'+esc(b.id)+'">Change image</button><button type="button" data-image-action="remove" data-image-target="hero-element:'+esc(b.id)+'">Remove image</button></div>'
    :'<div class="editable-hero-empty-image"><button type="button" data-image-action="add" data-image-target="hero-element:'+esc(b.id)+'">Add image</button></div>';
 }else if(b.type==='button'){
   body='<span class="editable-hero-button-preview" style="background:var(--button-bg,var(--accent));color:var(--button-text,#fff)">'+esc(b.button_text)+'</span>';
 }else{
   body='<div class="editable-hero-text" contenteditable="'+(editable?'true':'false')+'" data-eh-edit="'+esc(b.id)+'">'+esc(b.text)+'</div>';
 }
 return '<div class="editable-hero-element '+(b.type==='image'?'eh-image':b.type==='button'?'eh-button':'eh-text')+(b.id===selectedEditableHeroId?' selected':'')+'" data-eh-id="'+esc(b.id)+'" style="'+style+'"><span class="editable-hero-move" title="Drag to move" aria-label="Drag to move">↕</span><button type="button" class="editable-hero-delete" data-eh-delete="'+esc(b.id)+'" aria-label="Delete element">×</button><span class="editable-hero-resize" aria-label="Resize element"></span>'+body+'</div>';
}

function renderEditableHero(){
 const selected=editableHeroElements.find(x=>x.id===selectedEditableHeroId)||editableHeroElements.find(x=>x.type==='text')||editableHeroElements[0];
 if(selected)selectedEditableHeroId=selected.id;
 const fontOptions=[
  ['inherit','Site default'],['Arial','Arial'],['Arial Black','Arial Black'],['Calibri','Calibri'],['Cambria','Cambria'],
  ['Comic Sans MS','Comic Sans MS'],['Courier New','Courier New'],['Georgia','Georgia'],['Garamond','Garamond'],
  ['Impact','Impact'],['Tahoma','Tahoma'],['Times New Roman','Times New Roman'],['Trebuchet MS','Trebuchet MS'],['Verdana','Verdana'],
  ['Segoe UI','Segoe UI'],['Helvetica','Helvetica'],['Palatino Linotype','Palatino Linotype'],['Book Antiqua','Book Antiqua']
 ];
 const selectedOpt=(value,current)=>value===current?' selected':'';
 const textControls=el=>'<label class="editable-hero-text-control">Text<textarea data-eh-text rows="1">'+esc(el.text)+'</textarea></label><label>Font<select data-eh-style="font">'+fontOptions.map(o=>'<option value="'+esc(o[0])+'"'+selectedOpt(o[0],el.font)+'>'+esc(o[1])+'</option>').join('')+'</select></label>'+
 '<label>Size<select data-eh-style="fontSize"><option value="auto"'+selectedOpt('auto',el.fontSize)+'>Auto</option>'+[12,14,16,18,20,24,28,32,36,42,48,56,64,72,84,96].map(n=>'<option value="'+n+'"'+selectedOpt(String(n),String(el.fontSize))+'>'+n+'px</option>').join('')+'</select></label>'+
 '<label>Text colour<input type="color" data-eh-style="color" value="'+(el.color||themeColors.text||'#17202a')+'"></label>'+
 '<label>Horizontal<select data-eh-style="align"><option value="left"'+selectedOpt('left',el.align)+'>Left</option><option value="center"'+selectedOpt('center',el.align)+'>Centre</option><option value="right"'+selectedOpt('right',el.align)+'>Right</option></select></label>'+
 '<label>Vertical<select data-eh-style="vAlign"><option value="top"'+selectedOpt('top',el.vAlign)+'>Top</option><option value="center"'+selectedOpt('center',el.vAlign)+'>Centre</option><option value="bottom"'+selectedOpt('bottom',el.vAlign)+'>Bottom</option></select></label>'+
 '<label>Line spacing<select data-eh-style="lineHeight">'+[['1','Tight'],['1.2','Normal'],['1.4','Relaxed'],['1.6','Loose'],['2','Double']].map(o=>'<option value="'+o[0]+'"'+selectedOpt(o[0],String(el.lineHeight))+'>'+o[1]+'</option>').join('')+'</select></label>'+
 '<label>Letter spacing<select data-eh-style="letterSpacing">'+[['0','Normal'],['0.5','0.5px'],['1','1px'],['2','2px'],['4','4px'],['8','8px']].map(o=>'<option value="'+o[0]+'"'+selectedOpt(o[0],String(el.letterSpacing))+'>'+o[1]+'</option>').join('')+'</select></label>';
 let controls='<span>Select an element. Use its move handle to drag it or the corner handle to resize it.</span>';
 if(selected?.type==='text')controls=textControls(selected);
 if(selected?.type==='image')controls='<span>Image</span><button type="button" data-image-action="'+(selected.image_url?'replace':'add')+'" data-image-target="hero-element:'+esc(selected.id)+'">'+(selected.image_url?'Change image':'Add image')+'</button>'+(selected.image_url?'<button type="button" data-image-action="remove" data-image-target="hero-element:'+esc(selected.id)+'">Remove image</button>':'');
 if(selected?.type==='button')controls='<label>Button text<input type="text" data-eh-field="button_text" value="'+esc(selected.button_text)+'"></label><label>Link type<select data-eh-field="button_link_type"><option value="internal"'+selectedOpt('internal',selected.button_link_type)+'>TradeFlow page</option><option value="custom"'+selectedOpt('custom',selected.button_link_type)+'>Custom URL</option></select></label>'+(selected.button_link_type==='custom'?'<label>URL<input type="url" data-eh-field="button_link" value="'+esc(selected.button_link)+'"></label>':'<label>Page<select data-eh-field="button_link">'+editableHeroLinkOptions(selected.button_link)+'</select></label>');
 return '<section class="editable-hero-editor"><div class="editable-hero-toolbar"><strong>Top of page</strong><button type="button" data-eh-add="text">Add text box</button><button type="button" data-eh-add="image">Add image box</button><button type="button" data-eh-add="button">Add call-to-action button</button><button type="button" data-eh-add="logo">Add logo</button><button type="button" data-eh-add="banner">Add banner</button><div class="editable-hero-format">'+controls+'</div></div><div class="editable-hero-canvas" data-editable-hero-canvas style="height:'+heroCanvasHeight+'px;min-height:'+heroCanvasHeight+'px"><div class="editable-hero-height-handle" data-eh-height-handle title="Drag to make the top section taller or shorter">↕</div>'+editableHeroElements.map(x=>editableHeroElementMarkup(x,true)).join('')+'</div></section>';
}

function normalizeLayoutBlock(v,defaults){const x=Object.assign({font:'inherit',fontSize:'auto',color:'inherit',align:'left',vAlign:'center',lineHeight:'1.2',letterSpacing:'0'},defaults,v||{});x.type=x.type==='image'?'image':'text';x.x=Number.isFinite(Number(x.x))?Number(x.x):0;x.y=Number.isFinite(Number(x.y))?Number(x.y):0;x.width=Math.max(20,Math.min(100,Number(x.width)||defaults.width));x.aspect=Math.max(.35,Math.min(4,Number(x.aspect)||defaults.aspect));x.image_url=String(x.image_url||'');x.text=String(x.text||'');x.font=String(x.font||'inherit');x.fontSize=String(x.fontSize||'auto');x.color=String(x.color||'inherit');x.align=['left','center','right'].includes(x.align)?x.align:'left';x.vAlign=['top','center','bottom'].includes(x.vAlign)?x.vAlign:'center';x.lineHeight=String(x.lineHeight||'1.2');x.letterSpacing=String(x.letterSpacing||'0');return x;}
function loadLayoutBlocks(home){const lb=home?.layout_blocks||{};layoutBlocks={heroTitle:normalizeLayoutBlock(lb.heroTitle,{type:'text',x:0,y:0,width:100,aspect:2,image_url:'',text:headline}),heroImage:normalizeLayoutBlock(lb.heroImage,{type:'image',x:0,y:0,width:100,aspect:1.6,image_url:homeImageUrl,text:''}),heroImage2:normalizeLayoutBlock(lb.heroImage2,{type:'image',x:0,y:0,width:100,aspect:1.6,image_url:homeImageUrl2,text:''}),heroBanner:normalizeLayoutBlock(lb.heroBanner,{type:'image',x:0,y:0,width:60,aspect:4,image_url:String(home?.banner_url||bannerUrl||''),text:''})};}
function layoutBlockMarkup(id,block,content,tag='div',alt='Website image'){
 const b=normalizeLayoutBlock(block,{type:'text',x:0,y:0,width:100,aspect:2,image_url:'',text:''});
 const style='--lb-x:'+b.x+'%;--lb-y:'+b.y+'px;--lb-w:'+b.width+'%;--lb-aspect:'+b.aspect+';--lb-font:'+esc(b.font)+';--lb-size:'+esc(b.fontSize==='auto'?'inherit':(Number(b.fontSize)||16)+'px')+';--lb-color:'+esc(b.color)+';--lb-align:'+esc(b.align)+';--lb-valign:'+esc(b.vAlign)+';--lb-line:'+esc(b.lineHeight)+';--lb-letter:'+esc(b.letterSpacing)+'px;';
 const textTools=b.type==='text'?'<div class="layout-text-tools"><label>Font<select data-layout-style="font"><option value="inherit" '+(b.font==='inherit'?'selected':'')+'>Site font</option><option value="Inter" '+(b.font==='Inter'?'selected':'')+'>Inter</option><option value="Arial" '+(b.font==='Arial'?'selected':'')+'>Arial</option><option value="Georgia" '+(b.font==='Georgia'?'selected':'')+'>Georgia</option><option value="Trebuchet MS" '+(b.font==='Trebuchet MS'?'selected':'')+'>Trebuchet</option><option value="Verdana" '+(b.font==='Verdana'?'selected':'')+'>Verdana</option></select></label><label>Size<select data-layout-style="fontSize"><option value="auto" '+(b.fontSize==='auto'?'selected':'')+'>Auto</option>'+[12,14,16,18,20,24,28,32,36,42,48,56,64,72].map(n=>'<option value="'+n+'" '+(String(b.fontSize)===String(n)?'selected':'')+'>'+n+'px</option>').join('')+'</select></label><label>Colour<input type="color" data-layout-style="color" value="'+(/^#[0-9a-f]{6}$/i.test(b.color)?b.color:'#17202a')+'"></label><label>Align<select data-layout-style="align"><option value="left" '+(b.align==='left'?'selected':'')+'>Left</option><option value="center" '+(b.align==='center'?'selected':'')+'>Centre</option><option value="right" '+(b.align==='right'?'selected':'')+'>Right</option></select></label><label>Vertical<select data-layout-style="vAlign"><option value="top" '+(b.vAlign==='top'?'selected':'')+'>Top</option><option value="center" '+(b.vAlign==='center'?'selected':'')+'>Middle</option><option value="bottom" '+(b.vAlign==='bottom'?'selected':'')+'>Bottom</option></select></label><label>Line spacing<select data-layout-style="lineHeight"><option value="1" '+(b.lineHeight==='1'?'selected':'')+'>Tight</option><option value="1.2" '+(b.lineHeight==='1.2'?'selected':'')+'>Normal</option><option value="1.4" '+(b.lineHeight==='1.4'?'selected':'')+'>Relaxed</option><option value="1.6" '+(b.lineHeight==='1.6'?'selected':'')+'>Loose</option><option value="2" '+(b.lineHeight==='2'?'selected':'')+'>Double</option></select></label><label>Letter spacing<select data-layout-style="letterSpacing"><option value="0" '+(b.letterSpacing==='0'?'selected':'')+'>Normal</option><option value="0.5" '+(b.letterSpacing==='0.5'?'selected':'')+'>0.5px</option><option value="1" '+(b.letterSpacing==='1'?'selected':'')+'>1px</option><option value="2" '+(b.letterSpacing==='2'?'selected':'')+'>2px</option><option value="4" '+(b.letterSpacing==='4'?'selected':'')+'>4px</option></select></label></div>':'';
 const toolbar='<div class="layout-block-tools"><button type="button" data-layout-type="'+esc(id)+'" data-layout-next="text">Text</button><button type="button" data-layout-type="'+esc(id)+'" data-layout-next="image">Image</button>'+textTools+'</div><span class="layout-drag-handle" title="Drag to reposition">↕</span><span class="layout-resize-handle" title="Drag to resize proportionally"></span>';
 let body='';
 if(b.type==='image') body=b.image_url?'<div class="layout-image-inner"><img src="'+esc(b.image_url)+'" alt="'+esc(alt)+'"></div><button type="button" class="layout-image-action" data-image-action="replace" data-image-target="layout:'+esc(id)+'">Replace image</button>':'<div class="layout-empty-image"><button type="button" data-image-action="add" data-image-target="layout:'+esc(id)+'">Add image</button></div>';
 else body='<'+tag+' contenteditable="true" data-layout-edit="'+esc(id)+'">'+esc(b.text||content||'')+'</'+tag+'>';
 return '<div class="layout-block layout-block-'+esc(b.type)+'" data-layout-block="'+esc(id)+'" style="'+style+'">'+toolbar+body+'</div>';
}
let buyingCatalogue={categories:[],products:[]};
let retailListings=[];
let themeColors={accent:'#c46a2b',button_bg:'#c46a2b',button_text:'#ffffff',page_bg:'#ffffff',text:'#17202a',header_bg:'#ffffff',buy_bg:'#ffffff',sell_bg:'#f4f6f7',footer_bg:'#17202a',background_style:'none',background_category:'none',background_color:'#f5f6f8',background_color2:'#ffffff'};
const websiteBackgrounds=[
 {id:'clean-wave',label:'Clean Gradient',color:'#f5f8fb',image:'linear-gradient(135deg,#f4f8fc 0%,#dce9f4 48%,#ffffff 100%)',size:'cover',repeat:'no-repeat'},
 {id:'soft-blue',label:'Blue Gradient',color:'#eaf3fb',image:'linear-gradient(135deg,#e7f3ff 0%,#b9d9f2 50%,#f8fbff 100%)',size:'cover',repeat:'no-repeat'},
 {id:'soft-green',label:'Green Gradient',color:'#edf7f0',image:'linear-gradient(135deg,#e7f7ec 0%,#b8dfc3 50%,#fbfdfb 100%)',size:'cover',repeat:'no-repeat'},
 {id:'warm-sand',label:'Warm Gradient',color:'#f7f1e8',image:'linear-gradient(135deg,#f8eee0 0%,#dec7a9 50%,#fffaf4 100%)',size:'cover',repeat:'no-repeat'},
 {id:'soft-lavender',label:'Lavender Gradient',color:'#f3effa',image:'linear-gradient(135deg,#f2eaff 0%,#cfc0e8 50%,#fbf9ff 100%)',size:'cover',repeat:'no-repeat'},
 {id:'sunset',label:'Sunset Gradient',color:'#fff0e8',image:'linear-gradient(135deg,#ffe4d7 0%,#f3bfa7 48%,#d8c7ee 100%)',size:'cover',repeat:'no-repeat'},
 {id:'fine-diagonal',label:'Fine Lines',color:'#f4f6f8',image:'repeating-linear-gradient(135deg,rgba(45,60,75,.38) 0 2px,transparent 2px 12px)',size:'auto',repeat:'repeat'},
 {id:'wide-diagonal',label:'Wide Lines',color:'#f2f4f6',image:'repeating-linear-gradient(135deg,rgba(45,60,75,.48) 0 8px,transparent 8px 26px)',size:'auto',repeat:'repeat'},
 {id:'soft-dots',label:'Dot Pattern',color:'#f6f7f9',image:'radial-gradient(circle,rgba(45,60,75,.44) 0 2.5px,transparent 3px)',size:'22px 22px',repeat:'repeat'},
 {id:'fine-grid',label:'Grid Pattern',color:'#f4f6f8',image:'linear-gradient(rgba(45,60,75,.30) 1.5px,transparent 1.5px),linear-gradient(90deg,color-mix(in srgb,var(--accent) 25%,transparent) 1.5px,transparent 1.5px)',size:'28px 28px',repeat:'repeat'},
 {id:'soft-hex',label:'Hex Pattern',color:'#f2f5f7',image:'linear-gradient(30deg,rgba(45,60,75,.30) 12%,transparent 12.5%,transparent 87%,rgba(45,60,75,.30) 87.5%),linear-gradient(150deg,color-mix(in srgb,var(--accent) 25%,transparent) 12%,transparent 12.5%,transparent 87%,color-mix(in srgb,var(--accent) 25%,transparent) 87.5%),linear-gradient(60deg,rgba(45,60,75,.22) 25%,transparent 25.5%,transparent 75%,rgba(45,60,75,.22) 75%)',size:'56px 96px',repeat:'repeat'},
 {id:'dark-geometry',label:'Dark Geometry',color:'#111820',image:'linear-gradient(135deg,#111820 25%,#263747 25% 50%,#111820 50% 75%,#34495a 75%)',size:'80px 80px',repeat:'repeat'}
];
function normalizeBackgroundId(id){return id||'clean-wave';}
const categoryBackgrounds={
 none:{label:'None'},
 instruments:{label:'Musical instruments',svg:'<svg xmlns="http://www.w3.org/2000/svg" width="180" height="180"><g fill="none" stroke="currentColor" stroke-width="3" opacity=".24"><path d="M28 42v72a16 16 0 1 0 8 14V56h28V42H28z"/><circle cx="36" cy="128" r="7"/><path d="M103 32c-9 7-12 19-8 30l14 38c4 11 16 17 27 13l9-3-7-19-9 3c-3 1-6-1-7-4l-12-32 17-6-6-17-18 6z"/></g></svg>'},
 phones:{label:'Mobile phones',svg:'<svg xmlns="http://www.w3.org/2000/svg" width="180" height="180"><g fill="none" stroke="currentColor" stroke-width="3" opacity=".24"><rect x="30" y="20" width="48" height="92" rx="7"/><rect x="101" y="57" width="48" height="92" rx="7"/><circle cx="54" cy="101" r="3"/><circle cx="125" cy="138" r="3"/></g></svg>'},
 drones:{label:'Drones',svg:'<svg xmlns="http://www.w3.org/2000/svg" width="180" height="180"><g fill="none" stroke="currentColor" stroke-width="3" opacity=".24"><path d="M64 82h52l12 18-18 12H70L52 100zM64 84 39 59M116 84l25-25M70 108l-24 24M110 108l24 24"/><ellipse cx="33" cy="53" rx="18" ry="5"/><ellipse cx="147" cy="53" rx="18" ry="5"/><ellipse cx="41" cy="136" rx="18" ry="5"/><ellipse cx="139" cy="136" rx="18" ry="5"/></g></svg>'},
 cameras:{label:'Cameras',svg:'<svg xmlns="http://www.w3.org/2000/svg" width="180" height="180"><g fill="none" stroke="currentColor" stroke-width="3" opacity=".24"><rect x="25" y="56" width="130" height="76" rx="8"/><path d="M52 56l10-17h36l10 17"/><circle cx="90" cy="94" r="25"/><circle cx="90" cy="94" r="10"/></g></svg>'},
 detectors:{label:'Metal detectors',svg:'<svg xmlns="http://www.w3.org/2000/svg" width="180" height="180"><g fill="none" stroke="currentColor" stroke-width="3" opacity=".24"><path d="M73 31c-15 3-24 17-21 32l12 62M64 125l-8 28M83 124l7 28"/><rect x="50" y="26" width="28" height="9" rx="3"/><path d="M48 119h44c9 0 16 7 16 16v8H41v-8c0-9 7-16 16-16z"/></g></svg>'}
};
function categoryBackgroundImage(category){const item=categoryBackgrounds[category];if(!item||!item.svg)return 'none';const colour=themeColors.background_color2||'#ffffff';return 'url("data:image/svg+xml,'+encodeURIComponent(item.svg.replace(/currentColor/g,colour))+'")';}
function applyWebsiteBackground(){
 const e=$('site-editor');if(!e)return;
 const style=themeColors.background_style||'none',category=themeColors.background_category||'none',c1=themeColors.background_color||themeColors.page_bg||'#f5f6f8',c2=themeColors.background_color2||'#ffffff';
 let image='none';
 if(style==='stripes')image='repeating-linear-gradient(135deg,'+c1+' 0 18px,'+c2+' 18px 36px)';
 if(style==='dots')image='radial-gradient(circle,'+c2+' 1.8px,transparent 1.8px)';
 if(style==='gradient')image='linear-gradient(135deg,'+c1+' 0%,'+c2+' 100%)'; const categoryImage=categoryBackgroundImage(category); if(categoryImage!=='none')image=(image==='none'?'':image+',')+categoryImage;
 e.style.setProperty('--site-background-color',c1);e.style.setProperty('--site-background-image',image);e.style.setProperty('--site-background-size',category!=='none'?(style==='dots'?'18px 18px,180px 180px':'cover,180px 180px'):(style==='dots'?'18px 18px':'cover'));e.style.setProperty('--site-background-repeat',category!=='none'?(style==='gradient'?'no-repeat,repeat':'repeat,repeat'):(style==='dots'?'repeat':'no-repeat'));
}
function selectWebsiteBackground(){return false;}
function selectPresetBackgroundMode(){return false;}
function selectCustomBackground(){themeColors.background_style='none';applyWebsiteBackground();renderDesignControls();renderEditor();markDirty();}
window.tradeflowSelectWebsiteBackground=selectWebsiteBackground;
window.tradeflowSelectPresetBackgroundMode=selectPresetBackgroundMode;
window.tradeflowSelectCustomBackground=selectCustomBackground;

let socialLinks={facebook:'',instagram:'',linkedin:'',youtube:'',tiktok:'',x:'',show_share:true};
let reviewLinks=[];
let typography={font:'Inter',hero:'large',section:'large',body:'standard',nav:'standard',button:'solid',header:'standard',footer:'simple'};
let homepageSections={hero:true,hero_image:true,dual:true,buy:true,sell:true,trust:false,shop:true};
let headerLinks=[],footerLinks=[],homepageOrder=['hero','buy','sell'];
function defaultHomepageTiles(){return [
 {id:'buy-1',side:'buy',title:'',body:'',image_url:'',image_alt:'',cta:''},
 {id:'buy-2',side:'buy',title:'',body:'',image_url:'',image_alt:'',cta:''},
 {id:'buy-3',side:'buy',title:'',body:'',image_url:'',image_alt:'',cta:''},
 {id:'buy-4',side:'buy',title:'',body:'',image_url:'',image_alt:'',cta:''},
 {id:'sell-1',side:'sell',title:'',body:'',image_url:'',image_alt:'',cta:''},
 {id:'sell-2',side:'sell',title:'',body:'',image_url:'',image_alt:'',cta:''},
 {id:'sell-3',side:'sell',title:'',body:'',image_url:'',image_alt:'',cta:''},
 {id:'sell-4',side:'sell',title:'',body:'',image_url:'',image_alt:'',cta:''},
 {id:'buy-5',side:'buy',title:'',body:'',image_url:'',image_alt:'',cta:''},
 {id:'sell-5',side:'sell',title:'',body:'',image_url:'',image_alt:'',cta:''},
 {id:'buy-6',side:'buy',title:'',body:'',image_url:'',image_alt:'',cta:''},
 {id:'sell-6',side:'sell',title:'',body:'',image_url:'',image_alt:'',cta:''}
]}
homepageTiles=defaultHomepageTiles();
const params=new URLSearchParams(location.search),requestedTemplate=params.get('template'),requestedPage=params.get('page'),requestedFocus=params.get('focus');
const $=id=>document.getElementById(id);

const templates=[{id:'editable',name:'Fully editable',desc:'Drag, resize and format text, images, logo and banner freely'}];
const templatePalettes={
 editorial:{accent:'#b85c38',page_bg:'#f7f4f0',text:'#20252a',header_bg:'#fffdfb',buy_bg:'#fffdfb',sell_bg:'#f0ebe6',footer_bg:'#20252a'},
 classic:{accent:'#8b5e3c',page_bg:'#f7f1e8',text:'#30271f',header_bg:'#fffaf2',buy_bg:'#fffdf8',sell_bg:'#eee2d2',footer_bg:'#352b24'},
 grid:{accent:'#5ea8d6',page_bg:'#101820',text:'#eef3f6',header_bg:'#0d141b',buy_bg:'#151f28',sell_bg:'#1c2933',footer_bg:'#080d12'},
 studio:{accent:'#b35b3e',page_bg:'#f3ece5',text:'#2b2521',header_bg:'#fffaf5',buy_bg:'#fffdf9',sell_bg:'#e9ddd2',footer_bg:'#29221e'},
 horizon:{accent:'#287d9b',page_bg:'#edf5f8',text:'#19303a',header_bg:'#ffffff',buy_bg:'#ffffff',sell_bg:'#e1eef2',footer_bg:'#18343e'},
 field:{accent:'#b6a05a',page_bg:'#17231d',text:'#f1f2ed',header_bg:'#111a15',buy_bg:'#1a2820',sell_bg:'#26352b',footer_bg:'#0b110d'},
 business:{accent:'#2563a8',page_bg:'#f1f4f7',text:'#1d2a35',header_bg:'#ffffff',buy_bg:'#ffffff',sell_bg:'#e5ebf1',footer_bg:'#172431'},
 luxe:{accent:'#c49a58',page_bg:'#f3f0eb',text:'#202328',header_bg:'#fbfaf7',buy_bg:'#fbfaf7',sell_bg:'#e8e2d8',footer_bg:'#15191d'},
 commerce:{accent:'#d05a38',page_bg:'#f6f7f8',text:'#20252a',header_bg:'#ffffff',buy_bg:'#ffffff',sell_bg:'#eceff1',footer_bg:'#20252a'},
 impact:{accent:'#d64b3d',page_bg:'#f2f2ef',text:'#171b1f',header_bg:'#ffffff',buy_bg:'#ffffff',sell_bg:'#e7e8e4',footer_bg:'#171b1f'}
};
const templateHeadlines={editorial:'A clear way to buy and sell',classic:'A trusted way to buy and sell',grid:'Your products. Your buying list.',studio:'Good products deserve a good presentation.',horizon:'A simpler way to buy and sell',field:'Equipment for the next chapter.',business:'A straightforward way to buy and sell',luxe:'Quality products. Clear service.',commerce:'Browse, buy and sell with confidence.',impact:'BUY. SELL. MOVE FORWARD.'};
const templateDefaults={
 editorial:{kicker:'',cta1:'',cta2:'Visit our retail shop'},
 classic:{kicker:'',cta1:'',cta2:'Visit our retail shop'},
 grid:{kicker:'',cta1:'',cta2:'Visit our retail shop'},
 studio:{kicker:'',cta1:'',cta2:'Visit our retail shop'},
 horizon:{kicker:'',cta1:'',cta2:'Visit our retail shop'},
 field:{kicker:'',cta1:'',cta2:'Visit our retail shop'},
 business:{kicker:'',cta1:'',cta2:'Visit our retail shop'},
 luxe:{kicker:'',cta1:'',cta2:'Visit our retail shop'},
 commerce:{kicker:'',cta1:'',cta2:'Visit our retail shop'},
 impact:{kicker:'',cta1:'',cta2:'Visit our retail shop'}
};

const pageDefinitions=[
 {slug:'buying',title:'What We Buy',enabled:true,hint:'Buying page',prompt:'Show customers what you are looking to buy and how they can start a selling request.'},
 {slug:'shop',title:'Retail Shop',enabled:true,hint:'Selling page',prompt:'Show customers the products you currently have available to buy.'},
 {slug:'about',title:'About',enabled:true,hint:'About your business',prompt:'Tell customers about your business, service and experience.'},
 {slug:'contact',title:'Contact',enabled:true,hint:'Contact details',prompt:'Add the contact information customers need to reach your business.'},
 {slug:'customer-account',title:'Customer Account',enabled:true,hint:'Customer account area',prompt:'Customer account area managed by TradeFlow.'}
];

function defaultPages(){
 return pageDefinitions.map(p=>({
   slug:p.slug,title:p.title,enabled:p.enabled,
   body:p.slug==='shop'?'Welcome to our shop. Browse our current products below.':
        p.slug==='customer-account'?'':p.slug==='contact'?'Add your contact details here.':'',
   image_url:'',image_alt:'',image_url2:'',image_alt2:'',tile_count:p.slug==='shop'||p.slug==='buying'?6:0,tile_columns:p.slug==='shop'||p.slug==='buying'?3:3,tiles:p.slug==='shop'||p.slug==='buying'?defaultPageTiles(p.slug==='shop'?'shop-tile':'buying-tile'):[],seo_title:'',seo_description:''
 }));
}
let pages=defaultPages();

function defaultPageTiles(prefix){
 return Array.from({length:12},(_,i)=>({id:prefix+'-'+(i+1),title:'',body:'',image_url:'',image_alt:'',cta:''}));
}
function ensurePageTileCapacity(tiles,prefix){
 const existing=Array.isArray(tiles)?tiles:[];const byId=new Map(existing.map(t=>[t.id,t]));
 return defaultPageTiles(prefix).map(d=>byId.has(d.id)?Object.assign({},d,byId.get(d.id)):Object.assign({},d));
}
function cleanPageTiles(tiles,prefix){
 const defaults=new Map(defaultPageTiles(prefix).map(t=>[t.id,t]));
 return (Array.isArray(tiles)?tiles:[]).map(t=>{const d=defaults.get(t.id);if(!d)return t;const copy={...t};['title','body','cta'].forEach(k=>{if(copy[k]===d[k])copy[k]='';});return copy;});
}
function pageTileConfig(p){
 const prefix=p.slug==='shop'?'shop-tile':'buying-tile';
 return {tiles:ensurePageTileCapacity(cleanPageTiles(p.tiles,prefix),prefix),count:[3,4,6,8,9,10,12].includes(Number(p.tile_count))?Number(p.tile_count):6,columns:[2,3,4].includes(Number(p.tile_columns))?Number(p.tile_columns):3};
}
function esc(v){return String(v==null?'':v).replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]||c))}
function setStatus(text,type){const el=$('status');if(el){el.textContent=text||'';el.dataset.type=type||''}}
function markDirty(){dirty=true;const el=$('save-state');if(el)el.textContent='Unsaved changes';}
function pageDef(slug){return pageDefinitions.find(p=>p.slug===slug)||{slug:slug,title:slug,hint:'Optional',enabled:true,prompt:'Add the information customers need on this page.'}}
function cleanPageBody(slug,body){const v=String(body||'').trim();const placeholders={shop:['Welcome to our shop. Browse our current products below.','Browse our current retail range.'],contact:['Add your contact details here.']};return (placeholders[slug]||[]).includes(v)?'':v;}
function validPageSlug(slug){return slug==='home'||pages.some(p=>p.slug===slug)}
function currentPage(){return selectedPage==='home'?{slug:'home',title:'Home page'}:(pages.find(p=>p.slug===selectedPage)||pages[0])}

function renderPageList(){
 const box=$('page-list');if(!box)return;
 const items=[{slug:'home',title:'Home page',hint:'Main landing page',enabled:true},...pages.map(p=>({slug:p.slug,title:p.title,hint:p.slug==='shop'?'Retail selling page':p.slug==='buying'?'Buying page':pageDef(p.slug).hint,enabled:p.enabled}))];
 box.innerHTML=items.map(p=>'<div class="page-row '+(p.slug===selectedPage?'selected':'')+'"><button type="button" class="page-link" data-page="'+esc(p.slug)+'"><span class="page-link-icon">'+(p.slug==='home'?'HOME':p.slug==='shop'?'SHOP':p.slug==='buying'?'BUY':'PAGE')+'</span><span><b>'+esc(p.title)+'</b><small>'+esc(p.enabled===false?'Hidden from website':p.hint)+'</small></span></button>'+(p.slug==='home'||p.slug==='customer-account'?'':p.slug==='buying'||p.slug==='shop'?'<button type="button" class="page-visibility" data-toggle-page="'+esc(p.slug)+'">'+(p.enabled===false?'Show':'Hide')+'</button>':'<button type="button" class="page-delete" data-delete-page="'+esc(p.slug)+'" title="Delete page">Delete</button>')+'</div>').join('');
 box.querySelectorAll('[data-page]').forEach(b=>b.addEventListener('click',()=>selectPage(b.dataset.page)));
 box.querySelectorAll('[data-toggle-page]').forEach(b=>b.addEventListener('click',()=>{
   const slug=b.dataset.togglePage,page=pages.find(p=>p.slug===slug);if(!page)return;
   page.enabled=page.enabled===false;markDirty();renderPageList();renderHeaderFooterControls();renderEditor();setStatus(page.enabled?'What We Buy / What We Sell page shown.':'What We Buy / What We Sell page hidden from the customer website.','success');
 }));
 box.querySelectorAll('[data-delete-page]').forEach(b=>b.addEventListener('click',()=>{
   const slug=b.dataset.deletePage,page=pages.find(p=>p.slug===slug);if(!page)return;
   if(slug==='buying'||slug==='shop'){setStatus('What We Buy and What We Sell are permanent TradeFlow pages. They can be hidden, but not deleted.','error');return;}
   if(!window.confirm('Delete the page "'+page.title+'"? This will remove it from this website draft.'))return;
   if(!window.confirm('Are you sure you want to permanently remove "'+page.title+'" from this website draft?'))return;
   pages=pages.filter(p=>p.slug!==slug);headerLinks=headerLinks.filter(x=>x!==slug);footerLinks=footerLinks.filter(x=>x!==slug);
   selectedPage='home';markDirty();renderPageList();renderPageManager();renderHeaderFooterControls();renderBuilderPageHelp();renderEditor();setStatus('Page deleted from the draft. Save the draft to keep the change.','success');
 }));
}

function renderHeroImageControls(){const box=$('hero-image-controls');if(box)box.innerHTML='';}
function renderHomepageControls(){
 const box=$('homepage-controls');if(!box)return;
 const p=currentPage();
 const isCustomPage=p.slug==='buying'||p.slug==='shop';
 if(isCustomPage){
   const cfg=pageTileConfig(p);
   p.tiles=cfg.tiles;p.tile_count=cfg.count;p.tile_columns=cfg.columns;
   box.innerHTML='<div class="tile-count-title">'+(p.slug==='shop'?'What We Sell':'What We Buy')+' page tiles</div><div class="tile-counts">'+[3,4,6,8,9,10,12].map(n=>'<button type="button" class="tile-count '+(cfg.count===n?'selected':'')+'" data-page-tile-count="'+n+'">'+n+' tiles</button>').join('')+'</div><div class="tile-count-title">Tiles per row</div><div class="tile-counts">'+[2,3,4].map(n=>'<button type="button" class="tile-count '+(cfg.columns===n?'selected':'')+'" data-page-tile-columns="'+n+'">'+n+' per row</button>').join('')+'</div><small>Add images, headings, descriptions and links directly in the page preview. These tiles are separate from the homepage.</small>';
   box.querySelectorAll('[data-page-tile-count]').forEach(b=>b.addEventListener('click',()=>{p.tile_count=Number(b.dataset.pageTileCount);renderHomepageControls();renderEditor();markDirty();}));
   box.querySelectorAll('[data-page-tile-columns]').forEach(b=>b.addEventListener('click',()=>{p.tile_columns=Number(b.dataset.pageTileColumns);renderHomepageControls();renderEditor();markDirty();}));
   return;
 }
 box.innerHTML='<div class="tile-count-title">Homepage tile layout</div><div class="tile-counts">'+[3,4,6,8,9,10,12].map(n=>'<button type="button" class="tile-count '+(homepageTileCount===n?'selected':'')+'" data-tile-count="'+n+'">'+n+' tiles</button>').join('')+'</div><div class="tile-count-title">Tiles per row</div><div class="tile-counts">'+[2,3,4].map(n=>'<button type="button" class="tile-count '+(homepageTileColumns===n?'selected':'')+'" data-tile-columns="'+n+'">'+n+' per row</button>').join('')+'</div><small>Choose how many visual tiles appear and how many sit on each row. TradeFlow keeps the selected layout on the customer website.</small>';
 box.querySelectorAll('[data-tile-count]').forEach(b=>b.addEventListener('click',()=>{homepageTileCount=Number(b.dataset.tileCount);renderHomepageControls();renderEditor();markDirty();}));
 box.querySelectorAll('[data-tile-columns]').forEach(b=>b.addEventListener('click',()=>{homepageTileColumns=Number(b.dataset.tileColumns);renderHomepageControls();renderEditor();markDirty();}));
}
function renderPageTilesEditor(p){
 const cfg=pageTileConfig(p);p.tiles=cfg.tiles;p.tile_count=cfg.count;p.tile_columns=cfg.columns;
 const visible=cfg.tiles.slice(0,cfg.count);
 return '<section class="homepage-tiles page-custom-tiles"><div class="homepage-tile-grid" style="--tile-columns:'+cfg.columns+'">'+visible.map(tile=>'<article class="editable-home-tile page-tile" draggable="true" data-page-tile-id="'+esc(tile.id)+'"><div class="tile-image">'+(tile.image_url?'<img src="'+esc(tile.image_url)+'" alt="'+esc(tile.image_alt||tile.title||'')+'"><button type="button" data-image-action="remove" data-image-target="page:'+esc(p.slug)+':tile:'+esc(tile.id)+'">Remove</button>':'<button type="button" data-image-action="add" data-image-target="page:'+esc(p.slug)+':tile:'+esc(tile.id)+'">Add image</button>')+'</div><div class="tile-copy"><h3 contenteditable="true" data-page-tile-id="'+esc(tile.id)+'" data-tile-field="title">'+esc(tile.title)+'</h3><p contenteditable="true" data-page-tile-id="'+esc(tile.id)+'" data-tile-field="body">'+esc(tile.body)+'</p><b contenteditable="true" data-page-tile-id="'+esc(tile.id)+'" data-tile-field="cta">'+esc(tile.cta)+'</b></div></article>').join('')+'</div></section>';
}

function resetDesignColours(){
 const p=templatePalettes[currentTemplate]||templatePalettes.editorial;
 themeColors={...themeColors,accent:p.accent,button_bg:p.accent,button_text:'#ffffff',text:p.text,page_bg:p.page_bg,header_bg:p.header_bg,buy_bg:p.buy_bg,sell_bg:p.sell_bg,footer_bg:p.footer_bg,background_style:'none',background_category:'none',background_color:'#f5f6f8',background_color2:'#ffffff'};
 typography={font:'Inter',hero:'large',section:'large',body:'standard',nav:'standard',button:'solid',header:'standard',footer:'simple'};
 applyWebsiteBackground();
 renderDesignControls();renderEditor();markDirty();
 setStatus('Design colours reset to the selected template defaults. Your pages, text and images were kept. Save the draft to keep the reset.','success');
}
function renderDesignControls(){
 const box=$('design-controls');if(!box)return;
 const colors=[['accent','Brand / accent'],['button_bg','Button colour'],['button_text','Button text colour'],['text','Text'],['page_bg','Content surface'],['header_bg','Header / navigation'],['buy_bg','Buying section'],['sell_bg','Selling section'],['footer_bg','Footer']];
 const palettes={professional:{label:'Professional',description:'Navy, blue-grey and restrained gold',accent:'#2563a8',text:'#172a3a',page_bg:'#f3f6f8',header_bg:'#ffffff',buy_bg:'#ffffff',sell_bg:'#e8eef4',footer_bg:'#142635'},warm:{label:'Warm',description:'Terracotta, cream and soft brown',accent:'#a84f2d',text:'#2b211d',page_bg:'#fbf7f2',header_bg:'#fffaf5',buy_bg:'#fffdf9',sell_bg:'#f3e7dc',footer_bg:'#3a2b25'},dark:{label:'Dark',description:'Charcoal, slate and warm gold',accent:'#d79a55',text:'#f2f4f5',page_bg:'#151b20',header_bg:'#101419',buy_bg:'#182027',sell_bg:'#202a32',footer_bg:'#0b0f12'},clean:{label:'Clean',description:'Fresh blue with white space',accent:'#1769aa',text:'#17202a',page_bg:'#f7f9fb',header_bg:'#ffffff',buy_bg:'#ffffff',sell_bg:'#edf3f8',footer_bg:'#172b3a'},ocean:{label:'Ocean',description:'Deep teal, aqua and cool mist',accent:'#087f8c',text:'#12343a',page_bg:'#edf7f7',header_bg:'#ffffff',buy_bg:'#ffffff',sell_bg:'#dcefee',footer_bg:'#10383d'},emerald:{label:'Emerald',description:'Rich green, sage and ivory',accent:'#16825b',text:'#17352a',page_bg:'#f0f7f3',header_bg:'#ffffff',buy_bg:'#ffffff',sell_bg:'#deeee6',footer_bg:'#17382d'},royal:{label:'Royal',description:'Indigo, violet and soft lavender',accent:'#5b4bb7',text:'#242044',page_bg:'#f5f3fb',header_bg:'#ffffff',buy_bg:'#ffffff',sell_bg:'#e9e5f6',footer_bg:'#28204d'},sunset:{label:'Sunset',description:'Coral, amber and warm sand',accent:'#e45f3a',text:'#3a241e',page_bg:'#fff6f0',header_bg:'#fffdf9',buy_bg:'#ffffff',sell_bg:'#f8e4d8',footer_bg:'#40251e'},citrus:{label:'Citrus',description:'Lively orange, lemon and fresh cream',accent:'#e38b1f',text:'#302615',page_bg:'#fff9ec',header_bg:'#fffef8',buy_bg:'#ffffff',sell_bg:'#f7edc9',footer_bg:'#3a2d16'},berry:{label:'Berry',description:'Raspberry, plum and pale blush',accent:'#b43d69',text:'#351e2a',page_bg:'#fbf2f6',header_bg:'#fffafd',buy_bg:'#ffffff',sell_bg:'#f2dce5',footer_bg:'#3d2030'},coral:{label:'Coral',description:'Bright coral with coastal blue-grey',accent:'#e85d5d',text:'#302225',page_bg:'#fff5f3',header_bg:'#ffffff',buy_bg:'#ffffff',sell_bg:'#f5e1e1',footer_bg:'#3b252b'},sky:{label:'Sky',description:'Clear blue, powder blue and navy',accent:'#1684d8',text:'#183047',page_bg:'#f1f8fe',header_bg:'#ffffff',buy_bg:'#ffffff',sell_bg:'#dcecf9',footer_bg:'#15314a'},forest:{label:'Forest',description:'Deep green, moss and natural cream',accent:'#2f6b45',text:'#203026',page_bg:'#f2f6f1',header_bg:'#fffefa',buy_bg:'#ffffff',sell_bg:'#e2ebdf',footer_bg:'#1d3525'},plum:{label:'Plum',description:'Plum, mauve and warm stone',accent:'#7a3f70',text:'#302333',page_bg:'#f7f2f6',header_bg:'#fffdfd',buy_bg:'#ffffff',sell_bg:'#e9dce7',footer_bg:'#302034'},teal:{label:'Teal',description:'Vivid teal balanced with graphite',accent:'#009688',text:'#163332',page_bg:'#eff9f8',header_bg:'#ffffff',buy_bg:'#ffffff',sell_bg:'#d9efec',footer_bg:'#163b39'},electric:{label:'Electric',description:'Bright blue, cobalt and cool grey',accent:'#1769ff',text:'#18233b',page_bg:'#f2f6ff',header_bg:'#ffffff',buy_bg:'#ffffff',sell_bg:'#dfe8ff',footer_bg:'#172650'},rose:{label:'Rose',description:'Modern rose, blush and charcoal',accent:'#d34f78',text:'#30222a',page_bg:'#fff4f7',header_bg:'#ffffff',buy_bg:'#ffffff',sell_bg:'#f5dfe6',footer_bg:'#3b2530'},monochrome:{label:'Monochrome',description:'Black, white and neutral grey',accent:'#3f4650',text:'#1e2328',page_bg:'#f4f5f6',header_bg:'#ffffff',buy_bg:'#ffffff',sell_bg:'#e7e9eb',footer_bg:'#20252a'}};
 box.innerHTML='<div class="control-title">Website background</div><small>Choose a base colour and optionally add stripes, dots or an ombre gradient. The background covers the whole website, including the editable top area.</small><label class="color-control"><span>Background colour</span><input type="color" data-bg-color="1" value="'+esc(themeColors.background_color||themeColors.page_bg||'#f5f6f8')+'"><code>'+esc(themeColors.background_color||themeColors.page_bg||'#f5f6f8')+'</code></label><label class="select-control"><span>Background pattern</span><select data-bg-style><option value="none" '+(themeColors.background_style==='none'?'selected':'')+'>None — solid colour</option><option value="stripes" '+(themeColors.background_style==='stripes'?'selected':'')+'>Stripes</option><option value="dots" '+(themeColors.background_style==='dots'?'selected':'')+'>Dots</option><option value="gradient" '+(themeColors.background_style==='gradient'?'selected':'')+'>Ombre / gradient</option></select></label><label class="select-control"><span>Category pattern</span><select data-bg-category><option value="none" '+(themeColors.background_category==='none'?'selected':'')+'>None</option>'+Object.entries(categoryBackgrounds).filter(([id])=>id!=='none').map(([id,p])=>'<option value="'+id+'" '+(themeColors.background_category===id?'selected':'')+'>'+esc(p.label)+'</option>').join('')+'</select></label><label class="color-control"><span>Pattern / second colour</span><input type="color" data-bg-color="2" value="'+esc(themeColors.background_color2||'#ffffff')+'"><code>'+esc(themeColors.background_color2||'#ffffff')+'</code></label><div class="background-preview"></div><div class="control-title">Brand colours</div><small>These colours control the header, page surfaces, buying section, selling section and footer.</small><button type="button" class="design-reset-button" onclick="resetDesignColours();return false;">Reset design colours</button><div class="color-grid">'+colors.map(([key,label])=>'<label class="color-control"><span>'+label+'</span><input type="color" data-color="'+key+'" value="'+esc(themeColors[key])+'"><code>'+esc(themeColors[key])+'</code></label>').join('')+'</div><div class="preset-row"><span>Quick palettes</span><small>Choose a coordinated starting palette, then fine-tune any colour above.</small>'+Object.entries(palettes).map(([id,p])=>'<button type="button" data-palette="'+id+'" title="'+esc(p.label+' — '+p.description)+'"><i style="background:'+p.accent+'"></i>'+esc(p.label)+'</button>').join('')+'</div>';
 const bgPreview=box.querySelector('.background-preview');if(bgPreview){const s=themeColors.background_style||'none',cat=themeColors.background_category||'none',a=themeColors.background_color||'#f5f6f8',b=themeColors.background_color2||'#ffffff';bgPreview.style.backgroundColor=a;let pi=s==='stripes'?'repeating-linear-gradient(135deg,'+a+' 0 18px,'+b+' 18px 36px)':s==='dots'?'radial-gradient(circle,'+b+' 1.8px,transparent 1.8px)':s==='gradient'?'linear-gradient(135deg,'+a+' 0%,'+b+' 100%)':'none';const ci=categoryBackgroundImage(cat);bgPreview.style.backgroundImage=pi==='none'?(ci==='none'?'none':ci):(ci==='none'?pi:pi+','+ci);bgPreview.style.backgroundSize=s==='dots'?'18px 18px':'cover';bgPreview.style.backgroundRepeat=s==='dots'?'repeat':'no-repeat';}
 box.querySelectorAll('[data-bg-color]').forEach(input=>input.addEventListener('input',()=>{themeColors[input.dataset.bgColor==='1'?'background_color':'background_color2']=input.value;applyWebsiteBackground();renderDesignControls();markDirty();}));
 box.querySelectorAll('[data-bg-style]').forEach(input=>input.addEventListener('change',()=>{themeColors.background_style=input.value;applyWebsiteBackground();renderDesignControls();renderEditor();markDirty();})); box.querySelectorAll('[data-bg-category]').forEach(input=>input.addEventListener('change',()=>{themeColors.background_category=input.value;applyWebsiteBackground();renderDesignControls();renderEditor();markDirty();}));
 box.querySelectorAll('[data-color]').forEach(input=>input.addEventListener('input',()=>{themeColors[input.dataset.color]=input.value;renderEditor();renderDesignControls();markDirty();}));
 
 box.querySelectorAll('[data-palette]').forEach(b=>b.addEventListener('click',()=>{const p=palettes[b.dataset.palette];themeColors={...themeColors,accent:p.accent,button_bg:p.accent,button_text:'#ffffff',text:p.text,page_bg:p.page_bg,header_bg:p.header_bg,buy_bg:p.buy_bg,sell_bg:p.sell_bg,footer_bg:p.footer_bg};renderDesignControls();renderEditor();markDirty();}));
}
function renderHeaderFooterControls(){
 const box=$('header-footer-controls');if(!box)return;
 const available=[{slug:'home',title:'Home'},...pages.filter(p=>p.slug!=='customer-account').map(p=>({slug:p.slug,title:p.slug==='buying'?'What We Buy':p.slug==='shop'?'What We Sell':p.title}))];
 const checks=(arr,key)=>available.map(p=>'<label class="check-control"><input type="checkbox" data-link-area="'+key+'" data-link-slug="'+esc(p.slug)+'" '+(arr.includes(p.slug)?'checked':'')+'><span>'+esc(p.title)+'</span></label>').join('');
 box.innerHTML='<div class="control-title">Header & footer</div><small>Choose what appears in your navigation. You can edit the wording and links without changing your business data.</small><label class="select-control"><span>Header tagline</span><input type="text" data-hf-field="headerTagline" value="'+esc(headerTagline)+'" placeholder="Optional short line"></label><label class="select-control"><span>Footer text</span><input type="text" data-hf-field="footerText" value="'+esc(footerText)+'" placeholder="Short business message"></label><div class="hf-columns"><div><b>Header links</b>'+checks(headerLinks,'header')+'</div><div><b>Footer links</b>'+checks(footerLinks,'footer')+'</div></div>';
 box.querySelectorAll('[data-hf-field]').forEach(el=>el.addEventListener('input',()=>{if(el.dataset.hfField==='headerTagline')headerTagline=el.value;if(el.dataset.hfField==='footerText')footerText=el.value;markDirty();renderEditor();}));
 box.querySelectorAll('[data-link-area]').forEach(el=>el.addEventListener('change',()=>{const target=el.dataset.linkArea==='header'?headerLinks:footerLinks;el.checked?target.push(el.dataset.linkSlug):target.splice(target.indexOf(el.dataset.linkSlug),1);markDirty();renderHeaderFooterControls();renderEditor();}));
}
function renderPageManager(){
 const box=$('page-manager');if(!box)return;
 box.innerHTML='<div class="control-title">Pages</div><small>Add your own pages and then choose whether they appear in the header or footer.</small><div class="page-add-row"><input id="new-page-title" type="text" placeholder="New page name"><button type="button" id="add-page-button">Add page</button></div>';
 const btn=$('add-page-button');if(btn)btn.addEventListener('click',()=>{const input=$('new-page-title'),title=input.value.trim();if(!title)return;const slug=title.toLowerCase().replace(/[^a-z0-9]+/g,'-').replace(/^-|-$/g,'')||'page-'+Date.now();if(pages.some(p=>p.slug===slug)){setStatus('That page already exists.','error');return}pages.push({slug,title,enabled:true,prompt:'Add the information customers should see on this page.',body:'',image_url:'',image_alt:'',image_url2:'',image_alt2:'',tile_count:0,tile_columns:3,tiles:[],seo_title:'',seo_description:''});headerLinks.push(slug);footerLinks.push(slug);input.value='';markDirty();renderPageList();renderHeaderFooterControls();renderEditor();selectPage(slug);});
}
function renderBrandingControls(){
 const box=$('branding-controls');if(!box)return;
 box.innerHTML='<div class="control-title">Branding</div><small>Keep your customer-facing logo and website banner together here. Your business name remains managed in Business Settings. The logo is used in the website header; the banner is used in the homepage hero. Recommended banner size: <b>1600 × 600 px</b> (8:3). PNG, JPEG or WebP, maximum 5 MB.</small>'+
 '<div class="branding-control">'+(logoUrl?'<img src="'+esc(logoUrl)+'" alt="'+esc(siteName)+'"><span class="small">Logo uploaded</span>':'<span class="small">No business logo uploaded.</span>')+'<div class="actions"><button type="button" data-logo-upload>'+(logoUrl?'Replace logo':'Upload logo')+'</button>'+(logoUrl?'<button type="button" class="secondary" data-logo-remove>Remove logo</button>':'')+'</div></div>'+
 '<div class="branding-banner-control">'+(bannerUrl?'<img src="'+esc(bannerUrl)+'" alt="Website banner">':'<div class="generated-brand-banner-preview">'+esc(siteName||'Your Business')+'</div>')+
 '<div class="branding-banner-actions"><span class="small">'+(bannerUrl?'Website banner uploaded':'No banner uploaded — the business name will be used automatically')+'</span><div class="actions"><button type="button" data-banner-upload>Upload banner</button>'+(bannerUrl?'<button type="button" class="secondary" data-banner-remove>Remove banner</button>':'')+'</div></div>'+
 '<label class="check-control branding-banner-toggle"><input type="checkbox" data-use-banner '+(useBanner&&bannerUrl?'checked':'')+(bannerUrl?'':' disabled')+'> Use banner as the website title banner</label><label class="banner-position-control"><span>Position</span><select data-banner-position><option value="left" '+(bannerPosition==='left'?'selected':'')+'>Left</option><option value="center" '+(bannerPosition==='center'?'selected':'')+'>Centre</option><option value="right" '+(bannerPosition==='right'?'selected':'')+'>Right</option></select></label></div>'+
 '<div class="actions"><a href="settings.html">Business Settings</a></div>';
 const logoUpload=box.querySelector('[data-logo-upload]');
 if(logoUpload)logoUpload.addEventListener('click',()=>{const input=$('image-file-input');input.dataset.target='logo';input.value='';input.click();});
 const logoRemove=box.querySelector('[data-logo-remove]');
 if(logoRemove)logoRemove.addEventListener('click',()=>removeImage('logo'));
 const upload=box.querySelector('[data-banner-upload]');
 if(upload)upload.addEventListener('click',()=>{const input=$('image-file-input');input.dataset.target='banner';input.value='';input.click();});
 const remove=box.querySelector('[data-banner-remove]');
 if(remove)remove.addEventListener('click',()=>removeImage('banner'));
 const bannerToggle=box.querySelector('[data-use-banner]');
 if(bannerToggle)bannerToggle.addEventListener('change',()=>{useBanner=bannerToggle.checked;renderEditor();markDirty();setStatus(useBanner?'Banner will be used as the website title banner.':'Text headline will be used instead of the banner.','success');}); const bannerPositionSelect=box.querySelector('[data-banner-position]');if(bannerPositionSelect)bannerPositionSelect.addEventListener('change',()=>{bannerPosition=bannerPositionSelect.value;renderEditor();markDirty();});
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
 const items=[['hero','Hero section'],['hero_image','Hero image'],['dual','Buying & selling introduction'],['buy','What we buy tiles'],['sell','What we sell tiles'],['trust','Trust strip'],['shop','Retail shop']];
 box.innerHTML='<div class="control-title">Website sections</div><small>Show or hide sections without deleting your content. Hidden sections can be switched back on later.</small>'+items.map(([k,l])=>'<label class="check-control section-toggle"><input type="checkbox" data-section="'+k+'" '+(homepageSections[k]!==false?'checked':'')+'><span>'+l+'</span></label>').join('');
 box.querySelectorAll('[data-section]').forEach(el=>el.addEventListener('change',()=>{homepageSections[el.dataset.section]=el.checked;renderEditor();markDirty();}));
}

function renderTemplates(){
 const box=$('templates');if(!box)return;
 box.innerHTML=templates.map(t=>'<button type="button" class="template-card '+(t.id===currentTemplate?'selected':'')+'" data-template="'+t.id+'"><span class="template-mini template-mini-'+t.id+'"><i></i><b></b><em></em><u></u></span><strong>'+esc(t.name)+'</strong><small>'+esc(t.desc)+'</small></button>').join('');
 box.querySelectorAll('[data-template]').forEach(b=>b.addEventListener('click',()=>applyTemplate(b.dataset.template)));
}

function navMarkup(){
 const links=pages.filter(p=>p.enabled&&['about','contact'].includes(p.slug)).map(p=>'<button type="button" data-nav-page="'+esc(p.slug)+'">'+esc(p.title)+'</button>').join('');
 const cats=Array.isArray(buyingCatalogue.categories)?buyingCatalogue.categories:[];
 const categoryLinks=cats.map(cat=>'<button type="button" data-nav-page="buying"><b>'+esc(cat.name)+'</b><small>'+Number(cat.product_count||0)+' products</small></button>').join('');
 const buyingLink='<button type="button" data-nav-page="buying">What We Buy</button>';
 return '<header class="template-header"><nav class="template-nav"><div class="template-brand">'+logoEditor()+'<small>'+esc(headerTagline)+'</small></div><div class="template-nav-links">'+links+buyingLink+'<button type="button" data-nav-page="shop">What We Sell</button><span class="managed-login">Customer Login</span></div></nav></header>';
}
function footerMarkup(){
 const findTitle=slug=>slug==='home'?'Home':slug==='buying'?'What We Buy':slug==='shop'?'What We Sell':(pages.find(p=>p.slug===slug)?.title||slug);
 const links=footerLinks.filter(slug=>slug==='home'||pages.some(p=>p.slug===slug&&p.enabled!==false)).map(slug=>'<button type="button" data-nav-page="'+esc(slug)+'">'+esc(findTitle(slug))+'</button>').join('');
 return '<footer class="template-footer"><div><strong>'+esc(siteName)+'</strong><p>'+esc(footerText||'Your business website powered by TradeFlow.')+'</p></div><div class="template-footer-links">'+links+'</div></footer>';
}

function imageBlock(url,kind,label,alt){
 const heading=kind==='home'?'MAIN HERO IMAGE':kind==='home2'?'SECONDARY HERO IMAGE':kind==='home-buy'?'WHAT WE BUY IMAGE':kind==='home-sell'?'WHAT WE SELL IMAGE':'IMAGE';
 if(url)return '<div class="image-slot"><div class="image-slot-label">'+heading+'</div><div class="visual-image"><img src="'+esc(url)+'" alt="'+esc(alt||'')+'"><div class="image-tools"><button type="button" data-image-action="replace" data-image-target="'+esc(kind)+'">Replace image</button><button type="button" data-image-action="remove" data-image-target="'+esc(kind)+'">Remove</button></div></div></div>';
 return '<div class="image-slot"><div class="image-slot-label">'+heading+'</div><div class="image-drop"><button type="button" data-image-action="add" data-image-target="'+esc(kind)+'">Add image</button><span>'+esc(label)+'</span><small>PNG, JPEG or WebP · maximum 5 MB</small></div></div>';
}

function editText(field,value,tag='span',cls=''){return '<'+tag+' class="'+cls+'" contenteditable="true" data-edit="'+field+'">'+esc(value||'')+'</'+tag+'>'}
function logoEditor(){return logoUrl?'<div class="brand-mark"><img src="'+esc(logoUrl)+'" alt="'+esc(siteName)+'"><button type="button" data-image-action="replace" data-image-target="logo">Change logo</button></div>':'<div class="brand-mark"><button type="button" data-image-action="add" data-image-target="logo">Add logo</button><span>'+esc(siteName||'Your business')+'</span></div>'}
function buyingPreview(){
 const products=Array.isArray(buyingCatalogue.products)?buyingCatalogue.products:[];
 const categories=Array.isArray(buyingCatalogue.categories)?buyingCatalogue.categories:[];
 if(!categories.length)return '';
 const cards=categories.map(cat=>{
   const items=products.filter(p=>p.category_id===cat.id);
   const image=items.find(p=>p.image_url)?.image_url||'';
   const imageMarkup=image?'<img src="'+esc(image)+'" alt="'+esc(cat.name)+'">':'<span aria-hidden="true"></span>';
   return '<article class="buy-category-card"><div class="buy-category-image">'+imageMarkup+'</div><div class="buy-category-copy"><h3>'+esc(cat.name)+'</h3><strong>'+items.length+' '+(items.length===1?'product':'products')+'</strong><p>'+esc(cat.description||'Products selected for this business buying list.')+'</p><a href="#" data-nav-page="buying">Sell this type →</a></div></article>';
 }).join('');
 return '<div class="buy-category-grid">'+cards+'</div>';
}
function sellingPreview(){
 const list=Array.isArray(retailListings)?retailListings:[];
 if(!list.length)return '';
 return '<div class="sell-product-grid">'+list.slice(0,6).map(p=>'<article class="sell-product-card"><div class="sell-photo">'+(p.image_url?'<img src="'+esc(p.image_url)+'" alt="'+esc(p.title||'Product')+'">':'<span aria-hidden="true"></span>')+'</div><span>'+esc(p.category_name||'')+'</span><h3>'+esc(p.title||'Product')+'</h3><strong>'+esc(p.asking_price!=null?new Intl.NumberFormat('en-GB',{style:'currency',currency:p.currency||'GBP'}).format(Number(p.asking_price)):'')+'</strong><a href="#" data-nav-page="shop">View &amp; buy</a></article>').join('')+'</div>';
}
function navMarkup(){
 const links=pages.filter(p=>p.enabled&&['about','contact','buying','shop'].includes(p.slug)).map(p=>'<button type="button" data-nav-page="'+esc(p.slug)+'">'+esc(p.slug==='buying'?'What We Buy':p.slug==='shop'?'What We Sell':p.title)+'</button>').join('');
 return '<nav class="template-nav"><div class="template-brand">'+logoEditor()+'</div><div class="template-nav-links"><button type="button" data-nav-page="home">Home</button>'+links+'<span class="managed-login">Customer Login</span></div></nav>';
}
function templateHeroImage(url,target,label,alt){
 const text=label||'Add an image to this template area.';
 if(url)return '<div class="template-image-slot template-image-filled"><div class="template-image-frame"><img src="'+esc(url)+'" alt="'+esc(alt||siteName||'Website image')+'"><div class="template-image-tools"><button type="button" data-image-action="replace" data-image-target="'+esc(target)+'">Replace image</button><button type="button" data-image-action="remove" data-image-target="'+esc(target)+'">Remove</button></div></div></div>';
 return '<div class="template-image-slot template-image-empty"><button type="button" data-image-action="add" data-image-target="'+esc(target)+'">Add image</button><span>'+esc(text)+'</span></div>';
}
function templateHero(){return renderEditableHero();}

function normalizeGlobalHeaderElement(v){
 const d=normalizeEditableHeroElement(v||{});
 d.id=String(v?.id||d.id);
 d.x=Math.max(0,Math.min(92,Number(d.x)||0));
 d.y=Math.max(0,Math.min(80,Number(d.y)||0));
 d.width=Math.max(8,Math.min(92,Number(d.width)||40));
 d.height=Math.max(8,Math.min(90,Number(d.height)||30));
 d.role=String(v?.role||d.role||d.type);
 return d;
}
function makeGlobalHeaderElement(type,overrides={}){
 const id='gh-'+Date.now().toString(36)+'-'+Math.random().toString(36).slice(2,7);
 const base=type==='image'
   ?{id,type:'image',role:'photo',x:5,y:12,width:30,height:70,aspect:1.5,image_url:'',text:''}
   :{id,type:'text',role:'text',x:8,y:28,width:70,height:42,aspect:1,text:'Edit this text',font:'inherit',fontSize:28,color:'#17202a',align:'left',vAlign:'center',lineHeight:'1.2',letterSpacing:'0'};
 return normalizeGlobalHeaderElement(Object.assign(base,overrides));
}
function globalHeaderElementMarkup(el){
 const b=normalizeGlobalHeaderElement(el);
 const style='left:'+b.x+'%;top:'+b.y+'%;width:'+b.width+'%;height:'+b.height+'%;--eh-font:'+esc(b.font)+';--eh-size:'+esc(b.fontSize==='auto'?'inherit':(Number(b.fontSize)||16)+'px')+';--eh-color:'+esc(b.color)+';--eh-align:'+esc(b.align)+';--eh-valign:'+esc(b.vAlign)+';--eh-line:'+esc(b.lineHeight)+';--eh-letter:'+esc(b.letterSpacing)+'px;';
 let body='';
 if(b.type==='image'){
   body=(b.image_url||b.preview_url)
    ?'<div class="global-header-image-wrap"><img src="'+esc(b.preview_url||b.image_url)+'" alt="Website image"></div><div class="global-header-image-tools"><button type="button" data-image-action="replace" data-image-target="global-header:'+esc(b.id)+'">Change image</button><button type="button" data-image-action="remove" data-image-target="global-header:'+esc(b.id)+'">Remove image</button></div>'
    :'<div class="global-header-empty-image"><button type="button" data-image-action="add" data-image-target="global-header:'+esc(b.id)+'">'+(b.role==='banner'?'Add banner':b.role==='logo'?'Add logo':'Add photo')+'</button></div>';
 }else{
   body='<div class="global-header-text" contenteditable="true" data-gh-edit="'+esc(b.id)+'">'+esc(b.text)+'</div>';
 }
 return '<div class="global-header-element '+(b.type==='image'?'gh-image':'gh-text')+(b.id===selectedGlobalHeaderId?' selected':'')+'" data-gh-id="'+esc(b.id)+'" style="'+style+'"><span class="global-header-move" title="Drag to move">↕</span><button type="button" class="global-header-delete" data-gh-delete="'+esc(b.id)+'">×</button><span class="global-header-resize" aria-label="Resize element"></span>'+body+'</div>';
}
function renderGlobalHeaderEditor(){
 const selected=globalHeaderElements.find(x=>x.id===selectedGlobalHeaderId);
 const fontOptions=[
  ['inherit','Site default'],['Arial','Arial'],['Arial Black','Arial Black'],['Calibri','Calibri'],['Cambria','Cambria'],
  ['Comic Sans MS','Comic Sans MS'],['Courier New','Courier New'],['Georgia','Georgia'],['Garamond','Garamond'],
  ['Impact','Impact'],['Tahoma','Tahoma'],['Times New Roman','Times New Roman'],['Trebuchet MS','Trebuchet MS'],['Verdana','Verdana'],
  ['Segoe UI','Segoe UI'],['Helvetica','Helvetica'],['Palatino Linotype','Palatino Linotype'],['Book Antiqua','Book Antiqua']
 ];
 const opts=(items,current)=>items.map(o=>'<option value="'+esc(o[0])+'" '+(o[0]===current?'selected':'')+'>'+esc(o[1])+'</option>').join('');
 const selectedOpt=(v,current)=>v===String(current)?' selected':'';
 let controls='<span>Select a box to edit it. Use the move handle to drag and the corner handle to resize.</span>';
 if(selected&&selected.type==='text'){
   controls='<label>Font<select data-gh-style="font">'+opts(fontOptions,selected.font)+'</select></label>'+
    '<label>Size<select data-gh-style="fontSize"><option value="auto"'+selectedOpt('auto',selected.fontSize)+'>Auto</option>'+[12,14,16,18,20,24,28,32,36,42,48,56,64,72,84,96].map(n=>'<option value="'+n+'"'+selectedOpt(n,selected.fontSize)+'>'+n+'px</option>').join('')+'</select></label>'+
    '<label>Text colour<input type="color" data-gh-style="color" value="'+esc(selected.color||'#17202a')+'"></label>'+
    '<label>Horizontal<select data-gh-style="align"><option value="left"'+selectedOpt('left',selected.align)+'>Left</option><option value="center"'+selectedOpt('center',selected.align)+'>Centre</option><option value="right"'+selectedOpt('right',selected.align)+'>Right</option></select></label>'+
    '<label>Vertical<select data-gh-style="vAlign"><option value="top"'+selectedOpt('top',selected.vAlign)+'>Top</option><option value="center"'+selectedOpt('center',selected.vAlign)+'>Centre</option><option value="bottom"'+selectedOpt('bottom',selected.vAlign)+'>Bottom</option></select></label>'+
    '<label>Line spacing<select data-gh-style="lineHeight">'+[['1','Tight'],['1.2','Normal'],['1.4','Relaxed'],['1.6','Loose'],['2','Double']].map(o=>'<option value="'+o[0]+'"'+selectedOpt(o[0],selected.lineHeight)+'>'+o[1]+'</option>').join('')+'</select></label>'+
    '<label>Letter spacing<select data-gh-style="letterSpacing">'+[['0','Normal'],['0.5','0.5px'],['1','1px'],['2','2px'],['4','4px'],['8','8px']].map(o=>'<option value="'+o[0]+'"'+selectedOpt(o[0],selected.letterSpacing)+'>'+o[1]+'</option>').join('')+'</select></label>';
 }else if(selected&&selected.type==='image'){
   controls='<span>'+esc(selected.role==='banner'?'Banner':'Photo')+' selected. Click the image controls to change or remove it.</span>';
 }
 return '<section class="global-header-editor"><div class="global-header-toolbar">'+
  '<strong>Shared top section</strong>'+
  '<button type="button" data-gh-add="banner">Add banner</button>'+
  '<button type="button" data-gh-add="image">Add photo</button>'+
  '<button type="button" data-gh-add="text">Add text box</button>'+
  '<button type="button" data-gh-add="logo">Add logo</button>'+
  '<span class="global-header-help">Appears at the top of every page · fixed height</span>'+
  '<div class="global-header-format">'+controls+'</div></div>'+
  '<div class="global-header-canvas" data-global-header-canvas>'+globalHeaderElements.map(globalHeaderElementMarkup).join('')+'</div></section>';
}
function bindGlobalHeader(root){
 const editor=root.querySelector('.global-header-editor');if(!editor)return;
 editor.querySelectorAll('[data-gh-add]').forEach(btn=>btn.addEventListener('click',()=>{
   const type=btn.dataset.ghAdd;
   if(type==='logo'){
     const el=makeGlobalHeaderElement('image',{role:'logo',x:5,y:12,width:22,height:62,aspect:1.8,image_url:''});
     globalHeaderElements.push(el);selectedGlobalHeaderId=el.id;markDirty();renderEditor();
     if(!el.image_url){setStatus('Logo box added. Click Add image in the box to choose the logo.','success');}
     return;
   }
   const el=makeGlobalHeaderElement(type==='text'?'text':'image',{role:type==='banner'?'banner':'photo'});
   globalHeaderElements.push(el);selectedGlobalHeaderId=el.id;markDirty();renderEditor();
 }));
 editor.querySelectorAll('[data-gh-id]').forEach(el=>{
   const id=el.dataset.ghId,b=globalHeaderElements.find(x=>x.id===id);if(!b)return;
   el.addEventListener('pointerdown',e=>{
     if(e.button!==undefined&&e.button!==0)return;
     if(e.target.closest('[contenteditable="true"],button,input,select,.global-header-image-tools,.global-header-resize'))return;
     selectedGlobalHeaderId=id;el.classList.add('selected');e.preventDefault();e.stopPropagation();
     const sx=e.clientX,sy=e.clientY,ox=b.x,oy=b.y,parent=el.parentElement;
     const move=ev=>{
       b.x=Math.max(0,Math.min(92,ox+(ev.clientX-sx)/Math.max(1,parent.clientWidth)*100));
       b.y=Math.max(0,Math.min(80,oy+(ev.clientY-sy)/Math.max(1,parent.clientHeight)*100));
       el.style.left=b.x+'%';el.style.top=b.y+'%';
     };
     const up=()=>{window.removeEventListener('pointermove',move);window.removeEventListener('pointerup',up);markDirty();renderEditor();};
     window.addEventListener('pointermove',move);window.addEventListener('pointerup',up);
   });
 });
 editor.querySelectorAll('[data-gh-delete]').forEach(btn=>btn.addEventListener('click',e=>{
   e.preventDefault();e.stopPropagation();const id=btn.dataset.ghDelete;globalHeaderElements=globalHeaderElements.filter(x=>x.id!==id);selectedGlobalHeaderId=null;markDirty();renderEditor();
 }));
 editor.querySelectorAll('[data-gh-style]').forEach(control=>control.addEventListener('input',()=>{
   const b=globalHeaderElements.find(x=>x.id===selectedGlobalHeaderId);if(!b)return;
   b[control.dataset.ghStyle]=control.value;markDirty();
   const el=editor.querySelector('[data-gh-id="'+CSS.escape(b.id)+'"]');
   if(el){
     const key=control.dataset.ghStyle;
     const cssKey=key==='fontSize'?'--gh-size':key==='vAlign'?'--gh-valign':key==='lineHeight'?'--gh-line':key==='letterSpacing'?'--gh-letter':'--gh-'+key;
     el.style.setProperty(cssKey,key==='fontSize'&&control.value!=='auto'?control.value+'px':key==='letterSpacing'?control.value+'px':control.value);
   }
 }));
 editor.querySelectorAll('[data-gh-edit]').forEach(el=>el.addEventListener('input',()=>{
   const b=globalHeaderElements.find(x=>x.id===el.dataset.ghEdit);if(b){b.text=el.innerText;markDirty();}
 }));
 editor.querySelectorAll('.global-header-resize').forEach(handle=>handle.addEventListener('pointerdown',e=>{
   e.preventDefault();e.stopPropagation();const el=handle.parentElement,b=globalHeaderElements.find(x=>x.id===el.dataset.ghId);if(!b)return;
   selectedGlobalHeaderId=b.id;const sx=e.clientX,sy=e.clientY,sw=b.width,sh=b.height,parent=el.parentElement;
   const move=ev=>{
     b.width=Math.max(8,Math.min(92,sw+(ev.clientX-sx)/Math.max(1,parent.clientWidth)*100));
     b.height=Math.max(8,Math.min(90,sh+(ev.clientY-sy)/Math.max(1,parent.clientHeight)*100));
     el.style.width=b.width+'%';el.style.height=b.height+'%';
   };
   const up=()=>{window.removeEventListener('pointermove',move);window.removeEventListener('pointerup',up);markDirty();renderEditor();};
   window.addEventListener('pointermove',move);window.addEventListener('pointerup',up);
 }));
}

function renderHome(){
 const visibleTiles=homepageTiles.slice(0,homepageTileCount);
 const tileMarkup=visibleTiles.map(tile=>'<article class="editable-home-tile '+(tile.side==='buy'?'buy-tile':'sell-tile')+'" draggable="true" data-tile-id="'+esc(tile.id)+'"><div class="tile-image">'+(tile.image_url?'<img src="'+esc(tile.image_url)+'" alt="'+esc(tile.image_alt||tile.title)+'">':'<button type="button" data-image-action="add" data-image-target="tile:'+esc(tile.id)+'">Add image</button>')+'</div><div class="tile-copy"><h3 contenteditable="true" data-tile-id="'+esc(tile.id)+'" data-tile-field="title">'+esc(tile.title)+'</h3><p contenteditable="true" data-tile-id="'+esc(tile.id)+'" data-tile-field="body">'+esc(tile.body)+'</p><b contenteditable="true" data-tile-id="'+esc(tile.id)+'" data-tile-field="cta">'+esc(tile.cta)+'</b></div></article>').join('');
 const blocks={
  hero:homepageSections.hero!==false?templateHero():'',
  buy:homepageSections.buy!==false?'<section class="template-section buying-block" draggable="true" data-home-block="buy"><div class="section-intro"><div>'+editText('buyHeading',homeBuyHeading,'h2')+editText('buyIntro',homeBuyIntro,'p')+'</div>'+imageBlock(homeBuyImageUrl,'home-buy','Add a What We Buy image.',homeBuyHeading||'What We Buy')+'</div>'+buyingPreview()+'</section>':'',
  sell:homepageSections.sell!==false?'<section class="template-section selling-block" draggable="true" data-home-block="sell"><div class="section-intro"><div>'+editText('sellHeading',homeSellHeading,'h2')+editText('sellIntro',homeSellIntro,'p')+'</div>'+imageBlock(homeSellImageUrl,'home-sell','Add a What We Sell image.',homeSellHeading||'What We Sell')+'</div>'+sellingPreview()+'</section>':'',
  trust:''
 };
 const tiles=visibleTiles.length?'<section class="homepage-tiles" data-home-tiles><div class="homepage-tile-grid" style="--tile-columns:'+homepageTileColumns+'">'+tileMarkup+'</div></section>':'';
 const ordered=homepageOrder.filter(k=>blocks[k]).map(k=>blocks[k]).join('');
 return navMarkup()+renderGlobalHeaderEditor()+ordered+tiles+footerMarkup();
}

function pageTitleMarkup(p,opts={}){
 const title=opts.managed?'<h1>'+esc(p.title)+'</h1>':editText('page-title',p.title,'h1');
 const body=opts.noBody?'':editText('page-body',p.body||'','p');
 return title+body;
}
function renderPage(p){
 const isShop=p.slug==='shop',isBuying=p.slug==='buying',managed=p.slug==='customer-account';
 if(isBuying)return navMarkup()+renderGlobalHeaderEditor()+'<section class="full-page buying-page template-page"><div class="page-title-block">'+pageTitleMarkup(p)+'</div>'+buyingPreview()+renderPageTilesEditor(p)+'</section>'+footerMarkup();
 if(isShop)return navMarkup()+renderGlobalHeaderEditor()+'<section class="full-page shop-page template-page"><div class="page-title-block shop-page-title">'+pageTitleMarkup(p)+'</div>'+sellingPreview()+renderPageTilesEditor(p)+'</section>'+footerMarkup();
 return navMarkup()+renderGlobalHeaderEditor()+'<section class="full-page content-page template-page"><div class="page-title-block">'+pageTitleMarkup(p,{managed})+'</div>'+imageBlock(p.image_url,p.slug,'Add a branded image to this page.',p.image_alt||p.title)+'</section>'+footerMarkup();
}
function renderBuilderPageHelp(){
 const box=$('builder-page-help');if(!box)return;
 if(selectedPage==='buying'){box.hidden=false;box.innerHTML='<strong>How What We Buy works:</strong> this page is connected automatically to your <b>Buying Catalogue</b>. Products you add or remove in the catalogue control what customers see here. You do not need to add the products again in the Website Builder. <a href="buying-catalogue.html">Open Buying Catalogue</a> · <a href="subscriber-website-manual.html">Read the Website Manual</a>';return}
 if(selectedPage==='shop'){box.hidden=false;box.innerHTML='<strong>How What We Sell works:</strong> this page is connected automatically to your <b>Selling</b> listings. Products you set up for sale and publish through Selling appear here. You do not need to add the products again in the Website Builder. <a href="selling-dashboard.html">Open Selling</a> · <a href="subscriber-website-manual.html">Read the Website Manual</a>';return}
 box.hidden=true;box.innerHTML='';
}
function renderEditor(){
 const p=currentPage();
 $('editing-page-name').textContent=p.slug==='home'?'Home page':p.title;
 $('browser-label').textContent=(siteName||'Your business')+' · '+(p.slug==='home'?'Home':p.title);
 $('site-editor').className='site-editor template-'+currentTemplate;$('site-editor').dataset.font=typography.font;$('site-editor').dataset.heroSize=typography.hero;$('site-editor').dataset.sectionSize=typography.section;$('site-editor').dataset.bodySize=typography.body;$('site-editor').dataset.navSize=typography.nav;$('site-editor').dataset.buttonStyle=typography.button;$('site-editor').dataset.headerStyle=typography.header;$('site-editor').dataset.footerStyle=typography.footer;
 $('site-editor').innerHTML=p.slug==='home'?renderHome():renderPage(p);
 $('site-editor').style.setProperty('--accent',themeColors.accent);$('site-editor').style.setProperty('--button-bg',themeColors.button_bg||themeColors.accent);$('site-editor').style.setProperty('--button-text',themeColors.button_text||'#ffffff');applyWebsiteBackground();$('site-editor').style.setProperty('--page-bg',themeColors.page_bg);$('site-editor').style.setProperty('--text-color',themeColors.text);$('site-editor').style.setProperty('--header-bg',themeColors.header_bg);$('site-editor').style.setProperty('--buy-bg',themeColors.buy_bg);$('site-editor').style.setProperty('--sell-bg',themeColors.sell_bg);$('site-editor').style.setProperty('--footer-bg',themeColors.footer_bg);
 bindEditor();bindGlobalHeader($('site-editor'));bindEditableHero($('site-editor'));bindLayoutInteractions($('site-editor'));
}

function bindLayoutInteractions(root){
 root.querySelectorAll('[data-layout-type]').forEach(btn=>btn.addEventListener('click',e=>{e.preventDefault();e.stopPropagation();const id=btn.dataset.layoutType;if(!layoutBlocks[id])return;layoutBlocks[id].type=btn.dataset.layoutNext;if(layoutBlocks[id].type==='text'&&!layoutBlocks[id].text)layoutBlocks[id].text=id==='heroTitle'?headline:'';markDirty();renderEditor();}));
 root.querySelectorAll('[data-layout-edit]').forEach(el=>el.addEventListener('input',()=>{const id=el.dataset.layoutEdit;if(layoutBlocks[id]){layoutBlocks[id].text=el.innerText.trim();if(id==='heroTitle')headline=layoutBlocks[id].text;markDirty();}}));
 root.querySelectorAll('[data-layout-block]').forEach(el=>{
  const id=el.dataset.layoutBlock,b=layoutBlocks[id];if(!b)return;
  el.querySelectorAll('[data-layout-style]').forEach(control=>control.addEventListener('input',()=>{const key=control.dataset.layoutStyle;if(!['font','fontSize','color','align','vAlign','lineHeight','letterSpacing'].includes(key))return;b[key]=control.value;el.style.setProperty('--lb-'+(key==='fontSize'?'size':key==='vAlign'?'valign':key==='lineHeight'?'line':key==='letterSpacing'?'letter':key),key==='letterSpacing'?control.value+'px':control.value);markDirty();}));
  const resize=el.querySelector('.layout-resize-handle');
  const beginMove=e=>{
   if(e.button!==undefined&&e.button!==0)return;
   if(e.target.closest('[contenteditable="true"],button,a,select,input,.layout-block-tools,.layout-resize-handle'))return;
   e.preventDefault();e.stopPropagation();
   const sx=e.clientX,sy=e.clientY,ox=b.x,oy=b.y,parent=el.parentElement||el;
   const move=ev=>{b.x=Math.max(-45,Math.min(45,ox+(ev.clientX-sx)/Math.max(1,parent.clientWidth)*100));b.y=Math.max(-180,Math.min(180,oy+(ev.clientY-sy)));el.style.setProperty('--lb-x',b.x+'%');el.style.setProperty('--lb-y',b.y+'px');};
   const up=()=>{window.removeEventListener('pointermove',move);window.removeEventListener('pointerup',up);markDirty();};
   window.addEventListener('pointermove',move);window.addEventListener('pointerup',up);
  };
  el.addEventListener('pointerdown',beginMove);
  if(resize)resize.addEventListener('pointerdown',e=>{
   e.preventDefault();e.stopPropagation();
   const sx=e.clientX,sw=b.width,parent=el.parentElement||el,aw=Math.max(1,parent.clientWidth),aspect=Math.max(.35,b.aspect||1.6);
   const move=ev=>{b.width=Math.max(20,Math.min(100,sw+(ev.clientX-sx)/aw*100));b.aspect=aspect;el.style.setProperty('--lb-w',b.width+'%');el.style.setProperty('--lb-aspect',b.aspect);};
   const up=()=>{window.removeEventListener('pointermove',move);window.removeEventListener('pointerup',up);markDirty();};
   window.addEventListener('pointermove',move);window.addEventListener('pointerup',up);
  });
 });
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
     if(el.dataset.tileField){const tileId=el.dataset.tileId||el.dataset.pageTileId;const pageTile=el.dataset.pageTileId&&currentPage().tiles?.find(t=>t.id===el.dataset.pageTileId);const tile=homepageTiles.find(t=>t.id===tileId);if(pageTile)pageTile[el.dataset.tileField]=el.innerText.trim();else if(tile)tile[el.dataset.tileField]=el.innerText.trim();}
     if(field==='buyHeading')homeBuyHeading=el.innerText.trim();
     if(field==='buyIntro')homeBuyIntro=el.innerText.trim();
     if(field==='sellHeading')homeSellHeading=el.innerText.trim();
     if(field==='sellIntro')homeSellIntro=el.innerText.trim(); if(field==='templateKicker')templateCopy.kicker=el.innerText.trim(); if(el.dataset.templateField)templateCopy[el.dataset.templateField]=el.innerText.trim();
     markDirty();
   });
   el.addEventListener('focus',()=>el.classList.add('editing'));
   el.addEventListener('blur',()=>el.classList.remove('editing'));
 });
 root.querySelectorAll('[data-nav-page]').forEach(el=>el.addEventListener('click',e=>{e.preventDefault();selectPage(el.dataset.navPage)}));
 root.querySelectorAll('[data-image-action]').forEach(el=>{el.draggable=false;el.addEventListener('pointerdown',e=>e.stopPropagation());el.addEventListener('click',e=>{e.stopPropagation();
   const action=el.dataset.imageAction,target=el.dataset.imageTarget;
   if(target&&target.startsWith('hero-element:'))return;
   if(action==='remove'){removeImage(target);return}
   const input=$('image-file-input');input.dataset.target=target;input.value='';input.click();
 });});
 let draggedBlock=null;
 root.querySelectorAll('[data-home-block]').forEach(el=>{
   el.addEventListener('dragstart',()=>{draggedBlock=el.dataset.homeBlock;el.classList.add('dragging')});
   el.addEventListener('dragend',()=>el.classList.remove('dragging'));
   el.addEventListener('dragover',e=>{e.preventDefault();el.classList.add('drag-over')});
   el.addEventListener('dragleave',()=>el.classList.remove('drag-over'));
   el.addEventListener('drop',e=>{e.preventDefault();el.classList.remove('drag-over');const target=el.dataset.homeBlock;if(!draggedBlock||draggedBlock===target)return;homepageOrder=homepageOrder.filter(k=>k!==draggedBlock);const at=homepageOrder.indexOf(target);homepageOrder.splice(at<0?homepageOrder.length:at,0,draggedBlock);markDirty();renderEditor()});
 });
 let draggedTile=null;
 root.querySelectorAll('[data-tile-id]').forEach(el=>{
   if(el.matches('.editable-home-tile'))el.addEventListener('dragstart',()=>{draggedTile=el.dataset.tileId;el.classList.add('dragging')});
   if(el.matches('.editable-home-tile'))el.addEventListener('dragend',()=>el.classList.remove('dragging'));
   if(el.matches('.editable-home-tile'))el.addEventListener('dragover',e=>{e.preventDefault();el.classList.add('drag-over')});
   if(el.matches('.editable-home-tile'))el.addEventListener('drop',e=>{e.preventDefault();el.classList.remove('drag-over');if(!draggedTile||draggedTile===el.dataset.tileId)return;const from=homepageTiles.findIndex(t=>t.id===draggedTile),to=homepageTiles.findIndex(t=>t.id===el.dataset.tileId);if(from<0||to<0)return;const [item]=homepageTiles.splice(from,1);homepageTiles.splice(to,0,item);markDirty();renderEditor()});
 });
}

function selectPage(slug){
 if(!validPageSlug(slug))return;
 selectedPage=slug;
 const next=new URL(location.href);
 next.searchParams.set('page',slug);
 history.replaceState(null,'',next.toString());
 renderPageList();renderHomepageControls();renderEditor();window.scrollTo({top:0,behavior:'smooth'});
}

function applyTemplate(template){
 if(template==='editable'){currentTemplate='editable';renderTemplates();renderHomepageControls();renderHeroImageControls();renderEditor();markDirty();setStatus('Fully editable template selected.','success');return;}
 if(!templateHeadlines[template])return;
 const previousDefaults=Object.values(templateDefaults).some(d=>d.kicker===templateCopy.kicker&&d.cta1===templateCopy.cta1&&d.cta2===templateCopy.cta2);
 currentTemplate=template;
 themeColors=Object.assign({},themeColors,templatePalettes[template]||templatePalettes.editorial);
 if(!headline||Object.values(templateHeadlines).includes(headline))headline=templateHeadlines[template];
 if(!templateCopy.kicker||previousDefaults)templateCopy=Object.assign({},templateDefaults[template]||templateDefaults.editorial);
 renderTemplates();renderHomepageControls();renderHeroImageControls();renderEditor();markDirty();
 setStatus(template+' template selected. Text, colours and images remain editable.','success');
}
function buildContent(){
 return {schema_version:2,template_reset_version:2,site:{
   name:siteName.trim()||null,
   pages:pages,
   theme:{accent:themeColors.accent||accent||'#c46a2b',button_bg:themeColors.button_bg||themeColors.accent||accent||'#c46a2b',button_text:themeColors.button_text||'#ffffff',page_bg:themeColors.page_bg||'#ffffff',text:themeColors.text,header_bg:themeColors.header_bg,buy_bg:themeColors.buy_bg,sell_bg:themeColors.sell_bg,footer_bg:themeColors.footer_bg,background_style:['none','stripes','dots','gradient'].includes(themeColors.background_style)?themeColors.background_style:'none',background_category:['none','instruments','phones','drones','cameras','detectors'].includes(themeColors.background_category)?themeColors.background_category:'none',background_color:themeColors.background_color||themeColors.page_bg||'#f5f6f8',background_color2:themeColors.background_color2||'#ffffff',typography:typography},
   social:socialLinks,
   header:{tagline:headerTagline,links:headerLinks},footer:{text:footerText,links:footerLinks},
   reviews:reviewLinks,
   branding:{logo_url:logoUrl||'',banner_url:bannerUrl||''},
   global_header_elements:globalHeaderElements,
   homepage:{hero_canvas_height:heroCanvasHeight,banner_position:bannerPosition,block_order:homepageOrder,headline:headline.trim()||null,intro:intro.trim()||null,layout_blocks:layoutBlocks,image_url:homeImageUrl||'',image_alt:siteName||'Homepage image',image_url2:homeImageUrl2||'',image_alt2:siteName+' secondary image',buy_image_url:homeBuyImageUrl||'',buy_image_alt:homeBuyHeading||'What We Buy',sell_image_url:homeSellImageUrl||'',sell_image_alt:homeSellHeading||'What We Sell',use_banner:!!useBanner,sections:homepageSections,tile_count:homepageTileCount,tile_columns:homepageTileColumns,buy_heading:homeBuyHeading,buy_intro:homeBuyIntro,sell_heading:homeSellHeading,sell_intro:homeSellIntro,tiles:homepageTiles,editable_elements:editableHeroElements},
   navigation:[{label:'Home',path:'?page=home'}].concat(pages.filter(p=>p.enabled).map(p=>({label:p.title,path:'?page='+p.slug}))),
   category_manifest:Array.isArray(window.__existingCategoryManifest)?window.__existingCategoryManifest:[],
   template:currentTemplate,template_copy:templateCopy,
   contact:{text:(pages.find(p=>p.slug==='contact')?.body||'').trim()||null}
 }};
}

function cleanTemplateCopy(copy){
 const known=['YOUR BUSINESS','ESTABLISHED SERVICE','BUY / SELL / TRADE','BUYING / SELLING','BUSINESS INFORMATION','PRIVATE SERVICE','BUY / SELL','BUY · SELL · TRADE'];
 const cta=['What do you have to sell?','What we buy','What we sell','Sell to us','Browse the shop','Explore the shop','Sell your items','Browse products','Retail shop','Shop products','Start selling','01 / WHAT WE BUY','02 / WHAT WE SELL','View product','View shop','View & buy'];
 const out=Object.assign({},copy||{});
 if(known.includes(String(out.kicker||'')) || /^\s*\d+\s*\/\s*/.test(String(out.kicker||'')))out.kicker='';
 if(cta.includes(String(out.cta1||'')) || /^\s*\d+\s*\/\s*/.test(String(out.cta1||'')))out.cta1='';
 if(String(out.cta2||'').trim().toLowerCase()==='what we sell')out.cta2='Visit our retail shop'; else if(cta.includes(String(out.cta2||'')) || /^\s*\d+\s*\/\s*/.test(String(out.cta2||'')))out.cta2='';
 return out;
}
function ensureHomepageTileCapacity(tiles){
 const existing=Array.isArray(tiles)?tiles:[];
 const byId=new Map(existing.map(t=>[t.id,t]));
 return defaultHomepageTiles().map(d=>byId.has(d.id)?Object.assign({},d,byId.get(d.id)):Object.assign({},d));
}
function cleanHomepageTiles(tiles){
 const defaults=new Map(defaultHomepageTiles().map(t=>[t.id,t]));
 return (Array.isArray(tiles)?tiles:[]).map(t=>{const d=defaults.get(t.id);if(!d)return t;const copy={...t};['title','body','cta'].forEach(k=>{if(copy[k]===d[k])copy[k]='';});return copy;});
}

function loadContent(content){
 const s=content?.site||{}; templateCopy=cleanTemplateCopy(Object.assign({},templateDefaults[s.template]||templateDefaults.editorial,s.template_copy||{}));
 window.__existingCategoryManifest=Array.isArray(s.category_manifest)?s.category_manifest:[];
 siteName=s.name||'';headerTagline=s.header?.tagline||'';footerText=s.footer?.text||'';
 headline=s.homepage?.headline||'';
 intro=s.homepage?.intro||'';
 accent=s.theme?.accent||'#c46a2b';
 typography=Object.assign({font:'Inter',hero:'large',section:'large',body:'standard',nav:'standard',button:'solid',header:'standard',footer:'simple'},s.theme?.typography||{});homepageOrder=Array.isArray(s.homepage?.block_order)&&s.homepage.block_order.length?s.homepage.block_order:['hero','buy','sell','trust'];homepageSections=Object.assign({hero:true,hero_image:true,dual:true,buy:true,sell:true,trust:true,shop:true},s.homepage?.sections||{});
 themeColors={accent:accent,button_bg:s.theme?.button_bg||s.theme?.accent||accent||'#c46a2b',button_text:s.theme?.button_text||'#ffffff',page_bg:s.theme?.page_bg||'#ffffff',text:s.theme?.text||'#17202a',header_bg:s.theme?.header_bg||'#ffffff',buy_bg:s.theme?.buy_bg||'#ffffff',sell_bg:s.theme?.sell_bg||'#f4f6f7',footer_bg:s.theme?.footer_bg||'#17202a',background_style:['none','stripes','dots','gradient'].includes(s.theme?.background_style)?s.theme.background_style:(s.theme?.background_mode==='custom'?'none':'gradient'),background_category:['none','instruments','phones','drones','cameras','detectors'].includes(s.theme?.background_category)?s.theme.background_category:'none',background_color:s.theme?.background_color||s.theme?.page_bg||'#f5f6f8',background_color2:s.theme?.background_color2||'#ffffff'};
 socialLinks=Object.assign({facebook:'',instagram:'',linkedin:'',youtube:'',tiktok:'',x:'',show_share:true},s.social||{});
 reviewLinks=Array.isArray(s.reviews)?s.reviews.map(r=>({label:r.label||'',url:r.url||''})).slice(0,4):[];
 const branding=s.branding&&typeof s.branding==='object'?s.branding:{};
 logoUrl=Object.prototype.hasOwnProperty.call(branding,'logo_url')?String(branding.logo_url||''):(authoritativeBranding.logo_url||s.logo_url||'');
 bannerUrl=Object.prototype.hasOwnProperty.call(branding,'banner_url')?String(branding.banner_url||''):(authoritativeBranding.banner_url||'');
 const hasGlobalHeader=Object.prototype.hasOwnProperty.call(s,'global_header_elements');
 if(hasGlobalHeader){
   globalHeaderElements=Array.isArray(s.global_header_elements)?s.global_header_elements.map(normalizeGlobalHeaderElement):[];
 }else if(bannerUrl){
   globalHeaderElements=[normalizeGlobalHeaderElement({id:'gh-banner',type:'image',role:'banner',x:25,y:10,width:50,height:80,aspect:4,image_url:bannerUrl,text:''})];
 }else globalHeaderElements=[];
 selectedGlobalHeaderId=null;useBanner=s.homepage?.use_banner!==false;bannerPosition=['left','center','right'].includes(s.homepage?.banner_position)?s.homepage.banner_position:'center';headerLinks=Array.isArray(s.header?.links)?s.header.links:['home','buying','shop','about','contact'];footerLinks=Array.isArray(s.footer?.links)?s.footer.links:['home','buying','shop','about','contact'];
 homeImageUrl=s.homepage?.image_url||'';homeImageUrl2=s.homepage?.image_url2||'';homeBuyImageUrl=s.homepage?.buy_image_url||'';homeSellImageUrl=s.homepage?.sell_image_url||'';
 loadLayoutBlocks(s.homepage||{});loadEditableHeroElements(s.homepage||{});heroCanvasHeight=Math.max(620,Math.min(1800,Number(s.homepage?.hero_canvas_height)||760));
 homeBuyHeading=s.homepage?.buy_heading||'What we buy';homeBuyIntro=s.homepage?.buy_intro||'Tell customers the types of products, equipment or services you are looking to buy.';homeSellHeading=s.homepage?.sell_heading||'What we sell';homeSellIntro=s.homepage?.sell_intro||'Showcase the products and collections customers can browse and buy.';homepageTileCount=[3,4,6,8,9,10,12].includes(Number(s.homepage?.tile_count))?Number(s.homepage.tile_count):8;homepageTileColumns=[2,3,4].includes(Number(s.homepage?.tile_columns))?Number(s.homepage.tile_columns):4;homepageTiles=ensureHomepageTileCapacity(Array.isArray(s.homepage?.tiles)&&s.homepage.tiles.length?cleanHomepageTiles(s.homepage.tiles):defaultHomepageTiles());
 currentTemplate='editable';
 pages=Array.isArray(s.pages)&&s.pages.length?s.pages.map(p=>Object.assign({},p,{
   enabled:p.enabled!==false,
   title:p.slug==='shop'&&(!p.title||p.title==='Shop')?'Retail Shop':(p.title||p.slug),
   body:cleanPageBody(p.slug,p.body),image_url:p.image_url||'',image_alt:p.image_alt||'',image_url2:p.image_url2||'',image_alt2:p.image_alt2||'',tile_count:p.slug==='shop'||p.slug==='buying'?([3,4,6,8,9,10,12].includes(Number(p.tile_count))?Number(p.tile_count):6):0,tile_columns:p.slug==='shop'||p.slug==='buying'?([2,3,4].includes(Number(p.tile_columns))?Number(p.tile_columns):3):3,tiles:p.slug==='shop'||p.slug==='buying'?ensurePageTileCapacity(cleanPageTiles(p.tiles,p.slug==='shop'?'shop-tile':'buying-tile'),p.slug==='shop'?'shop-tile':'buying-tile'):[],seo_title:p.seo_title||'',seo_description:p.seo_description||''
 })):defaultPages();
 selectedPage=validPageSlug(requestedPage)?requestedPage:'home';dirty=false;
 renderPageList();renderPageManager();renderHeaderFooterControls();renderTemplates();renderHomepageControls();renderHeroImageControls();renderDesignControls();renderBrandingControls();renderBusinessExtras();renderEditor();
}

async function getImageDimensions(file){
 return await new Promise(function(resolve){
  if(!file||!/^image\//.test(file.type)){resolve(null);return;}
  const img=new Image();
  const url=URL.createObjectURL(file);
  img.onload=function(){const d={width:img.naturalWidth||img.width,height:img.naturalHeight||img.height};URL.revokeObjectURL(url);resolve(d);};
  img.onerror=function(){URL.revokeObjectURL(url);resolve(null);};
  img.src=url;
 });
}
async function uploadImage(file,target){
 if(!file)return;
 if(file.size>5242880)throw new Error('Image is larger than 5 MB.');
 if(!['image/png','image/jpeg','image/webp'].includes(file.type))throw new Error('Use PNG, JPEG or WebP images only.');
 if(!tenantId||!session?.access_token)throw new Error('Subscriber session is not ready.');
 const imageDimensions=await getImageDimensions(file);
 // Use a data URL for the immediate preview so the image cannot disappear because an object URL was revoked or the editor rerendered.
 const previewUrl=await new Promise(function(resolve,reject){
   const reader=new FileReader();
   reader.onload=function(){resolve(String(reader.result||''));};
   reader.onerror=reject;
   reader.readAsDataURL(file);
 });
 setStatus('Image selected. Uploading…');
 // Show the selected image immediately in the canvas while the upload completes.
 if(target.startsWith('global-header:')){
  const id=target.slice(14),el=globalHeaderElements.find(function(x){return x.id===id;});
  if(el){selectedGlobalHeaderId=id;el.preview_url=previewUrl;if(imageDimensions?.width&&imageDimensions?.height){el.aspect=imageDimensions.width/imageDimensions.height;el.width=el.role==='banner'?Math.min(72,Math.max(35,el.width||55)):el.width;el.height=Math.min(80,Math.max(10,el.width*4/Math.max(.35,el.aspect)));}renderEditor();}
 }
 if(target.startsWith('hero-element:')){
  const previewId=target.slice(12);
  const previewEl=editableHeroElements.find(function(x){return x.id===previewId;});
  if(previewEl){
   selectedEditableHeroId=previewId;
   previewEl.preview_url=previewUrl;
   if(imageDimensions?.width&&imageDimensions?.height){
    previewEl.aspect=imageDimensions.width/imageDimensions.height;
   }
   renderEditor();
  }
 }
 setStatus('Uploading image to website storage…');
 const slug=target==='home'?'home':target==='logo'?'logo':target==='banner'?'banner':target.startsWith('global-header:')?'global-header':target.startsWith('hero-element:')?'hero-elements':target;
 const safe=(file.name||'image').toLowerCase().replace(/[^a-z0-9._-]+/g,'-');
 const path=tenantId+'/'+slug+'/'+Date.now()+'-'+safe;
 const response=await fetch(SUPABASE_URL+'/storage/v1/object/tradeflow-site-media/'+path.split('/').map(encodeURIComponent).join('/'),{
   method:'POST',headers:{apikey:supabaseKey,Authorization:'Bearer '+session.access_token,'Content-Type':file.type,'x-upsert':'false'},body:file
 });
 const responseText=await response.text();
 if(!response.ok){
   setStatus('Image preview is visible, but the upload failed. '+(responseText||''),'error');
   throw new Error(responseText||'Image upload failed.');
 }
 const url=SUPABASE_URL+'/storage/v1/object/public/tradeflow-site-media/'+path.split('/').map(encodeURIComponent).join('/');
 if(target.startsWith('hero-element:')){const id=target.slice(12);selectedEditableHeroId=id;}
 if(target.startsWith('global-header:')){const id=target.slice(14),el=globalHeaderElements.find(function(x){return x.id===id;});if(el){el.image_url=url;el.preview_url='';selectedGlobalHeaderId=id;if(imageDimensions?.width&&imageDimensions?.height){el.aspect=imageDimensions.width/imageDimensions.height;el.width=el.role==='banner'?Math.min(72,Math.max(35,(imageDimensions.width/imageDimensions.height)*18)):el.width;el.height=Math.min(80,Math.max(10,el.width*4/Math.max(.35,el.aspect)));}if(el.role==='banner')bannerUrl=url;}}
 else if(target==='home')homeImageUrl=url;
 else if(target.startsWith('layout:')){const id=target.slice(7);if(layoutBlocks[id])layoutBlocks[id].image_url=url;}
 else if(target==='home2')homeImageUrl2=url;
 else if(target==='home-buy')homeBuyImageUrl=url;
 else if(target==='home-sell')homeSellImageUrl=url;
 else if(target==='logo')logoUrl=url;
 else if(target==='banner'){bannerUrl=url;layoutBlocks.heroBanner.image_url=url;} else if(target.startsWith('hero-element:')){const id=target.slice(12),el=editableHeroElements.find(function(x){return x.id===id;});if(el){el.image_url=url;el.preview_url='';selectedEditableHeroId=id;if(imageDimensions?.width&&imageDimensions?.height){el.aspect=imageDimensions.width/imageDimensions.height;if(el.role==='banner'){const canvas=document.querySelector('[data-editable-hero-canvas]');const rect=canvas?.getBoundingClientRect();const canvasWidth=rect?.width||1000;const canvasHeight=rect?.height||760;const targetWidthPct=Math.min(70,Math.max(25,(imageDimensions.width/imageDimensions.height)*canvasHeight/canvasWidth*30));el.width=targetWidthPct;el.height=Math.min(45,(targetWidthPct/100*canvasWidth/(imageDimensions.width/imageDimensions.height))/canvasHeight*100);}}if(el.role==='logo')logoUrl=url;if(el.role==='banner')bannerUrl=url;}}
 else if(target.endsWith(':image2')){const p=pages.find(x=>x.slug===target.split(':')[0]);if(p){p.image_url2=url;p.image_alt2=p.title+' second image';}}
 else if(target.startsWith('tile:')){const tile=homepageTiles.find(x=>x.id===target.slice(5));if(tile){tile.image_url=url;tile.image_alt=tile.title;}}
 else if(target.startsWith('page:')&&target.includes(':tile:')){const parts=target.split(':');const p=pages.find(x=>x.slug===parts[1]);const tile=p?.tiles?.find(x=>x.id===parts[3]);if(tile){tile.image_url=url;tile.image_alt=tile.title;}}
 else if(target.includes(':image2')){const p=pages.find(x=>x.slug===target.split(':')[0]);if(p){p.image_url2='';p.image_alt2='';}}
 else {const p=pages.find(x=>x.slug===target);if(p){p.image_url=url;p.image_alt=p.title;}}
 try{
   await api('/rest/v1/media_assets',{method:'POST',headers:{Prefer:'return=minimal'},body:JSON.stringify({
     tenant_id:tenantId,storage_bucket:'tradeflow-site-media',storage_path:path,original_filename:file.name,
     mime_type:file.type,byte_size:file.size,status:'active',created_by:session.user?.id||null,
     asset_kind:target==='logo'?'site_logo':target==='banner'?'site_banner':'site_image',retention_policy:'permanent'
   })});
 }catch(e){console.warn('Site image metadata insert failed',e)}
 dirty=true;renderHeroImageControls();renderBrandingControls();renderEditor();renderPageList();setStatus('Image added. Save the draft to keep the website change.','success');
}

function removeImage(target){
 if(target.startsWith('global-header:')){const id=target.slice(14),el=globalHeaderElements.find(function(x){return x.id===id;});if(el){el.image_url='';el.preview_url='';} }
 else if(target==='home')homeImageUrl='';
 else if(target==='home2')homeImageUrl2='';
 else if(target.startsWith('layout:')){const id=target.slice(7);if(layoutBlocks[id])layoutBlocks[id].image_url='';}
 else if(target==='home-buy')homeBuyImageUrl='';
 else if(target==='home-sell')homeSellImageUrl='';
 else if(target==='logo')logoUrl='';
 else if(target==='banner'){bannerUrl='';layoutBlocks.heroBanner.image_url='';} else if(target.startsWith('hero-element:')){const id=target.slice(12),el=editableHeroElements.find(function(x){return x.id===id;});if(el){el.image_url='';el.preview_url='';}}
 else if(target.startsWith('tile:')){const tile=homepageTiles.find(x=>x.id===target.slice(5));if(tile){tile.image_url='';tile.image_alt='';}}
 else if(target.startsWith('page:')&&target.includes(':tile:')){const parts=target.split(':');const p=pages.find(x=>x.slug===parts[1]);const tile=p?.tiles?.find(x=>x.id===parts[3]);if(tile){tile.image_url='';tile.image_alt='';}}
 else {const p=pages.find(x=>x.slug===target);if(p){p.image_url='';p.image_alt='';}}
 markDirty();renderHeroImageControls();renderBrandingControls();renderEditor();setStatus('Image removed from this draft. Save the draft to keep the change.','success');
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
 try{const profile=await api('/rest/v1/tenant_public_profiles?select=business_name,logo_url,banner_url&tenant_id=eq.'+encodeURIComponent(tenantId));const p=profile?.[0]||{};authoritativeBranding={logo_url:p.logo_url||'',banner_url:p.banner_url||''};if(p.business_name){siteName=p.business_name;window.__tradeflowBusinessNameLoaded=true;}}catch{authoritativeBranding={logo_url:'',banner_url:''};}
 return tenantId;
}

async function loadBuyingCatalogue(tenant){
 if(!tenant)return {categories:[],products:[]};
 const rows=await api('/rest/v1/rpc/get_public_buying_catalogue?p_tenant_id='+encodeURIComponent(tenant));
 const products=Array.isArray(rows)?rows:[];
 const map=new Map();
 for(const p of products){if(!map.has(p.category_id))map.set(p.category_id,{id:p.category_id,name:p.category_name,slug:p.category_slug,description:p.category_description||'',product_count:0});map.get(p.category_id).product_count++;}
 return {categories:Array.from(map.values()),products};
}
async function loadRetailListings(tenant){
 if(!tenant)return [];
 try{const rows=await api('/rest/v1/rpc/get_published_store_listings?p_tenant_id='+encodeURIComponent(tenant));return Array.isArray(rows)?rows:[]}
 catch(e){console.warn('TradeFlow retail preview listings unavailable:',e);return []}
}
async function clearFreshStartMedia(){
 try{
   const assets=await api('/rest/v1/media_assets?select=storage_path&tenant_id=eq.'+encodeURIComponent(tenantId));
   const paths=Array.isArray(assets)?assets.map(a=>a.storage_path).filter(Boolean):[];
   if(paths.length)await fetch(SUPABASE_URL+'/storage/v1/object/remove',{method:'POST',headers:{apikey:supabaseKey,Authorization:'Bearer '+session.access_token,'Content-Type':'application/json'},body:JSON.stringify({prefixes:paths})});
   await api('/rest/v1/media_assets?tenant_id=eq.'+encodeURIComponent(tenantId),{method:'DELETE',headers:{Prefer:'return=minimal'}});
 }catch(e){console.warn('Fresh website media cleanup skipped:',e)}
}
function resetToFreshWebsite(){
 siteName='';headerTagline='';footerText='';headline='';intro='';accent='#c46a2b';homeImageUrl='';homeImageUrl2='';homeBuyImageUrl='';homeSellImageUrl='';
 templateCopy=Object.assign({},templateDefaults.editorial);
 homepageTileCount=8;homepageTileColumns=4;homeBuyHeading='What we buy';homeBuyIntro='Tell customers what you are looking to buy.';
 homeSellHeading='What we sell';homeSellIntro='Show customers what is available to buy.';
 homepageTiles=defaultHomepageTiles();editableHeroElements=[];themeColors={accent:'#c46a2b',page_bg:'#f5f6f8',text:'#17202a',header_bg:'#ffffff',buy_bg:'#ffffff',sell_bg:'#f4f6f7',footer_bg:'#17202a',background_style:'none',background_color:'#f5f6f8',background_color2:'#ffffff'};
 socialLinks={facebook:'',instagram:'',linkedin:'',youtube:'',tiktok:'',x:'',show_share:true};reviewLinks=[];typography={font:'Inter',hero:'large',section:'large',body:'standard',nav:'standard',button:'solid',header:'standard',footer:'simple'};
 homepageSections={hero:true,hero_image:true,dual:true,buy:true,sell:true,trust:true,shop:true};headerLinks=['home','buying','shop','about','contact'];footerLinks=['home','buying','shop','about','contact'];homepageOrder=['hero','buy','sell','trust'];
 pages=defaultPages();selectedPage='home';currentTemplate='editable';editableHeroElements=defaultEditableHeroElements();window.__existingCategoryManifest=[];
}
async function loadDraft(){
 const rows=await api('/rest/v1/tenant_site_state?select=tenant_id,draft_revision_id,published_revision_id&tenant_id=eq.'+encodeURIComponent(tenantId));
 if(!Array.isArray(rows)||rows.length!==1)throw new Error('Subscriber website state is not initialised.');
 draftRevisionId=rows[0].draft_revision_id;
 const drafts=await api('/rest/v1/site_revisions?select=id,revision_number,status,content&tenant_id=eq.'+encodeURIComponent(tenantId)+'&id=eq.'+encodeURIComponent(draftRevisionId)+'&status=eq.draft');
 if(!Array.isArray(drafts)||drafts.length!==1)throw new Error('The current website draft revision could not be loaded.');
 if(Number(drafts[0].content?.template_reset_version||0)<2){await clearFreshStartMedia();resetToFreshWebsite();dirty=true;renderPageList();renderPageManager();renderHeaderFooterControls();renderTemplates();renderHomepageControls();renderHeroImageControls();renderDesignControls();renderBrandingControls();renderBusinessExtras();renderEditor();await api('/rest/v1/site_revisions?id=eq.'+encodeURIComponent(draftRevisionId)+'&tenant_id=eq.'+encodeURIComponent(tenantId),{method:'PATCH',headers:{Prefer:'return=minimal'},body:JSON.stringify({content:buildContent()})});dirty=false;const freshState=$('save-state');if(freshState)freshState.textContent='Fresh website saved';setStatus('Fresh website templates loaded. Previous website text, branding and images have been cleared.','success');}else{loadContent(drafts[0].content);}
 try{await loadBuyingCatalogue();}catch(e){console.warn('TradeFlow buying catalogue did not load in the builder:',e);buyingCatalogue={categories:[],products:[]};}
 retailListings=await loadRetailListings(tenantId);
 renderEditor();
 if(validPageSlug(requestedPage))selectedPage=requestedPage;
 if(requestedTemplate)applyTemplate(requestedTemplate);
 setStatus('Website loaded. Click the page and edit directly on the preview.','success'); if(requestedFocus==='branding'){const box=$('branding-controls');if(box){box.scrollIntoView({behavior:'smooth',block:'center'});}}
}

function resetDesignToDefaults(){
 if(!window.confirm('Reset the website design to its factory defaults? Your page text, pages and uploaded images will be kept.'))return;
 const palette=templatePalettes.editorial||{accent:'#b85c38',page_bg:'#f7f4f0',text:'#20252a',header_bg:'#fffdfb',buy_bg:'#fffdfb',sell_bg:'#f0ebe6',footer_bg:'#20252a'};
 currentTemplate='editable';
 themeColors=Object.assign({},palette,{background_style:'none',background_color:'#f5f6f8',background_color2:'#ffffff'});
 typography={font:'Inter',hero:'large',section:'large',body:'standard',nav:'standard',button:'solid',header:'standard',footer:'simple'};
 templateCopy=Object.assign({},templateDefaults.editorial);
 homepageTileCount=8;
 homepageTileColumns=4;
 homepageSections={hero:true,hero_image:true,dual:true,buy:true,sell:true,trust:true,shop:true};
 homepageOrder=['hero','buy','sell','trust'];
 applyWebsiteBackground();
 renderTemplates();
 renderHomepageControls();
 renderHeroImageControls();
 renderDesignControls();
 renderBrandingControls();
 renderTypographyControls();
 renderSectionControls();
 renderHeaderFooterControls();
 renderEditor();
 markDirty();
 setStatus('Design reset to factory defaults. Your content, pages and images were kept. Save the draft to keep the reset.','success');
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
 renderHeroImageControls();
 renderBrandingControls();
 renderPageManager();
 renderHeaderFooterControls();
 renderTypographyControls();
 renderSectionControls();
 renderBusinessExtras();
 $('image-file-input').addEventListener('change',e=>{
   const file=e.target.files?.[0],target=e.target.dataset.target;
   if(file)uploadImage(file,target).catch(err=>setStatus(err.message||String(err),'error'));
 });
 $('save-draft').addEventListener('click',()=>saveDraft().catch(e=>setStatus(e.message||String(e),'error')));
 $('reset-design').addEventListener('click',resetDesignToDefaults);
 $('publish').addEventListener('click',()=>publish().catch(e=>setStatus(e.message||String(e),'error')));
 $('preview-customer').addEventListener('click',()=>location.href='customer-dashboard-preview.html'+(tenantId?'?tenant_id='+encodeURIComponent(tenantId):''));
 $('preview-site').addEventListener('click',e=>{
   e.currentTarget.href='public-site.html?preview=draft'+(tenantId?'&tenant_id='+encodeURIComponent(tenantId):'');
 });
 (async()=>{const saveState=$('save-state');try{if(saveState)saveState.textContent='Connecting to your website…';await Promise.race([restoreSession(),new Promise((_,reject)=>setTimeout(()=>reject(new Error('Subscriber session timed out. Please refresh and sign in again.')),15000))]);if(saveState)saveState.textContent='Loading website draft…';await Promise.race([loadDraft(),new Promise((_,reject)=>setTimeout(()=>reject(new Error('Website draft loading timed out. Please refresh the builder.')),20000))]);if(saveState)saveState.textContent='Website loaded';}catch(error){if(saveState)saveState.textContent='Website could not be loaded';setStatus(error.message||String(error),'error');console.error('TradeFlow Website Builder load error',error)}})();
}
if(document.readyState==='loading')document.addEventListener('DOMContentLoaded',initBuilder);else initBuilder();function bindEditableHero(root){
 const canvas=root.querySelector('[data-editable-hero-canvas]');if(!canvas)return;
 root.querySelectorAll('[data-eh-add]').forEach(btn=>btn.addEventListener('click',function(e){
  e.preventDefault();const kind=btn.dataset.ehAdd;const type=kind==='text'?'text':kind==='button'?'button':'image';let o={};
  if(kind==='logo')o={role:'logo',image_url:logoUrl,x:5,y:5,width:18,height:16,aspect:2.8};
  if(kind==='banner')o={role:'banner',image_url:bannerUrl,x:5,y:18,width:90,height:20,aspect:5};
  if(kind==='text')o={role:'text',text:'Edit this text',x:8,y:42,width:42,height:18,fontSize:32};
  if(kind==='image')o={role:'image',x:55,y:16,width:38,height:34,aspect:1.45,image_url:''};
  if(kind==='button')o={role:'button',button_text:'Learn more',text:'Learn more',x:8,y:62,width:24,height:10,aspect:4};
  const el=makeEditableHeroElement(type,o);editableHeroElements.push(el);selectedEditableHeroId=el.id;markDirty();renderEditor();
 }));
 root.querySelectorAll('[data-image-action][data-image-target^="hero-element:"]').forEach(btn=>btn.addEventListener('click',function(e){
  e.preventDefault();e.stopPropagation();
  const target=btn.dataset.imageTarget;
  selectedEditableHeroId=target.slice(12);
  const input=$('image-file-input');
  input.dataset.target=target;input.value='';input.click();
 }));
 root.querySelectorAll('[data-eh-delete]').forEach(btn=>btn.addEventListener('click',function(e){
  e.preventDefault();e.stopPropagation();const id=btn.dataset.ehDelete;editableHeroElements=editableHeroElements.filter(x=>x.id!==id);if(selectedEditableHeroId===id)selectedEditableHeroId=editableHeroElements[0]?.id||null;markDirty();renderEditor();
 }));
 root.querySelectorAll('[data-eh-edit]').forEach(node=>{
  node.setAttribute('contenteditable','true');
  node.setAttribute('spellcheck','true');
  node.addEventListener('pointerdown',function(e){
   if(e.button!==undefined&&e.button!==0)return;
   selectedEditableHeroId=node.dataset.ehEdit;
   const box=node.closest('.editable-hero-element');
   root.querySelectorAll('.editable-hero-element.selected').forEach(x=>x.classList.remove('selected'));
   box?.classList.add('selected');
   renderEditableHeroToolbarOnly(root);
  });
  node.addEventListener('click',function(e){e.stopPropagation();selectedEditableHeroId=node.dataset.ehEdit;root.querySelectorAll('.editable-hero-element.selected').forEach(x=>x.classList.remove('selected'));node.closest('.editable-hero-element')?.classList.add('selected');});
  node.addEventListener('input',function(){const el=editableHeroElements.find(x=>x.id===node.dataset.ehEdit);if(!el)return;el.text=node.innerText; if(el.role==='headline')headline=el.text.trim(); markDirty();});
  node.addEventListener('paste',function(e){
   const text=(e.clipboardData||window.clipboardData)?.getData('text/plain');
   if(text==null)return;
   e.preventDefault();
   const sel=window.getSelection();
   if(!sel||!sel.rangeCount)return;
   sel.deleteFromDocument();
   const range=sel.getRangeAt(0);
   range.insertNode(document.createTextNode(text));
   range.collapse(false);
   sel.removeAllRanges();
   sel.addRange(range);
   node.dispatchEvent(new InputEvent('input',{bubbles:true,inputType:'insertText',data:text}));
  });
 });
 root.querySelectorAll('[data-eh-id]').forEach(node=>{
  const id=node.dataset.ehId,el=editableHeroElements.find(x=>x.id===id);if(!el)return;
  node.addEventListener('click',function(e){
   if(e.target.closest('button,select,input,a,.editable-hero-resize,.editable-hero-move,[contenteditable="true"]'))return;
   selectedEditableHeroId=id;root.querySelectorAll('.editable-hero-element.selected').forEach(x=>x.classList.remove('selected'));node.classList.add('selected');renderEditableHeroToolbarOnly(root);
  });
  const mover=node.querySelector('.editable-hero-move');
  const beginMove=function(e){
   if(e.button!==undefined&&e.button!==0)return;
   if(e.target.closest('button,select,input,a,.editable-hero-resize,.editable-hero-image-tools'))return;
   e.preventDefault();e.stopPropagation();selectedEditableHeroId=id;
   root.querySelectorAll('.editable-hero-element.selected').forEach(x=>x.classList.remove('selected'));node.classList.add('selected');renderEditableHeroToolbarOnly(root);
   const sx=e.clientX,sy=e.clientY,ox=el.x,oy=el.y,rect=canvas.getBoundingClientRect();
   const isText=e.target.closest('[contenteditable="true"]');
   let dragging=!isText;
   let finished=false;
   function apply(ev){
    el.x=Math.max(6,Math.min(94-el.width,ox+(ev.clientX-sx)/Math.max(1,rect.width)*100));
    el.y=Math.max(2,Math.min(98-el.height,oy+(ev.clientY-sy)/Math.max(1,rect.height)*100));
    node.style.left=el.x+'%';node.style.top=el.y+'%';
   }
   function move(ev){
    if(!dragging){
     const dx=ev.clientX-sx,dy=ev.clientY-sy;
     if(Math.hypot(dx,dy)<5)return;
     dragging=true;
    }
    if(dragging){ev.preventDefault();apply(ev);}
   }
   function up(ev){
    window.removeEventListener('pointermove',move);window.removeEventListener('pointerup',up);
    if(!dragging&&isText){
     const textNode=node.querySelector('[contenteditable="true"]');
     if(textNode){try{textNode.focus({preventScroll:true});}catch{textNode.focus();}}
     return;
    }
    if(dragging){apply(ev);markDirty();}
   }
   window.addEventListener('pointermove',move);window.addEventListener('pointerup',up);
  };
  if(mover)mover.addEventListener('pointerdown',beginMove);
  node.addEventListener('pointerdown',function(e){
   if(e.button!==undefined&&e.button!==0)return;
   if(e.target.closest('button,select,input,a,.editable-hero-resize,.editable-hero-move,.editable-hero-image-tools'))return;
   beginMove(e);
  });
  const resize=node.querySelector('.editable-hero-resize');
  if(resize)resize.addEventListener('pointerdown',function(e){
   e.preventDefault();e.stopPropagation();selectedEditableHeroId=id;
   const sx=e.clientX,sy=e.clientY,sw=el.width,sh=el.height,rect=canvas.getBoundingClientRect();
   const preserveAspect=el.role==='banner'&&Number(el.aspect)>0;
   const startPixelW=Math.max(1,sw/100*rect.width),startPixelH=Math.max(1,sh/100*rect.height);
   function move(ev){
    if(preserveAspect){
     const dx=ev.clientX-sx,dy=ev.clientY-sy;
     const useWidth=Math.abs(dx)>=Math.abs(dy);
     let pixelW=useWidth?startPixelW+dx:startPixelH*Number(el.aspect);
     let pixelH=useWidth?pixelW/Number(el.aspect):startPixelH+dy;
     pixelW=Math.max(80,Math.min(rect.width*(100-Math.max(0,el.x))/100,pixelW));
     pixelH=Math.max(40,Math.min(rect.height*(100-Math.max(0,el.y))/100,pixelH));
     if(useWidth)pixelH=pixelW/Number(el.aspect); else pixelW=pixelH*Number(el.aspect);
     if(pixelW>rect.width*(100-el.x)/100){pixelW=rect.width*(100-el.x)/100;pixelH=pixelW/Number(el.aspect);}
     if(pixelH>rect.height*(100-el.y)/100){pixelH=rect.height*(100-el.y)/100;pixelW=pixelH*Number(el.aspect);}
     el.width=Math.max(8,Math.min(92,pixelW/rect.width*100));
     el.height=Math.max(8,Math.min(90,pixelH/rect.height*100));
    }else{
     el.width=Math.max(8,Math.min(92,sw+(ev.clientX-sx)/Math.max(1,rect.width)*100));
     el.height=Math.max(8,Math.min(90,sh+(ev.clientY-sy)/Math.max(1,rect.height)*100));
    }
    node.style.width=el.width+'%';node.style.height=el.height+'%';
   }
   function up(){window.removeEventListener('pointermove',move);window.removeEventListener('pointerup',up);markDirty();}
   window.addEventListener('pointermove',move);window.addEventListener('pointerup',up);
  });
 });
 const heightHandle=canvas.querySelector('[data-eh-height-handle]');
 if(heightHandle)heightHandle.addEventListener('pointerdown',function(e){
  e.preventDefault();e.stopPropagation();const sy=e.clientY,start=heroCanvasHeight;
  function move(ev){heroCanvasHeight=Math.max(620,Math.min(1800,start+(ev.clientY-sy)));canvas.style.height=heroCanvasHeight+'px';canvas.style.minHeight=heroCanvasHeight+'px';}
  function up(){window.removeEventListener('pointermove',move);window.removeEventListener('pointerup',up);markDirty();}
  window.addEventListener('pointermove',move);window.addEventListener('pointerup',up);
 });
}
function renderEditableHeroToolbarOnly(root){
 const el=editableHeroElements.find(x=>x.id===selectedEditableHeroId);const format=root.querySelector('.editable-hero-format');if(!format||!el)return;
 const fontOptions=[['inherit','Site default'],['Arial','Arial'],['Arial Black','Arial Black'],['Calibri','Calibri'],['Cambria','Cambria'],['Comic Sans MS','Comic Sans MS'],['Courier New','Courier New'],['Georgia','Georgia'],['Garamond','Garamond'],['Impact','Impact'],['Tahoma','Tahoma'],['Times New Roman','Times New Roman'],['Trebuchet MS','Trebuchet MS'],['Verdana','Verdana'],['Segoe UI','Segoe UI'],['Helvetica','Helvetica'],['Palatino Linotype','Palatino Linotype'],['Book Antiqua','Book Antiqua']];
 const opt=(v,c)=>v===c?' selected':'';
 let html='<span>Selected element: drag ↕ to move, corner to resize.</span>';
 if(el.type==='text')html='<label class="editable-hero-text-control">Text<textarea data-eh-text rows="1">'+esc(el.text)+'</textarea></label><label>Font<select data-eh-style="font">'+fontOptions.map(o=>'<option value="'+esc(o[0])+'"'+opt(o[0],el.font)+'>'+esc(o[1])+'</option>').join('')+'</select></label><label>Size<select data-eh-style="fontSize"><option value="auto"'+opt('auto',el.fontSize)+'>Auto</option>'+[12,14,16,18,20,24,28,32,36,42,48,56,64,72,84,96].map(n=>'<option value="'+n+'"'+opt(String(n),String(el.fontSize))+'>'+n+'px</option>').join('')+'</select></label><label>Text colour<input type="color" data-eh-style="color" value="'+el.color+'"></label><label>Horizontal<select data-eh-style="align"><option value="left"'+opt('left',el.align)+'>Left</option><option value="center"'+opt('center',el.align)+'>Centre</option><option value="right"'+opt('right',el.align)+'>Right</option></select></label><label>Vertical<select data-eh-style="vAlign"><option value="top"'+opt('top',el.vAlign)+'>Top</option><option value="center"'+opt('center',el.vAlign)+'>Centre</option><option value="bottom"'+opt('bottom',el.vAlign)+'>Bottom</option></select></label><label>Line spacing<select data-eh-style="lineHeight">'+[['1','Tight'],['1.2','Normal'],['1.4','Relaxed'],['1.6','Loose'],['2','Double']].map(o=>'<option value="'+o[0]+'"'+opt(o[0],String(el.lineHeight))+'>'+o[1]+'</option>').join('')+'</select></label><label>Letter spacing<select data-eh-style="letterSpacing">'+[['0','Normal'],['0.5','0.5px'],['1','1px'],['2','2px'],['4','4px'],['8','8px']].map(o=>'<option value="'+o[0]+'"'+opt(o[0],String(el.letterSpacing))+'>'+o[1]+'</option>').join('')+'</select></label>';
 if(el.type==='image')html='<span>Image</span><button type="button" data-image-action="'+(el.image_url?'replace':'add')+'" data-image-target="hero-element:'+esc(el.id)+'">'+(el.image_url?'Change image':'Add image')+'</button>'+(el.image_url?'<button type="button" data-image-action="remove" data-image-target="hero-element:'+esc(el.id)+'">Remove image</button>':'');
 if(el.type==='button')html='<label>Button text<input type="text" data-eh-field="button_text" value="'+esc(el.button_text)+'"></label><label>Link type<select data-eh-field="button_link_type"><option value="internal"'+opt('internal',el.button_link_type)+'>TradeFlow page</option><option value="custom"'+opt('custom',el.button_link_type)+'>Custom URL</option></select></label>'+(el.button_link_type==='custom'?'<label>URL<input type="url" data-eh-field="button_link" value="'+esc(el.button_link)+'"></label>':'<label>Page<select data-eh-field="button_link">'+editableHeroLinkOptions(el.button_link)+'</select></label>');
 format.innerHTML=html;
 format.querySelectorAll('[data-eh-text]').forEach(function(control){
  control.addEventListener('input',function(){
   const target=editableHeroElements.find(function(x){return x.id===selectedEditableHeroId;});
   if(!target)return;
   target.text=control.value;
   if(target.role==='headline')headline=target.text.trim();
   const textNode=root.querySelector('[data-eh-edit="'+CSS.escape(target.id)+'"]');
   if(textNode && textNode.innerText!==target.text)textNode.innerText=target.text;
   markDirty();
  });
 });
 format.querySelectorAll('[data-eh-style]').forEach(function(control){control.addEventListener('input',function(){const target=editableHeroElements.find(function(x){return x.id===selectedEditableHeroId;});if(!target)return;target[control.dataset.ehStyle]=control.value;const elNode=root.querySelector('[data-eh-id="'+CSS.escape(target.id)+'"]');if(elNode){const key=control.dataset.ehStyle;const cssKey={font:'--eh-font',fontSize:'--eh-size',color:'--eh-color',align:'--eh-align',vAlign:'--eh-valign',lineHeight:'--eh-line',letterSpacing:'--eh-letter'}[key];if(cssKey)elNode.style.setProperty(cssKey,key==='fontSize'?(control.value==='auto'?'inherit':Number(control.value)+'px'):key==='letterSpacing'?control.value+'px':control.value);};markDirty();});});
 format.querySelectorAll('[data-eh-field]').forEach(function(control){control.addEventListener('input',function(){const target=editableHeroElements.find(function(x){return x.id===selectedEditableHeroId;});if(!target)return;target[control.dataset.ehField]=control.value;markDirty();});});
 format.querySelectorAll('[data-image-action]').forEach(function(control){control.addEventListener('click',function(e){e.preventDefault();e.stopPropagation();const input=$('image-file-input');input.dataset.target=control.dataset.imageTarget;input.value='';input.click();});});
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
     if(el.dataset.tileField){const tileId=el.dataset.tileId||el.dataset.pageTileId;const pageTile=el.dataset.pageTileId&&currentPage().tiles?.find(t=>t.id===el.dataset.pageTileId);const tile=homepageTiles.find(t=>t.id===tileId);if(pageTile)pageTile[el.dataset.tileField]=el.innerText.trim();else if(tile)tile[el.dataset.tileField]=el.innerText.trim();}
     if(field==='buyHeading')homeBuyHeading=el.innerText.trim();
     if(field==='buyIntro')homeBuyIntro=el.innerText.trim();
     if(field==='sellHeading')homeSellHeading=el.innerText.trim();
     if(field==='sellIntro')homeSellIntro=el.innerText.trim(); if(field==='templateKicker')templateCopy.kicker=el.innerText.trim(); if(el.dataset.templateField)templateCopy[el.dataset.templateField]=el.innerText.trim();
     markDirty();
   });
   el.addEventListener('focus',()=>el.classList.add('editing'));
   el.addEventListener('blur',()=>el.classList.remove('editing'));
 });
 root.querySelectorAll('[data-nav-page]').forEach(el=>el.addEventListener('click',e=>{e.preventDefault();selectPage(el.dataset.navPage)}));
 root.querySelectorAll('[data-image-action]').forEach(el=>{el.draggable=false;el.addEventListener('pointerdown',e=>e.stopPropagation());el.addEventListener('click',e=>{e.stopPropagation();
   const action=el.dataset.imageAction,target=el.dataset.imageTarget;
   if(action==='remove'){removeImage(target);return}
   const input=$('image-file-input');input.dataset.target=target;input.value='';input.click();
 });});
 let draggedBlock=null;
 root.querySelectorAll('[data-home-block]').forEach(el=>{
   el.addEventListener('dragstart',()=>{draggedBlock=el.dataset.homeBlock;el.classList.add('dragging')});
   el.addEventListener('dragend',()=>el.classList.remove('dragging'));
   el.addEventListener('dragover',e=>{e.preventDefault();el.classList.add('drag-over')});
   el.addEventListener('dragleave',()=>el.classList.remove('drag-over'));
   el.addEventListener('drop',e=>{e.preventDefault();el.classList.remove('drag-over');const target=el.dataset.homeBlock;if(!draggedBlock||draggedBlock===target)return;homepageOrder=homepageOrder.filter(k=>k!==draggedBlock);const at=homepageOrder.indexOf(target);homepageOrder.splice(at<0?homepageOrder.length:at,0,draggedBlock);markDirty();renderEditor()});
 });
 let draggedTile=null;
 root.querySelectorAll('[data-tile-id]').forEach(el=>{
   if(el.matches('.editable-home-tile'))el.addEventListener('dragstart',()=>{draggedTile=el.dataset.tileId;el.classList.add('dragging')});
   if(el.matches('.editable-home-tile'))el.addEventListener('dragend',()=>el.classList.remove('dragging'));
   if(el.matches('.editable-home-tile'))el.addEventListener('dragover',e=>{e.preventDefault();el.classList.add('drag-over')});
   if(el.matches('.editable-home-tile'))el.addEventListener('drop',e=>{e.preventDefault();el.classList.remove('drag-over');if(!draggedTile||draggedTile===el.dataset.tileId)return;const from=homepageTiles.findIndex(t=>t.id===draggedTile),to=homepageTiles.findIndex(t=>t.id===el.dataset.tileId);if(from<0||to<0)return;const [item]=homepageTiles.splice(from,1);homepageTiles.splice(to,0,item);markDirty();renderEditor()});
 });
}

function selectPage(slug){
 if(!validPageSlug(slug))return;
 selectedPage=slug;
 const next=new URL(location.href);
 next.searchParams.set('page',slug);
 history.replaceState(null,'',next.toString());
 renderPageList();renderHomepageControls();renderEditor();window.scrollTo({top:0,behavior:'smooth'});
}

function applyTemplate(template){
 if(!templateHeadlines[template])return;
 const previousDefaults=Object.values(templateDefaults).some(d=>d.kicker===templateCopy.kicker&&d.cta1===templateCopy.cta1&&d.cta2===templateCopy.cta2);
 currentTemplate=template;
 themeColors=Object.assign({},templatePalettes[template]||templatePalettes.editorial,{background_id:themeColors.background_id||'clean-wave',background_mode:themeColors.background_mode||'preset'});
 if(!headline||Object.values(templateHeadlines).includes(headline))headline=templateHeadlines[template];
 if(!templateCopy.kicker||previousDefaults)templateCopy=Object.assign({},templateDefaults[template]||templateDefaults.editorial);
 renderTemplates();renderHomepageControls();renderHeroImageControls();renderEditor();markDirty();
 setStatus(template+' template selected. Text, colours and images remain editable.','success');
}
function buildContent(){
 return {schema_version:2,template_reset_version:2,site:{
   name:siteName.trim()||null,
   pages:pages,
   theme:{accent:themeColors.accent||accent||'#c46a2b',page_bg:themeColors.page_bg,text:themeColors.text,header_bg:themeColors.header_bg,buy_bg:themeColors.buy_bg,sell_bg:themeColors.sell_bg,footer_bg:themeColors.footer_bg,background_id:normalizeBackgroundId(themeColors.background_id),background_mode:themeColors.background_mode==='custom'?'custom':'preset',background_color:themeColors.background_mode==='custom'?(themeColors.page_bg||'#f5f6f8'):(websiteBackgrounds.find(x=>x.id===themeColors.background_id)?.color||'#f5faff'),background_image:themeColors.background_mode==='custom'?'':(websiteBackgrounds.find(x=>x.id===themeColors.background_id)?.image||''),background_size:themeColors.background_mode==='custom'?'cover':(websiteBackgrounds.find(x=>x.id===themeColors.background_id)?.size||'cover'),background_repeat:themeColors.background_mode==='custom'?'no-repeat':(websiteBackgrounds.find(x=>x.id===themeColors.background_id)?.repeat||'no-repeat'),typography:typography},
   social:socialLinks,
   header:{tagline:headerTagline,links:headerLinks},footer:{text:footerText,links:footerLinks},
   reviews:reviewLinks,
   branding:{logo_url:logoUrl||'',banner_url:bannerUrl||''},
   homepage:{banner_position:bannerPosition,block_order:homepageOrder,headline:headline.trim()||null,intro:intro.trim()||null,layout_blocks:layoutBlocks,image_url:homeImageUrl||'',image_alt:siteName||'Homepage image',image_url2:homeImageUrl2||'',image_alt2:siteName+' secondary image',buy_image_url:homeBuyImageUrl||'',buy_image_alt:homeBuyHeading||'What We Buy',sell_image_url:homeSellImageUrl||'',sell_image_alt:homeSellHeading||'What We Sell',use_banner:!!useBanner,sections:homepageSections,tile_count:homepageTileCount,tile_columns:homepageTileColumns,buy_heading:homeBuyHeading,buy_intro:homeBuyIntro,sell_heading:homeSellHeading,sell_intro:homeSellIntro,tiles:homepageTiles,editable_elements:editableHeroElements},
   navigation:[{label:'Home',path:'?page=home'}].concat(pages.filter(p=>p.enabled).map(p=>({label:p.title,path:'?page='+p.slug}))),
   category_manifest:Array.isArray(window.__existingCategoryManifest)?window.__existingCategoryManifest:[],
   template:currentTemplate,template_copy:templateCopy,
   contact:{text:(pages.find(p=>p.slug==='contact')?.body||'').trim()||null}
 }};
}

function cleanTemplateCopy(copy){
 const known=['YOUR BUSINESS','ESTABLISHED SERVICE','BUY / SELL / TRADE','BUYING / SELLING','BUSINESS INFORMATION','PRIVATE SERVICE','BUY / SELL','BUY · SELL · TRADE'];
 const cta=['What do you have to sell?','What we buy','What we sell','Sell to us','Browse the shop','Explore the shop','Sell your items','Browse products','Retail shop','Shop products','Start selling','01 / WHAT WE BUY','02 / WHAT WE SELL','View product','View shop','View & buy'];
 const out=Object.assign({},copy||{});
 if(known.includes(String(out.kicker||'')) || /^\s*\d+\s*\/\s*/.test(String(out.kicker||'')))out.kicker='';
 if(cta.includes(String(out.cta1||'')) || /^\s*\d+\s*\/\s*/.test(String(out.cta1||'')))out.cta1='';
 if(String(out.cta2||'').trim().toLowerCase()==='what we sell')out.cta2='Visit our retail shop'; else if(cta.includes(String(out.cta2||'')) || /^\s*\d+\s*\/\s*/.test(String(out.cta2||'')))out.cta2='';
 return out;
}
function ensureHomepageTileCapacity(tiles){
 const existing=Array.isArray(tiles)?tiles:[];
 const byId=new Map(existing.map(t=>[t.id,t]));
 return defaultHomepageTiles().map(d=>byId.has(d.id)?Object.assign({},d,byId.get(d.id)):Object.assign({},d));
}
function cleanHomepageTiles(tiles){
 const defaults=new Map(defaultHomepageTiles().map(t=>[t.id,t]));
 return (Array.isArray(tiles)?tiles:[]).map(t=>{const d=defaults.get(t.id);if(!d)return t;const copy={...t};['title','body','cta'].forEach(k=>{if(copy[k]===d[k])copy[k]='';});return copy;});
}

