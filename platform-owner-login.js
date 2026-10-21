(() => {
  'use strict';
  const isTestHost = location.hostname === 'tradeflow-test.leannelaurenlowe.workers.dev';
  const SUPABASE_URL = isTestHost ? 'https://nnsshnfkjcflucjrftzi.supabase.co' : 'https://gxsrajtqzdjvmceqcpgv.supabase.co';
  const KEY = isTestHost ? 'sb_publishable_T_6zeNcVL8WlCWS521n4xw_Nh9ILPBQ' : 'sb_publishable_Y8NRuGXqHNTu9oaolrpprw_wysMNLuz';
  const SESSION_KEY = 'tradeflow_platform_owner_session';
  const $ = id => document.getElementById(id);
  const status = $('status');
  const signInButton = $('sign-in');
  const resetButton = $('send-reset');

  function message(text, ok = false) {
    status.textContent = text;
    status.classList.toggle('ok', ok);
  }
  async function api(path, options = {}, token = '') {
    const headers = {'apikey': KEY, ...(options.headers || {})};
    if (token) headers.Authorization = 'Bearer ' + token;
    if (options.body) headers['Content-Type'] = 'application/json';
    const response = await fetch(SUPABASE_URL + path, {...options, headers});
    const raw = await response.text();
    let data;
    try { data = raw ? JSON.parse(raw) : null; } catch { data = {message: raw}; }
    if (!response.ok) throw new Error(data?.msg || data?.message || data?.error_description || data?.error || 'Request failed (' + response.status + ').');
    return data;
  }
  $('login-form').addEventListener('submit', async event => {
    event.preventDefault();
    signInButton.disabled = true;
    signInButton.textContent = 'Verifying access…';
    message('');
    try {
      const email = $('owner-email').value.trim();
      const password = $('owner-password').value;
      const session = await api('/auth/v1/token?grant_type=password', {method:'POST', body:JSON.stringify({email,password})});
      if (!session?.access_token || !session?.user?.id) throw new Error('Sign-in did not return a valid session.');
      const memberships = await api('/rest/v1/platform_memberships?select=id,status&user_id=eq.' + encodeURIComponent(session.user.id) + '&status=eq.active&limit=1', {}, session.access_token);
      if (!Array.isArray(memberships) || memberships.length === 0) {
        try { await api('/auth/v1/logout', {method:'POST'}, session.access_token); } catch {}
        throw new Error('This account does not have active TradeFlow platform-owner access.');
      }
      localStorage.setItem(SESSION_KEY, JSON.stringify(session));
      message('Access verified. Opening the owner dashboard…', true);
      location.replace('/platform-owner-dashboard.html');
    } catch (error) {
      localStorage.removeItem(SESSION_KEY);
      message(error?.message || 'Unable to sign in. Please try again.');
    } finally {
      signInButton.disabled = false;
      signInButton.textContent = 'Sign in to owner portal';
    }
  });
  $('show-reset').addEventListener('click', () => {
    $('reset-form').classList.toggle('show');
    const current = $('owner-email').value.trim();
    if (current && !$('reset-email').value) $('reset-email').value = current;
    message('');
  });
  $('reset-form').addEventListener('submit', async event => {
    event.preventDefault();
    resetButton.disabled = true;
    resetButton.textContent = 'Sending…';
    message('');
    try {
      const email = $('reset-email').value.trim();
      await api('/auth/v1/recover', {
        method:'POST',
        body:JSON.stringify({email, redirect_to: new URL('/owner-reset-password', location.origin).href})
      });
      message('If that address is registered, a password reset email has been sent.', true);
    } catch (error) {
      message(error?.message || 'Unable to send the reset email.');
    } finally {
      resetButton.disabled = false;
      resetButton.textContent = 'Send password reset email';
    }
  });
})();
