export const IDLE_WORKER_HEARTBEAT_INTERVAL_MS = 60_000;

export function shouldReportIdleWorkerHeartbeat(lastReportedAt, now, intervalMs = IDLE_WORKER_HEARTBEAT_INTERVAL_MS) {
  if (!Number.isFinite(now)) throw new TypeError('Current time must be a finite timestamp.');
  if (!Number.isFinite(intervalMs) || intervalMs <= 0) throw new RangeError('Heartbeat interval must be a positive finite number.');
  if (lastReportedAt === null || lastReportedAt === undefined || !Number.isFinite(lastReportedAt)) return true;
  return now - lastReportedAt >= intervalMs;
}

export function createIdleWorkerHeartbeatRecord(workerId, pollIntervalMs) {
  const id = String(workerId || '').trim();
  const poll = Number(pollIntervalMs);
  if (!id) throw new TypeError('Worker identity is required.');
  if (!Number.isFinite(poll) || poll <= 0) throw new RangeError('Poll interval must be a positive finite number.');

  return {
    agent_key: 'gemma-task-worker',
    agent_name: 'Gemma Task Worker',
    category: 'Task control',
    status: 'idle',
    current_task: null,
    event_type: 'heartbeat',
    message: 'Persistent TradeFlow Gemma worker is alive and polling the LIVE task queue.',
    details: {
      worker_id: id,
      poll_interval_ms: poll,
      heartbeat_interval_ms: IDLE_WORKER_HEARTBEAT_INTERVAL_MS,
      worker_state: 'idle',
      heartbeat: true
    }
  };
}
