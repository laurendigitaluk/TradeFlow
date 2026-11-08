const THREE_D_PRINTER_AGENT_KEY = '3d-printers-equipment';

function normaliseKey(value, fallback = 'general-research') {
  return String(value || fallback).trim().toLowerCase().replace(/[^a-z0-9]+/g, '-');
}

export function resolveAgentIdentity(task = {}) {
  const categorySlug = String(task.category_slug || '').trim().toLowerCase();
  const categoryValue = task.category_slug || task.branch_slug || 'General research';
  const categoryKey = normaliseKey(task.category_slug || task.branch_slug || 'general-research');
  const suppliedKey = normaliseKey(task.agent_key, '');

  const key = suppliedKey === THREE_D_PRINTER_AGENT_KEY &&
    categorySlug &&
    categorySlug !== THREE_D_PRINTER_AGENT_KEY
    ? categoryKey
    : suppliedKey || categoryKey;

  return {
    agent_key: key,
    agent_name: 'Gemma — ' + (task.category_slug || task.branch_slug || 'Catalogue research'),
    category: categoryValue
  };
}
