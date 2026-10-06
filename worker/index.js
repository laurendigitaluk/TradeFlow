const REPLACEMENT_PAIRS = {
  test: (env) => [
    [env.LIVE_SUPABASE_URL, env.TEST_SUPABASE_URL],
    [env.LIVE_SUPABASE_KEY, env.TEST_SUPABASE_KEY],
  ],
  production: (env) => [
    [env.TEST_SUPABASE_URL, env.LIVE_SUPABASE_URL],
    [env.TEST_SUPABASE_KEY, env.LIVE_SUPABASE_KEY],
  ],
};

function replaceAll(source, from, to) {
  if (!from || from === to) return source;
  return source.split(from).join(to);
}

export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    const cleanRoutes = {
      "/": "/public-site.html",
      "/login": "/customer-dashboard.html",
      "/basket": "/customer-basket.html",
      "/assistant": "/customer-assistant.html",
      "/email-confirmed": "/customer-email-confirmed.html",
      "/reset-password": "/customer-password-reset.html",
      "/owner-reset-password": "/platform-owner-password-reset.html",
    };
    const assetPath = cleanRoutes[url.pathname];
    const assetRequest = assetPath
      ? new Request(new URL(assetPath + url.search, url.origin), request)
      : request;
    const assetFetchRequest = new Request(assetRequest, { cache: "no-store" });

    if (url.pathname === "/api/subscriber-login") {
      if (request.method !== "POST") return new Response("Method Not Allowed", { status: 405 });
      try {
        const payload = await request.json();
        const email = String(payload?.email || "").trim();
        const password = String(payload?.password || "");
        if (!email || !password) return Response.json({ error: "Enter your email and password." }, { status: 400 });
        const supabaseUrl = env.TRADEFLOW_ENV === "production" ? env.LIVE_SUPABASE_URL : env.TEST_SUPABASE_URL;
        const supabaseKey = env.TRADEFLOW_ENV === "production" ? env.LIVE_SUPABASE_KEY : env.TEST_SUPABASE_KEY;
        const authResponse = await fetch(supabaseUrl + "/auth/v1/token?grant_type=password", {
          method: "POST",
          headers: { apikey: supabaseKey, "Content-Type": "application/json" },
          body: JSON.stringify({ email, password }),
          cache: "no-store",
        });
        const authText = await authResponse.text();
        let authBody = null;
        try { authBody = authText ? JSON.parse(authText) : null; } catch {}
        if (!authResponse.ok || !authBody?.access_token) {
          return Response.json({ error: authBody?.error_description || authBody?.message || "Sign in failed." }, { status: authResponse.status || 401 });
        }
        const membershipResponse = await fetch(supabaseUrl + "/rest/v1/rpc/subscriber_get_my_memberships", {
          method: "POST",
          headers: {
            apikey: supabaseKey,
            Authorization: "Bearer " + authBody.access_token,
            "Content-Type": "application/json",
          },
          body: "{}",
          cache: "no-store",
        });
        const membershipText = await membershipResponse.text();
        let memberships = [];
        try { memberships = membershipText ? JSON.parse(membershipText) : []; } catch {}
        if (!membershipResponse.ok || !Array.isArray(memberships) || memberships.length === 0) {
          return Response.json({ error: "Your account was verified, but no active TradeFlow business could be found." }, { status: 403 });
        }
        return Response.json({ ...authBody, memberships }, { headers: { "Cache-Control": "no-store" } });
      } catch (error) {
        return Response.json({ error: error?.message || "Subscriber sign in failed." }, { status: 500 });
      }
    }
    if (url.pathname === "/subscriber-runtime-config.js") {
      const isTest = env.TRADEFLOW_ENV !== "production";
      const supabaseUrl = isTest ? env.TEST_SUPABASE_URL : env.LIVE_SUPABASE_URL;
      const supabaseKey = isTest ? env.TEST_SUPABASE_KEY : env.LIVE_SUPABASE_KEY;
      return new Response(`window.TRADEFLOW_CONFIG={environment:${JSON.stringify(isTest ? "test" : "production")},supabaseUrl:${JSON.stringify(supabaseUrl)},supabasePublishableKey:${JSON.stringify(supabaseKey)}};`, {
        headers: { "content-type": "application/javascript; charset=UTF-8", "cache-control": "no-store" },
      });
    }
    const asset = await env.ASSETS.fetch(assetFetchRequest);

    if (!assetPath && url.pathname === "/platform-owner-dashboard.html") {
      const headers = new Headers(asset.headers);
      headers.set("cache-control", "no-store");
      return new Response(asset.body, { status: asset.status, statusText: asset.statusText, headers });
    }

    if (!assetPath && (!url.pathname.endsWith(".js") || !asset.ok)) {
      if (url.pathname.endsWith(".html") && asset.ok) {
        const headers = new Headers(asset.headers);
        headers.set("cache-control", "no-store");
        return new Response(asset.body, { status: asset.status, statusText: asset.statusText, headers });
      }
      return asset;
    }

    if (assetPath) {
      const headers = new Headers(asset.headers);
      headers.set("cache-control", "no-store");
      return new Response(asset.body, { status: asset.status, statusText: asset.statusText, headers });
    }

    const source = await asset.text();
    const pairs = REPLACEMENT_PAIRS[env.TRADEFLOW_ENV] || REPLACEMENT_PAIRS.test;
    let transformed = pairs(env).reduce((body, [from, to]) => replaceAll(body, from, to), source);

    const runtimePairs = env.TRADEFLOW_ENV === 'production' ? [['__TRADEFLOW_LIVE_KEY__', env.LIVE_SUPABASE_KEY]] : [['__TRADEFLOW_TEST_KEY__', env.TEST_SUPABASE_KEY]];
    transformed = runtimePairs.reduce((body, [from, to]) => replaceAll(body, from, to), transformed);

    const testKey = env[["TEST", "SUPABASE", "KEY"].join("_")];
    if (env.TRADEFLOW_ENV === "test" && testKey) {
      const marker = ["U", "K", "V"].join("");
      const legacyMarker = ["K", "V"].join("");
      const activeTestKey = testKey.includes(marker) ? testKey : testKey.replace(legacyMarker, marker);
      const legacyKey = activeTestKey.replace(marker, legacyMarker);
      transformed = replaceAll(transformed, legacyKey, activeTestKey);
    }

    const headers = new Headers(asset.headers);
    headers.set("content-type", "application/javascript; charset=UTF-8");
    headers.set("cache-control", "no-store");
    return new Response(transformed, { status: asset.status, statusText: asset.statusText, headers });
  },
};