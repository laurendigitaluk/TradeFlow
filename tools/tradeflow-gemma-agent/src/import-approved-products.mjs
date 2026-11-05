import {readFile} from 'node:fs/promises';
import {resolve,dirname} from 'node:path';
import {fileURLToPath} from 'node:url';
import {reportAgent} from './agent-telemetry.mjs';

const root=resolve(dirname(fileURLToPath(import.meta.url)),'..');
const projectRefs={TEST:'nnsshnfkjcflucjrftzi',LIVE:'gxsrajtqzdjvmceqcpgv'};
const officialDomains=new Set(['apple.com','samsung.com','creality.com','bambulab.com','dji.com','sony.co.uk','microsoft.com','xbox.com','nintendo.com','canon.co.uk','nikon.co.uk','garrett.com','minelab.com']);
const env={...process.env};
for(const line of (await readFile(resolve(root,'.env'),'utf8')).split(/\r?\n/)){
 const m=line.match(/^\s*([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.*)\s*$/);
 if(m&&env[m[1]]===undefined)env[m[1]]=m[2].replace(/^['"]|['"]$/g,'');
}
function target(name){
 const prefix='TRADEFLOW_'+name+'_',url=env[prefix+'URL'],key=env[prefix+'SERVICE_ROLE_KEY'];
 if(!url||!key||new URL(url).hostname!==projectRefs[name]+'.supabase.co')throw Error('Invalid '+name+' connection; refusing catalogue import.');
 return{name,url:url.replace(/\/$/,''),key};
}
async function db(t,path,options={}){
 const response=await fetch(t.url+'/rest/v1/'+path,{...options,headers:{apikey:t.key,Authorization:'Bearer '+t.key,'Content-Type':'application/json',...(options.headers||{})},signal:AbortSignal.timeout(20000)});
 const body=await response.text();
 if(!response.ok)throw Error(t.name+' '+response.status+' '+body.slice(0,500));
 return body?JSON.parse(body):[];
}
function exactFilter(value){return 'eq.'+String(value).replace(/[\\,()]/g,'\\$&');}
function officialSource(url){
 const parsed=new URL(url);
 const host=parsed.hostname.toLowerCase().replace(/^www\./,'');
 return parsed.protocol==='https:'&&[...officialDomains].some(domain=>host===domain||host.endsWith('.'+domain));
}
function one(rows,label){if(rows.length!==1)throw Error(label+' expected one match, found '+rows.length);return rows[0];}
const TEST=target('TEST'),LIVE=target('LIVE');
const identity={agent_key:'catalogue-importer',agent_name:'TradeFlow — Catalogue Importer',category:'Owner-approved product imports'};
await reportAgent(env,{...identity,status:'running',current_task:'Approved product import',event_type:'task_started',message:'Starting approved product-candidate preflight across TEST and LIVE.'});
try{
 const queue=await db(TEST,'platform_catalogue_research_queue?'+new URLSearchParams({select:'*',status:'eq.approved',record_type:'eq.product_candidate',order:'created_at.asc',limit:'50'}));
 const prepared=[];
 for(const item of queue){
  for(const field of ['category_slug','manufacturer','model','package_key','package_name','release_status','source_url','source_excerpt']){
   if(!String(item[field]??'').trim())throw Error('Candidate '+item.id+' missing '+field);
  }
  if(!['announced','preorder','released','available'].includes(item.release_status))throw Error('Candidate '+item.id+' is not a confirmed product release.');
  if(!officialSource(item.source_url))throw Error('Candidate '+item.id+' source is not on the official manufacturer allowlist.');
  if(!item.source_excerpt.toLowerCase().includes(item.model.toLowerCase()))throw Error('Candidate '+item.id+' source excerpt does not explicitly identify exact model '+item.model);
  const resolved={};
  for(const t of [TEST,LIVE]){
   const categories=await db(t,'catalogue_master_categories?'+new URLSearchParams({select:'id,slug,name',slug:exactFilter(item.category_slug),active:'eq.true'}));
   const category=one(categories,t.name+' active category '+item.category_slug);
   const manufacturers=await db(t,'catalogue_master_manufacturers?'+new URLSearchParams({select:'id,name',name:exactFilter(item.manufacturer),active:'eq.true'}));
   const manufacturer=one(manufacturers,t.name+' active manufacturer '+item.manufacturer);
   let branchId=null;
   if(item.branch_slug){
    const branches=await db(t,'catalogue_master_branches?'+new URLSearchParams({select:'id,slug,name',category_id:'eq.'+category.id,slug:exactFilter(item.branch_slug),active:'eq.true'}));
    branchId=one(branches,t.name+' active branch '+item.branch_slug).id;
   }
   const filters={select:'id,category_id,branch_id,manufacturer_id,model,package_key,package_name,active',category_id:'eq.'+category.id,manufacturer_id:'eq.'+manufacturer.id,model:exactFilter(item.model),package_key:exactFilter(item.package_key),branch_id:branchId?'eq.'+branchId:'is.null'};
   const matches=await db(t,'catalogue_master_products?'+new URLSearchParams(filters));
   if(matches.length>1)throw Error(t.name+': duplicate master product identity '+item.model);
   if(matches.length===1){
    const p=matches[0];
    if(!p.active||p.package_name!==item.package_name)throw Error(t.name+': existing product is inactive or package name conflicts for '+item.model);
    resolved[t.name]={id:p.id,exists:true};
   }else resolved[t.name]={id:null,exists:false,category_id:category.id,branch_id:branchId,manufacturer_id:manufacturer.id};
  }
  prepared.push({item,resolved});
 }
 const imported=[];
 for(const plan of prepared){
  const ids={};
  for(const t of [TEST,LIVE]){
   let id=plan.resolved[t.name].id;
   if(!id){
    const payload={category_id:plan.resolved[t.name].category_id,branch_id:plan.resolved[t.name].branch_id,manufacturer_id:plan.resolved[t.name].manufacturer_id,model:plan.item.model,package_key:plan.item.package_key,package_name:plan.item.package_name,catalogue_category:plan.item.catalogue_category||null,main_category:plan.item.main_category||null,product_type:plan.item.product_type||null,notes:plan.item.research_notes||('Official release status: '+plan.item.release_status),active:true,customer_visible:false};
    const inserted=await db(t,'catalogue_master_products',{method:'POST',headers:{Prefer:'return=representation'},body:JSON.stringify(payload)});
    id=one(inserted,t.name+' inserted product').id;
   }
   const verify=await db(t,'catalogue_master_products?'+new URLSearchParams({select:'id,model,package_key,package_name,active',id:'eq.'+id}));
   const product=one(verify,t.name+' post-write verification');
   if(product.model!==plan.item.model||product.package_key!==plan.item.package_key||product.package_name!==plan.item.package_name||!product.active)throw Error(t.name+': post-write identity verification failed for '+plan.item.model);
   ids[t.name]=id;
  }
  await db(TEST,'platform_catalogue_research_queue?id=eq.'+plan.item.id,{method:'PATCH',headers:{Prefer:'return=minimal'},body:JSON.stringify({status:'imported',imported_at:new Date().toISOString(),test_master_product_id:ids.TEST,live_master_product_id:ids.LIVE,updated_at:new Date().toISOString()})});
  imported.push({queue_id:plan.item.id,manufacturer:plan.item.manufacturer,model:plan.item.model,test_product_id:ids.TEST,live_product_id:ids.LIVE});
 }
 await reportAgent(env,{...identity,status:'idle',current_task:null,event_type:'task_completed',message:'Approved product import completed and verified independently in TEST and LIVE: '+imported.length+' candidates.',tasks_completed_delta:1,details:{imported:imported.length}});
 console.log(JSON.stringify({status:'complete',imported:imported.length,items:imported},null,2));
}catch(error){
 await reportAgent(env,{...identity,status:'error',current_task:'Approved product import',event_type:'task_failed',message:'Approved product import failed: '+error.message,last_error:error.message});
 throw error;
}
