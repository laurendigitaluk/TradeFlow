// Queue payloads are product-level tasks. Preserve distinct manufacturer/model/package,
// category, branch, agent and research-type combinations while dropping malformed
// entries and accidental duplicate definitions in a single claim.
export function normaliseProductResearchTasks(tasks) {
  if (!Array.isArray(tasks)) return [];
  const seen = new Set();
  return tasks.filter(task => {
    if (!task || typeof task !== 'object' || Array.isArray(task)) return false;
    const required = ['category_slug', 'manufacturer', 'model', 'package_key', 'package_name', 'search_query'];
    if (required.some(field => !String(task[field] || '').trim())) return false;
    if (!['uk_new', 'uk_used', 'uk_both'].includes(task.research_type)) return false;
    const key = [
      task.category_slug || '',
      task.branch_slug || '',
      task.agent_key || '',
      task.manufacturer || '',
      task.model || '',
      task.package_key || '',
      task.research_type || ''
    ].map(value => String(value).trim().toLowerCase()).join('|');
    if (seen.has(key)) return false;
    seen.add(key);
    return true;
  });
}


export function getReviewQueueWriteCounts(writes) {
  const rows = Array.isArray(writes) ? writes : [];
  const queued = rows.filter(item => item?.status === 'capture-queued-for-chatgpt-review').length;
  const enriched = rows.filter(item => item?.status === 'capture-enriched-for-chatgpt-review').length;
  return { queued, enriched, staged: queued + enriched };
}


const RESEARCH_METRIC_SUM_FIELDS = [
  'search_results','discovered_product_pages','inspected_product_pages','fetched_price_pages',
  'gemma_calls','gemma_batch_failures','eligible_urls','captured_pages','accepted_candidates','borderline_candidates'
];
const ROUTE_METRIC_SUM_FIELDS = [
  'collection_errors','pagination_errors','approved_sources_probed','challenge_pages_skipped',
  'pagination_pages_followed','product_page_fetch_errors','approved_source_route_errors',
  'approved_source_routes_empty','approved_source_routes_found','opposite_lane_sources_skipped',
  'approved_source_route_attempts'
];

export function is3dPrinterResearchBatch(tasks) {
  return Array.isArray(tasks) && tasks.length > 1 && tasks.every(task =>
    String(task?.category_slug || '').toLowerCase() === '3d-printers-equipment' &&
    String(task?.branch_slug || '').toLowerCase() === '3d-printers'
  );
}

function sumResultMetric(rows, objectKey, field) {
  return rows.reduce((total, row) => {
    const value = Number(row?.[objectKey]?.[field] ?? 0);
    return total + (Number.isFinite(value) ? value : 0);
  }, 0);
}

export function summariseResearchBatch(results) {
  const rows = Array.isArray(results) ? results : [];
  const writes = rows.flatMap(row => Array.isArray(row?.writes) ? row.writes : []);
  const writeCounts = getReviewQueueWriteCounts(writes);
  const researchMetrics = Object.fromEntries(RESEARCH_METRIC_SUM_FIELDS.map(field =>
    [field, sumResultMetric(rows, 'research_metrics', field)]
  ));
  researchMetrics.search_result_limit = rows.reduce((maximum, row) =>
    Math.max(maximum, Number(row?.research_metrics?.search_result_limit) || 0), 0
  );
  const routeMetrics = Object.fromEntries(ROUTE_METRIC_SUM_FIELDS.map(field =>
    [field, sumResultMetric(rows, 'route_metrics', field)]
  ));
  return {
    subtasks: rows.length,
    candidates: rows.reduce((total, row) => total + (Array.isArray(row?.candidates) ? row.candidates.length : 0), 0),
    ...writeCounts,
    research_metrics: researchMetrics,
    route_metrics: routeMetrics,
    route_failures: rows.flatMap(row => Array.isArray(row?.route_failures) ? row.route_failures : []),
    gemma_failure_details: rows.flatMap(row =>
      Array.isArray(row?.research_metrics?.gemma_failure_details) ? row.research_metrics.gemma_failure_details : []
    )
  };
}
