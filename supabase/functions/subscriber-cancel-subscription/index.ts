import "jsr:@supabase/functions-js/edge-runtime.d.ts";

const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!;
const SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
const STRIPE_SECRET_KEY = Deno.env.get('STRIPE_SECRET_KEY')!;

const headers = {
  'Content-Type': 'application/json',
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type'
};

const json = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), { status, headers });

async function sb(path: string, init: RequestInit = {}) {
  return fetch(SUPABASE_URL + path, {
    ...init,
    headers: {
      apikey: SERVICE_ROLE_KEY,
      Authorization: 'Bearer ' + SERVICE_ROLE_KEY,
      'Content-Type': 'application/json',
      ...(init.headers || {})
    }
  });
}

Deno.serve(async req => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers });
  if (req.method !== 'POST') return json({ error: 'Method not allowed' }, 405);
  if (!STRIPE_SECRET_KEY) return json({ error: 'Stripe is not configured on LIVE TradeFlow.' }, 503);

  const auth = req.headers.get('Authorization');
  if (!auth) return json({ error: 'Authentication required.' }, 401);

  try {
    const userRes = await fetch(SUPABASE_URL + '/auth/v1/user', {
      headers: { apikey: SERVICE_ROLE_KEY, Authorization: auth }
    });
    if (!userRes.ok) return json({ error: 'Authentication required.' }, 401);

    const user = await userRes.json();
    const userId = String(user?.id || '');
    if (!userId) return json({ error: 'Authenticated user could not be identified.' }, 401);

    const body = await req.json().catch(() => ({}));
    const tenantId = String(body?.tenant_id || '').trim();
    if (!tenantId) return json({ error: 'Tenant ID is required.' }, 400);

    const membershipRes = await sb(
      '/rest/v1/tenant_memberships?tenant_id=eq.' + encodeURIComponent(tenantId) +
      '&user_id=eq.' + encodeURIComponent(userId) +
      '&status=eq.active&select=tenant_id,role_code&limit=1'
    );
    if (!membershipRes.ok) return json({ error: 'Unable to validate subscriber access.' }, 500);
    const memberships = await membershipRes.json();
    if (!Array.isArray(memberships) || !memberships.length) {
      return json({ error: 'You do not have access to this TradeFlow business.' }, 403);
    }

    const subRes = await sb(
      '/rest/v1/tenant_subscriptions?tenant_id=eq.' + encodeURIComponent(tenantId) +
      '&billing_provider=eq.stripe&select=id,provider_customer_id,provider_subscription_id,status,cancel_at_period_end,current_period_end,trial_end&order=created_at.desc&limit=1'
    );
    if (!subRes.ok) return json({ error: 'Unable to load the TradeFlow subscription.' }, 500);
    const subs = await subRes.json();
    const localSub = subs?.[0];
    if (!localSub?.provider_subscription_id || !localSub?.provider_customer_id) {
      return json({ error: 'No Stripe subscription is connected to this TradeFlow business.' }, 404);
    }

    const stripeRes = await fetch(
      'https://api.stripe.com/v1/subscriptions/' + encodeURIComponent(localSub.provider_subscription_id),
      { headers: { Authorization: 'Bearer ' + STRIPE_SECRET_KEY } }
    );
    const stripeSub = await stripeRes.json();
    if (!stripeRes.ok) {
      return json({ error: stripeSub?.error?.message || 'Unable to load the Stripe subscription.' }, 502);
    }

    const metadataUserId = String(stripeSub?.metadata?.user_id || '');
    const stripeCustomerId = String(stripeSub?.customer || '');
    if (metadataUserId && metadataUserId !== userId) {
      return json({ error: 'The Stripe subscription does not belong to this TradeFlow account.' }, 403);
    }
    if (stripeCustomerId !== localSub.provider_customer_id) {
      return json({ error: 'The Stripe customer does not match the connected TradeFlow subscription.' }, 409);
    }

    if (stripeSub.cancel_at_period_end) {
      return json({
        ok: true,
        already_cancelled: true,
        status: stripeSub.status,
        cancel_at_period_end: true,
        cancellation_at: stripeSub.current_period_end
          ? new Date(Number(stripeSub.current_period_end) * 1000).toISOString()
          : null
      });
    }

    const updateParams = new URLSearchParams();
    updateParams.set('cancel_at_period_end', 'true');

    const updateRes = await fetch(
      'https://api.stripe.com/v1/subscriptions/' + encodeURIComponent(stripeSub.id),
      {
        method: 'POST',
        headers: {
          Authorization: 'Bearer ' + STRIPE_SECRET_KEY,
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: updateParams
      }
    );
    const updated = await updateRes.json();
    if (!updateRes.ok) {
      return json({ error: updated?.error?.message || 'Stripe could not schedule the cancellation.' }, 502);
    }

    const now = new Date().toISOString();
    const dbPatch = await sb(
      '/rest/v1/tenant_subscriptions?id=eq.' + encodeURIComponent(localSub.id) +
      '&tenant_id=eq.' + encodeURIComponent(tenantId),
      {
        method: 'PATCH',
        headers: { Prefer: 'return=minimal' },
        body: JSON.stringify({
          cancel_at_period_end: true,
          provider_status: updated.status,
          updated_at: now,
          provider_metadata: {
            cancellation_requested_at: now,
            cancellation_source: 'subscriber_dashboard',
            stripe_cancel_at_period_end: true
          }
        })
      }
    );
    if (!dbPatch.ok) {
      return json({ error: 'Stripe cancellation was scheduled, but TradeFlow could not update its local subscription record.' }, 500);
    }

    return json({
      ok: true,
      status: updated.status,
      cancel_at_period_end: true,
      cancellation_at: updated.current_period_end
        ? new Date(Number(updated.current_period_end) * 1000).toISOString()
        : null
    });
  } catch (e) {
    return json({ error: e instanceof Error ? e.message : String(e) }, 500);
  }
});
