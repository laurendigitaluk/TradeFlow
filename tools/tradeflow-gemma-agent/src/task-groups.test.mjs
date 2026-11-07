import test from 'node:test';
import assert from 'node:assert/strict';
import { normaliseProductResearchTasks } from './task-groups.mjs';

test('returns no tasks for non-array input', () => {
  assert.deepEqual(normaliseProductResearchTasks(null), []);
  assert.deepEqual(normaliseProductResearchTasks({ manufacturer: 'Canon' }), []);
});

test('filters malformed entries and preserves valid product tasks', () => {
  const tasks = [
    null,
    'not a task',
    [],
    { manufacturer: 'Canon', model: 'EOS R7', package_key: 'body', research_type: 'uk_new' }
  ];
  assert.equal(normaliseProductResearchTasks(tasks).length, 1);
});

test('deduplicates the same product research task', () => {
  const first = { category_slug: 'cameras', manufacturer: 'Canon', model: 'EOS R7', package_key: 'body', research_type: 'uk_new' };
  const duplicate = { ...first };
  assert.deepEqual(normaliseProductResearchTasks([first, duplicate]), [first]);
});

test('keeps distinct package, category, branch, agent and research-type tasks', () => {
  const base = { category_slug: 'cameras', branch_slug: 'mirrorless', agent_key: 'camera-agent', manufacturer: 'Canon', model: 'EOS R7', package_key: 'body', research_type: 'uk_new' };
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
