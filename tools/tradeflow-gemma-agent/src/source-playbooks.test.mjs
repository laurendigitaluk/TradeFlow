import test from 'node:test';
import assert from 'node:assert/strict';
import { buildWebsiteSearchRoutes, getCategoryWebsitePlaybook, getWebsiteInstructions } from './source-playbooks.mjs';
import { decodeSearchRedirect, extractCollectionPaginationLinks, isCollectionDiscoveryPage, isEligibleProductPage, matchesTaskModel } from './agent.mjs';

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
    '<a rel="next" href="/collections/3d-printers?page=2">Next</a>',
    '<a href="https://outside.example/collections/3d-printers?page=3">Next</a>',
    '<a href="/collections/3d-printers?page=4">4</a>',
    '<a href="/products/creality-k1">Product</a>'
  ].join('');
  const links = extractCollectionPaginationLinks(html, 'https://store.creality.com/uk/collections/3d-printers', 3);
  assert.deepEqual(links, [
    'https://store.creality.com/collections/3d-printers?page=2',
    'https://store.creality.com/collections/3d-printers?page=4'
  ]);
});
