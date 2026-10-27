#!/usr/bin/env node
/**
 * Reconcile English Pokémon TCG source categories against canonical TCGdex card details.
 *
 * Safe by default: dry-run only. This script updates pokemon_tcg_cards only.
 * It does not update catalogue_master_products, tenant selections, or valuation rules.
 *
 * Required environment:
 *   SUPABASE_URL
 *   SUPABASE_SERVICE_ROLE_KEY
 *
 * Usage:
 *   node scripts/pokemon-tcg-reconcile-categories.mjs --limit=25
 *   node scripts/pokemon-tcg-reconcile-categories.mjs --after=base1:99:en --limit=100
 *   node scripts/pokemon-tcg-reconcile-categories.mjs --after=base1:99:en --limit=100 --repair-existing --write
 *
 * For correction of already-populated categories, both --repair-existing and --write are required.
 * Work in TEST first. Use NEXT_AFTER output to resume in bounded batches.
 */
const args = new Set(process.argv.slice(2));
const writeEnabled = args.has("--write");
const repairExisting = args.has("--repair-existing");
const readArg = (name, fallback = "") => {
  const inline = process.argv.find((arg) => arg.startsWith(`${name}=`));
  if (inline) return inline.slice(name.length + 1);
  const index = process.argv.indexOf(name);
  return index >= 0 ? (process.argv[index + 1] ?? fallback) : fallback;
};
const rawLimit = Number.parseInt(readArg("--limit", "25"), 10);
const batchLimit = Math.min(Math.max(Number.isFinite(rawLimit) ? rawLimit : 25, 1), 250);
const afterKey = readArg("--after", "");
const pauseMs = 120;
const apiBase = (process.env.TCGDEX_API_BASE || "https://api.tcgdex.net/v2").replace(/\/$/, "");
const supabaseUrl = process.env.SUPABASE_URL?.replace(/\/$/, "");
const serviceKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!supabaseUrl || !serviceKey) {
  console.error("Missing SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY.");
  process.exit(1);
}
if (writeEnabled && !repairExisting) {
  console.error("Refusing to write existing category values without --repair-existing.");
  process.exit(1);
}

const headers = {
  apikey: serviceKey,
  Authorization: `Bearer ${serviceKey}`,
  "Content-Type": "application/json",
};
const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

async function requestJson(url, options = {}, retries = 4) {
  let lastError;
  for (let attempt = 0; attempt <= retries; attempt += 1) {
    try {
      const response = await fetch(url, options);
      if (response.ok) return await response.json();
      const body = await response.text();
      if (![429, 500, 502, 503, 504].includes(response.status)) {
        throw new Error(`HTTP ${response.status} for ${url}: ${body.slice(0, 250)}`);
      }
      lastError = new Error(`HTTP ${response.status} for ${url}`);
    } catch (error) {
      lastError = error;
    }
    if (attempt < retries) await sleep(500 * (attempt + 1));
  }
  throw lastError;
}

async function main() {
  const selectUrl = new URL(`${supabaseUrl}/rest/v1/pokemon_tcg_cards`);
  selectUrl.searchParams.set("select", "id,card_key,name,source_language,source_payload,card_category");
  selectUrl.searchParams.set("source_language", "eq.en");
  selectUrl.searchParams.set("order", "card_key.asc");
  selectUrl.searchParams.set("limit", String(batchLimit));
  if (afterKey) selectUrl.searchParams.set("card_key", `gt.${afterKey}`);
  // Dry-runs inspect existing values too; writes are separately guarded by --repair-existing.

  const rows = await requestJson(selectUrl, { headers });
  let checked = 0;
  let changed = 0;
  let same = 0;
  let skipped = 0;
  let failed = 0;
  console.log(JSON.stringify({
    mode: writeEnabled ? "WRITE" : "DRY RUN",
    repairExisting,
    fetched: rows.length,
    afterKey: afterKey || null,
  }));

  for (const row of rows) {
    const payload = row.source_payload && typeof row.source_payload === "object" ? row.source_payload : {};
    const cardId = payload.summary?.id;
    if (!cardId || typeof cardId !== "string") {
      console.warn(`SKIP ${row.card_key}: no source_payload.summary.id; requires separate source-key recovery`);
      skipped += 1;
      continue;
    }

    try {
      const detailUrl = `${apiBase}/en/cards/${encodeURIComponent(cardId)}`;
      const detail = await requestJson(detailUrl);
      const category = detail?.category;
      if (!["Pokemon", "Trainer", "Energy"].includes(category)) {
        console.warn(`SKIP ${row.card_key}: unsupported/missing canonical category ${String(category)}`);
        skipped += 1;
        continue;
      }
      checked += 1;
      const nextPayload = {
        ...payload,
        detail,
        detail_source_url: detailUrl,
        detail_retrieved_at: new Date().toISOString(),
        detail_level: "full_card",
      };
      if (category === row.card_category) {
        same += 1;
      } else {
        console.log(`${writeEnabled ? "UPDATE" : "WOULD UPDATE"} ${row.card_key}: ${row.name} | ${row.card_category ?? "null"} -> ${category}`);
        changed += 1;
      }

      if (writeEnabled && (category !== row.card_category || payload.detail_level !== "full_card")) {
        const patchUrl = new URL(`${supabaseUrl}/rest/v1/pokemon_tcg_cards`);
        patchUrl.searchParams.set("id", `eq.${row.id}`);
        patchUrl.searchParams.set("source_language", "eq.en");
        const response = await fetch(patchUrl, {
          method: "PATCH",
          headers: { ...headers, Prefer: "return=minimal" },
          body: JSON.stringify({ card_category: category, source_payload: nextPayload }),
        });
        if (!response.ok) {
          const body = await response.text();
          throw new Error(`Supabase PATCH ${response.status}: ${body.slice(0, 250)}`);
        }
      }
    } catch (error) {
      failed += 1;
      console.error(`FAIL ${row.card_key}: ${error instanceof Error ? error.message : String(error)}`);
    }
    await sleep(pauseMs);
  }

  console.log(JSON.stringify({
    checked,
    categoryDifferences: changed,
    alreadyCorrect: same,
    skipped,
    failed,
    nextAfter: rows.length ? rows[rows.length - 1].card_key : null,
    moreLikelyRemain: rows.length === batchLimit,
    mode: writeEnabled ? "write" : "dry-run",
  }, null, 2));
  if (failed > 0) process.exitCode = 2;
}
main().catch((error) => {
  console.error(error instanceof Error ? error.stack : String(error));
  process.exit(1);
});
