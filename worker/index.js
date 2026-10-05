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
    const asset = await env.ASSETS.fetch(assetRequest);

    if (!assetPath && url.pathname === "/platform-owner-dashboard.html") {
      const headers = new Headers(asset.headers);
      headers.set("cache-control", "no-store");
      return new Response(asset.body, { status: asset.status, statusText: asset.statusText, headers });
    }

    if (!assetPath && (!url.pathname.endsWith(".js") || !asset.ok)) return asset;

    if (assetPath) {
      const headers = new Headers(asset.headers);
      headers.set("cache-control", "no-store");
      return new Response(asset.body, { status: asset.status, statusText: asset.statusText, headers });
    }

    const source = await asset.text();
    const pairs = REPLACEMENT_PAIRS[env.TRADEFLOW_ENV] || REPLACEMENT_PAIRS.test;
    let transformed = pairs(env).reduce((body, [from, to]) => replaceAll(body, from, to), source);

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