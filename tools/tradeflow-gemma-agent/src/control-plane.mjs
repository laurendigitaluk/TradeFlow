export const TRADEFLOW_PROJECTS = Object.freeze({
  TEST: 'nnsshnfkjcflucjrftzi',
  LIVE: 'gxsrajtqzdjvmceqcpgv'
});

export function resolveControlPlane(env = {}) {
  const name = String(env.TRADEFLOW_GEMMA_ENVIRONMENT || 'LIVE').trim().toUpperCase();
  if (!Object.hasOwn(TRADEFLOW_PROJECTS, name)) {
    throw new Error('TRADEFLOW_GEMMA_ENVIRONMENT must be TEST or LIVE; refusing to start.');
  }
  const prefix = 'TRADEFLOW_' + name + '_';
  const url = String(env[prefix + 'URL'] || '').trim();
  const key = String(env[prefix + 'SERVICE_ROLE_KEY'] || '').trim();
  if (!url || !key) throw new Error(prefix + 'URL and service-role key are required.');
  let parsed;
  try { parsed = new URL(url); } catch { throw new Error(prefix + 'URL is invalid.'); }
  if (parsed.protocol !== 'https:' || parsed.hostname !== TRADEFLOW_PROJECTS[name] + '.supabase.co') {
    throw new Error('Configured ' + name + ' URL does not match the approved TradeFlow ' + name + ' project.');
  }
  return Object.freeze({ name, url: url.replace(/\/+$/, ''), key });
}
