-- Consolidate the semantically duplicate Drone Remote Controllers branch into Drone Controllers.
-- TEST first; only TradeFlow-owned master catalogue data is changed.
do $$
declare
  canonical_id uuid;
  duplicate_id uuid;
begin
  select b.id into canonical_id
  from public.catalogue_master_branches b
  join public.catalogue_master_categories c on c.id=b.category_id
  where c.slug='drone-accessories' and b.slug='drone-controllers';

  select b.id into duplicate_id
  from public.catalogue_master_branches b
  join public.catalogue_master_categories c on c.id=b.category_id
  where c.slug='drone-accessories' and b.slug='drone-remote-controllers';

  if canonical_id is null or duplicate_id is null then
    raise exception 'Expected Drone Controllers and Drone Remote Controllers branches were not found';
  end if;

  update public.catalogue_master_products
  set branch_id=canonical_id, updated_at=now()
  where branch_id=duplicate_id;

  delete from public.catalogue_master_branches
  where id=duplicate_id;
end $$;
