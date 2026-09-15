const SUPABASE_URL = 'https://twfbmjwwqzxdxvclxbun.supabase.co';
const KEY_STORAGE = 'tradeflow_testlab_publishable_key';
const SESSION_STORAGE = 'tradeflow_testlab_session';
let supabaseKey = null;
let session = null;
let mode = 'signup';

const $ = (id) => document.getElementById(id);

function status(text, type = '') {
  const el = $('connection-status');
  if (el) {
    el.className = `small ${type}`.trim();
    el.textContent = text || '';
  }
}

function message(text, type = '') {
  const el = $('message');
  if (!el) return;
  el.className = type;
  el.textContent = text || '';
}

function setMode(nextMode) {
  mode = nextMode;
  document.querySelectorAll('.tab').forEach((b) => b.classList.toggle('active', b.dataset.mode === mode));
  $('name-fields').hidden = mode !== 'signup';
  $('auth-submit').textContent = mode === 'signup' ? 'Create customer account' : 'Sign in';
  $('password').autocomplete = mode === 'signup' ? 'new-password' : 'current-password';
  message('');
}

async function api(path, options = {}) {
  if (!supabaseKey) throw new Error('TradeFlow Supabase is not connected.');

  const headers = new Headers(options.headers || {});
  headers.set('apikey', supabaseKey);
  headers.set('Content-Type', 'application/json');
  if (session?.access_token) headers.set('Authorization', `Bearer ${session.access_token}`);

  const response = await fetch(`${SUPABASE_URL}${path}`, { ...options, headers });
  const text = await response.text();
  let body = null;
  try { body = text ? JSON.parse(text) : null; } catch { body = text; }

  if (!response.ok) {
    const detail = body?.msg || body?.message || body?.error_description || body?.error || text || `HTTP ${response.status}`;
    throw new Error(detail);
  }
  return body;
}

async function connect(key) {
  const button = $('save-config');
  try {
    status('Connect button clicked. Starting connection test…');

    if (!key || !key.startsWith('sb_')) {
      status('Enter the TradeFlow Supabase publishable key beginning with sb_.', 'error');
      return;
    }

    button.disabled = true;
    button.textContent = 'Connecting…';
    status('Testing the TradeFlow Supabase HTTPS API…');

    supabaseKey = key;
    localStorage.setItem(KEY_STORAGE, key);

    await api('/auth/v1/settings');
    status('Connected.');
    $('config').hidden = true;
    $('app').hidden = false;
    await restoreSession();
  } catch (error) {
    supabaseKey = null;
    button.disabled = false;
    button.textContent = 'Connect';
    status(`Connection failed: ${error.message || error}`, 'error');
    message(`Connection failed: ${error.message || error}`, 'error');
  }
}

function saveSession(nextSession) {
  session = nextSession || null;
  if (session?.access_token) {
    localStorage.setItem(SESSION_STORAGE, JSON.stringify(session));
  } else {
    localStorage.removeItem(SESSION_STORAGE);
  }
}

async function restoreSession() {
  const saved = localStorage.getItem(SESSION_STORAGE);
  if (!saved) {
    refreshSessionUI(null);
    return;
  }

  try {
    const parsed = JSON.parse(saved);
    if (!parsed?.access_token) throw new Error('Invalid saved session.');
    session = parsed;
    const user = await api('/auth/v1/user');
    session.user = user;
    localStorage.setItem(SESSION_STORAGE, JSON.stringify(session));
    refreshSessionUI(session);
  } catch {
    saveSession(null);
    refreshSessionUI(null);
  }
}

function refreshSessionUI(currentSession) {
  if (currentSession?.user) {
    $('session-panel').hidden = false;
    $('auth-panel').hidden = true;
    $('session-email').textContent = currentSession.user.email || '';
    $('onboarding-panel').hidden = false;
    $('ready-panel').hidden = true;
  } else {
    $('session-panel').hidden = true;
    $('auth-panel').hidden = false;
    $('onboarding-panel').hidden = true;
    $('ready-panel').hidden = true;
  }
}

async function signUp(email, password) {
  const data = await api('/auth/v1/signup', {
    method: 'POST',
    body: JSON.stringify({ email, password })
  });

  if (data?.access_token) {
    saveSession(data);
    return true;
  }

  return false;
}

async function signIn(email, password) {
  const data = await api('/auth/v1/token?grant_type=password', {
    method: 'POST',
    body: JSON.stringify({ email, password })
  });
  saveSession(data);
  const user = await api('/auth/v1/user');
  session.user = user;
  localStorage.setItem(SESSION_STORAGE, JSON.stringify(session));
}

async function completeOnboarding() {
  const firstName = $('onboard-first-name').value.trim();
  const lastName = $('onboard-last-name').value.trim() || null;
  const tenantSlug = $('tenant-slug').value;
  if (!firstName) return message('First name is required.', 'error');
  message('Creating the customer record…');

  try {
    const data = await api('/rest/v1/rpc/customer_complete_test_registration', {
      method: 'POST',
      body: JSON.stringify({
        p_tenant_slug: tenantSlug,
        p_first_name: firstName,
        p_last_name: lastName
      })
    });
    const label = tenantSlug === 'test-business-a' ? 'Customer A / Test Business A' : 'Customer B / Test Business B';
    $('onboarding-panel').hidden = true;
    $('ready-panel').hidden = false;
    $('ready-text').textContent = `${label} is ready. Customer ID: ${data}`;
    message('Customer record created.', 'success');
  } catch (error) {
    message(error.message || String(error), 'error');
  }
}

function initialise() {
  status('Test Lab loaded. Enter the publishable key and click Connect.');

  $('save-config').addEventListener('click', () => connect($('supabase-key').value.trim()));

  document.querySelectorAll('.tab').forEach((b) => b.addEventListener('click', () => setMode(b.dataset.mode)));

  $('auth-form').addEventListener('submit', async (event) => {
    event.preventDefault();
    message('Working…');
    const email = $('email').value.trim();
    const password = $('password').value;

    try {
      if (mode === 'signup') {
        $('onboard-first-name').value = $('first-name').value.trim();
        $('onboard-last-name').value = $('last-name').value.trim();
        const hasSession = await signUp(email, password);
        if (!hasSession) {
          message('Account created. Check the email address and confirm the account, then return here and sign in.', 'success');
          return;
        }
        refreshSessionUI(session);
      } else {
        await signIn(email, password);
        refreshSessionUI(session);
      }
    } catch (error) {
      message(error.message || String(error), 'error');
    }
  });

  $('complete-onboarding').addEventListener('click', completeOnboarding);

  $('sign-out').addEventListener('click', async () => {
    try {
      if (session?.access_token) await api('/auth/v1/logout', { method: 'POST' });
    } catch {
      // Clear the local test session even if remote logout fails.
    }
    saveSession(null);
    message('Signed out.');
    refreshSessionUI(null);
  });

  setMode('signup');

  const savedKey = localStorage.getItem(KEY_STORAGE);
  if (savedKey) {
    $('supabase-key').value = savedKey;
    status('Saved publishable key found. Click Connect to test the connection.');
  }
}

initialise();
