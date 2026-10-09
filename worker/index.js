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

// TEST customer API boundary repair
export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    // Platform-owned hostnames keep the TradeFlow application/marketing homepage.
    // Subscriber-owned vanity domains must instead enter the public-site shell at "/".
    // The public-site JavaScript then resolves the tenant from published_site_index
    // using the actual request hostname.
    const hostname = url.hostname.toLowerCase();
    const platformHostnames = new Set([
      "tradeflow.laurendigital.co.uk",
      "tradeflow.leannelaurenlowe.workers.dev",
      "tradeflow-test.leannelaurenlowe.workers.dev",
      "laurendigital.co.uk",
      "www.laurendigital.co.uk",
      "localhost",
      "127.0.0.1",
    ]);
    const isSubscriberDomain = !platformHostnames.has(hostname) && !hostname.endsWith(".github.io");
    const cleanRoutes = {
      "/login": "/customer-dashboard.html",
      "/basket": "/customer-basket.html",
      "/assistant": "/customer-assistant.html",
      "/email-confirmed": "/customer-email-confirmed.html",
      "/reset-password": "/customer-password-reset.html",
      "/owner-reset-password": "/platform-owner-password-reset.html",
    };
    if (isSubscriberDomain) {
      cleanRoutes["/"] = "/public-site.html";
      // Public subscriber pages use clean paths such as /buying and /sell.
      // Keep the public-site application behind the Worker; static assets retain
      // normal ASSETS handling.
      if (
        url.pathname !== "/" &&
        !url.pathname.includes(".") &&
        !cleanRoutes[url.pathname]
      ) {
        cleanRoutes[url.pathname] = "/public-site.html";
      }
    }

    const assetPath = cleanRoutes[url.pathname];
    const assetRequest = assetPath
      ? new Request(new URL(assetPath + url.search, url.origin), request)
      : request;
    const asset = await env.ASSETS.fetch(assetRequest);

    // The protected platform owner dashboard must not be served from a stale
    // browser/edge cache. Its HTML selects the current dashboard JS asset.
    if (!assetPath && url.pathname === "/platform-owner-dashboard.html") {
      const headers = new Headers(asset.headers);
      headers.set("cache-control", "no-store");
      return new Response(asset.body, {
        status: asset.status,
        statusText: asset.statusText,
        headers,
      });
    }

    if (!assetPath && (!url.pathname.endsWith(".js") || !asset.ok)) {
      return asset;
    }

    if (assetPath) {
      const headers = new Headers(asset.headers);
      headers.set("cache-control", "no-store");
      return new Response(asset.body, {
        status: asset.status,
        statusText: asset.statusText,
        headers,
      });
    }

    const source = await asset.text();
    const pairs = REPLACEMENT_PAIRS[env.TRADEFLOW_ENV] || REPLACEMENT_PAIRS.test;
    let transformed = pairs(env).reduce(
      (body, [from, to]) => replaceAll(body, from, to),
      source,
    );

    // TEST compatibility: derive the active test key from the Worker
    // environment and repair the older frontend spelling at the boundary.
    const testKey = env[["TEST", "SUPABASE", "KEY"].join("_")];
    if (env.TRADEFLOW_ENV === "test" && testKey) {
      const marker = ["U", "K", "V"].join("");
      const legacyMarker = ["K", "V"].join("");
      const activeTestKey = testKey.includes(marker)
        ? testKey
        : testKey.replace(legacyMarker, marker);
      const legacyKey = activeTestKey.replace(marker, legacyMarker);
      transformed = replaceAll(transformed, legacyKey, activeTestKey);
    }

    const headers = new Headers(asset.headers);
    headers.set("content-type", "application/javascript; charset=UTF-8");
    headers.set("cache-control", "no-store");

    return new Response(transformed, {
      status: asset.status,
      statusText: asset.statusText,
      headers,
    });
  },
};
