import test from 'node:test';
import assert from 'node:assert/strict';
import { buildExtractionPrompt, extractionBatchSizeForTask, probeApprovedResearchSources, filterBlockedSourceResults } from './agent.mjs';

const printerTask = {
  category_slug: '3d-printers-equipment',
  branch_slug: '3d-printers',
  research_type: 'uk_both',
  manufacturer: 'Bambu Lab',
  model: 'A1',
  package_key: 'standard',
  package_name: 'Standard Printer',
  search_query: 'Bambu Lab A1 3D printer UK'
};

test('3D printer extraction batches two pages while other categories retain two-page batches', () => {
  assert.equal(extractionBatchSizeForTask(printerTask), 2);
  assert.equal(extractionBatchSizeForTask({ ...printerTask, category_slug: 'drones', branch_slug: 'drones' }), 2);
});

test('3D printer extraction prompt requests one findings-array row for every supplied page', () => {
  const prompt = buildExtractionPrompt(printerTask, [
    {
      source_id: 'S1',
      title: 'Bambu Lab A1 3D Printer',
      url: 'https://example.co.uk/products/bambu-a1',
      text: 'Bambu Lab A1 3D Printer. Standard printer £289.00. In stock. New.'
    },
    {
      source_id: 'S2',
      title: 'Bambu Lab A1 Combo',
      url: 'https://example.co.uk/products/bambu-a1-combo',
      text: 'Bambu Lab A1 Combo. Printer with AMS Lite £399.00. In stock. New.'
    }
  ]);

  assert.match(prompt, /one top-level findings array/i);
  assert.match(prompt, /exactly one compact finding for every supplied source_id/i);
  assert.match(prompt, /"source_id":"S1"/);
  assert.match(prompt, /"source_id":"S2"/);
  assert.match(prompt, /Bambu Lab A1 3D Printer/);
  assert.match(prompt, /Bambu Lab A1 Combo/);
});

test('two-page 3D prompt keeps both pages within the reduced per-page excerpt budget', () => {
  const longText = 'Bambu Lab A1 printer £289.00 in stock new. '.repeat(300);
  const prompt = buildExtractionPrompt(printerTask, [
    { source_id: 'S1', title: 'Bambu Lab A1', url: 'https://example.co.uk/a1', text: longText },
    { source_id: 'S2', title: 'Bambu Lab A1 Combo', url: 'https://example.co.uk/a1-combo', text: longText }
  ]);
  // Both page payloads are present; the full page remains stored outside this prompt.
  assert.match(prompt, /"source_id":"S1"/);
  assert.match(prompt, /"source_id":"S2"/);
  assert.ok(prompt.length < 18000, 'two-page prompt should remain compact for the 4k context');
});


const ebaySource = {
  source_name: 'eBay UK',
  domain: 'ebay.co.uk',
  source_kind: 'marketplace',
  country_code: 'GB',
  research_scope: 'used_uk',
  enabled: true,
  priority: 40,
  category_slugs: ['*'],
  search_url_template: null
};

test('3D printer queue batch blocks eBay after the first HTTP 403 and skips it for later product subtasks', async () => {
  const originalFetch = globalThis.fetch;
  const calls = [];
  globalThis.fetch = async url => {
    calls.push(String(url));
    return new Response('', { status: 403 });
  };
  const blocked = new Set();
  const events = [];
  const products = ['A1', 'K1 Max', 'Kobra S1 Max', 'Neptune 4 Pro', 'K1 Max Combo', 'Kobra S1 Max Combo'];
  try {
    for (const model of products) {
      await probeApprovedResearchSources(
        { ...printerTask, model },
        {},
        event => events.push(event),
        [ebaySource],
        blocked
      );
    }
    assert.deepEqual([...blocked], ['ebay.co.uk']);
    assert.equal(calls.length, 1, 'only the first eBay route should be requested for the whole six-product queue batch');
    assert.equal(events.filter(event => event.stage === 'approved_source_route_attempt').length, 1);
    assert.equal(events.find(event => event.stage === 'approved_source_domain_blocked')?.skipped_routes, 2);
    assert.equal(
      events.filter(event => event.stage === 'approved_source_domain_skipped')
        .reduce((sum, event) => sum + event.skipped_routes, 0),
      15
    );
    const nextQueueBatch = new Set();
    await probeApprovedResearchSources(printerTask, {}, event => events.push(event), [ebaySource], nextQueueBatch);
    assert.equal(calls.length, 2, 'a new queue batch starts with a fresh source-block set');
    assert.ok(nextQueueBatch.has('ebay.co.uk'));
  } finally {
    globalThis.fetch = originalFetch;
  }
});

test('3D printer HTTP 403 block is scoped to the 3D printer branch; other categories retain existing route behaviour', async () => {
  const originalFetch = globalThis.fetch;
  const calls = [];
  globalThis.fetch = async url => {
    calls.push(String(url));
    return new Response('', { status: 403 });
  };
  const blocked = new Set();
  const events = [];
  try {
    await probeApprovedResearchSources(
      { ...printerTask, category_slug: 'drones', branch_slug: 'drones', manufacturer: 'DJI', model: 'Mini 5 Pro' },
      {},
      event => events.push(event),
      [ebaySource],
      blocked
    );
    assert.equal(calls.length, 2, 'non-3D source routes should continue using the existing parallel route behaviour');
    assert.equal(blocked.size, 0, 'non-3D tasks must not populate the 3D-only block set');
    assert.equal(events.some(event => event.stage === 'approved_source_domain_blocked'), false);
  } finally {
    globalThis.fetch = originalFetch;
  }
});

test('3D printer route HTTP 404 does not block the domain or suppress remaining routes', async () => {
  const originalFetch = globalThis.fetch;
  const calls = [];
  globalThis.fetch = async url => {
    calls.push(String(url));
    return new Response('', { status: 404 });
  };
  const blocked = new Set();
  try {
    await probeApprovedResearchSources(printerTask, {}, () => {}, [ebaySource], blocked);
    assert.equal(calls.length, 3, '404 on one route must not suppress other configured routes');
    assert.equal(blocked.size, 0, 'only HTTP 403 creates a batch-scoped block');
  } finally {
    globalThis.fetch = originalFetch;
  }
});

test('blocked 3D printer hosts are removed from search/seed results before page fetching only for the 3D branch', () => {
  const results = [
    { title: 'Used Bambu A1', url: 'https://www.ebay.co.uk/itm/123' },
    { title: 'Used Bambu A1', url: 'https://www.gumtree.com/p/printers-scanners/123' }
  ];
  const events = [];
  const blocked = new Set(['ebay.co.uk']);
  const filtered = filterBlockedSourceResults(results, printerTask, blocked, event => events.push(event));
  assert.deepEqual(filtered, [results[1]]);
  assert.equal(events.filter(event => event.stage === 'blocked_source_result_skipped').length, 1);
  assert.deepEqual(
    filterBlockedSourceResults(results, { ...printerTask, category_slug: 'drones', branch_slug: 'drones' }, blocked),
    results
  );
});
