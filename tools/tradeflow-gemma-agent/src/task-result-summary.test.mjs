import test from 'node:test';
import assert from 'node:assert/strict';
import { summarizeTaskOutput, summarizeTaskResults } from './task-result-summary.mjs';

test('task summary keeps useful evidence references and metrics but excludes raw page captures', () => {
  const raw = {
    worker: 'uk_both',
    product: 'Printer A',
    enqueue: true,
    candidates: [{
      source_id: 'S1',
      page_title: 'Printer A',
      source_url: 'https://example.co.uk/products/printer-a',
      review_classification: 'unverified_capture',
      observed_price: 399,
      price_currency: 'GBP',
      source_excerpt: 'x'.repeat(100000),
      page_capture: { url: 'https://example.co.uk/products/printer-a', captured_text: 'x'.repeat(100000) }
    }],
    writes: [{ id: 'capture-1', status: 'capture-queued-for-chatgpt-review', dedupe_key: 'd1', environment: 'LIVE_REVIEW_QUEUE', full_payload: 'x'.repeat(100000) }],
    research_metrics: { inspected_product_pages: 1, captured_pages: 1 },
    route_metrics: { approved_source_route_attempts: 5 },
    route_failures: [{ stage: 'fetch', source: 'example.co.uk', message: 'blocked' }]
  };
  const summary = summarizeTaskOutput(raw);
  assert.equal(summary.candidate_count, 1);
  assert.equal(summary.candidates[0].source_url, 'https://example.co.uk/products/printer-a');
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
