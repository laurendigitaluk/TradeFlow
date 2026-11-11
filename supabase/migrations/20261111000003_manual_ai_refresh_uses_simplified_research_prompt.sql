-- Ensure refreshing an unstarted manual research prompt uses the same simplified rules as new batches.

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
 v_research_task := $research$
Research EVERY product in this prompt. Cover all products before spending extra time on one.

For each product:
1. Search UK sources for the exact manufacturer, model and requested package. Check NEW and USED prices separately.
2. Start with one targeted UK-new search and one targeted UK-used search. Use a further search only when needed to find or clarify a real product page. Use the category-specific UK source directory below as a starting point.
3. Open the actual retailer or individual listing page before reporting a price. Record the direct page URL, displayed GBP price, exact model, actual package, condition, availability and date checked. A search snippet or category page is not an opened product page; if that is all you can access, label it comparison_only and say snippet_only/category_page.
4. Same exact model in another bundle/package is useful, but label it comparison_only and name the actual package. Never substitute a different model or claim an alternative bundle is the requested package.
5. Keep UK-new and UK-used separate. Keep VAT-exclusive prices clearly labelled. Do not convert foreign prices or invent missing information.
6. Aim for up to two good distinct UK sources for NEW and two for USED per product when available. Do not keep searching to fill a quota. First make sure EVERY product in this prompt has been checked.
7. If no reliable price is found, include that product in not_found with the actual searches and at least two source sites checked. Never omit a selected product.

Return ONE valid JSON object only, with no Markdown fences or report before or after it:
{"schema_version":"tradeflow_manual_research_v1","findings":[...],"not_found":[...]}.

Each finding must include: product_id (exact supplied UUID), manufacturer, model, package_name (actual source package), evidence_type ("uk_new" or "uk_used"), source_name, source_url (direct page URL), price_gbp (number), currency ("GBP"), item_condition, availability, observed_at ("YYYY-MM-DD"), product_match ("exact" or "likely"), source_excerpt (short verbatim text showing the model and price), search_queries_used (the actual two or more searches used for this product), and research_notes. Add package_match ("exact_package", "same_model_other_package" or "package_not_stated") and evidence_role ("catalogue_evidence" or "comparison_only") where relevant.

Each not_found entry must include product_id, manufacturer, model, package_name, searches_attempted (at least two actual searches), sources_checked (at least two site names), and reason.

Before returning, check that every supplied product_id appears in findings or not_found, every price is UK GBP, new and used are separate, the model/package match is correctly labelled, and each reported URL and quote supports the price.
$research$;
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
