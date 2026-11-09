export function idleHeartbeatIntervalMs(pollIntervalMs) {
  const parsed = Number(pollIntervalMs);
  const safePollMs = Number.isFinite(parsed) && parsed >= 5000
    ? Math.floor(parsed)
    : 15000;
  return Math.max(60000, Math.min(300000, safePollMs * 4));
}

export function shouldEmitIdleWorkerHeartbeat(state = {}) {
  return state.stopping !== true &&
    state.taskInProgress !== true &&
    state.pollInProgress !== true &&
    state.heartbeatInProgress !== true &&
    state.lastPollSucceeded !== false;
}

export function buildIdleWorkerHeartbeatRecord(workerId, pollIntervalMs) {
  return {
    agent_key: 'gemma-task-worker',
    agent_name: 'Gemma Task Worker',
    category: 'Task control',
    status: 'idle',
    event_type: 'heartbeat',
    message: 'Persistent TradeFlow Gemma worker is alive and idle.',
    details: {
      worker_id: String(workerId || '').slice(0, 120),
      poll_interval_ms: Number(pollIntervalMs) || 15000,
      stage: 'idle_poll'
    }
  };
}
