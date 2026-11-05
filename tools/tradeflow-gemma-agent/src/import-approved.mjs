import {readFile} from 'node:fs/promises';
import {resolve,dirname} from 'node:path';
import {fileURLToPath} from 'node:url';
const root=resolve(dirname(fileURLToPath(import.meta.url)),'..');
const ids={TEST:'nnsshnfkjcflucjrftzi',LIVE:'gxsrajtqzdjvmceqcpgv'};
const env={...process.env};
for(const line of (await readFile(resolve(root,'.env'),'utf8')).split(/\r?\n/)){const m=line.match(/^\s*([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.*)\s*$/);if(m&&env[m[1]]===undefined)env[m[1]]=m[2].replace(/^['"]|['"]$/g,'');}
function target(n){const p='TRADEFLOW_'+n+'_';const u=env[p+'URL'],k=env[p+'SERVICE_ROLE_KEY'];if(!u||!k||new URL(u).hostname!==ids[n]+'.supabase.co')throw Error('Invalid '+n+' connection');return{n,u:u.replace(/\/$/,''),k};}
async function db(t,path,opts={}){const r=await fetch(t.u+'/rest/v1/'+path,{...opts,headers:{apikey:t.k,Authorization:'Bearer '+t.k,'Content-Type':'application/json',...(opts.headers||{})}});const s=await r.text();if(!r.ok)throw Error(t.n+' '+r.status+' '+s.slice(0,350));return s?JSON.parse(s):[];}
const T=target('TEST'),L=target('LIVE');
const queue=await db(T,'platform_catalogue_research_queue?'+new URLSearchParams({select:'*',status:'eq.approved',record_type:'eq.evidence_candidate',order:'created_at.asc',limit:'50'}));
const plans=[];
for(const q of queue){
 const idsFor={};
 for(const t of [T,L]){
  const c=await db(t,'catalogue_master_categories?'+new URLSearchParams({select:'id',slug:'eq.'+q.category_slug,active:'eq.true'}));
  const m=await db(t,'catalogue_master_manufacturers?'+new URLSearchParams({select:'id',name:'ilike.'+q.manufacturer,active:'eq.true'}));
  if(c.length!==1||m.length!==1)throw Error(t.n+': category/manufacturer not unique for '+q.model);
  let b=null;if(q.branch_slug){const rows=await db(t,'catalogue_master_branches?'+new URLSearchParams({select:'id',category_id:'eq.'+c[0].id,slug:'eq.'+q.branch_slug,active:'eq.true'}));if(rows.length!==1)throw Error(t.n+': branch not unique');b=rows[0].id;}
  const f={select:'id',category_id:'eq.'+c[0].id,manufacturer_id:'eq.'+m[0].id,model:'eq.'+q.model,package_key:'eq.'+q.package_key,active:'eq.true',branch_id:b?'eq.'+b:'is.null'};
  const p=await db(t,'catalogue_master_products?'+new URLSearchParams(f));if(p.length!==1)throw Error(t.n+': exact master product missing/ambiguous '+q.model);idsFor[t.n]=p[0].id;
 }
 const payload={evidence_type:q.evidence_type,source_name:q.source_name,source_url:q.source_url,observed_price:Number(q.observed_price),price_currency:'GBP',item_condition:q.item_condition||null,sales_channel:q.sales_channel||null,availability:q.availability||null,observed_at:new Date().toISOString(),notes:[q.research_notes||'',q.evidence_type==='uk_used'?'Reference only; excluded from automatic valuation.':''].filter(Boolean).join('\n')||null,is_active:true,source_record_key:q.source_record_key};
 const source=new URL(payload.source_url);const host=source.hostname.toLowerCase();const ukSource=host.endsWith('.co.uk')||host.endsWith('.org.uk')||host.endsWith('.ac.uk')||host.endsWith('.gov.uk')||host.endsWith('.uk')||source.pathname.toLowerCase().includes('/uk/');if(source.protocol!=='https:'||!ukSource)throw Error('Non-UK or insecure evidence source '+q.id);if(!['uk_new','uk_used'].includes(payload.evidence_type)||!payload.source_record_key||!payload.source_name||!Number.isFinite(payload.observed_price)||payload.observed_price<=0)throw Error('Incomplete approved evidence '+q.id);
 const checks=[];
 for(const [name,t] of [['TEST',T],['LIVE',L]]){const f=new URLSearchParams({select:'id,master_product_id,evidence_type,source_url,observed_price,price_currency',source_name:'eq.'+payload.source_name,source_record_key:'eq.'+payload.source_record_key});const found=await db(t,'shared_market_evidence?'+f);if(found.length>1)throw Error(name+': duplicate source key');if(found.length&& (found[0].master_product_id!==idsFor[name]||found[0].evidence_type!==payload.evidence_type||found[0].source_url!==payload.source_url||Number(found[0].observed_price)!==payload.observed_price||found[0].price_currency!=='GBP'))throw Error(name+': conflicting existing evidence');checks.push(found[0]||null);}
 plans.push({q,idsFor,payload,checks});
}
const done=[];
for(const p of plans){
 const saved=[];
 for(const [i,t] of [T,L].entries()){const row=p.checks[i]||(await db(t,'shared_market_evidence',{method:'POST',headers:{Prefer:'return=representation'},body:JSON.stringify({...p.payload,master_product_id:p.idsFor[t.n]})}))[0];if(!row?.id)throw Error('Unverified '+t.n+' write for '+p.q.id);saved.push(row.id);}
 await db(T,'platform_catalogue_research_queue?id=eq.'+p.q.id,{method:'PATCH',headers:{Prefer:'return=representation'},body:JSON.stringify({status:'imported',imported_at:new Date().toISOString(),test_master_product_id:p.idsFor.TEST,live_master_product_id:p.idsFor.LIVE,test_evidence_id:saved[0],live_evidence_id:saved[1],updated_at:new Date().toISOString()})});
 done.push({queue_id:p.q.id,model:p.q.model,test_evidence_id:saved[0],live_evidence_id:saved[1]});
}
console.log(JSON.stringify({status:'complete',imported:done.length,items:done},null,2));
