const THREE_D_PRINTER_AGENT_KEY = '3d-printers-equipment';

function normaliseKey(value, fallback = 'general-research') {
  return String(value || fallback).trim().toLowerCase().replace(/[^a-z0-9]+/g, '-');
}

/**
 * Resolve the telemetry/Common Room identity for one research task.
 *
 * A task explicitly assigned to the 3D Printers agent must not be reported
 * under that agent when its category_slug explicitly identifies another
 * category. This narrow correction protects 3D-printer status counters and
 * Common Room history from malformed cross-category task metadata.
 *
 * Other supplied agent keys retain their existing behaviour.
 */
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
