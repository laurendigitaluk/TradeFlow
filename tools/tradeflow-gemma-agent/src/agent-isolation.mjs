import { DESKTOP_RESEARCH_AGENTS, normalizeDesktopConfig } from './desktop-control.mjs';

export function normalizeIsolatedAgentConfig(value) {
  const config = normalizeDesktopConfig(value);
  if (config.enabledAgentKeys.length !== 1) {
    throw new Error('An isolated Gemma installation must enable exactly one category agent.');
  }
  const definition = DESKTOP_RESEARCH_AGENTS.find(item => item.agent_key === config.enabledAgentKeys[0]);
  if (!definition) throw new Error('Unknown isolated Gemma agent key: ' + config.enabledAgentKeys[0]);
  return {
    ...config,
    agentKey: definition.agent_key,
    agentIdentity: {
      agent_key: definition.agent_key,
      agent_name: 'Gemma — ' + definition.label,
      category: definition.agent_key
    }
  };
}

export function assertTaskGroupBelongsToAgent(tasks, agentKey, resolveAgentIdentity) {
  if (!Array.isArray(tasks) || !agentKey || typeof resolveAgentIdentity !== 'function') return false;
  return tasks.length > 0 && tasks.every(task => resolveAgentIdentity(task).agent_key === agentKey);
}
