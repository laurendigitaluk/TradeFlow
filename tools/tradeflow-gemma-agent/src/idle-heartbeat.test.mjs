import test from 'node:test';
import assert from 'node:assert/strict';
import {
  IDLE_WORKER_HEARTBEAT_INTERVAL_MS,
  shouldReportIdleWorkerHeartbeat,
  createIdleWorkerHeartbeatRecord
} from './idle-heartbeat.mjs';

test('the first idle heartbeat is due when no previous report exists', () => {
  assert.equal(shouldReportIdleWorkerHeartbeat(null, 1000), true);
});

test('idle heartbeat is throttled until the configured interval has elapsed', () => {
  const last = 1000;
  assert.equal(shouldReportIdleWorkerHeartbeat(last, last + IDLE_WORKER_HEARTBEAT_INTERVAL_MS - 1), false);
  assert.equal(shouldReportIdleWorkerHeartbeat(last, last + IDLE_WORKER_HEARTBEAT_INTERVAL_MS), true);
});

test('a long idle period requires one heartbeat, not a catch-up burst', () => {
  const now = 900_000;
  assert.equal(shouldReportIdleWorkerHeartbeat(1000, now), true);
  assert.equal(shouldReportIdleWorkerHeartbeat(now, now + 15_000), false);
});

test('idle heartbeat record targets only the LIVE task-worker control-plane identity', () => {
  const record = createIdleWorkerHeartbeatRecord('DESKTOP-TEST-1234', 15_000);
  assert.equal(record.agent_key, 'gemma-task-worker');
  assert.equal(record.agent_name, 'Gemma Task Worker');
  assert.equal(record.category, 'Task control');
  assert.equal(record.status, 'idle');
  assert.equal(record.current_task, null);
  assert.equal(record.event_type, 'heartbeat');
  assert.deepEqual(record.details, {
    worker_id: 'DESKTOP-TEST-1234',
    poll_interval_ms: 15_000,
    heartbeat_interval_ms: 60_000,
    worker_state: 'idle',
    heartbeat: true
  });
  assert.equal(JSON.stringify(record).includes('SERVICE_ROLE_KEY'), false);
});

test('invalid heartbeat timing and worker identity are rejected', () => {
  assert.throws(() => shouldReportIdleWorkerHeartbeat(null, NaN), /finite timestamp/);
  assert.throws(() => shouldReportIdleWorkerHeartbeat(null, 1000, 0), /positive finite number/);
  assert.throws(() => createIdleWorkerHeartbeatRecord('', 15_000), /identity is required/);
  assert.throws(() => createIdleWorkerHeartbeatRecord('worker-1', 0), /positive finite number/);
});
