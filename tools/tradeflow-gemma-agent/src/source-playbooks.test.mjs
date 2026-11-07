import test from 'node:test';
import assert from 'node:assert/strict';
import { buildWebsiteSearchRoutes, getCategoryWebsitePlaybook, getWebsiteInstructions } from './source-playbooks.mjs';

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
