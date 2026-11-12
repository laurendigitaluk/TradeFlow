import { createHash } from "node:crypto";
import { readFileSync } from "node:fs";
import { readdirSync } from "node:fs";
import { join } from "node:path";

const base = "CHECKPOINTS";
const files = readdirSync(base).filter((f) => /^2026-11-12-scheduled-market-evidence-batch-(0[3-9]|1[0-3])\.md$/.test(f)).sort();
if (files.length !== 11) throw new Error(`Expected 11 research checkpoints, found ${files.length}`);
const uuid = /[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/ig;
const urlPattern = /https?:\/\/[^\s)\]>]+/g;
const records = [];
for (const file of files) {
  const body = readFileSync(join(base, file), "utf8");
  const matches = [...body.matchAll(uuid)];
  for (let i = 0; i < matches.length; i++) {
    const id = matches[i][0].toLowerCase();
    const start = Math.max(body.lastIndexOf("\n### ", matches[i].index), body.lastIndexOf("\n---", matches[i].index), 0);
    const next = matches[i + 1]?.index ?? body.length;
    let block = body.slice(start, next).trim();
    if (!block.includes(id)) continue;
    const heading = block.match(/^###\s+(.+)$/m)?.[1] || block.match(/^[-*]\s+(.+)$/m)?.[1] || "";
    const cleanHeading = heading.replace(/^\d+[.)]\s*/, "").replace(/\*\*/g, "").trim();
    const idPos = block.toLowerCase().indexOf(id);
    const before = block.slice(0, idPos);
    const after = block.slice(idPos);
    const label = cleanHeading || before.split("\n").filter(Boolean).slice(-1)[0]?.replace(/[*#]/g, "").trim() || "";
    const parts = label.split(/\s+[—–-]\s+/).map(s => s.trim()).filter(Boolean);
    let manufacturer = parts[0] || "Unknown manufacturer";
    let model = parts.slice(1).join(" — ") || label || "Unresolved product";
    const urls = [...new Set((block.match(urlPattern) || []).map(u => u.replace(/[.,;]+$/, "")))];
    const productId = id;
    if (!urls.length) continue;
    const batch = file.match(/batch-(\d+)/)?.[1] || "unknown";
    const sourceUrl = urls[0];
    const key = createHash("sha256").update(["checkpoint-2026-11-12", productId, ...urls].join("|").toLowerCase()).digest("hex");
    records.push({
      record_type: "evidence_candidate",
      status: "pending_review",
      dedupe_key: key,
      agent_name: "TradeFlow Background Checkpoint Importer",
      task_key: `scheduled-market-evidence-batch-${batch}`,
      manufacturer,
      model,
      source_url: sourceUrl,
      source_name: "Research checkpoint source",
      source_record_key: `checkpoint:${file}:${productId}`,
      source_excerpt: block.slice(0, 12000),
      research_notes: "Imported as a research reference for manual review. Source-to-price matching is not assumed. RED VERIFY where stated in checkpoint. Foreign currency, sold-out/ended listings and no-price leads are retained in raw payload and must not influence valuation unless independently verified.",
      availability: "research reference; review required",
      raw_payload: {
        origin: "production GitHub checkpoint",
        checkpoint_file: file,
        master_product_id: productId,
        source_urls: urls,
        checkpoint_record: block.slice(0, 20000),
        import_policy: "No price copied unless independently source-matched; no foreign-currency conversion; no automatic approval."
      }
    });
  }
}
const unique = [...new Map(records.map(r => [r.dedupe_key, r])).values()];
if (unique.length < 180 || unique.length > 260) throw new Error(`Unexpected extracted product count: ${unique.length}; refusing import`);
const url = process.env.SUPABASE_URL;
const key = process.env.SUPABASE_SERVICE_ROLE_KEY;
if (!url || !key) throw new Error("Missing SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY GitHub Actions secret");
let inserted = 0;
for (let i = 0; i < unique.length; i += 50) {
  const batch = unique.slice(i, i + 50);
  const response = await fetch(`${url.replace(/\/$/, "")}/rest/v1/platform_catalogue_research_queue?on_conflict=dedupe_key`, {
    method: "POST",
    headers: {
      apikey: key,
      Authorization: `Bearer ${key}`,
      "Content-Type": "application/json",
      Prefer: "resolution=ignore-duplicates,return=representation"
    },
    body: JSON.stringify(batch)
  });
  if (!response.ok) throw new Error(`Supabase import failed HTTP ${response.status}: ${(await response.text()).slice(0, 1000)}`);
  const saved = await response.json();
  inserted += saved.length;
}
console.log(JSON.stringify({ checkpoints: files.length, extracted_unique_products: unique.length, inserted, duplicates_or_existing: unique.length - inserted }, null, 2));
