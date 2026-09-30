-- Customer refusal of an initial/revised offer closes the buying item as offer_refused.
-- Final-offer refusal remains final_offer_refused.
create or replace function public.customer_refuse_offer(p_tenant_id uuid,p_offer_id uuid,p_response_notes text default null)
returns boolean
language plpgsql
security definer
set search_path to 'pg_catalog','public'
as $function$
declare v_customer_id uuid; v_status text; v_item_id uuid; v_offer_type text;
begin
 perform private.require_tenant_feature(p_tenant_id,'module.offers');
 if auth.uid() is null then raise exception 'authentication required'; end if;
 v_customer_id:=private.customer_id_for_current_user(p_tenant_id);
 if v_customer_id is null then raise exception 'customer account not linked to tenant'; end if;
 select o.status,o.buying_item_id,o.offer_type into v_status,v_item_id,v_offer_type
 from public.offers o
 join public.buying_items bi on bi.tenant_id=o.tenant_id and bi.id=o.buying_item_id
 join public.buying_requests br on br.tenant_id=bi.tenant_id and br.id=bi.buying_request_id
 where o.tenant_id=p_tenant_id and o.id=p_offer_id and br.customer_id=v_customer_id for update of o;
 if v_item_id is null then raise exception 'offer not found or not owned by current customer'; end if;
 if v_status<>'published' then raise exception 'offer is not available for refusal'; end if;
 update public.offers set status='refused',responded_at=now(),response_notes=p_response_notes,updated_at=now()
 where tenant_id=p_tenant_id and id=p_offer_id;
 insert into public.offer_events(tenant_id,offer_id,event_type,from_status,to_status,notes,actor_user_id)
 values(p_tenant_id,p_offer_id,'refused','published','refused',p_response_notes,auth.uid());
 insert into public.workflow_transitions(tenant_id,entity_type,entity_id,from_status,to_status,actor_user_id,notes,metadata)
 values(p_tenant_id,'offer',p_offer_id,'published','refused',auth.uid(),p_response_notes,jsonb_build_object('source','customer_action'));
 update public.buying_items
 set purchase_stage=case when v_offer_type='final' then 'final_offer_refused' else 'offer_refused' end,
     purchase_stage_updated_at=now(),updated_at=now()
 where tenant_id=p_tenant_id and id=v_item_id;
 return true;
end;$function$;