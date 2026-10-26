#!/usr/bin/env node
/**
 * Enrich summary-only Pokémon TCG card rows with verified TCGdex card details.
 *
 * Safe by default: dry-run unless --write is passed.
 * Required environment variables:
 *   SUPABASE_URL
 *   SUPABASE_SERVICE_ROLE_KEY
 *
 * Examples:
 *   node scripts/pokemon-tcg-enrich-details.mjs --limit 25
 *   node scripts/pokemon-tcg-enrich-details.mjs --limit 25 --write
 *
 * Run against TEST first. Only target LIVE after the TEST batch is verified.
 * This script updates only rows whose card_category is null and whose source
 * language is English. It never changes product catalogue or valuation tables.
 */
const args = new Set(process.argv.slice(2));
const writeEnabled = args.has("--write");
const limitArg = process.argv.slice(2).find((arg) => arg.startsWith("--limit="));
const limitFlagIndex = process.argv.indexOf("--limit");
const rawLimit = limitArg?.split("=")[1] ?? (limitFlagIndex >= 0 ? process.argv[limitFlagIndex + 1] : "25");
const batchLimit = Number.parseInt(rawLimit, 10);
const pageSize = Math.min(Math.max(Number.isFinite(batchLimit) ? batchLimit : 25, 1), 250);
const pauseMs = 120;
const apiBase = (process.env.TCGDEX_API_BASE || "https://api.tcgdex.net/v2").replace(/\/$/, "");
const supabaseUrl = process.env.SUPABASE_URL?.replace(/\/$/, "");
const serviceKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!supabaseUrl || !serviceKey) {
  console.error("Missing SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY.");
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
  selectUrl.searchParams.set("select", "id,card_key,name,source_language,source_payload");
  selectUrl.searchParams.set("card_category", "is.null");
  selectUrl.searchParams.set("source_language", "eq.en");
  selectUrl.searchParams.set("order", "card_key.asc");
  selectUrl.searchParams.set("limit", String(pageSize));

  const rows = await requestJson(selectUrl, { headers });
  let enriched = 0;
  let skipped = 0;
  let failed = 0;

  console.log(`Mode: ${writeEnabled ? "WRITE" : "DRY RUN"}; rows fetched: ${rows.length}; batch limit: ${pageSize}`);

  for (const row of rows) {
    const payload = row.source_payload && typeof row.source_payload === "object" ? row.source_payload : {};
    const cardId = payload.summary?.id;
    if (!cardId || typeof cardId !== "string") {
      console.warn(`SKIP ${row.card_key}: no source_payload.summary.id`);
      skipped += 1;
      continue;
    }

    try {
      const detailUrl = `${apiBase}/en/cards/${encodeURIComponent(cardId)}`;
      const detail = await requestJson(detailUrl);
      const category = detail?.category;
      if (!["Pokemon", "Trainer", "Energy"].includes(category)) {
        console.warn(`SKIP ${row.card_key}: unsupported/missing source category ${String(category)}`);
        skipped += 1;
        continue;
      }

      const nextPayload = {
        ...payload,
        detail,
        detail_source_url: detailUrl,
        detail_retrieved_at: new Date().toISOString(),
        detail_level: "full_card",
      };

      if (writeEnabled) {
        const patchUrl = new URL(`${supabaseUrl}/rest/v1/pokemon_tcg_cards`);
        patchUrl.searchParams.set("id", `eq.${row.id}`);
        patchUrl.searchParams.set("card_category", "is.null");
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

      enriched += 1;
      console.log(`${writeEnabled ? "UPDATED" : "WOULD UPDATE"} ${row.card_key}: ${row.name} → ${category}`);
    } catch (error) {
      failed += 1;
      console.error(`FAIL ${row.card_key}: ${error instanceof Error ? error.message : String(error)}`);
    }
    await sleep(pauseMs);
  }

  console.log(JSON.stringify({
    mode: writeEnabled ? "write" : "dry-run",
    fetched: rows.length,
    enriched,
    skipped,
    failed,
    moreLikelyRemain: rows.length === pageSize,
  }, null, 2));

  if (failed > 0) process.exitCode = 2;
}

main().catch((error) => {
  console.error(error instanceof Error ? error.stack : String(error));
  process.exit(1);
});
