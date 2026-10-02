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
    const asset = await env.ASSETS.fetch(request);

    if (!url.pathname.endsWith(".js") || !asset.ok) {
      return asset;
    }

    const source = await asset.text();
    const pairs = REPLACEMENT_PAIRS[env.TRADEFLOW_ENV] || REPLACEMENT_PAIRS.test;
    const transformed = pairs(env).reduce(
      (body, [from, to]) => replaceAll(body, from, to),
      source,
    );

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
