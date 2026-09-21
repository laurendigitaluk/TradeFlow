-- Repair customer offer acceptance events and expose category buying fields to customer portal
alter table public.offer_events drop constraint if exists offer_events_event_type_check;
alter table public.offer_events add constraint offer_events_event_type_check
  check (event_type = any (array['created','published','accepted','refused','withdrawn','superseded','expired','revised']));

create or replace function public.customer_accept_offer(p_tenant_id uuid,p_offer_id uuid,p_response_notes text default null)
returns uuid language plpgsql security definer set search_path='pg_catalog','public' as $$
declare v_customer_id uuid;v_buying_item_id uuid;v_offer_amount numeric;v_currency text;v_offer_status text;v_expires_at timestamptz;v_acquisition_id uuid;v_acquisition_item_id uuid;v_now timestamptz:=now();v_ref text;
begin
 perform private.require_tenant_feature(p_tenant_id,'module.offers');
 if auth.uid() is null then raise exception 'authentication required'; end if;
 v_customer_id:=private.customer_id_for_current_user(p_tenant_id);
 if v_customer_id is null then raise exception 'customer account not linked to tenant'; end if;
 select o.buying_item_id,o.amount,o.currency,o.status,o.expires_at into v_buying_item_id,v_offer_amount,v_currency,v_offer_status,v_expires_at
 from public.offers o join public.buying_items bi on bi.tenant_id=o.tenant_id and bi.id=o.buying_item_id join public.buying_requests br on br.tenant_id=bi.tenant_id and br.id=bi.buying_request_id
 where o.tenant_id=p_tenant_id and o.id=p_offer_id and br.customer_id=v_customer_id for update of o;
 if v_buying_item_id is null then raise exception 'offer not found or not owned by current customer'; end if;
 if v_offer_status<>'published' then raise exception 'offer is not available for acceptance'; end if;
 if v_expires_at is not null and v_expires_at<=v_now then raise exception 'offer has expired'; end if;
 update public.offers set status='accepted',responded_at=v_now,response_notes=p_response_notes,updated_at=v_now where tenant_id=p_tenant_id and id=p_offer_id;
 insert into public.offer_events(tenant_id,offer_id,event_type,from_status,to_status,amount,notes,actor_user_id) values(p_tenant_id,p_offer_id,'accepted','published','accepted',v_offer_amount,p_response_notes,auth.uid());
 v_ref:='ACQ-'||upper(substr(replace(gen_random_uuid()::text,'-',''),1,12));
 insert into public.acquisitions(tenant_id,acquisition_reference,status,customer_id,source_offer_id,currency,agreed_total,payment_total,accepted_at,created_by)
 values(p_tenant_id,v_ref,'accepted',v_customer_id,p_offer_id,v_currency,v_offer_amount,v_offer_amount,v_now,auth.uid()) returning id into v_acquisition_id;
 insert into public.acquisition_items(tenant_id,acquisition_id,buying_item_id,offer_id,status,agreed_amount,currency)
 values(p_tenant_id,v_acquisition_id,v_buying_item_id,p_offer_id,'accepted',v_offer_amount,v_currency) returning id into v_acquisition_item_id;
 insert into public.workflow_transitions(tenant_id,entity_type,entity_id,from_status,to_status,actor_user_id,notes,metadata) values
 (p_tenant_id,'offers',p_offer_id,'published','accepted',auth.uid(),p_response_notes,'{"source":"customer_action"}'::jsonb),
 (p_tenant_id,'acquisitions',v_acquisition_id,'accepted','accepted',auth.uid(),'Created from customer offer acceptance','{"source":"customer_action"}'::jsonb),
 (p_tenant_id,'acquisition_items',v_acquisition_item_id,'accepted','accepted',auth.uid(),'Created from customer offer acceptance','{"source":"customer_action"}'::jsonb);
 return v_acquisition_id;
end;$$;

create or replace function public.customer_refuse_offer(p_tenant_id uuid,p_offer_id uuid,p_response_notes text default null)
returns boolean language plpgsql security definer set search_path='pg_catalog','public' as $$
declare v_customer_id uuid;v_status text;v_item_id uuid;
begin
 perform private.require_tenant_feature(p_tenant_id,'module.offers');
 if auth.uid() is null then raise exception 'authentication required'; end if;
 v_customer_id:=private.customer_id_for_current_user(p_tenant_id);
 if v_customer_id is null then raise exception 'customer account not linked to tenant'; end if;
 select o.status,o.buying_item_id into v_status,v_item_id from public.offers o join public.buying_items bi on bi.tenant_id=o.tenant_id and bi.id=o.buying_item_id join public.buying_requests br on br.tenant_id=bi.tenant_id and br.id=bi.buying_request_id where o.tenant_id=p_tenant_id and o.id=p_offer_id and br.customer_id=v_customer_id for update of o;
 if v_item_id is null then raise exception 'offer not found or not owned by current customer'; end if;
 if v_status<>'published' then raise exception 'offer is not available for refusal'; end if;
 update public.offers set status='refused',responded_at=now(),response_notes=p_response_notes,updated_at=now() where tenant_id=p_tenant_id and id=p_offer_id;
 insert into public.offer_events(tenant_id,offer_id,event_type,from_status,to_status,notes,actor_user_id) values(p_tenant_id,p_offer_id,'refused','published','refused',p_response_notes,auth.uid());
 insert into public.workflow_transitions(tenant_id,entity_type,entity_id,from_status,to_status,actor_user_id,notes,metadata) values(p_tenant_id,'offers',p_offer_id,'published','refused',auth.uid(),p_response_notes,'{"source":"customer_action"}'::jsonb);
 return true;
end;$$;

create or replace function public.customer_get_buying_category_fields(p_tenant_id uuid,p_category_id uuid)
returns table(field_id uuid,field_key text,label text,field_type text,required_for_buying boolean,options jsonb)
language plpgsql stable security definer set search_path='pg_catalog','public' as $$
begin
 perform private.require_tenant_feature(p_tenant_id,'module.buying');
 if auth.uid() is null then raise exception 'authentication required'; end if;
 if private.customer_id_for_current_user(p_tenant_id) is null then raise exception 'customer account not linked to tenant'; end if;
 return query
 select f.id,f.field_key,f.label,f.field_type,f.required_for_buying,
 coalesce((select jsonb_agg(jsonb_build_object('value',o.value,'label',o.label) order by o.sort_order nulls last,o.label)
 from public.category_field_options o where o.tenant_id=f.tenant_id and o.category_id=f.category_id and o.field_id=f.id and o.active),'[]'::jsonb)
 from public.category_fields f
 where f.tenant_id=p_tenant_id and f.category_id=p_category_id and f.customer_visible and f.enabled_for_buying
 order by f.sort_order nulls last,f.label;
end;$$;
