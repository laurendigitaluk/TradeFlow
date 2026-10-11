import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "GET, OPTIONS"
};

const json = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { ...cors, "Content-Type": "application/json" }
  });

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });
  if (req.method !== "GET") return json({ error: "GET required" }, 405);

  const auth = req.headers.get("Authorization");
  if (!auth) return json({ error: "Authentication required" }, 401);

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
  );

  const { data: { user }, error: userError } =
    await supabase.auth.getUser(auth.replace(/^Bearer\s+/i, ""));

  if (userError || !user) return json({ error: "Authentication required" }, 401);

  const url = new URL(req.url);
  const tenantId = url.searchParams.get("tenant_id");
  const buyingItemId = url.searchParams.get("buying_item_id");
  const inventoryAssetId = url.searchParams.get("inventory_asset_id");

  if (!tenantId || (!buyingItemId && !inventoryAssetId)) {
    return json({ error: "tenant_id and buying_item_id or inventory_asset_id are required" }, 400);
  }

  const { data: membership } = await supabase
    .from("tenant_memberships")
    .select("tenant_id")
    .eq("tenant_id", tenantId)
    .eq("user_id", user.id)
    .eq("status", "active")
    .maybeSingle();

  if (!membership) return json({ error: "Tenant membership required" }, 403);

  const links: { media_asset_id: string; sort_order: number; source: string }[] = [];

  if (buyingItemId) {
    const { data, error } = await supabase
      .from("buying_item_media")
      .select("media_asset_id,sort_order")
      .eq("tenant_id", tenantId)
      .eq("buying_item_id", buyingItemId)
      .order("sort_order", { ascending: true });

    if (error) return json({ error: error.message }, 500);
    for (const row of data ?? []) {
      if (row.media_asset_id) links.push({
        media_asset_id: row.media_asset_id,
        sort_order: row.sort_order ?? 0,
        source: "buying"
      });
    }
  }

  if (inventoryAssetId) {
    const { data, error } = await supabase
      .from("inventory_asset_media")
      .select("media_asset_id,sort_order")
      .eq("tenant_id", tenantId)
      .eq("inventory_asset_id", inventoryAssetId)
      .order("sort_order", { ascending: true });

    if (error) return json({ error: error.message }, 500);
    for (const row of data ?? []) {
      if (row.media_asset_id) links.push({
        media_asset_id: row.media_asset_id,
        sort_order: row.sort_order ?? 0,
        source: "inventory"
      });
    }
  }

  const uniqueLinks = links.filter((x, i, a) =>
    a.findIndex(y => y.media_asset_id === x.media_asset_id) === i
  );

  const ids = uniqueLinks.map(x => x.media_asset_id);
  if (!ids.length) return json({ media: [] });

  const { data: assets, error: assetError } = await supabase
    .from("media_assets")
    .select("id,original_filename,storage_bucket,storage_path,asset_kind,mime_type,byte_size")
    .eq("tenant_id", tenantId)
    .in("id", ids);

  if (assetError) return json({ error: assetError.message }, 500);

  const byId = Object.fromEntries((assets ?? []).map(x => [x.id, x]));
  const media = [];

  for (const link of uniqueLinks) {
    const asset = byId[link.media_asset_id];
    if (!asset?.storage_bucket || !asset?.storage_path) continue;

    const { data: signed, error: signError } = await supabase.storage
      .from(asset.storage_bucket)
      .createSignedUrl(asset.storage_path, 86400);

    if (signError || !signed?.signedUrl) continue;

    media.push({
      id: asset.id,
      sort_order: link.sort_order ?? 0,
      source: link.source,
      asset_kind: asset.asset_kind ?? null,
      original_filename: asset.original_filename ?? "Customer photo",
      mime_type: asset.mime_type ?? null,
      byte_size: asset.byte_size ?? null,
      signed_url: signed.signedUrl
    });
  }

  return json({ media });
});