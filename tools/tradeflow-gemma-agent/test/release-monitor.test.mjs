import test from 'node:test';
import assert from 'node:assert/strict';
import {runReleaseMonitor} from '../src/release-monitor.mjs';

const env={TRADEFLOW_TEST_URL:'https://nnsshnfkjcflucjrftzi.supabase.co',TRADEFLOW_TEST_SERVICE_ROLE_KEY:'test',TRADEFLOW_LIVE_URL:'https://gxsrajtqzdjvmceqcpgv.supabase.co',TRADEFLOW_LIVE_SERVICE_ROLE_KEY:'live'};
const watchlist={manufacturers:[{name:'Example Maker',families:['Phone'],official_domains:['example.com/uk']}]};
const hit={title:'Official product announcement',url:'https://example.com/uk/news/new-phone'};
const page={url:hit.url,text:'Example Maker New Phone 1 official announcement'};
const extraction={candidates:[{model:'New Phone 1',release_status:'announced',release_date:null,category_slug:'phones',branch_slug:'mobile-phones',summary:'Officially announced.'}]};

test('release monitor stages an officially announced model missing from both environments',async()=>{
 const calls=[];
 const dbFn=async(t,path,options={})=>{
  if(path.startsWith('catalogue_master_manufacturers?'))return[{id:t.name+'-maker'}];
  if(path.startsWith('catalogue_master_products?'))return[];
  if(path.startsWith('platform_catalogue_research_queue?'))return[];
  if(path==='platform_catalogue_research_queue'){calls.push(JSON.parse(options.body));return[{id:'queue-1'}];}
  throw new Error('unexpected query '+path);
 };
 const result=await runReleaseMonitor({env,watchlist,enqueue:true,dbFn,searchFn:async()=>[hit],pageFn:async()=>page,extractFn:async()=>extraction});
 assert.equal(result.candidates[0].status,'queued-for-owner-review');
 assert.equal(calls.length,1);
 assert.equal(calls[0].record_type,'release_candidate');
 assert.equal(calls[0].status,'pending_review');
 assert.equal(calls[0].model,'New Phone 1');
});

test('release monitor sends mismatched TEST/LIVE catalogue coverage to manual research',async()=>{
 const dbFn=async(t,path)=>{
  if(path.startsWith('catalogue_master_manufacturers?'))return[{id:t.name+'-maker'}];
  if(path.startsWith('catalogue_master_products?'))return t.name==='TEST'?[{id:'existing'}]:[];
  if(path.startsWith('platform_catalogue_research_queue?'))return[];
  throw new Error('unexpected query '+path);
 };
 let inserted;
 const wrapped=async(t,path,opts={})=>{if(path==='platform_catalogue_research_queue'){inserted=JSON.parse(opts.body);return[{id:'q2'}];}return dbFn(t,path,opts);};
 const result=await runReleaseMonitor({env,watchlist,enqueue:true,dbFn:wrapped,searchFn:async()=>[hit],pageFn:async()=>page,extractFn:async()=>extraction});
 assert.equal(result.candidates[0].status,'queued-needs-research');
 assert.equal(inserted.status,'needs_research');
});
