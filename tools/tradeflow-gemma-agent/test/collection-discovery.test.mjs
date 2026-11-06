import test from 'node:test';
import assert from 'node:assert/strict';
import {
  isCollectionDiscoveryPage,
  isEligibleProductPage,
  extractCollectionProductLinks
} from '../src/agent.mjs';
import { combineProductResearchTasks } from '../src/task-groups.mjs';

const collectionUrl = 'https://store.creality.com/uk/collections/k1-series-3d-printer';

test('collection routes are discovery pages, not direct evidence pages', () => {
  assert.equal(isCollectionDiscoveryPage(collectionUrl), true);
  assert.equal(isEligibleProductPage(collectionUrl), false);
});

test('collection discovery follows exact base-model links and excludes other variants', () => {
  const html = [
    '<a href="/uk/products/k1-3d-printer">Creality K1 3D Printer</a>',
    '<a href="/uk/products/k1-max-3d-printer">Creality K1 Max 3D Printer</a>',
    '<a href="/uk/products/k1c-3d-printer">Creality K1C 3D Printer</a>',
    '<a href="/uk/products/k1-combo">Creality K1 Combo</a>',
    '<a href="/uk/products/endless">Ender 3 V3</a>'
  ].join('');
  const rows = extractCollectionProductLinks(html, collectionUrl, { manufacturer: 'Creality', model: 'K1' });
  assert.deepEqual(rows.map(row => row.url), ['https://store.creality.com/uk/products/k1-3d-printer']);
});

test('paired research task searches real product identity, not internal package label', () => {
  const [task] = combineProductResearchTasks([{
    category_slug: '3d-printers',
    manufacturer: 'Creality',
    model: 'K1',
    package_key: 'standard',
    package_name: 'Standard Printer'
  }]);
  assert.equal(task.search_query, 'Creality K1 UK price retailer product');
  assert.equal(task.research_type, 'uk_both');
});
