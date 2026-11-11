do $migration$
declare
  v_definition text;
  v_old text := $old$
  v_evidence_role:=case
    when v_package_match='exact_package'
     and v_source_kind in ('retailer_product_page','marketplace_listing','manufacturer_product_page')
     and v_page_access='opened'
    then 'catalogue_evidence'
    else 'comparison_only'
  end;
  if coalesce(v_finding->>'evidence_role','')<>v_evidence_role then
   v_rejected:=v_rejected+1; continue;
  end if;
$old$;
  v_new text := $new$
  -- The assistant may conservatively downgrade a direct source to comparison_only.
  -- Generic marketplace shop/search/category URLs are never direct product evidence.
  v_evidence_role:=case
    when coalesce(v_finding->>'evidence_role','')='comparison_only' then 'comparison_only'
    when v_package_match='exact_package'
     and v_source_kind in ('retailer_product_page','manufacturer_product_page')
     and v_page_access='opened'
    then 'catalogue_evidence'
    when v_package_match='exact_package'
     and v_source_kind='marketplace_listing'
     and v_page_access='opened'
     and v_source_url ~* '/(itm/[0-9]+|dp/[A-Z0-9]+|gp/product/[A-Z0-9]+)'
    then 'catalogue_evidence'
    else 'comparison_only'
  end;
  if coalesce(v_finding->>'evidence_role','')<>v_evidence_role then
   v_rejected:=v_rejected+1; continue;
  end if;
$new$;
begin
  select pg_get_functiondef('public.platform_owner_submit_manual_ai_research_response(uuid,text)'::regprocedure)
    into v_definition;
  if position(v_old in v_definition)=0 then
    raise exception 'Expected evidence-role validation block not found; refusing to alter submit function.';
  end if;
  execute replace(v_definition,v_old,v_new);
end;
$migration$;