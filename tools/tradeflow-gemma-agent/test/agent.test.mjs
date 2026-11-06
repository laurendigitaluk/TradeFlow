import test from 'node:test';
import assert from 'node:assert/strict';
import { sourceKey, validate, ollamaOptions, isEligibleProductPage, hasVisibleUkPrice, extractBatch, extractRelevantPageText } from '../src/agent.mjs';
import { combineProductResearchTasks } from '../src/task-groups.mjs';
const task={manufacturer:'Creality',model:'K1',research_type:'uk_new'};
const evidence={evidence_type:'uk_new',source_name:'Creality UK',source_url:'https://store.creality.com/uk/products/k1',observed_price:299,price_currency:'GBP',item_condition:'New',sales_channel:'Creality UK',availability:'sold_out'};
test('source keys are deterministic',()=>assert.equal(sourceKey(evidence.source_url,'uk_new',299),sourceKey(evidence.source_url,'uk_new',299)));
test('accepts visible UK GBP evidence',()=>assert.equal(validate(evidence,task,'Creality K1 Speedy 3D Printer £299.00').valid,true));
test('rejects non-UK sources',()=>assert.equal(validate({...evidence,source_url:'https://example.com/product'},task,'Creality K1 Speedy 3D Printer £299.00').valid,false));
test('accepts opened-never-used as UK used and preserves exact condition',()=>{
 const opened={...evidence,evidence_type:'uk_used',item_condition:'Opened - never used'};
 const result=validate(opened,{...task,research_type:'uk_used'},'Creality K1 Speedy 3D Printer Opened - never used £299.00');
 assert.equal(result.valid,true);
 assert.equal(opened.item_condition,'Opened - never used');
});
test('rejects opened-never-used as UK new',()=>{
 const opened={...evidence,evidence_type:'uk_new',item_condition:'Opened - never used'};
 assert.equal(validate(opened,{...task,research_type:'uk_new'},'Creality K1 Speedy 3D Printer Opened - never used £299.00').valid,false);
});
test('rejects marketplace search pages',()=>assert.equal(validate({...evidence,source_url:'https://www.ebay.co.uk/sch/i.html?_nkw=k1'},task,'Creality K1 Speedy 3D Printer £299.00').valid,false));
test('rejects Amazon search results as product pages',()=>{
 const url='https://www.amazon.co.uk/creality-k1-3d-printer/s?k=creality+k1';
 assert.equal(isEligibleProductPage(url,'Creality K1 3D Printer'),false);
 assert.equal(validate({...evidence,source_url:url},task,'Creality K1 Speedy 3D Printer £299.00').valid,false);
});
test('accepts an Amazon direct ASIN product detail URL',()=>{
 assert.equal(isEligibleProductPage('https://www.amazon.co.uk/dp/B0ABCDE123','Creality K1 3D Printer'),true);
});
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

test('search fans out complementary UK product queries across providers', async () => {
 const original=globalThis.fetch;
 const seen=[];
 globalThis.fetch=async(url)=>{
  const target=String(url); seen.push(target);
  if(target.includes('duckduckgo.com')) return new Response('<html><a class="result__a" href="https://maker.co.uk/products/k1">Creality K1 product</a></html>',{status:200,headers:{'content-type':'text/html'}});
  if(target.includes('bing.com')) return new Response('<html><li class="b_algo"><h2><a href="https://retailer.co.uk/products/k1">Creality K1 printer</a></h2></li></html>',{status:200,headers:{'content-type':'text/html'}});
  if(target.includes('mojeek.com')) return new Response('<html><a class="result__a" href="https://shop.co.uk/item/k1">Creality K1 listing</a></html>',{status:200,headers:{'content-type':'text/html'}});
  throw new Error('unexpected provider');
 };
 try {
  const results=await searchWebResults('Creality K1 Standard Printer',{SEARCH_RESULTS_PER_TASK:'8'});
  assert.ok(seen.length >= 9);
  assert.ok(seen.some(url=>decodeURIComponent(url).includes('"Creality K1 Standard Printer" UK price GBP product page')));
  assert.equal(results.length,3);
 } finally {globalThis.fetch=original;}
});

test('Google Web Search Service is used when its own TradeFlow credentials are configured', async () => {
 const original=globalThis.fetch; const seen=[];
 globalThis.fetch=async(url,options={})=>{
  seen.push({url:String(url),headers:options.headers||{}});
  if(String(url).includes('websearchservice.googleapis.com')) return new Response(JSON.stringify({searchResults:[{title:'Creality K1 UK printer',displayUrl:'https://retailer.co.uk/products/k1',snippet:'£299.00'}]}),{status:200,headers:{'content-type':'application/json'}});
  throw new Error('unexpected provider');
 };
 try {
  const results=await searchWebResults('Creality K1',{GOOGLE_SEARCH_API_KEY:'test-key',GOOGLE_WEB_SEARCH_CLIENT_ID:'test-client',GOOGLE_SEARCH_USER_IP:'192.0.2.10',SEARCH_RESULTS_PER_TASK:'5'});
  assert.ok(seen.some(item=>item.url.includes('websearchservice.googleapis.com')));
  assert.ok(results.some(item=>item.provider==='google'&&item.url==='https://retailer.co.uk/products/k1'));
 } finally {globalThis.fetch=original;}
});
test('Amazon UK exact-model discovery queries are included without accepting search URLs as evidence', async () => {
 const original=globalThis.fetch; const seen=[];
 globalThis.fetch=async(url)=>{
  const target=String(url); seen.push(target);
  if(target.includes('duckduckgo.com')) return new Response('<html></html>',{status:200,headers:{'content-type':'text/html'}});
  if(target.includes('bing.com')) return new Response('<html></html>',{status:200,headers:{'content-type':'text/html'}});
  if(target.includes('mojeek.com')) return new Response('<html></html>',{status:200,headers:{'content-type':'text/html'}});
  throw new Error('unexpected provider');
 };
 try {
  await searchWebResults('Creality K1',{});
  assert.ok(seen.some(url=>decodeURIComponent(url).includes('site:amazon.co.uk/dp/')));
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


test('approved source collection discovery hubs are permitted as discovery, never direct evidence', () => {
 assert.equal(isCollectionDiscoveryPage('https://store.creality.com/uk/collections/k1-series-3d-printer','Creality K1 Series'),true);
 assert.equal(isEligibleProductPage('https://store.creality.com/uk/collections/k1-series-3d-printer','Creality K1 Series'),false);
});

test('prefilter rejects collection, search, forum and marketplace category URLs before page fetch', () => {
 assert.equal(isEligibleProductPage('https://store.creality.com/uk/collections/k1-series-3d-printer'), false);
 assert.equal(isEligibleProductPage('https://www.gumtree.com/for-sale/miscellaneous-goods/uk/srpsearch+3d+printer'), false);
 assert.equal(isEligibleProductPage('https://www.3dprintersforum.co.uk/viewtopic.php?t=704'), false);
 assert.equal(isEligibleProductPage('https://www.ebay.co.uk/shop/k1-max?_nkw=k1+max'), false);
});

test('rejects storefront homepages and locale landing pages', () => {
 assert.equal(isEligibleProductPage('https://waustore.creality.com/uk/'), false);
 assert.equal(isEligibleProductPage('https://store.creality.com/'), false);
 assert.equal(validate({...evidence,source_url:'https://waustore.creality.com/uk/'},task,'Creality K1 £339.00').valid,false);
});
test('prefilter permits a direct UK product listing', () => {
 assert.equal(isEligibleProductPage('https://www.ebay.co.uk/itm/405135219874'), true);
 assert.equal(isEligibleProductPage('https://store.creality.com/uk/products/k1'), true);
});

test('product extraction excludes navigation and unrelated footer prices', () => {
 const html = '<html><body><header>Sale £999.00</header><nav>Other printer £799.00</nav><main><h1>Creality K1 3D Printer</h1><p>New model £299.00 in stock</p></main><footer>Unrelated product £499.00</footer></body></html>';
 const text = extractRelevantPageText(html, {manufacturer:'Creality',model:'K1'});
 assert.match(text,/Creality K1 3D Printer/);
 assert.match(text,/£299.00/);
 assert.doesNotMatch(text,/£999.00|£799.00|£499.00/);
});
test('product extraction adds matching JSON-LD product offer', () => {
 const html = '<main><h1>Creality K1</h1></main><script type="application/ld+json">'+JSON.stringify({
  '@context':'https://schema.org','@type':'Product',name:'Creality K1 3D Printer',brand:{'@type':'Brand',name:'Creality'},model:'K1',offers:{'@type':'Offer',price:'299.00',priceCurrency:'GBP',availability:'https://schema.org/InStock',itemCondition:'https://schema.org/NewCondition'}
 })+'</script>';
 const text = extractRelevantPageText(html,{manufacturer:'Creality',model:'K1'});
 assert.match(text,/Price: 299.00 Currency: GBP/);
 assert.match(text,/Creality K1 3D Printer/);
});
test('visible UK price prefilter requires an explicit positive GBP amount', () => {
 assert.equal(hasVisibleUkPrice('Creality K1 3D Printer ' + String.fromCharCode(163) + '299.00'), true);
 assert.equal(hasVisibleUkPrice('Price ' + String.fromCharCode(163) + '1,299.99'), true);
 assert.equal(hasVisibleUkPrice('Creality K1 3D Printer £299.00'), true);
 assert.equal(hasVisibleUkPrice('Price GBP 1,299.99'), true);
 assert.equal(hasVisibleUkPrice('Price ' + String.fromCharCode(163) + String.fromCharCode(160) + '299.00'), true);
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
 assert.equal(combined[0].search_query,'Creality K1 UK price retailer product');
 assert.doesNotMatch(combined[0].search_query,/Standard Printer/);
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


test('search result cap is shared fairly across independent providers', async () => {
 const original=globalThis.fetch;
 globalThis.fetch=async(url)=>{
  const target=String(url);
  const parsed=new URL(target);
  const queryIndex=parsed.searchParams.get('q')?.includes('buy new')?2:parsed.searchParams.get('q')?.includes('price GBP')?1:0;
  if(target.includes('duckduckgo.com')) return new Response(
   '<html><a class="result__a" href="https://ddg-retailer.co.uk/product/'+queryIndex+'">Creality K1 direct product</a></html>',
   {status:200,headers:{'content-type':'text/html'}});
  if(target.includes('bing.com')) return new Response(
   '<html><li class="b_algo"><h2><a href="https://bing-retailer.co.uk/product/'+queryIndex+'">Creality K1 direct product</a></h2></li></html>',
   {status:200,headers:{'content-type':'text/html'}});
  if(target.includes('mojeek.com')) return new Response(
   '<html><a class="result__a" href="https://mojeek-retailer.co.uk/product/'+queryIndex+'">Creality K1 direct product</a></html>',
   {status:200,headers:{'content-type':'text/html'}});
  throw new Error('unexpected provider');
 };
 try {
  const results=await searchWebResults('Creality K1 Standard Printer',{SEARCH_RESULTS_PER_TASK:'6'});
  assert.equal(results.length,6);
  for(const provider of ['duckduckgo','bing','mojeek']) {
   assert.equal(results.filter(item=>item.provider===provider).length,2);
  }
 } finally { globalThis.fetch=original; }
});
