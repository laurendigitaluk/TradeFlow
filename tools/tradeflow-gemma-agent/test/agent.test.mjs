import test from 'node:test';
import assert from 'node:assert/strict';
import { sourceKey, validate, ollamaOptions } from '../src/agent.mjs';
const task={manufacturer:'Creality',model:'K1',research_type:'uk_new'};
const evidence={evidence_type:'uk_new',source_name:'Creality UK',source_url:'https://store.creality.com/uk/products/k1',observed_price:299,price_currency:'GBP',item_condition:'New',sales_channel:'Creality UK',availability:'sold_out'};
test('source keys are deterministic',()=>assert.equal(sourceKey(evidence.source_url,'uk_new',299),sourceKey(evidence.source_url,'uk_new',299)));
test('accepts visible UK GBP evidence',()=>assert.equal(validate(evidence,task,'Creality K1 Speedy 3D Printer £299.00').valid,true));
test('rejects non-UK sources',()=>assert.equal(validate({...evidence,source_url:'https://example.com/product'},task,'Creality K1 Speedy 3D Printer £299.00').valid,false));
test('rejects opened-never-used as UK used',()=>assert.equal(validate({...evidence,evidence_type:'uk_used',item_condition:'Opened - never used'},{...task,research_type:'uk_used'},'Creality K1 Speedy 3D Printer £299.00').valid,false));
test('rejects marketplace search pages',()=>assert.equal(validate({...evidence,source_url:'https://www.ebay.co.uk/sch/i.html?_nkw=k1'},task,'Creality K1 Speedy 3D Printer £299.00').valid,false));
test('rejects a near-match price rather than accepting a different amount',()=>assert.equal(validate(evidence,task,'Creality K1 Speedy 3D Printer £299.99').valid,false));


import { searchWebResults } from '../src/agent.mjs';

test('search uses local SearXNG JSON endpoint without an API key',async()=>{
 const original=globalThis.fetch;let requested;
 globalThis.fetch=async(url,options)=>{requested={url:new URL(url),options};return new Response(JSON.stringify({results:[{title:'Product UK',url:'https://shop.co.uk/product',content:'UK listing'},{title:'No URL'}]}),{status:200,headers:{'content-type':'application/json'}});};
 try {
  const results=await searchWebResults('Creality K1',{SEARXNG_BASE_URL:'http://127.0.0.1:8080',SEARCH_RESULTS_PER_TASK:'5'});
  assert.equal(requested.url.origin,'http://127.0.0.1:8080');
  assert.equal(requested.url.pathname,'/search');
  assert.equal(requested.url.searchParams.get('format'),'json');
  assert.equal(requested.url.searchParams.get('language'),'en-GB');
  assert.match(requested.url.searchParams.get('q'),/Creality K1 UK GBP/);
  assert.deepEqual(results,[{title:'Product UK',url:'https://shop.co.uk/product',description:'UK listing'}]);
 } finally {globalThis.fetch=original;}
});

test('search fails clearly when local SearXNG is unavailable',async()=>{
 const original=globalThis.fetch;globalThis.fetch=async()=>new Response('offline',{status:503});
 try {await assert.rejects(()=>searchWebResults('phone',{}),/HTTP 503/);}
 finally {globalThis.fetch=original;}
});


test('Gemma defaults to CPU inference to avoid exhausting 4 GB GPU memory',()=>{
 const options=ollamaOptions({});
 assert.equal(options.num_gpu,0);
 assert.equal(options.num_ctx,4096);
 assert.equal(options.num_predict,256);
});
test('Gemma GPU layer override must be a non-negative integer',()=>{
 assert.equal(ollamaOptions({OLLAMA_NUM_GPU:'12'}).num_gpu,12);
 assert.throws(()=>ollamaOptions({OLLAMA_NUM_GPU:'auto'}),/non-negative integer/);
});
