// Collapse paired UK-new and UK-used jobs into one product-level research task.
// Gemma classifies each source as new or used during the single extraction pass.
export function combineProductResearchTasks(tasks) {
  const groups = new Map();
  for (const task of tasks || []) {
    const key = [task.category_slug, task.branch_slug || '', task.manufacturer, task.model, task.package_key, task.package_name].join('|').toLowerCase();
    if (!groups.has(key)) groups.set(key, { ...task });
  }
  return [...groups.values()].map(task => ({
    ...task,
    research_type: 'uk_both',
    search_query: [task.manufacturer, task.model, task.package_name, 'UK new used price GBP'].filter(Boolean).join(' ')
  }));
}
