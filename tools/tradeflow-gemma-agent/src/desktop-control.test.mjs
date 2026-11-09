import test from 'node:test';
import assert from 'node:assert/strict';
import { buildAgentClaimArgs, getDesktopAgentState, normalizeDesktopConfig } from './desktop-control.mjs';

const base = { schemaVersion: 1, serviceEnabled: true, autoStart: true, enabledAgentKeys: ['3d-printers-equipment', 'gaming-consoles-accessories'] };

test('desktop config rejects unknown keys and malformed config', () => {
  assert.throws(() => normalizeDesktopConfig(null), /JSON object/);
  assert.throws(() => normalizeDesktopConfig({ ...base, enabledAgentKeys: ['xbox'] }), /Unknown research agent/);
});

test('disabled service and empty selection never claim queued work', () => {
  assert.equal(buildAgentClaimArgs({ ...base, serviceEnabled: false }, 'pc-1'), null);
  assert.equal(buildAgentClaimArgs({ ...base, enabledAgentKeys: [] }, 'pc-1'), null);
});

test('claim scope includes canonical keys and legacy agent aliases only for enabled agents', () => {
  const args = buildAgentClaimArgs(base, 'pc-1', 600);
  assert.deepEqual(args.p_agent_keys, ['3d-printers-equipment', '3d-printers', 'gaming-consoles-accessories', 'gaming-consoles']);
  assert.equal(args.p_worker_id, 'pc-1');
  assert.equal(buildAgentClaimArgs({ ...base, enabledAgentKeys: ['cameras'] }, 'pc-1').p_agent_keys.includes('3d-printers'), false);
});

test('agent state distinguishes disabled, waiting, running and migration-required', () => {
  const config = { ...base, enabledAgentKeys: ['cameras'] };
  assert.equal(getDesktopAgentState('cameras', config, { state: 'waiting', activeAgentKeys: [] }), 'waiting');
  assert.equal(getDesktopAgentState('cameras', config, { state: 'processing', activeAgentKeys: ['cameras'] }), 'running');
  assert.equal(getDesktopAgentState('drones', config, {}), 'disabled');
  assert.equal(getDesktopAgentState('cameras', config, { state: 'requires_migration' }), 'requires-migration');
});
