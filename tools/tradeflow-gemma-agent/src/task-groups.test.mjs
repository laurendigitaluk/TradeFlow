import test from 'node:test';
import assert from 'node:assert/strict';
import { normaliseProductResearchTasks, getReviewQueueWriteCounts, is3dPrinterResearchBatch, summariseResearchBatch } from './task-groups.mjs';

test('returns no tasks for non-array input', () => {
  assert.deepEqual(normaliseProductResearchTasks(null), []);
  assert.deepEqual(normaliseProductResearchTasks({ manufacturer: 'Canon' }), []);
});

test('filters malformed entries and preserves valid product tasks', () => {
  const tasks = [
    null,
    'not a task',
    [],
    { category_slug: 'cameras', manufacturer: 'Canon', model: 'EOS R7', package_key: 'body', package_name: 'Body only', search_query: 'Canon EOS R7 UK new price', research_type: 'uk_new' }
  ];
  assert.equal(normaliseProductResearchTasks(tasks).length, 1);
  assert.deepEqual(normaliseProductResearchTasks([{ manufacturer: 'Canon', model: 'EOS R7', research_type: 'uk_new' }]), []);
});

test('deduplicates the same product research task', () => {
  const first = { category_slug: 'cameras', manufacturer: 'Canon', model: 'EOS R7', package_key: 'body', package_name: 'Body only', search_query: 'Canon EOS R7 UK new price', research_type: 'uk_new' };
  const duplicate = { ...first };
  assert.deepEqual(normaliseProductResearchTasks([first, duplicate]), [first]);
});

test('keeps distinct package, category, branch, agent and research-type tasks', () => {
  const base = { category_slug: 'cameras', branch_slug: 'mirrorless', agent_key: 'camera-agent', manufacturer: 'Canon', model: 'EOS R7', package_key: 'body', package_name: 'Body only', search_query: 'Canon EOS R7 UK new price', research_type: 'uk_new' };
  const variants = [
    base,
    { ...base, package_key: 'kit' },
    { ...base, category_slug: 'video' },
    { ...base, branch_slug: 'dslr' },
    { ...base, agent_key: 'other-agent' },
    { ...base, research_type: 'uk_used' }
  ];
  assert.equal(normaliseProductResearchTasks(variants).length, 6);
});


test('counts new and enriched review rows as staged without counting duplicate skips', () => {
  assert.deepEqual(getReviewQueueWriteCounts([
    { status: 'capture-queued-for-chatgpt-review' },
    { status: 'capture-enriched-for-chatgpt-review' },
    { status: 'capture-enriched-for-chatgpt-review' },
    { status: 'duplicate-skipped' },
    { status: 'capture-dry-run-ready' }
  ]), { queued: 1, enriched: 2, staged: 3 });
  assert.deepEqual(getReviewQueueWriteCounts(null), { queued: 0, enriched: 0, staged: 0 });
});


test('recognises only multi-subtask batches entirely scoped to the 3D Printers branch', () => {
  const printer = { category_slug: '3d-printers-equipment', branch_slug: '3d-printers' };
  assert.equal(is3dPrinterResearchBatch([printer, { ...printer, research_type: 'uk_used' }]), true);
  assert.equal(is3dPrinterResearchBatch([printer]), false);
  assert.equal(is3dPrinterResearchBatch([printer, { ...printer, branch_slug: '3d-printer-equipment-accessories' }]), false);
  assert.equal(is3dPrinterResearchBatch([printer, { ...printer, category_slug: 'lenses', branch_slug: 'photography-lenses' }]), false);
  assert.equal(is3dPrinterResearchBatch(null), false);
});

test('aggregates parent-batch metrics and review writes across subtasks', () => {
  const summary = summariseResearchBatch([
    {
      candidates: [{}, {}],
      writes: [
        { status: 'capture-queued-for-chatgpt-review' },
        { status: 'capture-enriched-for-chatgpt-review' }
      ],
      research_metrics: {
        search_results: 10, discovered_product_pages: 3, inspected_product_pages: 2,
        fetched_price_pages: 2, gemma_calls: 1, gemma_batch_failures: 0,
        eligible_urls: 3, captured_pages: 2, accepted_candidates: 1,
        borderline_candidates: 1, search_result_limit: 30, gemma_failure_details: []
      },
      route_metrics: {
        approved_source_route_attempts: 4, approved_source_routes_found: 2,
        approved_source_routes_empty: 1, approved_source_route_errors: 1,
        product_page_fetch_errors: 0
      },
      route_failures: [{ stage: 'approved_source_error', source: 'example.co.uk', message: 'HTTP 404' }]
    },
    {
      candidates: [{}],
      writes: [{ status: 'duplicate-skipped' }],
      research_metrics: {
        search_results: 5, discovered_product_pages: 2, inspected_product_pages: 1,
        fetched_price_pages: 0, gemma_calls: 2, gemma_batch_failures: 1,
        eligible_urls: 2, captured_pages: 1, accepted_candidates: 0,
        borderline_candidates: 1, search_result_limit: 30,
        gemma_failure_details: [{ error: 'timeout', source_ids: ['S2'] }]
      },
      route_metrics: {
        approved_source_route_attempts: 3, approved_source_routes_found: 1,
        approved_source_routes_empty: 1, approved_source_route_errors: 1,
        product_page_fetch_errors: 1
      },
      route_failures: []
    }
  ]);

  assert.equal(summary.subtasks, 2);
  assert.equal(summary.candidates, 3);
  assert.deepEqual({ queued: summary.queued, enriched: summary.enriched, staged: summary.staged },
    { queued: 1, enriched: 1, staged: 2 });
  assert.equal(summary.research_metrics.search_results, 15);
  assert.equal(summary.research_metrics.discovered_product_pages, 5);
  assert.equal(summary.research_metrics.inspected_product_pages, 3);
  assert.equal(summary.research_metrics.gemma_calls, 3);
  assert.equal(summary.research_metrics.gemma_batch_failures, 1);
  assert.equal(summary.research_metrics.search_result_limit, 30);
  assert.equal(summary.route_metrics.approved_source_route_attempts, 7);
  assert.equal(summary.route_metrics.approved_source_routes_found, 3);
  assert.equal(summary.route_metrics.approved_source_route_errors, 2);
  assert.equal(summary.route_metrics.product_page_fetch_errors, 1);
  assert.equal(summary.route_failures.length, 1);
  assert.equal(summary.gemma_failure_details.length, 1);
});
