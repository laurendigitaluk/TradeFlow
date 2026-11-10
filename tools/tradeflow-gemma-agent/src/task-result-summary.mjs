// Keep the queue task result small. Individual page captures and raw observations
// are already persisted in the review queue; copying them into the task result can
// exceed PostgREST's request parser limits for block-sized research tasks.
export function summarizeTaskOutput(result = {}) {
  const candidates = Array.isArray(result.candidates) ? result.candidates : [];
  const writes = Array.isArray(result.writes) ? result.writes : [];
  return {
    worker: result.worker ?? null,
    product: result.product ?? null,
    enqueue: result.enqueue === true,
    candidate_count: candidates.length,
    candidates: candidates.map(candidate => ({
      source_id: candidate.source_id ?? null,
      page_title: candidate.page_title ?? null,
      source_url: candidate.source_url ?? candidate.page_capture?.url ?? null,
      review_classification: candidate.review_classification ?? null,
      observed_price: candidate.observed_price ?? null,
      price_currency: candidate.price_currency ?? null
    })),
    writes: writes.map(write => ({
      id: write.id ?? null,
      status: write.status ?? null,
      dedupe_key: write.dedupe_key ?? null,
      environment: write.environment ?? null
    })),
    research_metrics: result.research_metrics ?? {},
    route_metrics: result.route_metrics ?? {},
    route_failures: Array.isArray(result.route_failures) ? result.route_failures.slice(0, 20) : []
  };
}

export function summarizeTaskResults(taskKey, outputs = []) {
  const rows = Array.isArray(outputs) ? outputs : [];
  return {
    task_key: taskKey,
    subtasks: rows.length,
    aggregate: summarizeTaskAggregate(rows),
    results: rows.map(summarizeTaskOutput)
  };
}

const RESEARCH_METRIC_KEYS = [
  'search_results',
  'discovered_product_pages',
  'inspected_product_pages',
  'fetched_price_pages',
  'captured_pages',
  'gemma_calls',
  'gemma_batch_failures',
  'gemma_extraction_ms',
  'product_page_fetch_attempts',
  'product_pages_fetched',
  'model_variant_prefilter_rejections',
  'model_variant_postfetch_rejections',
  'eligible_product_pages'
];

const ROUTE_METRIC_KEYS = [
  'approved_sources_probed',
  'approved_source_route_attempts',
  'approved_source_routes_found',
  'approved_source_routes_empty',
  'approved_source_route_errors',
  'pagination_errors',
  'product_page_fetch_errors',
  'collection_errors',
  'challenge_pages_skipped',
  'opposite_lane_sources_skipped',
  'pagination_pages_followed'
];

function numericValue(value) {
  const number = Number(value);
  return Number.isFinite(number) ? number : 0;
}

function sumMetric(rows, group, key) {
  return rows.reduce((total, row) => total + numericValue(row?.[group]?.[key]), 0);
}

// Parent-level reporting must aggregate every product subtask, not reuse the
// final product's metrics. Raw page bodies remain excluded from this summary.
export function summarizeTaskAggregate(outputs = []) {
  const rows = Array.isArray(outputs) ? outputs : [];
  const writes = rows.flatMap(row => Array.isArray(row?.writes) ? row.writes : []);
  const queued = writes.filter(write => write?.status === 'capture-queued-for-chatgpt-review').length;
  const enriched = writes.filter(write => write?.status === 'capture-enriched-for-chatgpt-review').length;
  const candidateCount = rows.reduce((total, row) => total + (
    Array.isArray(row?.candidates) ? row.candidates.length : numericValue(row?.candidate_count)
  ), 0);

  return {
    subtasks: rows.length,
    candidate_count: candidateCount,
    staged: queued + enriched,
    queued,
    enriched,
    research_metrics: Object.fromEntries(RESEARCH_METRIC_KEYS.map(key => [key, sumMetric(rows, 'research_metrics', key)])),
    route_metrics: Object.fromEntries(ROUTE_METRIC_KEYS.map(key => [key, sumMetric(rows, 'route_metrics', key)])),
    route_failures: rows.flatMap(row => Array.isArray(row?.route_failures) ? row.route_failures : []).slice(0, 40)
  };
}

export function buildSubtaskCompletionReport({
  identity,
  taskKey,
  queueTaskId,
  task = {},
  subtaskIndex,
  subtaskCount,
  candidateCount = 0,
  staged = 0,
  queued = 0,
  enriched = 0,
  researchMetrics = {},
  routeMetrics = {},
  routeFailures = []
}) {
  const product = [task.manufacturer, task.model, task.package_name || task.package_key].filter(Boolean).join(' ');
  return {
    ...identity,
    status: 'running',
    current_task: taskKey,
    event_type: 'progress',
    task_key: taskKey,
    message: 'Completed product subtask ' + subtaskIndex + ' of ' + subtaskCount +
      (product ? ': ' + product : '') + ': ' + candidateCount +
      ' page captures; ' + staged + ' staged for ChatGPT review (' + queued +
      ' new, ' + enriched + ' enriched).',
    tasks_completed_delta: 1,
    candidates_found_delta: candidateCount,
    evidence_queued_delta: queued,
    details: {
      queue_task_id: queueTaskId,
      stage: 'subtask_completed',
      subtask_index: subtaskIndex,
      subtask_count: subtaskCount,
      branch_slug: task.branch_slug ?? null,
      manufacturer: task.manufacturer ?? null,
      model: task.model ?? null,
      package_key: task.package_key ?? null,
      staged,
      queued,
      enriched,
      research_metrics: researchMetrics,
      route_metrics: routeMetrics,
      route_failures: routeFailures
    }
  };
}

export function buildParentCompletionReport({ identity, taskKey, queueTaskId, branchSlug, aggregate = {} }) {
  const research = aggregate.research_metrics || {};
  const routes = aggregate.route_metrics || {};
  const message = 'Completed parent task ' + taskKey + ': ' + (aggregate.subtasks ?? 0) +
    ' product subtasks; ' + (aggregate.candidate_count ?? 0) + ' page captures; ' +
    (aggregate.staged ?? 0) + ' staged for ChatGPT review (' + (aggregate.queued ?? 0) +
    ' new, ' + (aggregate.enriched ?? 0) + ' enriched). Search ' +
    (research.search_results ?? 0) + ' results, discovered ' +
    (research.discovered_product_pages ?? 0) + ' product pages, fetched ' +
    (research.inspected_product_pages ?? 0) + '; ' +
    (routes.approved_source_route_attempts ?? 0) + ' approved-source routes; Gemma ' +
    (research.gemma_calls ?? 0) + ' batches (' + (research.gemma_batch_failures ?? 0) + ' failed).';

  return {
    ...identity,
    status: 'idle',
    current_task: null,
    event_type: 'task_completed',
    task_key: taskKey,
    message,
    details: {
      queue_task_id: queueTaskId,
      mode: 'background-queue',
      branch_slug: branchSlug ?? null,
      subtask_count: aggregate.subtasks ?? 0,
      candidate_count: aggregate.candidate_count ?? 0,
      staged: aggregate.staged ?? 0,
      queued: aggregate.queued ?? 0,
      enriched: aggregate.enriched ?? 0,
      research_metrics: research,
      route_metrics: routes,
      route_failures: aggregate.route_failures ?? []
    }
  };
}
