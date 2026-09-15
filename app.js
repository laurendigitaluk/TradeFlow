const SUPABASE_URL = 'https://twfbmjwwqzxdxvclxbun.supabase.co';
const KEY_STORAGE = 'tradeflow_testlab_publishable_key';
let supabase = null;
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

async function connect(key) {
  const button = $('save-config');
  try {
    status('Connect button clicked. Checking Supabase browser library…');

    if (!key || !key.startsWith('sb_')) {
      status('Enter the TradeFlow Supabase publishable key beginning with sb_.', 'error');
      return;
    }

    if (!window.supabase || typeof window.supabase.createClient !== 'function') {
      status('The Supabase browser library did not load. The CDN script is unavailable in this browser.', 'error');
      return;
    }

    button.disabled = true;
    button.textContent = 'Connecting…';
    status('Connecting to TradeFlow Supabase…');

    const client = window.supabase.createClient(SUPABASE_URL, key);
    const { error } = await client.auth.getSession();
    if (error) throw error;

    supabase = client;
    localStorage.setItem(KEY_STORAGE, key);
    $('config').hidden = true;
    $('app').hidden = false;
    status('Connected.');
    await refreshSession();
  } catch (error) {
    button.disabled = false;
    button.textContent = 'Connect';
    status(`Connection failed: ${error.message || error}`, 'error');
    message(`Connection failed: ${error.message || error}`, 'error');
  }
}

async function refreshSession() {
  try {
    const { data, error } = await supabase.auth.getSession();
    if (error) throw error;

    if (data.session) {
      $('session-panel').hidden = false;
      $('auth-panel').hidden = true;
      $('session-email').textContent = data.session.user.email || '';
      $('onboarding-panel').hidden = false;
      $('ready-panel').hidden = true;
    } else {
      $('session-panel').hidden = true;
      $('auth-panel').hidden = false;
      $('onboarding-panel').hidden = true;
      $('ready-panel').hidden = true;
    }
  } catch (error) {
    message(`Session check failed: ${error.message || error}`, 'error');
  }
}

function initialise() {
  const connectButton = $('save-config');
  connectButton.addEventListener('click', () => connect($('supabase-key').value.trim()));

  document.querySelectorAll('.tab').forEach((b) => b.addEventListener('click', () => setMode(b.dataset.mode)));

  $('auth-form').addEventListener('submit', async (event) => {
    event.preventDefault();
    message('Working…');
    const email = $('email').value.trim();
    const password = $('password').value;

    try {
      if (mode === 'signup') {
        const { data, error } = await supabase.auth.signUp({ email, password });
        if (error) throw error;
        $('onboard-first-name').value = $('first-name').value.trim();
        $('onboard-last-name').value = $('last-name').value.trim();
        if (!data.session) {
          message('Account created. Check the email address and confirm the account, then return here and sign in.', 'success');
          return;
        }
        await refreshSession();
      } else {
        const { error } = await supabase.auth.signInWithPassword({ email, password });
        if (error) throw error;
        await refreshSession();
      }
    } catch (error) {
      message(error.message || String(error), 'error');
    }
  });

  $('complete-onboarding').addEventListener('click', async () => {
    const firstName = $('onboard-first-name').value.trim();
    const lastName = $('onboard-last-name').value.trim() || null;
    const tenantSlug = $('tenant-slug').value;
    if (!firstName) return message('First name is required.', 'error');
    message('Creating the customer record…');

    try {
      const { data, error } = await supabase.rpc('customer_complete_test_registration', {
        p_tenant_slug: tenantSlug,
        p_first_name: firstName,
        p_last_name: lastName
      });
      if (error) throw error;
      const label = tenantSlug === 'test-business-a' ? 'Customer A / Test Business A' : 'Customer B / Test Business B';
      $('onboarding-panel').hidden = true;
      $('ready-panel').hidden = false;
      $('ready-text').textContent = `${label} is ready. Customer ID: ${data}`;
      message('Customer record created.', 'success');
    } catch (error) {
      message(error.message || String(error), 'error');
    }
  });

  $('sign-out').addEventListener('click', async () => {
    await supabase.auth.signOut();
    message('Signed out.');
    await refreshSession();
  });

  setMode('signup');

  const savedKey = localStorage.getItem(KEY_STORAGE);
  if (savedKey) {
    $('supabase-key').value = savedKey;
    status('Saved publishable key found. Click Connect to test the connection.');
  } else {
    status('Ready. Enter the publishable key and click Connect.');
  }
}

// app.js is loaded with defer, so the document is already parsed and the Supabase CDN script has run first.
initialise();
