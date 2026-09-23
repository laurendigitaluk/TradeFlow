import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "GET, OPTIONS"
};

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });
  const listingId = new URL(req.url).searchParams.get("listing_id");
  if (!listingId) return new Response(JSON.stringify({ error: "listing_id is required" }), { status: 400, headers: { ...cors, "Content-Type": "application/json" } });

  const supabase = createClient(Deno.env.get("SUPABASE_URL")!, Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!);
  const { data: listing } = await supabase.from("listings").select("id,tenant_id,status,category_id,channel_id").eq("id", listingId).eq("status","published").maybeSingle();
  if (!listing) return new Response(JSON.stringify({ error: "Published listing not found" }), { status: 404, headers: { ...cors, "Content-Type": "application/json" } });

  const { data: category } = await supabase.from("categories").select("id").eq("id",listing.category_id).eq("tenant_id",listing.tenant_id).eq("active",true).eq("selling_enabled",true).maybeSingle();
  const { data: channel } = await supabase.from("sales_channels").select("id").eq("id",listing.channel_id).eq("tenant_id",listing.tenant_id).eq("active",true).maybeSingle();
  const { data: siteState } = await supabase.from("tenant_site_state").select("published_revision_id").eq("tenant_id",listing.tenant_id).maybeSingle();
  if (!category || !channel || !siteState?.published_revision_id) return new Response(JSON.stringify({ error: "Listing is not eligible for public display" }), { status: 404, headers: { ...cors, "Content-Type": "application/json" } });
  const { data: revision } = await supabase.from("site_revisions").select("id").eq("id",siteState.published_revision_id).eq("tenant_id",listing.tenant_id).eq("status","published").maybeSingle();
  if (!revision) return new Response(JSON.stringify({ error: "Published site revision not found" }), { status: 404, headers: { ...cors, "Content-Type": "application/json" } });

  const { data: media } = await supabase.from("listing_media").select("media_asset_id,sort_order,media_assets(storage_bucket,storage_path,original_filename)").eq("listing_id",listingId).order("sort_order",{ascending:true});
  const output = [];
  for (const row of media ?? []) {
    const asset = row.media_assets;
    if (!asset?.storage_bucket || !asset?.storage_path) continue;
    const { data: signed } = await supabase.storage.from(asset.storage_bucket).createSignedUrl(asset.storage_path,3600);
    if (signed?.signedUrl) output.push({ listing_id:listingId, sort_order:row.sort_order??0, original_filename:asset.original_filename??"", signed_url:signed.signedUrl });
  }
  return new Response(JSON.stringify({ media: output }), { headers: { ...cors, "Content-Type": "application/json", "Cache-Control": "public, max-age=300" } });
});