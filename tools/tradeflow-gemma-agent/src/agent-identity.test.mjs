import test from 'node:test';
import assert from 'node:assert/strict';
import { resolveAgentIdentity } from './agent-identity.mjs';

test('keeps the 3D Printers identity for an explicit 3D Printers category task', () => {
  assert.deepEqual(resolveAgentIdentity({
    agent_key: '3d-printers-equipment',
    category_slug: '3d-printers-equipment',
    branch_slug: '3d-printers'
  }), {
    agent_key: '3d-printers-equipment',
    agent_name: 'Gemma — 3d-printers-equipment',
    category: '3d-printers-equipment'
  });
});

test('does not attribute a lens task to the 3D Printers agent when its category is explicit', () => {
  assert.deepEqual(resolveAgentIdentity({
    agent_key: '3d-printers-equipment',
    category_slug: 'lenses',
    branch_slug: 'photography-lenses',
    manufacturer: 'Sigma',
    model: '105mm F2.8 DG DN Macro Art'
  }), {
    agent_key: 'lenses',
    agent_name: 'Gemma — lenses',
    category: 'lenses'
  });
});

test('preserves a correctly assigned non-3D category agent key', () => {
  assert.equal(resolveAgentIdentity({
    agent_key: 'lenses',
    category_slug: 'lenses',
    branch_slug: 'photography-lenses'
  }).agent_key, 'lenses');
});

test('does not rewrite other supplied agent keys when category differs', () => {
  assert.equal(resolveAgentIdentity({
    agent_key: 'specialist-research-agent',
    category_slug: 'lenses',
    branch_slug: 'photography-lenses'
  }).agent_key, 'specialist-research-agent');
});

test('falls back to the category when no agent key is supplied', () => {
  assert.equal(resolveAgentIdentity({
    category_slug: '3d-printers-equipment',
    branch_slug: '3d-printers'
  }).agent_key, '3d-printers-equipment');
});
