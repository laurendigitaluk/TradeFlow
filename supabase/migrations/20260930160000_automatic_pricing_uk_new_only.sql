-- Automatic buying rules use UK New research only.
-- UK Used research remains visible as supporting/view-only evidence, but it must
-- never be used as the automatic valuation basis.

update public.tenant_buying_condition_rules
set sealed_reference_type='uk_new',
    opened_never_used_reference_type='uk_new',
    excellent_reference_type='uk_new',
    good_reference_type='uk_new',
    poor_reference_type='uk_new',
    updated_at=now();

CREATE OR REPLACE FUNCTION public.configure_master_catalogue_buying_product_pricing(
 p_tenant_id uuid,
 p_master_product_id uuid,
 p_mode text,
 p_manual_price numeric DEFAULT NULL,
 p_sealed_percentage numeric DEFAULT NULL,
 p_opened_never_used_percentage numeric DEFAULT NULL,
 p_excellent_percentage numeric DEFAULT NULL,
 p_good_percentage numeric DEFAULT NULL,
 p_poor_percentage numeric DEFAULT NULL,
 p_sealed_manual_price numeric DEFAULT NULL,
 p_opened_never_used_manual_price numeric DEFAULT NULL,
 p_excellent_manual_price numeric DEFAULT NULL,
 p_good_manual_price numeric DEFAULT NULL,
 p_poor_manual_price numeric DEFAULT NULL,
 p_sealed_reference_type text DEFAULT 'uk_new',
 p_opened_never_used_reference_type text DEFAULT 'uk_new',
 p_excellent_reference_type text DEFAULT 'uk_new',
 p_good_reference_type text DEFAULT 'uk_new',
 p_poor_reference_type text DEFAULT 'uk_new',
 p_sealed_trade_in_percentage numeric DEFAULT NULL,
 p_opened_never_used_trade_in_percentage numeric DEFAULT NULL,
 p_excellent_trade_in_percentage numeric DEFAULT NULL,
 p_good_trade_in_percentage numeric DEFAULT NULL,
 p_poor_trade_in_percentage numeric DEFAULT NULL,
 p_sealed_trade_in_manual_price numeric DEFAULT NULL,
 p_opened_never_used_trade_in_manual_price numeric DEFAULT NULL,
 p_excellent_trade_in_manual_price numeric DEFAULT NULL,
 p_good_trade_in_manual_price numeric DEFAULT NULL,
 p_poor_trade_in_manual_price numeric DEFAULT NULL
)
returns jsonb
language plpgsql
security definer
set search_path to ''
as $function$
declare v_result jsonb;
begin
 if lower(trim(coalesce(p_mode,'')))='automatic' then
   if (p_sealed_trade_in_percentage is not null and (p_sealed_trade_in_percentage<0 or p_sealed_trade_in_percentage>100))
   or (p_opened_never_used_trade_in_percentage is not null and (p_opened_never_used_trade_in_percentage<0 or p_opened_never_used_trade_in_percentage>100))
   or (p_excellent_trade_in_percentage is not null and (p_excellent_trade_in_percentage<0 or p_excellent_trade_in_percentage>100))
   or (p_good_trade_in_percentage is not null and (p_good_trade_in_percentage<0 or p_good_trade_in_percentage>100))
   or (p_poor_trade_in_percentage is not null and (p_poor_trade_in_percentage<0 or p_poor_trade_in_percentage>100)) then
     raise exception 'Trade-in percentages must be between 0 and 100';
   end if;
 end if;
 v_result:=public.configure_master_catalogue_buying_product(p_tenant_id,p_master_product_id,p_mode,p_manual_price,p_sealed_percentage,p_opened_never_used_percentage,p_excellent_percentage,p_good_percentage,p_poor_percentage);
 if lower(trim(coalesce(p_mode,'')))='automatic' then
   update public.tenant_buying_condition_rules r
   set sealed_manual_price=p_sealed_manual_price,
       opened_never_used_manual_price=p_opened_never_used_manual_price,
       excellent_manual_price=p_excellent_manual_price,
       good_manual_price=p_good_manual_price,
       poor_manual_price=p_poor_manual_price,
       sealed_reference_type='uk_new',
       opened_never_used_reference_type='uk_new',
       excellent_reference_type='uk_new',
       good_reference_type='uk_new',
       poor_reference_type='uk_new',
       sealed_trade_in_percentage=p_sealed_trade_in_percentage,
       opened_never_used_trade_in_percentage=p_opened_never_used_trade_in_percentage,
       excellent_trade_in_percentage=p_excellent_trade_in_percentage,
       good_trade_in_percentage=p_good_trade_in_percentage,
       poor_trade_in_percentage=p_poor_trade_in_percentage,
       sealed_trade_in_manual_price=p_sealed_trade_in_manual_price,
       opened_never_used_trade_in_manual_price=p_opened_never_used_trade_in_manual_price,
       excellent_trade_in_manual_price=p_excellent_trade_in_manual_price,
       good_trade_in_manual_price=p_good_trade_in_manual_price,
       poor_trade_in_manual_price=p_poor_trade_in_manual_price,
       updated_at=now()
   where r.tenant_id=p_tenant_id and r.buying_product_id=(v_result->>'buying_product_id')::uuid;
 end if;
 return v_result;
end;
$function$;