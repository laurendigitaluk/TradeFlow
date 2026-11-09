import test from 'node:test';
import assert from 'node:assert/strict';
import { normalizeIsolatedAgentConfig, assertTaskGroupBelongsToAgent } from './agent-isolation.mjs';

const resolve = task => ({ agent_key: task.agent_key || task.category_slug });

test('accepts exactly one enabled category agent', () => {
  const config = normalizeIsolatedAgentConfig({ schemaVersion: 1, serviceEnabled: true, autoStart: false, enabledAgentKeys: ['3d-printers-equipment'] });
  assert.equal(config.agentKey, '3d-printers-equipment');
  assert.equal(config.agentIdentity.agent_name, 'Gemma — 3D Printers & Equipment');
  assert.deepEqual(config.enabledAgentKeys, ['3d-printers-equipment']);
});

test('rejects a multi-agent shared worker configuration', () => {
  assert.throws(() => normalizeIsolatedAgentConfig({ schemaVersion: 1, serviceEnabled: true, enabledAgentKeys: ['3d-printers-equipment', 'gaming-consoles-accessories'] }), /exactly one/);
});

test('preserves the local stop switch and rejects unknown agents', () => {
  const stopped = normalizeIsolatedAgentConfig({ schemaVersion: 1, serviceEnabled: false, enabledAgentKeys: ['3d-printers-equipment'] });
  assert.equal(stopped.serviceEnabled, false);
  assert.throws(() => normalizeIsolatedAgentConfig({ schemaVersion: 1, serviceEnabled: true, enabledAgentKeys: ['unknown-category'] }), /Unknown research agent key/);
});

test('accepts homogeneous batches and rejects cross-category batches', () => {
  assert.equal(assertTaskGroupBelongsToAgent([{ category_slug: '3d-printers-equipment' }, { category_slug: '3d-printers-equipment' }], '3d-printers-equipment', resolve), true);
  assert.equal(assertTaskGroupBelongsToAgent([{ agent_key: '3d-printers' }], '3d-printers-equipment', resolve), true);
  assert.equal(assertTaskGroupBelongsToAgent([{ category_slug: '3d-printers-equipment' }, { category_slug: 'gaming-consoles-accessories' }], '3d-printers-equipment', resolve), false);
  assert.equal(assertTaskGroupBelongsToAgent([], '3d-printers-equipment', resolve), false);
});
