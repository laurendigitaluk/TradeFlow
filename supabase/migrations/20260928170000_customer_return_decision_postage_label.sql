-- Customer retail return decision, postage payer and return label
create or replace function public.subscriber_decide_customer_return(
  p_tenant_id uuid,
  p_return_id uuid,
  p_decision text,
  p_postage_payer text default null,
  p_return_label_path text default null,
  p_notes text default null
)
returns boolean
language plpgsql
security definer
set search_path = pg_catalog, public
as $$
declare
  v_actor uuid := auth.uid();
  v_status text;
  v_metadata jsonb;
begin
  if v_actor is null or not private.is_tenant_member(p_tenant_id,v_actor) then raise exception 'Tenant membership required'; end if;
  if not private.has_tenant_permission(p_tenant_id,v_actor,'returns.manage') then raise exception 'Permission required: returns.manage'; end if;
  if not (private.has_tenant_feature(p_tenant_id,'module.buying') or private.has_tenant_feature(p_tenant_id,'module.orders')) then raise exception 'Subscription capability required for returns'; end if;
  if p_decision not in ('approved','denied') then raise exception 'Decision must be approved or denied'; end if;
  if p_decision='approved' and p_postage_payer not in ('subscriber','customer') then raise exception 'Select who pays return postage'; end if;
  if p_decision='approved' and coalesce(trim(p_return_label_path),'')='' then raise exception 'A return label must be supplied before approving the return'; end if;

  select status, metadata into v_status, v_metadata
  from public.returns
  where id=p_return_id and tenant_id=p_tenant_id and return_type='customer_retail'
  for update;

  if not found then raise exception 'Return request not found'; end if;
  if v_status <> 'requested' then raise exception 'Return is no longer awaiting a decision'; end if;

  v_metadata := coalesce(v_metadata,'{}'::jsonb)
    || jsonb_build_object(
      'decision',p_decision,
      'decision_at',now(),
      'decision_by',v_actor,
      'postage_payer',case when p_decision='approved' then p_postage_payer else null end,
      'return_label_path',case when p_decision='approved' then p_return_label_path else null end
    );
  if coalesce(trim(p_notes),'')<>'' then v_metadata := v_metadata || jsonb_build_object('decision_notes',p_notes); end if;

  update public.returns
  set status=case when p_decision='approved' then 'authorised' else 'rejected' end,
      authorised_at=case when p_decision='approved' then coalesce(authorised_at,now()) else authorised_at end,
      resolved_at=case when p_decision='denied' then coalesce(resolved_at,now()) else resolved_at end,
      metadata=v_metadata, updated_at=now()
  where id=p_return_id and tenant_id=p_tenant_id and status='requested';

  insert into public.workflow_transitions(tenant_id,entity_type,entity_id,from_status,to_status,actor_user_id,notes,metadata)
  values(p_tenant_id,'return',p_return_id,'requested',
    case when p_decision='approved' then 'authorised' else 'rejected' end,
    v_actor,p_notes,jsonb_build_object('source','returns-dashboard','decision',p_decision,
      'postage_payer',case when p_decision='approved' then p_postage_payer else null end,
      'return_label_path',case when p_decision='approved' then p_return_label_path else null end));

  return true;
end;
$$;

revoke all on function public.subscriber_decide_customer_return(uuid,uuid,text,text,text,text) from public;
grant execute on function public.subscriber_decide_customer_return(uuid,uuid,text,text,text,text) to authenticated;

drop policy if exists tradeflow_media_customer_return_label_select on storage.objects;
create policy tradeflow_media_customer_return_label_select
on storage.objects for select to authenticated
using (
  bucket_id='tradeflow-media'
  and (storage.foldername(name))[2]='returns'
  and exists (
    select 1 from public.returns r
    join public.customers c on c.id=r.customer_id and c.tenant_id=r.tenant_id
    where r.tenant_id=((storage.foldername(name))[1])::uuid
      and r.id=((storage.foldername(name))[3])::uuid
      and c.auth_user_id=auth.uid()
  )
);
