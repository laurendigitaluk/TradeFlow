const SUPABASE_URL = 'https://twfbmjwwqzxdxvclxbun.supabase.co';
const KEY_STORAGE = 'tradeflow_testlab_publishable_key';
let supabase = null;
let mode = 'signup';

const $ = (id) => document.getElementById(id);

function message(text, type = '') {
  const el = $('message');
  el.className = type;
  el.textContent = text;
}

function setMode(nextMode) {
  mode = nextMode;
  document.querySelectorAll('.tab').forEach((b) => b.classList.toggle('active', b.dataset.mode === mode));
  $('name-fields').hidden = mode !== 'signup';
  $('auth-submit').textContent = mode === 'signup' ? 'Create customer account' : 'Sign in';
  $('password').autocomplete = mode === 'signup' ? 'new-password' : 'current-password';
  message('');
}

function connect(key) {
  if (!key || !key.startsWith('sb_')) return message('Enter the TradeFlow Supabase publishable key.', 'error');
  supabase = window.supabase.createClient(SUPABASE_URL, key);
  localStorage.setItem(KEY_STORAGE, key);
  $('config').hidden = true;
  $('app').hidden = false;
  refreshSession();
}

async function refreshSession() {
  const { data, error } = await supabase.auth.getSession();
  if (error) return message(error.message, 'error');
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
}

$('save-config').addEventListener('click', () => connect($('supabase-key').value.trim()));
document.querySelectorAll('.tab').forEach((b) => b.addEventListener('click', () => setMode(b.dataset.mode)));

$('auth-form').addEventListener('submit', async (event) => {
  event.preventDefault();
  message('Working…');
  const email = $('email').value.trim();
  const password = $('password').value;

  if (mode === 'signup') {
    const { data, error } = await supabase.auth.signUp({ email, password });
    if (error) return message(error.message, 'error');
    $('onboard-first-name').value = $('first-name').value.trim();
    $('onboard-last-name').value = $('last-name').value.trim();
    if (!data.session) {
      message('Account created. Check the email address and confirm the account, then return here and sign in.', 'success');
      return;
    }
    await refreshSession();
  } else {
    const { error } = await supabase.auth.signInWithPassword({ email, password });
    if (error) return message(error.message, 'error');
    await refreshSession();
  }
});

$('complete-onboarding').addEventListener('click', async () => {
  const firstName = $('onboard-first-name').value.trim();
  const lastName = $('onboard-last-name').value.trim() || null;
  const tenantSlug = $('tenant-slug').value;
  if (!firstName) return message('First name is required.', 'error');
  message('Creating the customer record…');
  const { data, error } = await supabase.rpc('customer_complete_test_registration', {
    p_tenant_slug: tenantSlug,
    p_first_name: firstName,
    p_last_name: lastName
  });
  if (error) return message(error.message, 'error');
  const label = tenantSlug === 'test-business-a' ? 'Customer A / Test Business A' : 'Customer B / Test Business B';
  $('onboarding-panel').hidden = true;
  $('ready-panel').hidden = false;
  $('ready-text').textContent = `${label} is ready. Customer ID: ${data}`;
  message('Customer record created.', 'success');
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
  connect(savedKey);
}
