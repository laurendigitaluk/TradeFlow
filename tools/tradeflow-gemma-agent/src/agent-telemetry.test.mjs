import test from 'node:test';
import assert from 'node:assert/strict';
import { buildWorkerHeartbeatDetails } from './agent-telemetry.mjs';

test('worker heartbeat uses its own stage and retains the active research stage separately', () => {
  const details = buildWorkerHeartbeatDetails({
    activeStage: 'extraction_batch_started',
    queueTaskId: 'queue-123',
    workerId: 'worker-456'
  });

  assert.deepEqual(details, {
    stage: 'heartbeat',
    active_stage: 'extraction_batch_started',
    heartbeat: true,
    queue_task_id: 'queue-123',
    worker_id: 'worker-456'
  });
  assert.notEqual(details.stage, details.active_stage);
});

test('worker heartbeat preserves an absent active stage as null without inventing a research stage', () => {
  const details = buildWorkerHeartbeatDetails({
    queueTaskId: 'queue-123',
    workerId: 'worker-456'
  });

  assert.equal(details.stage, 'heartbeat');
  assert.equal(details.active_stage, null);
  assert.equal(details.heartbeat, true);
});
