import test from 'node:test';
import assert from 'node:assert/strict';
import {
  buildIdleWorkerHeartbeatRecord,
  idleHeartbeatIntervalMs,
  shouldEmitIdleWorkerHeartbeat
} from './worker-heartbeat.mjs';

test('idle heartbeat is rate-limited to at least one minute and bounded to five minutes', () => {
  assert.equal(idleHeartbeatIntervalMs(5000), 60000);
  assert.equal(idleHeartbeatIntervalMs(15000), 60000);
  assert.equal(idleHeartbeatIntervalMs(30000), 120000);
  assert.equal(idleHeartbeatIntervalMs(60000), 240000);
  assert.equal(idleHeartbeatIntervalMs(180000), 300000);
});

test('invalid poll intervals use the safe default cadence', () => {
  assert.equal(idleHeartbeatIntervalMs(undefined), 60000);
  assert.equal(idleHeartbeatIntervalMs('not-a-number'), 60000);
  assert.equal(idleHeartbeatIntervalMs(1000), 60000);
});

test('idle heartbeat is emitted only while the worker is healthy and not processing a task', () => {
  assert.equal(shouldEmitIdleWorkerHeartbeat({ lastPollSucceeded: true }), true);
  assert.equal(shouldEmitIdleWorkerHeartbeat({ taskInProgress: true }), false);
  assert.equal(shouldEmitIdleWorkerHeartbeat({ pollInProgress: true }), false);
  assert.equal(shouldEmitIdleWorkerHeartbeat({ heartbeatInProgress: true }), false);
  assert.equal(shouldEmitIdleWorkerHeartbeat({ lastPollSucceeded: false }), false);
  assert.equal(shouldEmitIdleWorkerHeartbeat({ stopping: true }), false);
});

test('idle heartbeat reports only the generic queue worker, not a product category', () => {
  const record = buildIdleWorkerHeartbeatRecord('DESKTOP-TEST-123', 15000);
  assert.equal(record.agent_key, 'gemma-task-worker');
  assert.equal(record.category, 'Task control');
  assert.equal(record.status, 'idle');
  assert.equal(record.event_type, 'heartbeat');
  assert.equal(record.details.worker_id, 'DESKTOP-TEST-123');
  assert.equal(record.details.poll_interval_ms, 15000);
  assert.equal(record.details.stage, 'idle_poll');
  assert.equal(Object.hasOwn(record.details, 'branch_slug'), false);
});
