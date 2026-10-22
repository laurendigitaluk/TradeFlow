do $migration$
declare
  v_def text;
  v_old_new text := $old$
   left join lateral(
      select tr.observed_price,tr.source_name,tr.source_url,tr.checked_at
      from public.tenant_buying_research tr
      where tr.tenant_id=p_tenant_id and tr.buying_product_id=bp.id and tr.evidence_type='uk_new'
        and tr.observed_price is not null and upper(coalesce(tr.price_currency,'GBP'))='GBP'
      order by tr.checked_at desc nulls last,tr.created_at desc nulls last,tr.id desc limit 1
   ) rn on true
$old$;
  v_old_used text := $old$
   left join lateral(
      select tr.observed_price,tr.source_name,tr.source_url,tr.checked_at
      from public.tenant_buying_research tr
      where tr.tenant_id=p_tenant_id and tr.buying_product_id=bp.id and tr.evidence_type='uk_used'
        and tr.observed_price is not null and upper(coalesce(tr.price_currency,'GBP'))='GBP'
      order by tr.checked_at desc nulls last,tr.created_at desc nulls last,tr.id desc limit 1
   ) ru on true
$old$;
  v_new_new text := $new$
   left join lateral(
      select ev.observed_price,ev.source_name,ev.source_url,ev.checked_at from (
        select tr.observed_price,tr.source_name,tr.source_url,tr.checked_at,0 priority,tr.created_at,tr.id
        from public.tenant_buying_research tr
        where tr.tenant_id=p_tenant_id and tr.buying_product_id=bp.id and tr.evidence_type='uk_new'
          and tr.observed_price is not null and upper(coalesce(tr.price_currency,'GBP'))='GBP'
        union all
        select sm.observed_price,sm.source_name,sm.source_url,sm.observed_at,1 priority,sm.created_at,sm.id
        from public.shared_market_evidence sm
        where v_use_shared and sm.master_product_id=p.id and sm.evidence_type='uk_new'
          and sm.is_active and sm.observed_price is not null and upper(coalesce(sm.price_currency,'GBP'))='GBP'
      ) ev order by ev.priority,ev.checked_at desc nulls last,ev.created_at desc nulls last,ev.id desc limit 1
   ) rn on true
$new$;
  v_new_used text := $new$
   left join lateral(
      select ev.observed_price,ev.source_name,ev.source_url,ev.checked_at from (
        select tr.observed_price,tr.source_name,tr.source_url,tr.checked_at,0 priority,tr.created_at,tr.id
        from public.tenant_buying_research tr
        where tr.tenant_id=p_tenant_id and tr.buying_product_id=bp.id and tr.evidence_type='uk_used'
          and tr.observed_price is not null and upper(coalesce(tr.price_currency,'GBP'))='GBP'
        union all
        select sm.observed_price,sm.source_name,sm.source_url,sm.observed_at,1 priority,sm.created_at,sm.id
        from public.shared_market_evidence sm
        where v_use_shared and sm.master_product_id=p.id and sm.evidence_type='uk_used'
          and sm.is_active and sm.observed_price is not null and upper(coalesce(sm.price_currency,'GBP'))='GBP'
      ) ev order by ev.priority,ev.checked_at desc nulls last,ev.created_at desc nulls last,ev.id desc limit 1
   ) ru on true
$new$;
begin
  v_def := pg_get_functiondef('public.get_master_buying_catalogue_page_filtered(uuid,uuid,uuid,uuid,text,integer,integer,boolean)'::regprocedure);
  if position('v_use_shared' in v_def)>0 then return; end if;
  v_def := replace(v_def,'v_total integer; v_products jsonb;','v_total integer; v_products jsonb; v_use_shared boolean;');
  v_def := replace(v_def,
    ' if not private.has_tenant_feature(p_tenant_id,''module.buying'') then raise exception ''Buying is not enabled for this subscription''; end if;',
    ' if not private.has_tenant_feature(p_tenant_id,''module.buying'') then raise exception ''Buying is not enabled for this subscription''; end if;' || E'\n' ||
    ' select coalesce((t.settings->>''use_shared_evidence'')::boolean,true) into v_use_shared from public.tenants t where t.id=p_tenant_id;' || E'\n' ||
    ' v_use_shared := coalesce(v_use_shared,true);');
  if position(v_old_new in v_def)=0 or position(v_old_used in v_def)=0 then
    raise exception 'Expected research query blocks not found; no function update applied';
  end if;
  v_def := replace(v_def,v_old_new,v_new_new);
  v_def := replace(v_def,v_old_used,v_new_used);
  if position('v_use_shared' in v_def)=0 or position('shared_market_evidence' in v_def)=0 then
    raise exception 'Shared evidence integration validation failed';
  end if;
  execute v_def;
end
$migration$;
