import "jsr:@supabase/functions-js/edge-runtime.d.ts";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const ALLOWED_ORIGINS = new Set(["https://tradeflow.laurendigital.co.uk", "https://www.scenesource.co.uk", "https://scenesource.co.uk", "https://laurendigitaluk.github.io"]);
const STRIPE_SECRET_KEY = Deno.env.get("STRIPE_SECRET_KEY") || "";
function corsHeaders(origin: string) {
  return {
    "Content-Type": "application/json",
    "Access-Control-Allow-Origin": ALLOWED_ORIGINS.has(origin) ? origin : "https://tradeflow.laurendigital.co.uk",
    "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
    "Vary": "Origin",
  };
}
const json = (body: unknown, status = 200, origin = "") =>
  new Response(JSON.stringify(body), { status, headers: corsHeaders(origin) });  const origin = req.headers.get("origin") || "";
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders(origin) });
  }

