-- Improve Manual AI Research prompt quality and align output with the LIVE intake validator.
-- Prompt-generation change only: no candidate or shared evidence records are modified.

CREATE OR REPLACE FUNCTION public.platform_manual_ai_research_prompt_instructions()
RETURNS text
LANGUAGE sql
IMMUTABLE
PARALLEL SAFE
SET search_path TO ''
AS $helper$
  SELECT $prompt$TRADEFLOW — MANUAL UK PRICE RESEARCH — QUALITY RULES V2

PURPOSE
Research every selected catalogue product and produce accurate, traceable UK GBP price comparisons. The catalogue snapshot is authoritative for the selected manufacturer, model and package. Research is not complete merely because a search result contains a similar product or a price.

1. PRODUCT IDENTITY — CHECK BEFORE PRICE
- Preserve the exact supplied product_id, manufacturer, model and catalogue_package_name for every selected product.
- Verify manufacturer and exact model against manufacturer product/support information where available. Check suffixes, revisions, generations, mounts, storage, capacity and other identity-defining variants.
- Do not treat family resemblance as an exact match. Examples: Brave 7 is not Brave 7 LE; Brave 4 is not Brave 4 Pro; PL mount is not L mount when the selected identity specifies PL.
- Do not create a finding for a different model, sibling model, accessory, compatible part or product whose identity cannot be established. Mention it in the readable report only if it explains a gap.
- Keep selected catalogue package separate from the actual package shown by the source. Never rename an alternative bundle to make it look like the selected package.

2. RESEARCH COVERAGE — EVERY PRODUCT
- Work through every selected product. Do not spend the whole run researching only the first few products.
- For each product, run at least THREE distinct, product-specific searches and record the actual search strings used:
  A. exact manufacturer + exact model + exact requested package + UK;
  B. exact manufacturer + exact model + UK new retail price;
  C. exact manufacturer + exact model + UK used / pre-owned / refurbished price.
- If the exact package is not found, run a fourth targeted search for the same exact model in standard, body-only or alternative bundles. This is useful comparison research, not a reason to change the selected package.
- Search relevant sites in the LIVE category-specific source directory individually where useful. Use manufacturer, suitable UK retailers and suitable UK used dealers. Do not use one broad OR query as a substitute for distinct product searches.
- Three to five purposeful searches per product are normally enough. Follow promising direct product/listing pages; do not inflate the search count with repeated wording or unrelated results.
- A query used for one finding must genuinely have been used for that product. Never copy a generic query into every finding.

3. OPEN AND INSPECT THE ACTUAL SOURCE PAGE
- For each candidate price, open the direct product page or individual listing URL. Inspect the page itself, not just the search result.
- Confirm the page visibly identifies the exact model and shows the stated GBP price. Also check actual package/bundle, seller, condition, availability and relevant date/price context.
- Record the direct page URL actually inspected. Do not use a retailer homepage, category page, search URL, shop/search page or generic marketplace results page as if it were an individual product page.
- Set page_access to opened only after opening and inspecting that exact page. Otherwise use blocked, snippet_only or quoted_by_secondary_source accurately.
- If only a search snippet is available, preserve it as comparison_only only when the snippet itself clearly shows the exact model and GBP price and has a meaningful destination URL. Do not claim the destination page was opened.
- A manufacturer product-list page showing several products is category_page, not manufacturer_product_page. Use manufacturer_product_page only for an actual individual model page.
- A price-comparison site or aggregator is price_aggregator, not a retailer. Editorial articles are editorial_review, not retail listings.
- Allowed source_kind values: retailer_product_page, marketplace_listing, manufacturer_product_page, price_aggregator, editorial_review, category_page, search_snippet, other.
- Allowed page_access values: opened, blocked, snippet_only, quoted_by_secondary_source.

4. PRICE MUST BELONG TO THE EXACT ITEM
- The quoted price must be visibly associated with the exact model/product on that page. Do not pick a nearby price belonging to another model, bundle, seller, condition, option, accessory, product card or promotion.
- Do not use RRP, savings, finance instalments, delivery charges, deposits, trade-in values, price ranges or historical prices as the current item price.
- If a page shows multiple variants or used units, create separate findings only when each price can be tied to its own identifiable listing/SKU and condition.
- Keep VAT basis explicit. Prefer UK consumer prices including VAT for retail comparisons. If only an ex-VAT figure is shown, state that clearly and classify it as comparison_only; do not present it as an ordinary VAT-inclusive consumer price.
- Record the displayed numeric GBP price without converting currencies. Exclude overseas prices, foreign sellers and imported offers that are not clearly UK-local.
- source_excerpt must be a short verbatim excerpt from the source showing the exact model and displayed GBP price together (or two clearly separated verbatim fragments from the same page). Include £ or GBP. Never write your own paraphrase as a source quote.

5. NEW, USED AND AVAILABILITY MUST STAY SEPARATE
- evidence_type uk_new: genuinely new/brand-new retail stock or an explicitly new/sealed individual offer.
- evidence_type uk_used: used, pre-owned, refurbished, open-box or opened-never-used offers. Preserve precise item_condition wording; do not relabel opened-never-used as sealed/new.
- Keep refurbished, used, open-box and opened-never-used distinguishable in item_condition.
- Used-market prices are reference evidence only. They must not be described as automatic buying valuations or allowed to influence TradeFlow automatic buying valuation.
- Use availability conservatively: in_stock only when the page says so; listed when an active offer is visible but stock is not confirmed; out_of_stock when stated; sold only for a completed sale with realised price visible; ended for an ended listing; otherwise unknown.
- An eBay Best Offer sale with accepted amount hidden is not a known completed-sale price. Do not record original asking price as realised sale price.
- Do not treat sold/ended page as a current asking price. It may be retained as historical comparison only when actual sold price is visible.
- observed_at is the date you inspected the source, not an inferred listing date. If the page's own listing/sale date is visible, mention it separately in research_notes.

6. PACKAGE MATCH AND EVIDENCE ROLE — EXACT RULES
- catalogue_package_name must exactly repeat the selected package_name from the supplied catalogue snapshot.
- package_name must describe the actual package on the source page. Do not copy the catalogue package name unless the source actually shows that package.
- package_match must be exact_package only when actual source package is the same package as selected catalogue package; same_model_other_package when it is the same exact model but a different bundle/package; package_not_stated when the source does not make the package clear.
- Never classify a different model or identity-defining variant as same_model_other_package. That is a product mismatch, not a package difference.
- evidence_role must be catalogue_evidence only when ALL are true: product_match is exact; package_match is exact_package; the direct individual product/listing page was opened; source_kind is retailer_product_page, marketplace_listing or manufacturer_product_page; and displayed GBP price is clearly tied to that exact item.
- Every other result is comparison_only. This includes alternative packages, package-unclear results, category pages, aggregators, editorial pages, search snippets, blocked pages and quoted-by-secondary-source results.
- Keep useful same-model alternative-package prices in findings as comparison_only. Do not discard them, but do not inflate selected package evidence count.
- Keep every finding tied to selected product_id. Do not invent another product_id or silently reassign a finding to a different catalogue product. If an alternative package may correspond to another catalogue row not included in this prompt, identify that possibility in research_notes for later owner matching; do not claim it has been mapped or imported.

7. EXISTING EVIDENCE AND DUPLICATES
- Review existing_evidence_references supplied for each selected product before reporting a result.
- Do not repeat an existing source URL + price + evidence_type combination as a new finding. If it is re-opened, state in research_notes that it was re-verified and whether current page still supports the same price/condition/availability.
- If an old reference cannot be opened or is stale, say it was not re-verified. Do not silently treat it as current.
- Do not report the same listing twice because it appeared in more than one search result. One finding per distinct source/listing and price.
- Do not claim a result is current when page is inaccessible or its date/availability is unclear.

8. REQUIRED READABLE REPORT
Before the JSON, provide a concise but complete report with:
- Separate NEW UK and USED UK tables.
- For each row: selected catalogue product/package, actual source package, price, source link, condition, availability, VAT basis, page_access and evidence_role.
- Clearly distinguish exact-package catalogue-evidence candidates from comparison_only references.
- Summarise products with no useful exact-model result, stale or unverified existing references, conflicting prices, VAT ambiguity and source-access limitations.
- Do not hide useful comparisons, but never make a comparison look like verified catalogue evidence.
- Do not claim any source page was opened unless it was actually opened.

9. FINAL JSON — MATCH THE TRADEFLOW INTAKE VALIDATOR
After the readable report, output exactly ONE fenced code block labelled json. Do not output a plain 'json' label followed by raw JSON. Do not put prose, comments or trailing commas inside the JSON block. The report may precede it; the final block must contain one strict JSON object.

Top-level shape:
{"schema_version":"tradeflow_manual_research_v1","findings":[...],"not_found":[...]}

Every finding MUST contain ALL these fields:
product_id, manufacturer, model, catalogue_package_name, package_name, package_match, evidence_role, product_match, evidence_type, source_name, source_url, source_kind, page_access, price_gbp, currency, item_condition, availability, observed_at, source_excerpt, search_queries_used, research_notes.

Field rules:
- product_id: exact UUID supplied for the selected catalogue product.
- manufacturer, model and catalogue_package_name: exact identity values from that product snapshot.
- product_match: exact only. Do not submit likely/near matches.
- evidence_type: uk_new or uk_used.
- price_gbp: positive numeric GBP value; currency must be GBP.
- source_url: direct HTTPS URL to actual product/listing page or meaningful destination. Never invent or shorten it.
- source_excerpt: verbatim page text containing exact model and displayed £/GBP price.
- search_queries_used: array of at least THREE distinct actual queries for this product. Do not fabricate queries.
- observed_at: YYYY-MM-DD date actually inspected; never a future date.
- source_kind and page_access: use only exact allowed values above.
- package_match and evidence_role: follow section 6 exactly.

Every not_found entry MUST contain:
product_id, manufacturer, model, package_name, searches_attempted, sources_checked, reason.
Use not_found only when no useful UK GBP price for exact model itself was found. If exact package was unavailable but same exact model was found in another package, keep that result in findings as comparison_only and explain missing exact package in research_notes. Do not mark whole product not_found in that case.
Each not_found entry must list at least THREE actual distinct searches and at least TWO source sites checked.

Before finishing, confirm every selected product_id appears in findings or not_found, no wrong model or suffix has been included, every price is GBP, each quote supports displayed price, all page_access labels are truthful, every comparison is marked comparison_only, and final JSON is valid and fenced exactly as required.$prompt$::text;
$helper$;

REVOKE ALL ON FUNCTION public.platform_manual_ai_research_prompt_instructions() FROM PUBLIC, anon, authenticated;

DO $migration$
DECLARE
  v_signature regprocedure;
  v_definition text;
  v_start integer;
  v_end integer;
  v_marker text := '$research$;';
  v_replacement text := 'v_research_task := public.platform_manual_ai_research_prompt_instructions();';
BEGIN
  v_signature := 'public.platform_owner_create_manual_ai_research_batch(uuid[],text,integer,text)'::regprocedure;
  v_definition := pg_get_functiondef(v_signature);
  v_start := strpos(v_definition, 'v_research_task := $research$');
  v_end := CASE WHEN v_start > 0 THEN v_start + strpos(substr(v_definition, v_start), v_marker) - 1 ELSE 0 END;
  IF v_start = 0 OR v_end < v_start THEN
    RAISE EXCEPTION 'Could not locate research instructions in LIVE create-batch function; no function was changed.';
  END IF;
  v_definition := overlay(v_definition PLACING v_replacement FROM v_start FOR (v_end + length(v_marker) - v_start));
  EXECUTE v_definition;

  v_signature := 'public.platform_owner_refresh_manual_ai_research_prompt(uuid)'::regprocedure;
  v_definition := pg_get_functiondef(v_signature);
  v_start := strpos(v_definition, 'v_research_task := $research$');
  v_end := CASE WHEN v_start > 0 THEN v_start + strpos(substr(v_definition, v_start), v_marker) - 1 ELSE 0 END;
  IF v_start = 0 OR v_end < v_start THEN
    RAISE EXCEPTION 'Could not locate research instructions in LIVE refresh-prompt function; no function was changed.';
  END IF;
  v_definition := overlay(v_definition PLACING v_replacement FROM v_start FOR (v_end + length(v_marker) - v_start));
  EXECUTE v_definition;
END;
$migration$;

COMMENT ON FUNCTION public.platform_manual_ai_research_prompt_instructions()
IS 'Quality v2 manual research instructions aligned with platform_owner_submit_manual_ai_research_response validation.';
