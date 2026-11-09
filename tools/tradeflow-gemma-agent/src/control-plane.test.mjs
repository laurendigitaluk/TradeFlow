import test from 'node:test';
import assert from 'node:assert/strict';
import { resolveControlPlane } from './control-plane.mjs';

const env = {
  TRADEFLOW_TEST_URL: 'https://nnsshnfkjcflucjrftzi.supabase.co',
  TRADEFLOW_TEST_SERVICE_ROLE_KEY: 'test-secret',
  TRADEFLOW_LIVE_URL: 'https://gxsrajtqzdjvmceqcpgv.supabase.co',
  TRADEFLOW_LIVE_SERVICE_ROLE_KEY: 'live-secret'
};

test('Gemma worker defaults to the approved LIVE control plane', () => {
  assert.equal(resolveControlPlane(env).name, 'LIVE');
  assert.equal(resolveControlPlane(env).url, env.TRADEFLOW_LIVE_URL);
  assert.equal(resolveControlPlane(env).key, 'live-secret');
});

test('Gemma worker selects TEST only after an explicit TEST setting', () => {
  assert.equal(resolveControlPlane({ ...env, TRADEFLOW_GEMMA_ENVIRONMENT: 'TEST' }).name, 'TEST');
});

test('Gemma worker rejects unknown or unsafe environment names', () => {
  assert.throws(() => resolveControlPlane({ ...env, TRADEFLOW_GEMMA_ENVIRONMENT: 'production' }), /must be TEST or LIVE/);
});

test('Gemma worker rejects a URL that does not match the selected project', () => {
  assert.throws(() => resolveControlPlane({ ...env, TRADEFLOW_TEST_URL: env.TRADEFLOW_LIVE_URL }), /does not match the approved TradeFlow TEST project/);
});

test('Gemma worker refuses to start when selected environment credentials are missing', () => {
  assert.throws(() => resolveControlPlane({}), /TRADEFLOW_LIVE_URL and service-role key are required/);
});
