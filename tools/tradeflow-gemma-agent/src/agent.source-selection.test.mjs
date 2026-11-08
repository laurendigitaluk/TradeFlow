import test from 'node:test';
import assert from 'node:assert/strict';
import { buildApprovedResearchSourcesPath } from './agent.mjs';

test('approved source query is restricted to the requested category and universal sources', () => {
  const path = buildApprovedResearchSourcesPath({ category_slug: '3d-printers-equipment' });
  const params = new URLSearchParams(path.split('?')[1]);

  assert.equal(params.get('enabled'), 'eq.true');
  assert.equal(params.get('country_code'), 'eq.GB');
  assert.equal(params.get('category_slugs'), 'ov.{3d-printers-equipment,*}');
  assert.match(path, /order=priority\.asc/);
});

test('each specialist category receives its own source filter', () => {
  for (const category of ['cameras', 'drones', 'gaming-consoles-accessories', 'laptops', 'metal-detectors', 'mobile-phones']) {
    const params = new URLSearchParams(buildApprovedResearchSourcesPath({ category_slug: category }).split('?')[1]);
    assert.equal(params.get('category_slugs'), 'ov.{' + category + ',*}');
  }
});

test('invalid or missing category fails closed instead of loading the global registry', () => {
  assert.throws(() => buildApprovedResearchSourcesPath({}), /valid category_slug/);
  assert.throws(() => buildApprovedResearchSourcesPath({ category_slug: 'cameras,playstation' }), /valid category_slug/);
});
