import test from 'node:test';
import assert from 'node:assert/strict';
import {
  buildSpecialistIdleHeartbeatRecord,
  specialistIdleHeartbeatIntervalMs,
  shouldEmitSpecialistIdleHeartbeat
} from './specialist-idle-heartbeat.mjs';

test('specialist idle heartbeat cadence is bounded between one and five minutes', () => {
  assert.equal(specialistIdleHeartbeatIntervalMs(5000), 60000);
  assert.equal(specialistIdleHeartbeatIntervalMs(15000), 60000);
  assert.equal(specialistIdleHeartbeatIntervalMs(30000), 120000);
  assert.equal(specialistIdleHeartbeatIntervalMs(60000), 240000);
  assert.equal(specialistIdleHeartbeatIntervalMs(180000), 300000);
});

test('invalid poll intervals use the safe default cadence', () => {
  assert.equal(specialistIdleHeartbeatIntervalMs(undefined), 60000);
  assert.equal(specialistIdleHeartbeatIntervalMs('not-a-number'), 60000);
  assert.equal(specialistIdleHeartbeatIntervalMs(1000), 60000);
});

test('heartbeat is emitted only after a successful idle poll and never during work or shutdown', () => {
  assert.equal(shouldEmitSpecialistIdleHeartbeat({ lastPollSucceeded: true }), true);
  assert.equal(shouldEmitSpecialistIdleHeartbeat({ lastPollSucceeded: false }), false);
  assert.equal(shouldEmitSpecialistIdleHeartbeat({ taskInProgress: true, lastPollSucceeded: true }), false);
  assert.equal(shouldEmitSpecialistIdleHeartbeat({ pollInProgress: true, lastPollSucceeded: true }), false);
  assert.equal(shouldEmitSpecialistIdleHeartbeat({ heartbeatInProgress: true, lastPollSucceeded: true }), false);
  assert.equal(shouldEmitSpecialistIdleHeartbeat({ stopping: true, lastPollSucceeded: true }), false);
});

test('idle heartbeat retains the assigned specialist identity and LIVE worker metadata', () => {
  const identity = {
    agent_key: '3d-printers-equipment',
    agent_name: 'Gemma — 3D Printers & Equipment',
    category: '3d-printers-equipment'
  };
  const record = buildSpecialistIdleHeartbeatRecord(identity, 'DESKTOP-TEST-3d-printers-123', 15000, '3d-printers-equipment');
  assert.equal(record.agent_key, '3d-printers-equipment');
  assert.equal(record.agent_name, 'Gemma — 3D Printers & Equipment');
  assert.equal(record.category, '3d-printers-equipment');
  assert.equal(record.status, 'idle');
  assert.equal(record.current_task, null);
  assert.equal(record.event_type, 'heartbeat');
  assert.equal(record.details.worker_id, 'DESKTOP-TEST-3d-printers-123');
  assert.equal(record.details.poll_interval_ms, 15000);
  assert.equal(record.details.stage, 'idle_poll');
  assert.equal(record.details.isolated_agent_key, '3d-printers-equipment');
});
