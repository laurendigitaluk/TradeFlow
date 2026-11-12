import { createHash } from "node:crypto";
import { readFileSync } from "node:fs";
import { readdirSync } from "node:fs";
import { join } from "node:path";

const base = "CHECKPOINTS";
const files = readdirSync(base).filter((f) => /^2026-11-12-scheduled-market-evidence-batch-(0[3-9]|1[0-3])\.md$/.test(f)).sort();
if (files.length !== 11) throw new Error(`Expected 11 research checkpoints, found ${files.length}`);
const records = [];
const idLine = /^(?:[-*]\s*)?\*{0,2}(?:LIVE\s+master\s+product\s+ID|Master\s+product\s+ID|LIVE\s+product\s+ID|Product\s+ID)\*{0,2}:\s*`?([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})/gim;
const urlPattern = /https?:\/\/[^\s)\]>]+/g;
for (const file of files) {
  const body = readFileSync(join(base, file), "utf8");
  const headings = [...body.matchAll(/^#{1,5}\s+\d+[.)]\s+(.+)$/gm)];
  const ids = [...body.matchAll(idLine)];
  for (let i = 0; i < ids.length; i++) {
    const match = ids[i];
    const heading = headings.filter(h => h.index < match.index).at(-1);
    const nextId = ids[i + 1]?.index ?? body.length;
    const start = heading?.index ?? match.index;
    const block = body.slice(start, nextId).trim();
    const label = (heading?.[1] || "").replace(/\*\*/g, "").trim();
    const parts = label.replace(/^\d+[.)]\s*/, "").split(/\s+[—–-]\s+/).map(s => s.trim()).filter(Boolean);
    const manufacturer = parts[0] || "Unresolved manufacturer";
    const model = parts.slice(1).join(" — ") || label || "Unresolved product";
    const urls = [...new Set((block.match(urlPattern) || []).map(u => u.replace(/[.,;]+$/, "")))];
    if (!urls.length) throw new Error(`No source URLs found for ${match[1]} in ${file}`);
    const productId = match[1].toLowerCase();
    const batch = file.match(/batch-(\d+)/)?.[1] || "unknown";
    const key = createHash("sha256").update(["checkpoint-2026-11-12", productId, ...urls].join("|").toLowerCase()).digest("hex");
    records.push({
      record_type: "evidence_candidate", status: "pending_review", dedupe_key: key,
      agent_name: "TradeFlow Background Checkpoint Importer",
      task_key: `scheduled-market-evidence-batch-${batch}`,
      manufacturer, model, source_url: urls[0], source_name: "Research checkpoint source",
      source_record_key: `checkpoint:${file}:${productId}`,
      source_excerpt: block.slice(0, 12000),
      research_notes: "Imported as a research reference for manual review. Source-to-price matching is not assumed. RED VERIFY where stated in checkpoint. Foreign currency, sold-out/ended listings and no-price leads are retained in raw payload and must not influence valuation unless independently verified.",
      availability: "research reference; review required",
      raw_payload: { origin:"production GitHub checkpoint", checkpoint_file:file, master_product_id:productId, source_urls:urls, checkpoint_record:block.slice(0,20000), import_policy:"No price copied unless independently source-matched; no foreign-currency conversion; no automatic approval." }
    });
  }
}
const unique = [...new Map(records.map(r => [r.dedupe_key, r])).values()];
if (unique.length !== 220) throw new Error(`Expected exactly 220 product records, extracted ${unique.length}; refusing import`);
const url = process.env.SUPABASE_URL;
const key = process.env.SUPABASE_SERVICE_ROLE_KEY;
if (!url || !key) throw new Error(`Missing GitHub Actions secrets: SUPABASE_URL=${!!url}, SUPABASE_SERVICE_ROLE_KEY=${!!key}`);
let inserted = 0;
for (let i = 0; i < unique.length; i += 50) {
  const response = await fetch(`${url.replace(/\/$/, "")}/rest/v1/platform_catalogue_research_queue?on_conflict=dedupe_key`, {
    method:"POST",
    headers:{apikey:key,Authorization:`Bearer ${key}`,"Content-Type":"application/json",Prefer:"resolution=ignore-duplicates,return=representation"},
    body:JSON.stringify(unique.slice(i,i+50))
  });
  if (!response.ok) throw new Error(`Supabase import failed HTTP ${response.status}: ${(await response.text()).slice(0,1000)}`);
  inserted += (await response.json()).length;
}
console.log(JSON.stringify({checkpoints:files.length,extracted_unique_products:unique.length,inserted,duplicates_or_existing:unique.length-inserted},null,2));
