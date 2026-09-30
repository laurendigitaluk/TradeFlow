-- Inspection refusal: explicit condition mismatch check and return_pending stage.
create or replace function public.subscriber_complete_buying_item_inspection(p_tenant_id uuid,p_buying_item_id uuid,p_condition_grade text,p_passed boolean,p_outcome text,p_notes text,p_metadata jsonb)
returns jsonb language plpgsql security definer set search_path to 'public','private'
as $function$
declare v_actor uuid:=auth.uid();v_item public.buying_items%rowtype;v_id uuid;v_meta jsonb:=coalesce(p_metadata,'{}'::jsonb);v_next text;
begin
 if v_actor is null or not private.has_tenant_permission(p_tenant_id,v_actor,'buying.manage') then raise exception 'Permission required: buying.manage'; end if;
 if p_outcome not in ('accepted','testing_required','repair_required','refused') then raise exception 'Invalid inspection outcome'; end if;
 if p_outcome<>'refused' and coalesce((v_meta->>'customer_description_confirmed')::boolean,false) is not true then raise exception 'Confirm that the item matches the customer description before completing inspection'; end if;
 if p_outcome='refused' and coalesce((v_meta->>'condition_not_as_described')::boolean,false) is not true then raise exception 'Confirm that the item condition is not as described before refusing the purchase'; end if;
 if coalesce((v_meta->>'condition_confirmed')::boolean,false) is not true then raise exception 'Confirm the inspected condition before completing the inspection'; end if;
 select * into v_item from public.buying_items where tenant_id=p_tenant_id and id=p_buying_item_id for update;
 if v_item.id is null then raise exception 'Buying item not found'; end if;
 if v_item.purchase_stage<>'inspection' then raise exception 'Buying item is not currently in inspection'; end if;
 v_meta:=v_meta||jsonb_build_object('completed_by',v_actor,'completed_at',now(),'buying_item_id',p_buying_item_id,'customer_description_snapshot',coalesce(v_item.description,''),'customer_condition_snapshot',coalesce(v_item.item_condition,''));
 insert into public.buying_item_inspections(tenant_id,buying_item_id,inspection_type,outcome,condition_grade,notes,passed,inspected_by,inspected_at,metadata)
 values(p_tenant_id,p_buying_item_id,'condition',p_outcome,nullif(trim(p_condition_grade),''),nullif(trim(p_notes),''),p_passed,v_actor,now(),v_meta) returning id into v_id;
 v_next:=case when p_outcome='accepted' then 'final_offer_required' when p_outcome='testing_required' then 'testing' when p_outcome='repair_required' then 'repair' else 'return_pending' end;
 update public.buying_items set inspection_completed_at=now(),purchase_stage=v_next,purchase_stage_updated_at=now(),updated_at=now() where tenant_id=p_tenant_id and id=p_buying_item_id;
 if p_outcome='refused' then
  insert into public.buying_item_return_shipping(tenant_id,buying_item_id,return_reason,shipping_status)
  values(p_tenant_id,p_buying_item_id,coalesce(nullif(trim(p_notes),''),'Condition not as described.'),'return_required')
  on conflict(buying_item_id) do update set return_reason=excluded.return_reason,shipping_status='return_required',shipping_status_updated_at=now(),updated_at=now();
 end if;
 insert into public.workflow_transitions(tenant_id,entity_type,entity_id,from_status,to_status,notes,metadata,actor_user_id)
 values(p_tenant_id,'buying_item',p_buying_item_id,'inspection',v_next,coalesce(p_notes,'Inspection completed.'),jsonb_build_object('source','inspection','condition_not_as_described',coalesce((v_meta->>'condition_not_as_described')::boolean,false)),v_actor);
 return jsonb_build_object('inspection_id',v_id,'buying_item_id',p_buying_item_id,'outcome',p_outcome,'next_stage',v_next,'return_required',p_outcome='refused');
end;$function$;