import test from 'node:test';
import assert from 'node:assert/strict';
import {
  summarizeTaskOutput,
  summarizeTaskResults,
  summarizeTaskAggregate,
  buildSubtaskCompletionReport,
  buildParentCompletionReport
} from './task-result-summary.mjs';

test('task summary keeps useful evidence references and metrics but excludes raw page captures', () => {
  const raw = {
    worker: 'uk_both',
    product: 'Anycubic Kobra S1 / Standard Printer',
    enqueue: true,
    candidates: [{
      source_id: 'S1',
      page_title: 'Kobra S1',
      source_url: 'https://example.co.uk/products/kobra-s1',
      review_classification: 'unverified_capture',
      observed_price: 399,
      price_currency: 'GBP',
      source_excerpt: 'x'.repeat(100000),
      page_capture: { url: 'https://example.co.uk/products/kobra-s1', captured_text: 'x'.repeat(100000) }
    }],
    writes: [{ id: 'capture-1', status: 'capture-queued-for-chatgpt-review', dedupe_key: 'd1', environment: 'LIVE_REVIEW_QUEUE', full_payload: 'x'.repeat(100000) }],
    research_metrics: { inspected_product_pages: 1, captured_pages: 1 },
    route_metrics: { approved_source_route_attempts: 5 },
    route_failures: [{ stage: 'fetch', source: 'example.co.uk', message: 'blocked' }]
  };
  const summary = summarizeTaskOutput(raw);
  assert.equal(summary.candidate_count, 1);
  assert.equal(summary.candidates[0].source_url, 'https://example.co.uk/products/kobra-s1');
  assert.equal(summary.candidates[0].observed_price, 399);
  assert.equal(summary.writes[0].id, 'capture-1');
  assert.equal(summary.research_metrics.captured_pages, 1);
  assert.equal(summary.route_metrics.approved_source_route_attempts, 5);
  assert.equal('page_capture' in summary.candidates[0], false);
  assert.equal('source_excerpt' in summary.candidates[0], false);
  assert.ok(JSON.stringify(summary).length < 5000);
});

test('task result summary preserves subtask count and compact results', () => {
  const result = summarizeTaskResults('batch-1', [{ product: 'Printer A', candidates: [] }, { product: 'Printer B', candidates: [] }]);
  assert.equal(result.task_key, 'batch-1');
  assert.equal(result.subtasks, 2);
  assert.equal(result.results.length, 2);
});

test('parent aggregate totals every product subtask rather than reporting only the last product', () => {
  const makeSubtask = ({ product, candidates, writes, search, discovered, inspected, captured, gemmaCalls, gemmaFailures, attempts, found, empty, errors }) => ({
    product,
    candidates: Array.from({ length: candidates }, (_, index) => ({ source_id: product + '-' + index })),
    writes: writes.map(status => ({ status })),
    research_metrics: {
      search_results: search,
      discovered_product_pages: discovered,
      inspected_product_pages: inspected,
      captured_pages: captured,
      gemma_calls: gemmaCalls,
      gemma_batch_failures: gemmaFailures
    },
    route_metrics: {
      approved_source_route_attempts: attempts,
      approved_source_routes_found: found,
      approved_source_routes_empty: empty,
      approved_source_route_errors: errors
    }
  });

  const outputs = [
    makeSubtask({ product: 'Kobra 3 Max V2 Combo', candidates: 2, writes: ['capture-enriched-for-chatgpt-review', 'capture-enriched-for-chatgpt-review'], search: 15, discovered: 4, inspected: 2, captured: 2, gemmaCalls: 1, gemmaFailures: 1, attempts: 16, found: 1, empty: 14, errors: 1 }),
    makeSubtask({ product: 'Kobra 3 Max V2 Standard', candidates: 1, writes: ['capture-queued-for-chatgpt-review'], search: 22, discovered: 2, inspected: 1, captured: 1, gemmaCalls: 1, gemmaFailures: 1, attempts: 16, found: 9, empty: 6, errors: 1 }),
    makeSubtask({ product: 'Kobra 4 Standard', candidates: 1, writes: ['capture-enriched-for-chatgpt-review'], search: 9, discovered: 2, inspected: 1, captured: 1, gemmaCalls: 1, gemmaFailures: 1, attempts: 15, found: 8, empty: 3, errors: 4 }),
    makeSubtask({ product: 'Kobra 4 ACE 2 Pro Combo', candidates: 0, writes: [], search: 0, discovered: 0, inspected: 0, captured: 0, gemmaCalls: 0, gemmaFailures: 0, attempts: 15, found: 0, empty: 14, errors: 1 }),
    makeSubtask({ product: 'Kobra S1 ACE 2 Pro Combo', candidates: 2, writes: ['capture-queued-for-chatgpt-review', 'capture-queued-for-chatgpt-review'], search: 2, discovered: 2, inspected: 2, captured: 2, gemmaCalls: 1, gemmaFailures: 1, attempts: 16, found: 2, empty: 13, errors: 1 })
  ];

  const aggregate = summarizeTaskAggregate(outputs);
  assert.equal(aggregate.subtasks, 5);
  assert.equal(aggregate.candidate_count, 6);
  assert.equal(aggregate.staged, 6);
  assert.equal(aggregate.queued, 3);
  assert.equal(aggregate.enriched, 3);
  assert.equal(aggregate.research_metrics.search_results, 48);
  assert.equal(aggregate.research_metrics.discovered_product_pages, 10);
  assert.equal(aggregate.research_metrics.inspected_product_pages, 6);
  assert.equal(aggregate.research_metrics.captured_pages, 6);
  assert.equal(aggregate.research_metrics.gemma_calls, 4);
  assert.equal(aggregate.research_metrics.gemma_batch_failures, 4);
  assert.equal(aggregate.route_metrics.approved_source_route_attempts, 78);
  assert.equal(aggregate.route_metrics.approved_source_routes_found, 20);
  assert.equal(aggregate.route_metrics.approved_source_routes_empty, 50);
  assert.equal(aggregate.route_metrics.approved_source_route_errors, 8);
});

test('subtask completion keeps the parent running; parent completion is emitted separately', () => {
  const identity = { agent_key: '3d-printers-equipment', agent_name: 'Gemma 3D Printers', category: '3d-printers-equipment' };
  const subtask = buildSubtaskCompletionReport({
    identity,
    taskKey: 'batch-1',
    queueTaskId: 'queue-1',
    task: { manufacturer: 'Anycubic', model: 'Kobra 4', package_key: 'standard', branch_slug: '3d-printers' },
    subtaskIndex: 1,
    subtaskCount: 5,
    candidateCount: 2,
    staged: 2,
    queued: 1,
    enriched: 1
  });
  assert.equal(subtask.event_type, 'progress');
  assert.equal(subtask.status, 'running');
  assert.equal(subtask.current_task, 'batch-1');
  assert.equal(subtask.details.stage, 'subtask_completed');
  assert.equal(subtask.tasks_completed_delta, 1);
  assert.equal(subtask.candidates_found_delta, 2);
  assert.equal(subtask.evidence_queued_delta, 1);

  const parent = buildParentCompletionReport({
    identity,
    taskKey: 'batch-1',
    queueTaskId: 'queue-1',
    branchSlug: '3d-printers',
    aggregate: { subtasks: 5, candidate_count: 6, staged: 6, queued: 3, enriched: 3, research_metrics: { search_results: 48, discovered_product_pages: 10, inspected_product_pages: 6, gemma_calls: 4, gemma_batch_failures: 4 }, route_metrics: { approved_source_route_attempts: 78 } }
  });
  assert.equal(parent.event_type, 'task_completed');
  assert.equal(parent.status, 'idle');
  assert.equal(parent.current_task, null);
  assert.equal(parent.details.subtask_count, 5);
  assert.match(parent.message, /48 results, discovered 10 product pages, fetched 6/);
  assert.equal(parent.tasks_completed_delta, undefined);
  assert.equal(parent.candidates_found_delta, undefined);
  assert.equal(parent.evidence_queued_delta, undefined);
});

test('compact parent result includes aggregate totals while retaining compact per-product records', () => {
  const outputs = [
    { product: 'Printer A', candidates: [{ source_id: 'A1' }], writes: [{ status: 'capture-queued-for-chatgpt-review' }], research_metrics: { search_results: 4 } },
    { product: 'Printer B', candidates: [{ source_id: 'B1' }, { source_id: 'B2' }], writes: [{ status: 'capture-enriched-for-chatgpt-review' }], research_metrics: { search_results: 6 } }
  ];
  const result = summarizeTaskResults('batch-2', outputs);
  assert.equal(result.subtasks, 2);
  assert.equal(result.aggregate.candidate_count, 3);
  assert.equal(result.aggregate.staged, 2);
  assert.equal(result.aggregate.queued, 1);
  assert.equal(result.aggregate.enriched, 1);
  assert.equal(result.aggregate.research_metrics.search_results, 10);
  assert.equal(result.results.length, 2);
});
