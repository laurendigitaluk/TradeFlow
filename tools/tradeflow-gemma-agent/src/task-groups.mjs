// Queue payloads are product-level tasks. Preserve distinct manufacturer/model/package,
// category, branch, agent and research-type combinations while dropping malformed
// entries and accidental duplicate definitions in a single claim.
export function normaliseProductResearchTasks(tasks) {
  if (!Array.isArray(tasks)) return [];
  const seen = new Set();
  return tasks.filter(task => {
    if (!task || typeof task !== 'object' || Array.isArray(task)) return false;
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
