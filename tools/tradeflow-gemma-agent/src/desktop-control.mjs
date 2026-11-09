export const DESKTOP_RESEARCH_AGENTS = Object.freeze([
  { agent_key: '3d-printers-equipment', label: '3D Printers & Equipment', aliases: ['3d-printers'] },
  { agent_key: 'gaming-consoles-accessories', label: 'Gaming Consoles & Accessories', aliases: ['gaming-consoles'] },
  { agent_key: 'drones', label: 'Drones', aliases: [] },
  { agent_key: 'metal-detectors', label: 'Metal Detectors', aliases: [] },
  { agent_key: 'mobile-phones', label: 'Mobile Phones', aliases: [] },
  { agent_key: 'laptops', label: 'Laptops & Computers', aliases: [] },
  { agent_key: 'cameras', label: 'Cameras & Lenses', aliases: [] }
]);

const agentMap = new Map(DESKTOP_RESEARCH_AGENTS.map(agent => [agent.agent_key, agent]));

export function normalizeDesktopConfig(value) {
  if (!value || typeof value !== 'object' || Array.isArray(value)) {
    throw new Error('Desktop agent configuration must be a JSON object.');
  }
  if (Number(value.schemaVersion) !== 1) throw new Error('Unsupported desktop agent configuration version.');
  if (typeof value.serviceEnabled !== 'boolean') throw new Error('serviceEnabled must be true or false.');
  const requested = Array.isArray(value.enabledAgentKeys) ? value.enabledAgentKeys : [];
  const unknown = requested.filter(key => !agentMap.has(String(key)));
  if (unknown.length) throw new Error('Unknown research agent key(s): ' + unknown.join(', '));
  return {
    schemaVersion: 1,
    serviceEnabled: value.serviceEnabled,
    autoStart: value.autoStart !== false,
    enabledAgentKeys: [...new Set(requested.map(String))]
  };
}

export function buildAgentClaimArgs(config, workerId, leaseSeconds = 600) {
  const safe = normalizeDesktopConfig(config);
  if (!safe.serviceEnabled || safe.enabledAgentKeys.length === 0) return null;
  const allowedKeys = new Set();
  for (const key of safe.enabledAgentKeys) {
    const agent = agentMap.get(key);
    allowedKeys.add(agent.agent_key);
    for (const alias of agent.aliases) allowedKeys.add(alias);
  }
  return {
    p_worker_id: String(workerId || '').trim(),
    p_agent_keys: [...allowedKeys],
    p_lease_seconds: Math.max(120, Math.min(1800, Number(leaseSeconds) || 600))
  };
}

export function getDesktopAgentState(agentKey, config, status = {}) {
  const safe = normalizeDesktopConfig(config);
  const enabled = safe.enabledAgentKeys.includes(agentKey);
  const running = Array.isArray(status.activeAgentKeys) && status.activeAgentKeys.includes(agentKey);
  if (!safe.serviceEnabled) return 'service-stopped';
  if (!enabled) return 'disabled';
  if (running) return 'running';
  if (status.state === 'requires_migration') return 'requires-migration';
  if (status.state === 'error') return 'error';
  return 'waiting';
}
