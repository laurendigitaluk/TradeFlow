const SUPABASE_URL = 'https://twfbmjwwqzxdxvclxbun.supabase.co';
const KEY_STORAGE = 'tradeflow_testlab_publishable_key';
const SESSION_STORAGE = 'tradeflow_testlab_session';
const TENANTS = {
  a: { slug: 'test-business-a', id: 'f50fb889-c615-4e55-84d4-f0fd9f48b0b0', label: 'Customer A / Test Business A' },
  b: { slug: 'test-business-b', id: '373598f0-7d35-41be-8ed2-3cc7ee9709c7', label: 'Customer B / Test Business B' }
};
const CUSTOMER_READ_TESTS = [
  ['customer_get_profile', 'Customer profile'], ['customer_get_addresses', 'Customer addresses'],
  ['customer_get_buying_requests', 'Buying requests'], ['customer_get_buying_items', 'Buying items'],
  ['customer_get_trading_values', 'Trading Values'], ['customer_get_offers', 'Offers'],
  ['customer_get_acquisitions', 'Acquisitions'], ['customer_get_trade_ins', 'Trade-ins'],
  ['customer_get_order_trade_ins', 'Order trade-ins'], ['customer_get_orders', 'Orders'],
  ['customer_get_order_items', 'Order items'], ['customer_get_fulfilments', 'Fulfilments'],
  ['customer_get_returns', 'Returns']
];
const PROTECTED_TABLES = ['customers', 'customer_addresses', 'buying_requests', 'buying_items', 'offers', 'retail_orders', 'retail_order_items', 'returns', 'trade_in_transactions'];
let supabaseKey = null;
let session = null;
let mode = 'signup';
const $ = (id) => document.getElementById(id);
function status(text, type = '') { const el = $('connection-status'); if (el) { el.className = `small ${type}`.trim(); el.textContent = text || ''; } }
function message(text, type = '') { const el = $('message'); if (!el) return; el.className = type; el.textContent = text || ''; }
function setMode(nextMode) { mode = nextMode; document.querySelectorAll('.tab').forEach((b) => b.classList.toggle('active', b.dataset.mode === mode)); $('name-fields').hidden = mode !== 'signup'; $('auth-submit').textContent = mode === 'signup' ? 'Create customer account' : 'Sign in'; $('password').autocomplete = mode === 'signup' ? 'new-password' : 'current-password'; message(''); }
async function api(path, options = {}) {
  if (!supabaseKey) throw new Error('TradeFlow Supabase is not connected.');
  const headers = new Headers(options.headers || {}); headers.set('apikey', supabaseKey); headers.set('Content-Type', 'application/json');
  if (session?.access_token) headers.set('Authorization', `Bearer ${session.access_token}`);
  const response = await fetch(`${SUPABASE_URL}${path}`, { ...options, headers }); const text = await response.text(); let body = null;
  try { body = text ? JSON.parse(text) : null; } catch { body = text; }
  if (!response.ok) { const detail = body?.msg || body?.message || body?.error_description || body?.error || text || `HTTP ${response.status}`; const error = new Error(detail); error.status = response.status; throw error; }
  return body;
}
async function connect(key) {
  const button = $('save-config');
  try { status('Connect button clicked. Starting connection test…'); if (!key || !key.startsWith('sb_')) { status('Enter the TradeFlow Supabase publishable key beginning with sb_.', 'error'); return; }
    button.disabled = true; button.textContent = 'Connecting…'; status('Testing the TradeFlow Supabase HTTPS API…'); supabaseKey = key; localStorage.setItem(KEY_STORAGE, key); await api('/auth/v1/settings'); status('Connected.'); $('config').hidden = true; $('app').hidden = false; await restoreSession();
  } catch (error) { supabaseKey = null; button.disabled = false; button.textContent = 'Connect'; status(`Connection failed: ${error.message || error}`, 'error'); message(`Connection failed: ${error.message || error}`, 'error'); }
}
function saveSession(nextSession) { session = nextSession || null; if (session?.access_token) localStorage.setItem(SESSION_STORAGE, JSON.stringify(session)); else localStorage.removeItem(SESSION_STORAGE); }
async function restoreSession() { const saved = localStorage.getItem(SESSION_STORAGE); if (!saved) { refreshSessionUI(null); return; } try { const parsed = JSON.parse(saved); if (!parsed?.access_token) throw new Error('Invalid saved session.'); session = parsed; const user = await api('/auth/v1/user'); session.user = user; localStorage.setItem(SESSION_STORAGE, JSON.stringify(session)); refreshSessionUI(session); await resolveExistingCustomer(); } catch { saveSession(null); refreshSessionUI(null); } }
function refreshSessionUI(currentSession) { if (currentSession?.user) { $('session-panel').hidden = false; $('auth-panel').hidden = true; $('session-email').textContent = currentSession.user.email || ''; $('onboarding-panel').hidden = false; $('ready-panel').hidden = true; } else { $('session-panel').hidden = true; $('auth-panel').hidden = false; $('onboarding-panel').hidden = true; $('ready-panel').hidden = true; } }
async function resolveExistingCustomer() {
  if (!session?.access_token) return false;
  const profiles = {};
  for (const key of ['a', 'b']) {
    try {
      const data = await api(`/rest/v1/rpc/customer_get_profile?p_tenant_id=${encodeURIComponent(TENANTS[key].id)}`, { method: 'GET' });
      profiles[key] = Array.isArray(data) ? data : (data ? [data] : []);
    } catch (error) {
      message(`Could not check existing customer registration: ${error.message || error}`, 'error');
      return false;
    }
  }
  const ownKeys = ['a', 'b'].filter((key) => profiles[key].length > 0);
  if (ownKeys.length === 1) {
    const ownKey = ownKeys[0];
    const profile = profiles[ownKey][0] || {};
    $('onboarding-panel').hidden = true;
    $('ready-panel').hidden = false;
    $('ready-text').textContent = `${TENANTS[ownKey].label} is already registered for this Auth account${profile.id ? `. Customer ID: ${profile.id}` : '.'}`;
    message('Existing customer registration found. You can continue to the security test.', 'success');
    return true;
  }
  if (ownKeys.length > 1) {
    $('onboarding-panel').hidden = false;
    $('ready-panel').hidden = true;
    message('Security check stopped: this Auth account appears linked to both test tenants. No customer records were changed.', 'error');
    return false;
  }
  $('onboarding-panel').hidden = false;
  $('ready-panel').hidden = true;
  return false;
}
async function signUp(email, password) { const data = await api('/auth/v1/signup', { method: 'POST', body: JSON.stringify({ email, password }) }); if (data?.access_token) { saveSession(data); return true; } return false; }
async function signIn(email, password) { const data = await api('/auth/v1/token?grant_type=password', { method: 'POST', body: JSON.stringify({ email, password }) }); saveSession(data); const user = await api('/auth/v1/user'); session.user = user; localStorage.setItem(SESSION_STORAGE, JSON.stringify(session)); }
async function completeOnboarding() { const firstName = $('onboard-first-name').value.trim(); const lastName = $('onboard-last-name').value.trim() || null; const tenantSlug = $('tenant-slug').value; if (!firstName) return message('First name is required.', 'error'); message('Checking whether this Auth account is already registered…'); try { const existing = await resolveExistingCustomer(); if (existing) return; message('Creating the customer record…'); const data = await api('/rest/v1/rpc/customer_complete_test_registration', { method: 'POST', body: JSON.stringify({ p_tenant_slug: tenantSlug, p_first_name: firstName, p_last_name: lastName }) }); const label = tenantSlug === 'test-business-a' ? 'Customer A / Test Business A' : 'Customer B / Test Business B'; $('onboarding-panel').hidden = true; $('ready-panel').hidden = false; $('ready-text').textContent = `${label} is ready. Customer ID: ${data}`; message('Customer record created.', 'success'); } catch (error) { message(error.message || String(error), 'error'); } }
function resultRow(label, passed, detail) { return `<div class="security-result ${passed ? 'pass' : 'fail'}"><strong>${passed ? 'PASS' : 'FAIL'} — ${label}</strong><span>${detail}</span></div>`; }
async function runSecurityTest() {
  const button = $('run-security-test'), results = $('security-results'); button.disabled = true; button.textContent = 'Running security test…'; results.hidden = false; results.innerHTML = '<p>Testing the current authenticated session against both test tenants and protected tables…</p>';
  const rows = []; let passCount = 0;
  try {
    if (!session?.access_token || !session?.user?.id) throw new Error('No authenticated customer session is available.');
    const profiles = {};
    for (const key of ['a', 'b']) {
      try { const data = await api(`/rest/v1/rpc/customer_get_profile?p_tenant_id=${encodeURIComponent(TENANTS[key].id)}`, { method: 'GET' }); profiles[key] = Array.isArray(data) ? data : (data ? [data] : []); }
      catch (error) { profiles[key] = null; rows.push(resultRow(`Controlled profile read — ${TENANTS[key].label}`, false, `Unexpected HTTP ${error.status || '?'}: ${error.message}`)); }
    }
    if (profiles.a && profiles.b) {
      const ownCount = [profiles.a, profiles.b].filter((x) => x.length > 0).length; const ownKey = profiles.a.length ? 'a' : (profiles.b.length ? 'b' : null); const passedIdentity = ownCount === 1;
      if (passedIdentity) passCount++;
      rows.push(resultRow('Customer identity resolves to exactly one tenant', passedIdentity, passedIdentity ? `${TENANTS[ownKey].label} returned the authenticated customer's profile; the other tenant returned no profile.` : `Unexpected profile counts: A=${profiles.a.length}, B=${profiles.b.length}.`));
      if (passedIdentity) {
        const otherKey = ownKey === 'a' ? 'b' : 'a';
        for (const [fn, label] of CUSTOMER_READ_TESTS) {
          try { const data = await api(`/rest/v1/rpc/${fn}?p_tenant_id=${encodeURIComponent(TENANTS[otherKey].id)}`, { method: 'GET' }); const count = Array.isArray(data) ? data.length : (data ? 1 : 0); const passedRead = count === 0; if (passedRead) passCount++; rows.push(resultRow(`Cross-tenant ${label}`, passedRead, passedRead ? '0 records returned from the opposite tenant.' : `${count} record(s) returned — tenant isolation failure.`)); }
          catch (error) { rows.push(resultRow(`Cross-tenant ${label}`, false, `Unexpected HTTP ${error.status || '?'}: ${error.message}`)); }
        }
        for (const table of PROTECTED_TABLES) {
          try { await api(`/rest/v1/${table}?select=*`, { method: 'GET' }); rows.push(resultRow(`Direct access blocked — ${table}`, false, 'The authenticated browser received a successful response from a protected table.')); }
          catch (error) { const passedTable = error.status === 401 || error.status === 403; if (passedTable) passCount++; rows.push(resultRow(`Direct access blocked — ${table}`, passedTable, passedTable ? `HTTP ${error.status} as expected.` : `Unexpected HTTP ${error.status || '?'}: ${error.message}`)); }
        }
      }
      const total = rows.length; const failed = rows.filter((row) => row.includes('class="security-result fail"')).length;
      results.innerHTML = `<h3>Authenticated Tenant-Isolation Test</h3><p><strong>${passCount}/${total} checks passed.</strong> ${failed ? `${failed} check(s) require attention.` : 'All checks passed.'}</p>${rows.join('')}`;
    }
  } catch (error) { results.innerHTML = `<p class="error"><strong>Test could not complete:</strong> ${error.message || error}</p>${rows.join('')}`; }
  finally { button.disabled = false; button.textContent = 'Run tenant-isolation security test again'; }
}
function initialise() {
  status('Test Lab loaded. Enter the publishable key and click Connect.'); $('save-config').addEventListener('click', () => connect($('supabase-key').value.trim())); document.querySelectorAll('.tab').forEach((b) => b.addEventListener('click', () => setMode(b.dataset.mode)));
  $('auth-form').addEventListener('submit', async (event) => { event.preventDefault(); message('Working…'); const email = $('email').value.trim(), password = $('password').value; try { if (mode === 'signup') { $('onboard-first-name').value = $('first-name').value.trim(); $('onboard-last-name').value = $('last-name').value.trim(); const hasSession = await signUp(email, password); if (!hasSession) { message('Account created. Check the email address and confirm the account, then return here and sign in.', 'success'); return; } refreshSessionUI(session); await resolveExistingCustomer(); } else { await signIn(email, password); refreshSessionUI(session); await resolveExistingCustomer(); } } catch (error) { message(error.message || String(error), 'error'); } });
  $('complete-onboarding').addEventListener('click', completeOnboarding); $('run-security-test').addEventListener('click', runSecurityTest); $('sign-out').addEventListener('click', async () => { try { if (session?.access_token) await api('/auth/v1/logout', { method: 'POST' }); } catch {} saveSession(null); message('Signed out.'); refreshSessionUI(null); }); setMode('signup'); const savedKey = localStorage.getItem(KEY_STORAGE); if (savedKey) { $('supabase-key').value = savedKey; status('Saved publishable key found. Click Connect to test the connection.'); }
}
initialise();
