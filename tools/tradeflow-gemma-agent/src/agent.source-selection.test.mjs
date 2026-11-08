import test from 'node:test';
import assert from 'node:assert/strict';
import { buildApprovedResearchSourcesPath } from './agent.mjs';

test('approved source query is restricted to the requested category and universal UK sources', () => {
  const path = buildApprovedResearchSourcesPath({ category_slug: 'gaming-consoles-accessories' });
  const params = new URLSearchParams(path.split('?')[1]);

  assert.equal(params.get('enabled'), 'eq.true');
  assert.equal(params.get('country_code'), 'eq.GB');
  assert.equal(params.get('category_slugs'), 'ov.{gaming-consoles-accessories,*}');
  assert.equal(params.get('order'), 'priority.asc');
});

test('each specialist category gets its own category filter', () => {
  for (const category of ['3d-printers-equipment', 'cameras', 'drones', 'gaming-consoles-accessories', 'laptops', 'metal-detectors', 'mobile-phones']) {
    const params = new URLSearchParams(buildApprovedResearchSourcesPath({ category_slug: category }).split('?')[1]);
    assert.equal(params.get('category_slugs'), 'ov.{' + category + ',*}');
  }
});

test('missing or malformed category fails closed', () => {
  assert.throws(() => buildApprovedResearchSourcesPath({}), /valid category_slug/);
  assert.throws(() => buildApprovedResearchSourcesPath({ category_slug: 'cameras,playstation' }), /valid category_slug/);
});
