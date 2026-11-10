CREATE OR REPLACE FUNCTION public.platform_owner_refresh_manual_ai_research_prompt(p_prompt_id uuid)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO ''
AS $function$
DECLARE
 v_prompt public.platform_manual_ai_research_prompts;
 v_batch public.platform_manual_ai_research_batches;
 v_research_task text;
 v_prompt_text text;
BEGIN
 if not public.platform_cloud_ai_owner_check() then raise exception 'Platform owner access required'; end if;
 select p.* into v_prompt
 from public.platform_manual_ai_research_prompts p
 join public.platform_manual_ai_research_batches b on b.id=p.batch_id
 where p.id=p_prompt_id and b.created_by=auth.uid()
 for update of p;
 if not found then raise exception 'Research prompt not found'; end if;
 if v_prompt.status <> 'ready' or v_prompt.response_draft is not null or v_prompt.response_text is not null then
  raise exception 'Only an unstarted prompt with no saved response can be regenerated. Existing drafts and submitted responses are preserved.';
 end if;
 select b.* into v_batch from public.platform_manual_ai_research_batches b
 where b.id=v_prompt.batch_id and b.created_by=auth.uid();
 if not found then raise exception 'Research batch not found'; end if;
 v_research_task := 'RESEARCH OBJECTIVE: Research the selected product and return a useful UK new-versus-used price comparison, with source links. This is live web research, not a memory exercise. Browse the web actively, search several different sites, and open promising pages where possible. Do not stop after one or two search results. ' ||
    'IMPORTANT PRODUCT-MATCH RULE: the selected catalogue row gives the exact manufacturer, model and requested package. First search for that exact package. THEN deliberately broaden the search to the same exact camera/model sold on its own and in other bundles or packages. Do NOT discard same-model results just because the bundle differs. Those alternative packages are useful market comparisons, but must be clearly labelled as COMPARISON ONLY and must never be presented as the price of the requested package. Do not substitute a different camera model. ' ||
    'For every price, identify the actual package listed by the source: standard camera only, Cycling Combo, Creator Combo, Motorcycle Combo, card bundle, accessory bundle, or the precise package title shown. Record the actual package name as package_name, and separately repeat the selected catalogue package as catalogue_package_name. Set package_match to exact_package when the actual package is the same as the catalogue package; same_model_other_package when it is the same exact model but the package/bundle differs; or package_not_stated when the source does not make the package clear. Never label an alternative package as exact_package. ' ||
    'SEARCH DEPTH: for each catalogue product run at least five distinct searches, not just repeated wording. Cover (1) exact manufacturer + model + requested package, (2) exact model + UK price, (3) exact model + major UK retailers, (4) exact model + used/second-hand UK, and (5) exact model + other bundle names / standard camera / refurbished. Follow useful leads into eBay UK, Amazon UK, manufacturer UK/official store, specialist retailers, used dealers, price-comparison sites and relevant marketplaces. Search retailer and marketplace names individually, not just one broad query. Include the actual queries in search_queries_used. ' ||
    'SOURCE AND PAGE ACCESS: distinguish retailer_product_page, marketplace_listing, manufacturer_product_page, price_aggregator, editorial_review, category_page and search_snippet. Set page_access to opened only if you actually opened and inspected the page; otherwise use blocked, snippet_only or quoted_by_secondary_source. Never claim to have opened a page that blocked access or was only mentioned by another site. Prefer individual item/listing URLs. A category/search URL or aggregator can still be reported as a comparison reference if it genuinely displays the model and price, but it is comparison_only, not approved product evidence. Editorial articles are context, not retail listings. ' ||
    'UK NEW PRICES: search current UK retailer product pages and new/brand-new marketplace listings. Keep Amazon marketplace seller offers distinct from direct retailer sales. Record exact displayed GBP price, condition, availability, seller/retailer and direct URL. ' ||
    'UK USED PRICES: search current UK used, pre-owned, open-box and refurbished listings separately. Record the individual asking price, seller, exact model, actual package if known, condition, availability and listing URL. Keep used and open-box/never-used conditions distinct. Do not infer a used value from a new price. Ended/sold listings may be mentioned as historical context but not as current active asking prices. ' ||
    'PRICE-COMPARISON REPORT: before the data block, write a readable report with separate tables for NEW UK prices and USED UK prices. Show the package name beside every price. Separate exact requested-package results from same-model alternative-package results. Include links to every source. Explain when a source is an aggregator, editorial review, import marketplace, search snippet or inaccessible page. Summarise what the results mean and state clearly if the exact requested package could not be found even though same-model alternatives were found. Never invent an exact-package price. Foreign-currency prices may be mentioned in a clearly separate international context section only; never convert them and never enter them as UK findings. ' ||
    'EVIDENCE QUALITY: direct, opened retailer or individual marketplace pages for the exact requested package are catalogue evidence candidates. Same-model alternative bundles, standard-camera listings, package-unclear offers, price aggregators, editorial pages, category pages and blocked/snippet-only results are comparison_only. The TradeFlow validator will keep those comparisons separate so they cannot inflate the selected catalogue package evidence count. Do not hide comparison results merely because they are not importable evidence. ' ||
    'NO RESULT: only use not_found when no useful UK GBP result for the exact model itself was found at all. If the exact requested package was unavailable but another package or the standard camera was found, put those prices in findings as comparison_only and explain the missing exact package in research_notes; do not mark the whole product not_found. ' ||
    'OUTPUT FORMAT: after the readable report, include one final fenced JSON code block labelled json. It must be valid strict JSON using straight ASCII double quotes, with no comments or trailing commas. Do not use curly smart quotes in the JSON. The top-level object must have schema_version "tradeflow_manual_research_v1", findings array, and not_found array. Each finding must contain product_id (the exact supplied catalogue UUID), manufacturer, model, catalogue_package_name (the selected catalogue package), package_name (the actual package on the source page), package_match (exact_package, same_model_other_package, or package_not_stated), evidence_role (catalogue_evidence or comparison_only), product_match ("exact" for the same exact camera/model), evidence_type ("uk_new" or "uk_used"), source_name, source_url, source_kind, page_access, price_gbp (number), currency ("GBP"), item_condition, availability, observed_at (YYYY-MM-DD), source_excerpt (short quote/snippet that shows the model and price), search_queries_used (at least five distinct queries for this product), and research_notes. Use one finding per distinct source and price. Keep comparison_only results in findings; do not omit them. ' ||
    'Each not_found entry must contain product_id, manufacturer, model, package_name (the selected catalogue package), searches_attempted (at least five distinct queries), sources_checked (at least two sources), and reason. Every selected product must appear in findings or not_found. ' ||
    'Before answering, check that the package shown beside each price matches the source, that new and used have not been mixed, that the actual model is the same model, that prices are GBP, that every link goes to the described source, and that exact package evidence is not confused with comparisons.';
 v_prompt_text :=
  'TRADEFLOW — MANUAL UK PRODUCT PRICE COMPARISON RESEARCH' || E'\n' ||
  'Assistant: ' || v_batch.assistant_name || E'\n' ||
  'Research date: ' || to_char(current_date,'FMDD FMMonth YYYY') || E'\n' ||
  'Prompt batch: ' || v_prompt.prompt_number || E'\n\n' ||
  v_research_task || E'\n\n' ||
  'PRODUCTS TO RESEARCH (catalogue data supplied by TradeFlow; use as authoritative identity data):' || E'\n' ||
  v_prompt.products_snapshot::text || E'\n\n' ||
  'Return the complete readable price-comparison report followed by the final valid JSON code block. Do not replace the tables and source links with JSON only. Do not omit any selected product: every supplied product_id must appear either in findings or not_found.';
 update public.platform_manual_ai_research_prompts
 set prompt_text=v_prompt_text,updated_at=now()
 where id=v_prompt.id;
 return jsonb_build_object('refreshed',true,'prompt_id',v_prompt.id,'batch_id',v_prompt.batch_id,'assistant_name',v_batch.assistant_name,'products',array_length(v_prompt.product_ids,1));
END;
$function$;
REVOKE ALL ON FUNCTION public.platform_owner_refresh_manual_ai_research_prompt(uuid) FROM public,anon;
GRANT EXECUTE ON FUNCTION public.platform_owner_refresh_manual_ai_research_prompt(uuid) TO authenticated;
