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
  return {
    task_key: taskKey,
    subtasks: outputs.length,
    results: outputs.map(summarizeTaskOutput)
  };
}
