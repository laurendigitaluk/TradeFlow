import test from 'node:test';
import assert from 'node:assert/strict';
import { buildWebsiteSearchRoutes, getCategoryWebsitePlaybook, getWebsiteInstructions } from './source-playbooks.mjs';
import { buildExtractionPrompt, extractVisibleGbpPriceMentions, extractRelevantPageText, decodeSearchRedirect, extractCollectionPaginationLinks, extractSearchPaginationLinks, isCollectionDiscoveryPage, isEligibleProductPage, isChallengePage, matchesTaskModel, ollamaOptions, getResearchSourceLane, isApprovedSourceForTask, buildCategoryScopedSearchQuery, isAllowedSourceHost, searchResultsLimitForTask, is3dPrinterResearchTask, extractGemmaFindingRows } from './agent.mjs';

const task = {
  category_slug: '3d-printers-equipment',
  manufacturer: 'Creality',
  model: 'K1',
  search_query: 'Creality K1 UK new and used price'
};

test('3D printer playbook contains category-wide and individual website rules', () => {
  const playbook = getCategoryWebsitePlaybook(task.category_slug);
  assert.ok(playbook);
  assert.ok(playbook.categoryInstructions.some(rule => rule.includes('discovery page')));
  assert.ok(getWebsiteInstructions(task.category_slug, 'store.creality.com'));
  assert.ok(getWebsiteInstructions(task.category_slug, 'ebay.co.uk'));
  assert.ok(getWebsiteInstructions(task.category_slug, 'amazon.co.uk'));
});

test('manufacturer-specific playbook builds UK search and collection routes', () => {
  const routes = buildWebsiteSearchRoutes({ domain: 'store.creality.com' }, task);
  assert.ok(routes.some(url => url.includes('/uk/search?q=Creality%20K1')));
  assert.ok(routes.some(url => url.includes('/uk/collections/3d-printers')));
});

test('eBay and Amazon use their own search routes, not generic guessed paths only', () => {
  const ebay = buildWebsiteSearchRoutes({ domain: 'ebay.co.uk' }, task);
  const amazon = buildWebsiteSearchRoutes({ domain: 'amazon.co.uk' }, task);
  assert.ok(ebay.some(url => url.includes('/sch/i.html?_nkw=')));
  assert.ok(amazon.some(url => url.includes('/s?k=')));
});

test('direct product detail template is not reused as a search route', () => {
  const routes = buildWebsiteSearchRoutes({
    domain: 'store.creality.com',
    search_url_template: 'https://store.creality.com/uk/products/k1-speedy-3d-printer'
  }, task);
  assert.ok(routes.some(url => url.includes('/uk/search?q=')));
  assert.ok(!routes.some(url => url.includes('/uk/products/k1-speedy-3d-printer')));
});

test('unknown categories do not inherit the 3D printer website playbook', () => {
  assert.equal(getCategoryWebsitePlaybook('mobile-phones'), null);
  assert.deepEqual(getWebsiteInstructions('mobile-phones', 'store.creality.com'), null);
});

test('Gumtree uses its UK srpsearch slug route for marketplace discovery', () => {
  const routes = buildWebsiteSearchRoutes({ domain: 'gumtree.com' }, task);
  assert.ok(routes.some(url => url === 'https://gumtree.com/uk/srpsearch%2Bcreality-k1'));
});

test('UK Gumtree individual adverts are accepted and second-hand category pages remain discovery only', () => {
  assert.equal(isEligibleProductPage('https://www.gumtree.com/p/printers-scanners/ender-3-good-condition/1804597701', 'Ender 3 3D Printer'), true);
  assert.equal(isCollectionDiscoveryPage('https://www.secondhand.org.uk/second-hand-3d-printers'), true);
  assert.equal(isEligibleProductPage('https://www.gumtree.com/uk/srpsearch%2Bcreality-k1', 'Creality K1 search results'), false);
});

test('designated UK 3D printer retailer hosts accept individual product pages', () => {
  for (const host of ['3dgbire.com','3dflo.com','bambu-lab-uk.myshopify.com','uk.anycubic3d.com','www.gumtree.com']) {
    assert.equal(isEligibleProductPage('https://'+host+'/products/creality-k1', 'Creality K1 3D Printer'), true, host);
  }
});

test('model matching ignores search query terms so accessories are not mistaken for the requested printer', () => {
  const accessory = 'https://www.amazon.co.uk/Creality-Leveling-Extruder-Filament/dp/B0GD12KF2V?keywords=Creality+K1';
  assert.equal(matchesTaskModel('Creality Leveling Extruder Filament', accessory, task), false);
  assert.equal(matchesTaskModel('Creality K1 Speedy 3D Printer', 'https://store.creality.com/uk/products/k1-speedy-3d-printer?ref=search', task), true);
  assert.equal(matchesTaskModel('Creality K1 Max Combo 8-Color Printer', 'https://store.creality.com/uk/products/k1-max-combo', task), true);
  assert.equal(matchesTaskModel('Creality K1 Printer Upgrade Kit', 'https://store.creality.com/uk/products/k1-upgrade-kit', task), true);
});

test('Amazon AAX sponsored redirects are unwrapped to the canonical ASIN product URL', () => {
  const wrapped = 'https://aax-eu-zaz.amazon.co.uk/x/c/token/https://www.amazon.co.uk/Creality-Leveling-Extruder-Filament/dp/B0GD12KF2V/ref=sxin?keywords=Creality+K1';
  assert.equal(decodeSearchRedirect(wrapped), 'https://www.amazon.co.uk/Creality-Leveling-Extruder-Filament/dp/B0GD12KF2V/ref=sxin');
});

test('Shopify collection API fallback is enabled only on sources that declare support', () => {
  assert.equal(getWebsiteInstructions(task.category_slug, '123-3d.co.uk').collectionApi, 'shopify');
  assert.equal(getWebsiteInstructions(task.category_slug, '3dgbire.com').collectionApi, 'shopify');
  assert.equal(getWebsiteInstructions(task.category_slug, 'store.creality.com').collectionApi, undefined);
  assert.equal(getWebsiteInstructions(task.category_slug, 'uni3dverse.co.uk').collectionApi, undefined);
});

test('3D printer instructions require category-to-product traversal and retain borderline findings', () => {
  const instructions = getCategoryWebsitePlaybook(task.category_slug).categoryInstructions.join(' ').toLowerCase();
  assert.match(instructions, /category.*branch.*product family.*manufacturer/);
  assert.match(instructions, /do not stop after the first successful route/);
  assert.match(instructions, /borderline.*chatgpt inspection/);
});

test('collection pagination follows same-site next pages only and is bounded', () => {
  const html = [
    '<a rel="next" href="/uk/collections/3d-printers?page=2">Next</a>',
    '<a href="https://outside.example/collections/3d-printers?page=3">Next</a>',
    '<a href="/uk/collections/3d-printers?page=4">4</a>',
    '<a href="/products/creality-k1">Product</a>'
  ].join('');
  const links = extractCollectionPaginationLinks(html, 'https://store.creality.com/uk/collections/3d-printers', 3);
  assert.deepEqual(links, [
    'https://store.creality.com/uk/collections/3d-printers?page=2',
    'https://store.creality.com/uk/collections/3d-printers?page=4'
  ]);
});

test('website search pagination follows same-host next and page links only', () => {
  const html = [
    '<a rel="next" href="?q=Creality%20K1&page=2">Next</a>',
    '<a href="https://outside.example/search?page=3">Next</a>',
    '<a href="?q=Creality%20K1&page=4">4</a>',
    '<a href="/products/creality-k1">Product</a>'
  ].join('');
  assert.deepEqual(extractSearchPaginationLinks(html, 'https://store.creality.com/uk/search?q=Creality%20K1', 2), [
    'https://store.creality.com/uk/search?q=Creality%20K1&page=2',
    'https://store.creality.com/uk/search?q=Creality%20K1&page=4'
  ]);
});

test('3D printer branch rules distinguish printer machines from accessories', () => {
  const rules = getCategoryWebsitePlaybook(task.category_slug).branchInstructions;
  assert.match(rules['3d-printers'].join(' '), /standalone 3D printer machines/i);
  assert.match(rules['3d-printer-equipment-accessories'].join(' '), /do not reject an accessory/i);
  assert.match(rules['3d-printer-equipment-accessories'].join(' '), /compatib/i);
});


test('Gemma extraction prompt is capture-first and retains every supplied page', () => {
  const prompt = buildExtractionPrompt({
    ...task, branch_slug: '3d-printers', research_type: 'uk_both',
    package_name: '8-Color Combo'
  }, [{
    source_id: 'S1', title: 'Kobra S1 Max',
    url: 'https://uk.anycubic3d.com/products/kobra-s1-max',
    text: 'Kobra S1 Max £549.00 Combo 4 colours £749.00 8 colours £935.00'
  }]);
  assert.match(prompt, /YOUR JOB IS CAPTURE, NOT DECISION/i);
  assert.match(prompt, /exactly one finding for EVERY supplied source_id/i);
  assert.match(prompt, /Do not choose one price if a page shows several package prices/i);
  assert.match(prompt, /S1/);
  assert.match(prompt, /8-Color Combo/);
  assert.doesNotMatch(prompt, /VERIFIED EVIDENCE:/i);
});

test('Gemma extraction uses a larger output budget without increasing the 4k context', () => {
  assert.equal(ollamaOptions({}).num_ctx, 4096);
  assert.equal(ollamaOptions({}).num_predict, 1024);
});


test('Gemma reports observations rather than deciding whether evidence is usable', () => {
  const prompt = buildExtractionPrompt({
    ...task, branch_slug: '3d-printers', research_type: 'uk_both',
    package_name: '8-Color Combo'
  }, [
    { source_id: 'S1', title: 'Kobra S1 Max', url: 'https://uk.anycubic3d.com/products/kobra-s1-max', text: 'Kobra S1 Max £549.00 Combo 4 colours £749.00 8 colours £935.00' },
    { source_id: 'S2', title: 'Kobra S1 Max used', url: 'https://www.ebay.co.uk/itm/1234567890', text: 'Used Kobra S1 Max £400 collection only' }
  ]);
  assert.match(prompt, /YOUR JOB IS CAPTURE, NOT DECISION/i);
  assert.match(prompt, /exactly one finding for EVERY supplied source_id/i);
  assert.match(prompt, /Do not choose one price if a page shows several package prices/i);
  assert.match(prompt, /S1/);
  assert.match(prompt, /S2/);
  assert.doesNotMatch(prompt, /VERIFIED EVIDENCE:/i);
});

test('GBP price capture preserves multiple visible prices and their context', () => {
  const prices = extractVisibleGbpPriceMentions('Machine £549.00; 4-colour combo £749.00; 8-colour combo £935.00');
  assert.deepEqual(prices.map(item => item.amount), [549, 749, 935]);
  assert.match(prices[2].context, /8-colour combo/);
});


const laneSources = [
  { source_name: '3D Prima UK', domain: '3dprima.co.uk', source_kind: 'retailer', country_code: 'GB', research_scope: 'new_uk', category_slugs: ['3d-printers-equipment'] },
  { source_name: 'eBay UK', domain: 'ebay.co.uk', source_kind: 'marketplace', country_code: 'GB', research_scope: 'used_uk', category_slugs: ['*'] },
  { source_name: 'Anycubic UK Official Store', domain: 'uk.anycubic3d.com', source_kind: 'manufacturer', country_code: 'GB', research_scope: 'official', category_slugs: ['3d-printers-equipment'] },
  { source_name: 'Amazon UK', domain: 'amazon.co.uk', source_kind: 'retailer', country_code: 'GB', research_scope: 'all', category_slugs: ['*'] }
];

test('new and used research tasks only search their assigned UK source lane', () => {
  const newTask = { ...task, manufacturer: 'Anycubic', research_type: 'uk_new' };
  const usedTask = { ...task, manufacturer: 'Anycubic', research_type: 'uk_used' };
  const bothTask = { ...task, manufacturer: 'Anycubic', research_type: 'uk_both' };

  assert.equal(getResearchSourceLane(laneSources[0]), 'uk_new');
  assert.equal(getResearchSourceLane(laneSources[1]), 'uk_used');
  assert.equal(getResearchSourceLane(laneSources[2]), 'uk_new');
  assert.equal(getResearchSourceLane(laneSources[3]), 'both');

  assert.equal(isApprovedSourceForTask(laneSources[0], newTask), true);
  assert.equal(isApprovedSourceForTask(laneSources[1], newTask), false);
  assert.equal(isApprovedSourceForTask(laneSources[2], newTask), true);
  assert.equal(isApprovedSourceForTask(laneSources[3], newTask), true);

  assert.equal(isApprovedSourceForTask(laneSources[0], usedTask), false);
  assert.equal(isApprovedSourceForTask(laneSources[1], usedTask), true);
  assert.equal(isApprovedSourceForTask(laneSources[2], usedTask), false);
  assert.equal(isApprovedSourceForTask(laneSources[3], usedTask), true);

  assert.ok(isApprovedSourceForTask(laneSources[0], bothTask));
  assert.ok(isApprovedSourceForTask(laneSources[1], bothTask));
  assert.ok(isApprovedSourceForTask(laneSources[2], bothTask));
  assert.ok(isApprovedSourceForTask(laneSources[3], bothTask));
});

test('category-scoped web search and host validation obey the new/used lane', () => {
  const newTask = { ...task, manufacturer: 'Anycubic', research_type: 'uk_new' };
  const usedTask = { ...task, manufacturer: 'Anycubic', research_type: 'uk_used' };
  const newQuery = buildCategoryScopedSearchQuery('Anycubic Kobra S1', laneSources, newTask);
  const usedQuery = buildCategoryScopedSearchQuery('Anycubic Kobra S1 used', laneSources, usedTask);

  assert.match(newQuery, /site:3dprima\.co\.uk/);
  assert.match(newQuery, /site:uk\.anycubic3d\.com/);
  assert.match(newQuery, /site:amazon\.co\.uk/);
  assert.doesNotMatch(newQuery, /site:ebay\.co\.uk/);
  assert.match(usedQuery, /site:ebay\.co\.uk/);
  assert.doesNotMatch(usedQuery, /site:3dprima\.co\.uk/);
  assert.match(usedQuery, /site:amazon\.co\.uk/);
  assert.equal(isAllowedSourceHost('https://www.ebay.co.uk/itm/1234567890', laneSources, newTask), false);
  assert.equal(isAllowedSourceHost('https://www.ebay.co.uk/itm/1234567890', laneSources, usedTask), true);
  assert.equal(isAllowedSourceHost('https://www.amazon.co.uk/dp/B000000000', laneSources, usedTask), true);
});

test('3D printer web search defaults to 30 results only for the 3D Printers branch', () => {
  const printerTask = { category_slug: '3d-printers-equipment', branch_slug: '3d-printers' };
  assert.equal(is3dPrinterResearchTask(printerTask), true);
  assert.equal(searchResultsLimitForTask(printerTask, {}), 30);
  assert.equal(searchResultsLimitForTask(printerTask, { GEMMA_3D_PRINTER_SEARCH_RESULTS_PER_TASK: '24' }), 24);
  assert.equal(searchResultsLimitForTask(printerTask, { GEMMA_3D_PRINTER_SEARCH_RESULTS_PER_TASK: '80' }), 30);
  assert.equal(searchResultsLimitForTask({ category_slug: '3d-printers-equipment', branch_slug: 'other' }, {}), 18);
  assert.equal(searchResultsLimitForTask({ category_slug: '3d-printers-equipment' }, {}), 18);
  assert.equal(searchResultsLimitForTask({ category_slug: 'mobile-phones' }, {}), 18);
  assert.equal(searchResultsLimitForTask({ category_slug: 'mobile-phones' }, { SEARCH_RESULTS_PER_TASK: '12' }), 12);
});

test('new/used lane routing does not change other catalogue categories', () => {
  const mobileUsedTask = { ...task, category_slug: 'mobile-phones', branch_slug: 'mobile-phones', research_type: 'uk_used' };
  assert.equal(is3dPrinterResearchTask(mobileUsedTask), false);
  assert.equal(isApprovedSourceForTask(laneSources[1], mobileUsedTask), true);
  assert.equal(isApprovedSourceForTask(laneSources[3], mobileUsedTask), true);
});

test('GBP price extraction recognises HTML pound entities after page text normalisation', () => {
  const pageText = extractRelevantPageText(
    '<main>Bambu Lab printer current price &pound;1,079.00; previous price &#163;1,179.00</main>',
    { manufacturer: 'Bambu Lab', model: 'A1' }
  );
  const prices = extractVisibleGbpPriceMentions(pageText);
  assert.deepEqual(prices.map(item => item.amount), [1079, 1179]);
  assert.match(prices[0].display, /^GBP /);
  assert.match(prices[0].context, /current price/);
});

test('eBay bot challenge URLs are identified and never treated as product pages', () => {
  const challenge = 'https://www.ebay.co.uk/splashui/challenge?ap=1&ru=https%3A%2F%2Fwww.ebay.co.uk%2Fitm%2F1234567890';
  assert.equal(isChallengePage(challenge), true);
  assert.equal(isEligibleProductPage(challenge, 'eBay'), false);
  assert.equal(isEligibleProductPage('https://www.ebay.co.uk/itm/1234567890', 'Anycubic Kobra S1 3D Printer'), true);
});


test('Gemma JSON parser accepts recognised finding arrays and a single source finding', () => {
  const row = { source_id: 'S1', page_title: 'Kobra S1', observed_price: 249 };
  assert.deepEqual(extractGemmaFindingRows([row]), [row]);
  assert.deepEqual(extractGemmaFindingRows({ findings: [row] }), [row]);
  assert.deepEqual(extractGemmaFindingRows({ evidence: [row], borderline: [{ source_id: 'S2' }] }), [row, { source_id: 'S2' }]);
  assert.deepEqual(extractGemmaFindingRows({ results: [row] }), [row]);
  assert.deepEqual(extractGemmaFindingRows({ output: [row] }), [row]);
  assert.deepEqual(extractGemmaFindingRows({ response: [row] }), [row]);
  assert.deepEqual(extractGemmaFindingRows({ data: { pages: [row] } }), [row]);
  assert.deepEqual(extractGemmaFindingRows(row), [row]);
  assert.equal(extractGemmaFindingRows({ summary: 'done', candidates: [] }), null);
});


test('Gemma extraction prompt stays bounded and keeps recent guidance plus full-page price mentions', () => {
  const notes = Array.from({ length: 12 }, (_, index) => ({
    type: 'learning_note',
    sender: 'test',
    title: 'note-' + index,
    body: 'NOTE-' + index + ' ' + 'N'.repeat(1800)
  }));
  const longPage = 'A'.repeat(5000) + ' Current listed price £999.00';
  const prompt = buildExtractionPrompt({
    ...task,
    branch_slug: '3d-printers',
    research_type: 'uk_new',
    common_room_context: notes
  }, [
    { source_id: 'S1', title: 'Printer page', url: 'https://www.3dprima.co.uk/printer', text: longPage },
    { source_id: 'S2', title: 'Second page', url: 'https://www.3djake.uk/printer', text: 'B'.repeat(5000) }
  ]);

  assert.ok(prompt.length < 18000, 'bounded prompt length: ' + prompt.length);
  assert.match(prompt, /NOTE-11/);
  assert.doesNotMatch(prompt, /NOTE-0 /);
  assert.match(prompt, /£999\.00/);
  assert.match(prompt, /visible_gbp_price_context/);
  assert.ok(prompt.includes('A'.repeat(2200)));
  assert.ok(!prompt.includes('A'.repeat(2201)));
});
