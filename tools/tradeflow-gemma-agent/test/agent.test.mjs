import test from 'node:test';
import assert from 'node:assert/strict';
import { sourceKey, validate, ollamaOptions, isEligibleProductPage, hasVisibleUkPrice, extractBatch } from '../src/agent.mjs';
import { combineProductResearchTasks } from '../src/task-groups.mjs';
const task={manufacturer:'Creality',model:'K1',research_type:'uk_new'};
const evidence={evidence_type:'uk_new',source_name:'Creality UK',source_url:'https://store.creality.com/uk/products/k1',observed_price:299,price_currency:'GBP',item_condition:'New',sales_channel:'Creality UK',availability:'sold_out'};
test('source keys are deterministic',()=>assert.equal(sourceKey(evidence.source_url,'uk_new',299),sourceKey(evidence.source_url,'uk_new',299)));
test('accepts visible UK GBP evidence',()=>assert.equal(validate(evidence,task,'Creality K1 Speedy 3D Printer £299.00').valid,true));
test('rejects non-UK sources',()=>assert.equal(validate({...evidence,source_url:'https://example.com/product'},task,'Creality K1 Speedy 3D Printer £299.00').valid,false));
test('rejects opened-never-used as UK used',()=>assert.equal(validate({...evidence,evidence_type:'uk_used',item_condition:'Opened - never used'},{...task,research_type:'uk_used'},'Creality K1 Speedy 3D Printer £299.00').valid,false));
test('rejects marketplace search pages',()=>assert.equal(validate({...evidence,source_url:'https://www.ebay.co.uk/sch/i.html?_nkw=k1'},task,'Creality K1 Speedy 3D Printer £299.00').valid,false));
test('rejects a near-match price rather than accepting a different amount',()=>assert.equal(validate(evidence,task,'Creality K1 Speedy 3D Printer £299.99').valid,false));


import { searchWebResults } from '../src/agent.mjs';

test('search continues when one independent provider is unavailable', async () => {
 const original=globalThis.fetch;
 globalThis.fetch=async(url)=>{
  const target=String(url);
  if(target.includes('duckduckgo.com')) throw new Error('provider unavailable');
  if(target.includes('bing.com')) return new Response('<html><li class="b_algo"><h2><a href="https://shop.co.uk/product">Creality K1 UK printer</a></h2></li></html>',{status:200,headers:{'content-type':'text/html'}});
  if(target.includes('mojeek.com')) return new Response('<html><a class="result__a" href="https://retailer.co.uk/item">Creality K1 listing</a></html>',{status:200,headers:{'content-type':'text/html'}});
  throw new Error('unexpected provider');
 };
 try {
  const results=await searchWebResults('Creality K1',{SEARCH_RESULTS_PER_TASK:'5'});
  assert.equal(results.length,2);
  assert.ok(results.some(x=>x.url==='https://shop.co.uk/product'));
  assert.ok(results.some(x=>x.url==='https://retailer.co.uk/item'));
 } finally {globalThis.fetch=original;}
});

test('search does not require a local SearXNG service', async () => {
 const original=globalThis.fetch;
 globalThis.fetch=async(url)=>{
  if(String(url).includes('duckduckgo.com')) throw new Error('offline');
  if(String(url).includes('bing.com')) throw new Response('blocked',{status:503});
  return new Response('<html><a class="result__a" href="https://manufacturer.co.uk/product">Creality K1 product page</a></html>',{status:200,headers:{'content-type':'text/html'}});
 };
 try {
  const results=await searchWebResults('Creality K1',{});
  assert.equal(results.length,1);
  assert.equal(results[0].url,'https://manufacturer.co.uk/product');
 } finally {globalThis.fetch=original;}
});

test('Gemma defaults to CPU inference to avoid exhausting 4 GB GPU memory',()=>{
 const options=ollamaOptions({});
 assert.equal(options.num_gpu,0);
 assert.equal(options.num_ctx,4096);
 assert.equal(options.num_predict,512);
});
test('Gemma GPU layer override must be a non-negative integer',()=>{
 assert.equal(ollamaOptions({OLLAMA_NUM_GPU:'12'}).num_gpu,12);
 assert.throws(()=>ollamaOptions({OLLAMA_NUM_GPU:'auto'}),/non-negative integer/);
});


test('prefilter rejects collection, search, forum and marketplace category URLs before page fetch', () => {
 assert.equal(isEligibleProductPage('https://store.creality.com/uk/collections/k1-series-3d-printer'), false);
 assert.equal(isEligibleProductPage('https://www.gumtree.com/for-sale/miscellaneous-goods/uk/srpsearch+3d+printer'), false);
 assert.equal(isEligibleProductPage('https://www.3dprintersforum.co.uk/viewtopic.php?t=704'), false);
 assert.equal(isEligibleProductPage('https://www.ebay.co.uk/shop/k1-max?_nkw=k1+max'), false);
});

test('prefilter permits a direct UK product listing', () => {
 assert.equal(isEligibleProductPage('https://www.ebay.co.uk/itm/405135219874'), true);
 assert.equal(isEligibleProductPage('https://store.creality.com/uk/products/k1'), true);
});

test('visible UK price prefilter requires an explicit positive GBP amount', () => {
 assert.equal(hasVisibleUkPrice('Creality K1 3D Printer ' + String.fromCharCode(163) + '299.00'), true);
 assert.equal(hasVisibleUkPrice('Price ' + String.fromCharCode(163) + '1,299.99'), true);
 assert.equal(hasVisibleUkPrice('Creality K1 3D Printer £299.00'), true);
 assert.equal(hasVisibleUkPrice('Price GBP 1,299.99'), true);
 assert.equal(hasVisibleUkPrice('Creality K1 high speed 3D printer'), false);
 assert.equal(hasVisibleUkPrice('£0.00'), false);
});


test('one Ollama request extracts multiple eligible pages in one batch', async () => {
 const original = globalThis.fetch;
 let calls = 0;
 globalThis.fetch = async (url, options) => {
  calls++;
  assert.equal(String(url), 'http://ollama.local/api/chat');
  const request = JSON.parse(options.body);
  assert.equal(request.messages.length, 1);
  assert.equal(request.options.num_predict, 512);
  return new Response(JSON.stringify({
   message: { content: JSON.stringify({ evidence: [
    { source_id: 'S1', observed_price: 299, item_condition: 'New', availability: 'In stock' },
    { source_id: 'S2', observed_price: 249, item_condition: 'Used - good', availability: 'Available' }
   ] }) }
  }), { status: 200, headers: { 'content-type': 'application/json' } });
 };
 try {
  const pages = [
   { source_id: 'S1', title: 'Creality K1', url: 'https://store.creality.com/uk/products/k1', text: 'Creality K1 £299.00' },
   { source_id: 'S2', title: 'Creality K1 used', url: 'https://retailer.co.uk/item/k1', text: 'Creality K1 used £249.00' }
  ];
  const result = await extractBatch({ manufacturer: 'Creality', model: 'K1', research_type: 'uk_new' }, pages, { OLLAMA_BASE_URL: 'http://ollama.local' });
  assert.equal(calls, 1);
  assert.equal(result.length, 2);
  assert.equal(result[0].evidence_type, 'uk_new');
  assert.equal(result[1].price_currency, 'GBP');
  assert.equal(result[1].source_url, pages[1].url);
 } finally { globalThis.fetch = original; }
});

test('paired new and used tasks collapse to one combined product research task', () => {
 const tasks = [
  {category_slug:'3d-printers-equipment',branch_slug:'3d-printers',manufacturer:'Creality',model:'K1',package_key:'standard',package_name:'Standard Printer',research_type:'uk_new',search_query:'Creality K1 new UK'},
  {category_slug:'3d-printers-equipment',branch_slug:'3d-printers',manufacturer:'Creality',model:'K1',package_key:'standard',package_name:'Standard Printer',research_type:'uk_used',search_query:'Creality K1 used UK'}
 ];
 const combined=combineProductResearchTasks(tasks);
 assert.equal(combined.length,1);
 assert.equal(combined[0].research_type,'uk_both');
 assert.match(combined[0].search_query,/new used price GBP/);
});
test('different package variants remain separate research tasks', () => {
 const tasks = [
  {category_slug:'3d-printers-equipment',manufacturer:'Creality',model:'K1',package_key:'standard',package_name:'Standard Printer'},
  {category_slug:'3d-printers-equipment',manufacturer:'Creality',model:'K1',package_key:'combo',package_name:'Combo Bundle'}
 ];
 assert.equal(combineProductResearchTasks(tasks).length,2);
});
test('combined extraction accepts both explicit UK-new and UK-used classifications', () => {
 const newEvidence={...evidence,evidence_type:'uk_new',item_condition:'New'};
 const usedEvidence={...evidence,evidence_type:'uk_used',item_condition:'Used - good',observed_price:249,source_url:'https://retailer.co.uk/item/k1'};
 assert.equal(validate(newEvidence,{...task,research_type:'uk_both'},'Creality K1 new £299.00').valid,true);
 assert.equal(validate(usedEvidence,{...task,research_type:'uk_both'},'Creality K1 used £249.00').valid,true);
});
