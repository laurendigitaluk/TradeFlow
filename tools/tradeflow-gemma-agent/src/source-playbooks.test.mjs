import test from 'node:test';
import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import { buildWebsiteSearchRoutes, getCategoryWebsitePlaybook, getWebsiteInstructions } from './source-playbooks.mjs';
import { buildExtractionPrompt, buildDeepPageExcerpt, extractionBatchSizeForTask, fallbackPageCapture, buildCaptureEnrichmentPatch, extractVisibleGbpPriceMentions, extractRelevantPageText, decodeSearchRedirect, extractCollectionPaginationLinks, extractCollectionProductLinks, extractShopifyCollectionProducts, extractSearchPaginationLinks, isCollectionDiscoveryPage, isEligibleProductPage, isChallengePage, matchesTaskModel, ollamaOptions, getResearchSourceLane, isResearchTypeAllowedSource, isApprovedSourceForTask, buildCategoryScopedSearchQuery, isAllowedSourceHost, searchResultsLimitForTask, is3dPrinterResearchTask, isGamingConsoleResearchTask, isCaptureOnlyResearchTask, extractGemmaFindingRows } from './agent.mjs';

const task = {
  category_slug: '3d-printers-equipment',
  branch_slug: '3d-printers',
  manufacturer: 'Creality',
  model: 'K1',
  search_query: 'Creality K1 UK new and used price',
  package_key: 'standard',
  package_name: 'Standard Printer'
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
  assert.ok(routes.some(url => url.includes('/uk/collections/fdm-3d-printer')));
});

test('verified 123-3D collections route new and refurbished searches separately', () => {
  const newTask = { ...task, manufacturer: 'Anycubic', model: 'Kobra S1', research_type: 'uk_new' };
  const usedTask = { ...newTask, research_type: 'uk_used' };
  const bothTask = { ...newTask, research_type: 'uk_both' };

  assert.deepEqual(
    buildWebsiteSearchRoutes({ domain: '123-3d.co.uk' }, newTask),
    ['https://www.123-3d.co.uk/collections/3d-printers']
  );
  assert.deepEqual(
    buildWebsiteSearchRoutes({ domain: '123-3d.co.uk' }, usedTask),
    ['https://www.123-3d.co.uk/collections/refurbished-printers']
  );
  assert.deepEqual(
    buildWebsiteSearchRoutes({ domain: '123-3d.co.uk' }, bothTask),
    [
      'https://www.123-3d.co.uk/collections/3d-printers',
      'https://www.123-3d.co.uk/collections/refurbished-printers'
    ]
  );
});

test('3DFLO and iDig use their verified WordPress 3D-printer category routes', () => {
  assert.deepEqual(
    buildWebsiteSearchRoutes({ domain: '3dflo.com' }, task),
    ['https://www.3dflo.com/product-category/3d-printers/']
  );
  assert.deepEqual(
    buildWebsiteSearchRoutes({ domain: 'idig3dprinting.co.uk' }, task),
    ['https://www.idig3dprinting.co.uk/product-category/3d-printers/']
  );
  assert.deepEqual(
    buildWebsiteSearchRoutes({
      domain: '3dflo.com',
      search_url_template: 'https://www.3dflo.com/product-category/3d-printers/'
    }, task),
    ['https://www.3dflo.com/product-category/3d-printers/']
  );
});
test('ELEGOO UK uses separate FDM and pre-owned collections for new and used lanes', () => {
  const newTask = { ...task, manufacturer: 'Elegoo', model: 'Neptune 4 Pro', research_type: 'uk_new' };
  const usedTask = { ...newTask, research_type: 'uk_used' };
  const bothTask = { ...newTask, research_type: 'uk_both' };
  const fdm = 'https://uk.elegoo.com/collections/fdm-printers';
  const preOwned = 'https://uk.elegoo.com/collections/pre-owned-3d-printer';

  assert.deepEqual(buildWebsiteSearchRoutes({ domain: 'uk.elegoo.com' }, newTask), [fdm]);
  assert.deepEqual(buildWebsiteSearchRoutes({ domain: 'uk.elegoo.com' }, usedTask), [preOwned]);
  assert.deepEqual(buildWebsiteSearchRoutes({ domain: 'uk.elegoo.com' }, bothTask), [fdm, preOwned]);
  assert.equal(isCollectionDiscoveryPage(fdm, 'ELEGOO FDM 3D Printers'), true);
  assert.equal(isEligibleProductPage(fdm, 'ELEGOO FDM 3D Printers'), false);
  assert.equal(isCollectionDiscoveryPage(preOwned, 'ELEGOO Pre-owned 3D Printers'), true);
  assert.equal(isEligibleProductPage(preOwned, 'ELEGOO Pre-owned 3D Printers'), false);
});


test('WordPress printer categories are discovery pages and their individual product links are followed', () => {
  const base = 'https://www.3dflo.com/product-category/3d-printers/';
  const idig = 'https://www.idig3dprinting.co.uk/product-category/3d-printers/';
  for (const url of [base, idig]) {
    assert.equal(isCollectionDiscoveryPage(url, '3D Printers'), true);
    assert.equal(isEligibleProductPage(url, '3D Printers'), false);
  }
  const links = extractCollectionProductLinks(
    '<a href="/product/anycubic-kobra-s1/">Anycubic Kobra S1 3D Printer</a>',
    base,
    { ...task, manufacturer: 'Anycubic', model: 'Kobra S1' },
    5
  );
  assert.deepEqual(links.map(item => item.url), ['https://www.3dflo.com/product/anycubic-kobra-s1/']);
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
test('gaming category playbook preserves console and accessory identity for ChatGPT review', () => {
  const category = 'gaming-consoles-accessories';
  const playbook = getCategoryWebsitePlaybook(category);
  assert.ok(playbook);
  assert.ok(playbook.categoryInstructions.some(rule => rule.includes('ChatGPT')));
  assert.ok(playbook.categoryInstructions.some(rule => rule.includes('disc versus digital')));
  assert.match(playbook.branchInstructions['xbox-consoles'].join(' '), /storage.*disc\/digital/i);
  assert.ok(getWebsiteInstructions(category, 'xbox.com'));
  assert.ok(getWebsiteInstructions(category, 'nintendo.com'));
  assert.ok(getWebsiteInstructions(category, 'playstation.com'));
  assert.ok(getWebsiteInstructions(category, 'ebay.co.uk'));
  assert.ok(getWebsiteInstructions(category, 'cashconverters.co.uk'));
  assert.ok(getWebsiteInstructions(category, 'cashexp.co.uk'));
  assert.ok(getWebsiteInstructions(category, 'gumtree.com'));
  const routes = buildWebsiteSearchRoutes({ domain: 'xbox.com' }, {
    manufacturer: 'Microsoft', model: 'Xbox Series S'
  });
  assert.ok(routes.some(url => url.includes('/search?q=Microsoft%20Xbox%20Series%20S')));
});

test('gaming research lanes keep UK-new and UK-used sources separate', () => {
  const base = { category_slug: 'gaming-consoles-accessories', branch_slug: 'xbox-consoles' };
  const official = { source_kind: 'manufacturer', research_scope: 'official' };
  const newRetailer = { source_kind: 'retailer', research_scope: 'new_uk' };
  const usedDealer = { source_kind: 'used_dealer', research_scope: 'used_uk' };
  const universal = { source_kind: 'marketplace', research_scope: 'all' };
  assert.equal(isResearchTypeAllowedSource(official, { ...base, research_type: 'uk_new' }), true);
  assert.equal(isResearchTypeAllowedSource(newRetailer, { ...base, research_type: 'uk_new' }), true);
  assert.equal(isResearchTypeAllowedSource(usedDealer, { ...base, research_type: 'uk_new' }), false);
  assert.equal(isResearchTypeAllowedSource(official, { ...base, research_type: 'uk_used' }), false);
  assert.equal(isResearchTypeAllowedSource(usedDealer, { ...base, research_type: 'uk_used' }), true);
  assert.equal(isResearchTypeAllowedSource(universal, { ...base, research_type: 'uk_new' }), true);
  assert.equal(isResearchTypeAllowedSource(universal, { ...base, research_type: 'uk_used' }), true);
});

test('gaming category tasks use capture-only handoff and preserve the full raw page', () => {
  const gamingTask = {
    category_slug: 'gaming-consoles-accessories', branch_slug: 'xbox-consoles',
    manufacturer: 'Microsoft', model: 'Xbox Series S', package_key: '512gb-standard',
    package_name: '512GB Standard Console', research_type: 'uk_both'
  };
  const longText = 'Microsoft Xbox Series S 512GB Standard Console. Brand new. Disc-free digital console. £249.99. In stock for UK delivery. ' + 'Console details '.repeat(900);
  const source = {
    source_id: 'G1', title: 'Microsoft Xbox Series S 512GB Standard Console',
    url: 'https://www.xbox.com/en-GB/consoles/xbox-series-s', text: longText
  };
  const finding = fallbackPageCapture(gamingTask, source, 'Raw capture for ChatGPT review.');
  assert.equal(isGamingConsoleResearchTask(gamingTask), true);
  assert.equal(isCaptureOnlyResearchTask(gamingTask), true);
  assert.equal(finding.observed_price, null);
  assert.equal(finding.evidence_type, null);
  assert.equal(finding.review_classification, 'unverified_capture');
  assert.match(finding.product_identity_text, /Xbox Series S/);
  assert.match(finding.package_or_variant_text, /512GB|digital/i);
  assert.match(finding.item_condition_text, /Brand new/i);
  assert.match(finding.availability_text, /In stock/i);
  assert.equal(finding.source_excerpt, longText);
  assert.equal(finding.page_capture.captured_text, longText);
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
  for (const host of ['3dgbire.com','3dflo.com','bambu-lab-uk.myshopify.com','uk.anycubic3d.com','uk.elegoo.com','www.gumtree.com']) {
    assert.equal(isEligibleProductPage('https://'+host+'/products/creality-k1', 'Creality K1 3D Printer'), true, host);
  }
});

test('3D printer matching rejects sibling models, accessories and package mismatches', () => {
  const accessory = 'https://www.amazon.co.uk/Creality-Leveling-Extruder-Filament/dp/B0GD12KF2V?keywords=Creality+K1';
  assert.equal(matchesTaskModel('Creality Leveling Extruder Filament', accessory, task), false);
  assert.equal(matchesTaskModel('Creality K1 Speedy 3D Printer', 'https://store.creality.com/uk/products/k1-speedy-3d-printer?ref=search', task), true);
  assert.equal(matchesTaskModel('Creality K1 Max 3D Printer', 'https://store.creality.com/uk/products/k1-max', task), false);
  assert.equal(matchesTaskModel('Creality K1 Max Combo 8-Color Printer', 'https://store.creality.com/uk/products/k1-max-combo', task), false);

  assert.equal(matchesTaskModel('Creality K1 Printer Upgrade Kit', 'https://store.creality.com/uk/products/k1-upgrade-kit', task), false);
  assert.equal(matchesTaskModel('Creality K1 Build Plate', 'https://store.creality.com/uk/products/k1-build-plate', task), false);

  const comboTask = { ...task, package_key: 'combo-8-color', package_name: '8-Color Combo' };
  assert.equal(matchesTaskModel('Creality K1 Combo 8-Color 3D Printer', 'https://store.creality.com/uk/products/k1-combo-8-color', comboTask), true);
  assert.equal(matchesTaskModel('Creality K1 Speedy 3D Printer', 'https://store.creality.com/uk/products/k1-speedy-3d-printer', comboTask), false);

  const maxTask = { ...task, model: 'K1 Max' };
  const comboSlug = 'https://store.creality.com/uk/products/essential-combok1-max-hyper-pla-2';
  const comboTitle = 'K1 Max + PLA*2(White+Red)';
  // This exact captured page must be rejected for K1 Max Standard because the
  // concatenated URL slug contains a Combo package marker.
  assert.equal(matchesTaskModel(comboTitle, comboSlug, maxTask), false);
  // The same page remains eligible for the exact matching K1 Max Combo task.
  const maxComboTask = { ...maxTask, package_key: 'combo-2-pla', package_name: 'Combo with two PLA rolls' };
  assert.equal(matchesTaskModel(comboTitle, comboSlug, maxComboTask), true);
  assert.equal(matchesTaskModel('Creality K1 Max 3D Printer', 'https://store.creality.com/uk/products/k1-max', maxTask), true);
});

test('short 3D printer model IDs are disambiguated without losing generic printer listings', () => {
  const a1Task = { ...task, category_slug: '3d-printers-equipment', branch_slug: '3d-printers', manufacturer: 'Bambu Lab', model: 'A1' };
  assert.equal(
    matchesTaskModel('Used Audi A1 for Sale in Narberth', 'https://www.gumtree.com/cars-vans-motorbikes/cars/audi/a1/uk/narberth', a1Task),
    false
  );
  assert.equal(
    matchesTaskModel('Bambu Lab A1 Combo 3D Printer with AMS Lite', 'https://www.gumtree.com/p/printers-scanners/bambu-lab-a1-combo/1804662526', a1Task),
    false
  );
  const a1ComboTask = { ...a1Task, package_key: 'combo-ams-lite', package_name: 'Combo with AMS Lite' };
  assert.equal(
    matchesTaskModel('Bambu Lab A1 Combo 3D Printer with AMS Lite', 'https://www.gumtree.com/p/printers-scanners/bambu-lab-a1-combo/1804662526', a1ComboTask),
    true
  );
  assert.equal(
    matchesTaskModel('A1 3D Printer Used', 'https://www.gumtree.com/p/printers-scanners/a1-3d-printer/123', a1Task),
    true
  );
  const unrelatedCategory = { ...a1Task, category_slug: 'mobile-phones', branch_slug: 'mobile-phones' };
  assert.equal(matchesTaskModel('Audi A1', 'https://example.com/audi-a1', unrelatedCategory), true);
});

test('Amazon AAX sponsored redirects are unwrapped to the canonical ASIN product URL', () => {
  const wrapped = 'https://aax-eu-zaz.amazon.co.uk/x/c/token/https://www.amazon.co.uk/Creality-Leveling-Extruder-Filament/dp/B0GD12KF2V/ref=sxin?keywords=Creality+K1';
  assert.equal(decodeSearchRedirect(wrapped), 'https://www.amazon.co.uk/Creality-Leveling-Extruder-Filament/dp/B0GD12KF2V/ref=sxin');
});

test('Shopify collection API fallback is enabled only on sources that declare support', () => {
  assert.equal(getWebsiteInstructions(task.category_slug, '123-3d.co.uk').collectionApi, 'shopify');
  assert.equal(getWebsiteInstructions(task.category_slug, '3dgbire.com').collectionApi, 'shopify');
  assert.equal(getWebsiteInstructions(task.category_slug, 'store.creality.com').collectionApi, 'shopify');
  assert.equal(getWebsiteInstructions(task.category_slug, 'uni3dverse.co.uk').collectionApi, undefined);
});

test('Creality UK uses verified live printer collections and Shopify JSON to discover exact printer pages', () => {
  const printerTask = { ...task, manufacturer: 'Creality', model: 'Ender-3 V3 KE', research_type: 'uk_new' };
  const routes = buildWebsiteSearchRoutes({ domain: 'store.creality.com' }, printerTask);
  assert.ok(routes.includes('https://store.creality.com/uk/collections/fdm-3d-printer'));
  assert.ok(routes.includes('https://store.creality.com/uk/collections/ender-3-v3-series'));
  assert.equal(getWebsiteInstructions(task.category_slug, 'store.creality.com').collectionApi, 'shopify');

  const products = extractShopifyCollectionProducts({
    products: [
      { title: 'Ender-3 V3 KE 3D Printer', handle: 'ender-3-v3-ke-3d-printer' },
      { title: 'Ender-3 V3 SE 3D Printer', handle: 'ender-3-v3-se-3d-printer' },
      { title: 'Ender-3 V3 KE Upgrade Kit', handle: 'ender-3-v3-ke-upgrade-kit' }
    ]
  }, 'https://store.creality.com/uk/collections/fdm-3d-printer', printerTask, 24);

  assert.deepEqual(products.map(product => product.url), [
    'https://store.creality.com/uk/products/ender-3-v3-ke-3d-printer'
  ]);
  assert.equal(isEligibleProductPage(products[0].url, products[0].title), true);
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
  assert.match(prompt, /CAPTURE, DO NOT DECIDE/i);
  assert.match(prompt, /supplied JSON schema exactly/i);
  assert.match(prompt, /One compact finding per supplied source_id/i);
  assert.match(prompt, /Do not choose one page price/i);
  assert.match(prompt, /one price_observations entry for every visible GBP price/i);
  assert.match(prompt, /never infer association from proximity alone/i);
  assert.match(prompt, /S1/);
  assert.match(prompt, /8-Color Combo/);
  assert.doesNotMatch(prompt, /VERIFIED EVIDENCE:/i);
});

test('Gemma extraction uses a larger output budget without increasing the 4k context', () => {
  assert.equal(ollamaOptions({}).num_ctx, 4096);
  assert.equal(ollamaOptions({}).num_predict, 1024);
});


test('3D printer Gemma prompt returns findings-array observations for ChatGPT review', () => {
  const prompt = buildExtractionPrompt({
    ...task, branch_slug: '3d-printers', research_type: 'uk_both',
    package_name: '8-Color Combo'
  }, [
    { source_id: 'S1', title: 'Kobra S1 Max', url: 'https://uk.anycubic3d.com/products/kobra-s1-max', text: 'Kobra S1 Max £549.00 Combo 4 colours £749.00 8 colours £935.00' }
  ]);
  assert.match(prompt, /CAPTURE, DO NOT DECIDE/i);
  assert.match(prompt, /supplied JSON schema exactly/i);
  assert.match(prompt, /One compact finding per supplied source_id/i);
  assert.match(prompt, /price_observations/i);
  assert.match(prompt, /association/i);
  assert.match(prompt, /Do not calculate, convert or invent prices/i);
  assert.match(prompt, /S1/);
  assert.match(prompt, /8-Color Combo/);
  assert.doesNotMatch(prompt, /VERIFIED EVIDENCE:/i);
});

test('3D printer extraction uses two pages per Gemma call', () => {
  assert.equal(extractionBatchSizeForTask({ ...task, branch_slug: '3d-printers' }), 2);
  assert.equal(extractionBatchSizeForTask({ ...task, category_slug: 'mobile-phones', branch_slug: 'mobile-phones' }), 2);
});

test('3D printer deep-page excerpt includes price and offer details found below the opening text', () => {
  const longPage = 'Opening product description. '.repeat(100) +
    'Machine only £549.00. Kobra S1 Max Combo 8 colours £935.00. Condition: Refurbished - Grade A. Currently in stock for UK delivery.';
  const excerpt = buildDeepPageExcerpt(longPage, { manufacturer: 'Anycubic', model: 'Kobra S1 Max', package_name: '8-Color Combo' });
  assert.ok(excerpt.length <= 6200);
  assert.match(excerpt, /£549\.00/);
  assert.match(excerpt, /£935\.00/);
  assert.match(excerpt, /Refurbished - Grade A/);
  assert.match(excerpt, /Currently in stock/);
});

test('3D printer fallback preserves structured price, package, condition and availability observations', () => {
  const source = {
    source_id: 'S1',
    title: 'Creality K1 Speedy 3D Printer',
    url: 'https://store.creality.com/uk/products/k1-speedy-3d-printer',
    text: 'Creality K1 Speedy 3D Printer Standard Printer £299.00. Condition: New. Only 15 left in stock. UK VAT included.'
  };
  const finding = fallbackPageCapture({ ...task, research_type: 'uk_new' }, source, 'Ollama timeout');
  assert.equal(finding.observed_price, null);
  assert.equal(finding.price_currency, 'GBP');
  assert.match(finding.product_identity_text, /Creality K1 Speedy/);
  assert.match(finding.package_or_variant_text, /Standard Printer/);
  assert.match(finding.item_condition_text, /New/);
  assert.match(finding.availability_text, /Only 15 left in stock/);
  assert.match(finding.location_text, /UK VAT included/);
  assert.equal(finding.evidence_type, null);
  assert.equal(finding.review_classification, 'unverified_capture');
});

test('3D printer raw capture retains the complete fetched page beyond 10k characters', () => {
  const longText = 'Anycubic Kobra S1 Max Standard Printer £549.00. ' + 'SPECIFICATION '.repeat(1200);
  const source = {
    source_id: 'S5',
    title: 'Anycubic Kobra S1 Max',
    url: 'https://uk.anycubic3d.com/products/kobra-s1-max',
    text: longText
  };
  const finding = fallbackPageCapture({ ...task, manufacturer: 'Anycubic', model: 'Kobra S1 Max' }, source, 'Capture-only mode');
  assert.equal(finding.source_excerpt, longText);
  assert.equal(finding.page_capture.captured_text, longText);
  assert.ok(finding.page_capture.captured_text.length > 10000);
});

test('3D printer HTML text extraction supports a larger capture limit without changing the default', () => {
  const html = '<main>' + 'Anycubic Kobra S1 Max specification. '.repeat(500) + '</main>';
  const defaultText = extractRelevantPageText(html, { manufacturer: 'Anycubic', model: 'Kobra S1 Max' });
  const fullText = extractRelevantPageText(html, { manufacturer: 'Anycubic', model: 'Kobra S1 Max' }, { maxChars: 100000 });
  assert.equal(defaultText.length, 10000);
  assert.ok(fullText.length > 10000);
});

test('3D printer raw capture never promotes a single visible price before ChatGPT review', () => {
  const source = {
    source_id: 'S4',
    title: 'Anycubic Kobra S1 Max',
    url: 'https://uk.anycubic3d.com/products/kobra-s1-max',
    text: 'Anycubic Kobra S1 Max Standard Printer £549.00. VAT included. Ships in 24 hours.'
  };
  const finding = fallbackPageCapture({ ...task, manufacturer: 'Anycubic', model: 'Kobra S1 Max', research_type: 'uk_new' }, source, 'Capture-only mode');
  assert.equal(finding.observed_price, null);
  assert.equal(finding.evidence_type, null);
  assert.equal(finding.review_classification, 'unverified_capture');
  assert.equal(finding.page_capture.captured_text, source.text);
  assert.equal(finding.page_capture.gbp_price_mentions[0].amount, 549);
  assert.match(finding.page_capture.gbp_price_mentions[0].context, /Standard Printer/);
});

test('3D printer fallback does not promote a filament unit price to the printer price', () => {
  const source = {
    source_id: 'S3',
    title: 'Creality K1 Speedy 3D Printer',
    url: 'https://store.creality.com/uk/products/k1-speedy-3d-printer',
    text: 'Creality K1 Speedy 3D Printer. Compatible filament 1kg £17.99.'
  };
  const finding = fallbackPageCapture({ ...task, research_type: 'uk_new' }, source, 'Ollama timeout');
  assert.equal(finding.observed_price, null);
  assert.deepEqual(finding.price_mentions, ['£17.99']);
});

test('3D printer fallback preserves multiple package prices without guessing the printer price', () => {
  const source = {
    source_id: 'S2',
    title: 'Anycubic Kobra S1 Max',
    url: 'https://uk.anycubic3d.com/products/kobra-s1-max',
    text: 'Kobra S1 Max machine only £549.00; 4 colour Combo £749.00; 8 colour Combo £935.00'
  };
  const finding = fallbackPageCapture({ ...task, manufacturer: 'Anycubic', model: 'Kobra S1 Max', research_type: 'uk_new' }, source, 'Gemma JSON parse failure');
  assert.equal(finding.observed_price, null);
  assert.equal(finding.price_mentions.length, 3);
  assert.equal(finding.price_contexts.length, 3);
  assert.match(finding.package_or_variant_text, /Combo/);
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

test('GBP price extraction collapses adjacent split-decimal duplicates without dropping separate price contexts', () => {
  const amazonCapture = 'Printer £13.99 £ 13 . 99; accessory £16.99 £ 16 . 99; extruder £52.27 £ 52 . 27';
  const prices = extractVisibleGbpPriceMentions(amazonCapture);
  assert.deepEqual(prices.map(item => item.amount), [13.99, 16.99, 52.27]);
  assert.deepEqual(prices.map(item => item.display), ['£13.99', '£16.99', '£52.27']);

  const distinctProducts = extractVisibleGbpPriceMentions('Machine A £299.00. ' + 'A'.repeat(160) + ' Machine B £299.00.');
  assert.deepEqual(distinctProducts.map(item => item.amount), [299, 299]);
  assert.notEqual(distinctProducts[0].context, distinctProducts[1].context);
});

test('historical Anycubic Kobra S1 Max capture retains standard, crossed-out, saving and combo prices independently', () => {
  const capture = 'Anycubic Kobra S1 Max Regular price £549.00 Sale price £549.00 Regular price £849.00 Save £300.00 Kobra S1 Max £549.00 Kobra S1 Max Combo (4 Colors) £749.00 Kobra S1 Max Combo + ACE 2 Pro (8 Colors) £935.00 Kobra S1 Max Combo + ACE 2 Pro (16 Colors) £1,307.00';
  const prices = extractVisibleGbpPriceMentions(capture);
  assert.deepEqual(prices.map(item => item.amount), [549, 549, 849, 300, 549, 749, 935, 1307]);
  assert.match(prices[5].context, /Combo \(4 Colors\)/);
  assert.match(prices[6].context, /8 Colors/);
  assert.match(prices[7].context, /16 Colors/);
});

test('historical Amazon A1 Combo capture parses a split-decimal printer price once and keeps protection-plan prices separate', () => {
  const capture = '2-year product care £18.49; protection cover from £300 to £349.99; 3-year product care £25.49; Buy New £345.00 £ 345 . 00 FREE delivery';
  const prices = extractVisibleGbpPriceMentions(capture);
  assert.deepEqual(prices.map(item => item.amount), [18.49, 300, 349.99, 25.49, 345]);
  assert.equal(prices.at(-1).display, '£345.00');
  assert.match(prices.at(-1).context, /Buy New/);
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


test('3D printer extraction prompt stays bounded and includes deep-page price context plus recent guidance', () => {
  const notes = Array.from({ length: 12 }, (_, index) => ({
    type: 'learning_note',
    sender: 'test',
    title: 'note-' + index,
    body: 'NOTE-' + index + ' ' + 'N'.repeat(1800)
  }));
  const longPage = 'A'.repeat(5000) + ' Current listed price £999.00; Condition: New; only 4 left in stock.';
  const prompt = buildExtractionPrompt({
    ...task,
    branch_slug: '3d-printers',
    research_type: 'uk_new',
    common_room_context: notes
  }, [
    { source_id: 'S1', title: 'Printer page', url: 'https://www.3dprima.co.uk/printer', text: longPage }
  ]);

  assert.ok(prompt.length < 18000, 'bounded prompt length: ' + prompt.length);
  assert.match(prompt, /NOTE-11/);
  assert.doesNotMatch(prompt, /NOTE-0 /);
  assert.match(prompt, /£999\.00/);
  assert.match(prompt, /visible_gbp_price_context/);
  assert.match(prompt, /only 4 left in stock/i);
  assert.ok(!prompt.includes('A'.repeat(5000)));
});


test('duplicate enrichment appends unverified observations without changing top-level price or review state', () => {
  const sourceUrl = 'https://uk.anycubic3d.com/products/kobra-s1';
  const existing = {
    id: 'queue-1', status: 'needs_research', dedupe_key: 'capture-abc',
    category_slug: '3d-printers-equipment', branch_slug: '3d-printers',
    manufacturer: 'Anycubic', model: 'Kobra S1', package_key: 'standard',
    source_url: sourceUrl, observed_price: null, evidence_type: null,
    reviewed_at: null, reviewed_by: null, approved_at: null, imported_at: null,
    research_notes: 'Original raw capture retained.',
    raw_payload: { review_classification: 'unverified_capture', page_capture: { url: sourceUrl, title: 'Original capture', captured_text: 'Original page text' } }
  };
  const incoming = {
    ...existing, task_key: 'task-20261107', source_name: 'Anycubic UK',
    raw_payload: {
      review_classification: 'unverified_capture',
      evidence: {
        evidence_type: 'uk_new', observed_price: 319, price_currency: 'GBP',
        item_condition_text: 'New', availability_text: 'In stock',
        package_or_variant_text: 'Kobra S1 Standard Printer', product_identity_text: 'Anycubic Kobra S1',
        match_observation: 'Exact model title match', notes: 'Structured observation for ChatGPT review.',
        page_capture: { url: sourceUrl, title: 'Anycubic Kobra S1', captured_text: 'Latest page text with visible price £319.00', gbp_price_mentions: [{ amount: 319, display: '£319.00' }] }
      }
    }
  };
  const patch = buildCaptureEnrichmentPatch(existing, incoming, '2026-11-07T23:55:00.000Z');
  assert.ok(patch);
  assert.equal(patch.raw_payload.review_classification, 'unverified_capture');
  assert.equal(patch.raw_payload.enrichment_history.length, 1);
  assert.equal(patch.raw_payload.enrichment_history[0].task_key, 'task-20261107');
  assert.equal(patch.raw_payload.enrichment_history[0].gemma_observed_price, 319);
  assert.match(patch.raw_payload.enrichment_history[0].page_capture_excerpt.captured_text, /Latest page text/);
  assert.match(patch.research_notes, /unverified Gemma extraction/i);
  assert.equal(patch.updated_at, '2026-11-07T23:55:00.000Z');
  assert.equal('status' in patch, false);
  assert.equal('observed_price' in patch, false);
  assert.equal('evidence_type' in patch, false);
});

test('duplicate enrichment refuses reviewed, approved, imported and mismatched rows', () => {
  const existing = {
    status: 'needs_research', dedupe_key: 'capture-abc',
    category_slug: '3d-printers-equipment', branch_slug: '3d-printers',
    manufacturer: 'Anycubic', model: 'Kobra S1', package_key: 'standard',
    source_url: 'https://uk.anycubic3d.com/products/kobra-s1',
    reviewed_at: null, reviewed_by: null, approved_at: null, imported_at: null,
    raw_payload: { review_classification: 'unverified_capture' }
  };
  const incoming = {
    ...existing, task_key: 'task-20261107',
    raw_payload: { review_classification: 'unverified_capture', evidence: { evidence_type: 'uk_new', observed_price: 319, product_identity_text: 'Anycubic Kobra S1' } }
  };
  assert.equal(buildCaptureEnrichmentPatch({ ...existing, reviewed_at: '2026-11-07T22:00:00Z' }, incoming), null);
  assert.equal(buildCaptureEnrichmentPatch({ ...existing, reviewed_by: 'reviewer' }, incoming), null);
  assert.equal(buildCaptureEnrichmentPatch({ ...existing, approved_at: '2026-11-07T22:00:00Z' }, incoming), null);
  assert.equal(buildCaptureEnrichmentPatch({ ...existing, imported_at: '2026-11-07T22:00:00Z' }, incoming), null);
  assert.equal(buildCaptureEnrichmentPatch({ ...existing, status: 'approved' }, incoming), null);
  assert.equal(buildCaptureEnrichmentPatch({ ...existing, category_slug: 'mobile-phones' }, incoming), null);
  assert.equal(buildCaptureEnrichmentPatch({ ...existing, package_key: 'combo' }, incoming), null);
  assert.equal(buildCaptureEnrichmentPatch({ ...existing, source_url: 'https://example.com/other' }, incoming), null);
  const alreadyEnriched = { ...existing, raw_payload: { ...existing.raw_payload, enrichment_history: [{ task_key: 'task-20261107', source_url: existing.source_url }] } };
  assert.equal(buildCaptureEnrichmentPatch(alreadyEnriched, incoming), null);
});

test('duplicate enrichment selects only columns present in the LIVE review queue schema', async () => {
  const agentSource = await readFile(new URL('./agent.mjs', import.meta.url), 'utf8');
  const selectMatch = agentSource.match(/const existing = await db\(liveTarget, 'platform_catalogue_research_queue\?select=([^']+)/);
  assert.ok(selectMatch, 'review-queue duplicate lookup must declare its selected columns');
  const fields = selectMatch[1].split('&')[0].split(',');
  assert.deepEqual(fields, [
    'id','status','dedupe_key','category_slug','branch_slug','manufacturer','model',
    'package_key','source_url','reviewed_at','reviewed_by','approved_at','imported_at',
    'raw_payload','research_notes','updated_at'
  ]);
  assert.match(agentSource, /reviewed_at=is\.null&reviewed_by=is\.null&approved_at=is\.null&imported_at=is\.null/);
  assert.doesNotMatch(agentSource, /approved_by|imported_by/);
});
