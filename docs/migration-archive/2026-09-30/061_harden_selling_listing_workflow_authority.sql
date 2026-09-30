-- TradeFlow migration 061: harden selling/listing access and status authority.

DROP POLICY IF EXISTS listings_delete_admins ON public.listings;
DROP POLICY IF EXISTS listings_insert_members ON public.listings;
DROP POLICY IF EXISTS listings_select_members ON public.listings;
DROP POLICY IF EXISTS listings_update_members ON public.listings;
DROP POLICY IF EXISTS listings_subscription_delete ON public.listings;
DROP POLICY IF EXISTS listings_subscription_insert ON public.listings;
DROP POLICY IF EXISTS listings_subscription_select ON public.listings;
DROP POLICY IF EXISTS listings_subscription_update ON public.listings;

CREATE POLICY listings_subscription_select ON public.listings FOR SELECT USING (
  private.has_tenant_permission(tenant_id, auth.uid(), 'selling.view')
  AND private.has_tenant_feature(tenant_id, 'module.selling')
);
CREATE POLICY listings_subscription_insert ON public.listings FOR INSERT WITH CHECK (
  private.has_tenant_permission(tenant_id, auth.uid(), 'selling.manage')
  AND private.has_tenant_feature(tenant_id, 'module.selling')
  AND ((created_by IS NULL) OR created_by = auth.uid())
);
CREATE POLICY listings_subscription_update ON public.listings FOR UPDATE USING (
  private.has_tenant_permission(tenant_id, auth.uid(), 'selling.manage')
  AND private.has_tenant_feature(tenant_id, 'module.selling')
) WITH CHECK (
  private.has_tenant_permission(tenant_id, auth.uid(), 'selling.manage')
  AND private.has_tenant_feature(tenant_id, 'module.selling')
);
CREATE POLICY listings_subscription_delete ON public.listings FOR DELETE USING (
  private.has_tenant_permission(tenant_id, auth.uid(), 'selling.manage')
  AND private.has_tenant_feature(tenant_id, 'module.selling')
);

CREATE OR REPLACE FUNCTION public.guard_listing_status_entry()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $$
BEGIN
  IF NEW.status IS DISTINCT FROM OLD.status AND current_user <> 'postgres' THEN
    RAISE EXCEPTION 'Listing status changes must use transition_workflow_entity';
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS listings_status_entry_guard ON public.listings;
CREATE TRIGGER listings_status_entry_guard
BEFORE UPDATE OF status ON public.listings
FOR EACH ROW EXECUTE FUNCTION public.guard_listing_status_entry();
REVOKE ALL ON FUNCTION public.guard_listing_status_entry() FROM public;

ALTER TABLE public.listing_events ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS listing_events_delete_admins ON public.listing_events;
DROP POLICY IF EXISTS listing_events_insert_members ON public.listing_events;
DROP POLICY IF EXISTS listing_events_select_members ON public.listing_events;
CREATE POLICY listing_events_subscription_select ON public.listing_events FOR SELECT USING (
  private.has_tenant_permission(tenant_id, auth.uid(), 'selling.view')
  AND private.has_tenant_feature(tenant_id, 'module.selling')
);
CREATE POLICY listing_events_subscription_insert ON public.listing_events FOR INSERT WITH CHECK (
  private.has_tenant_permission(tenant_id, auth.uid(), 'selling.manage')
  AND private.has_tenant_feature(tenant_id, 'module.selling')
  AND ((actor_user_id IS NULL) OR actor_user_id = auth.uid())
);
CREATE POLICY listing_events_subscription_delete ON public.listing_events FOR DELETE USING (
  private.has_tenant_permission(tenant_id, auth.uid(), 'selling.manage')
  AND private.has_tenant_feature(tenant_id, 'module.selling')
);

ALTER TABLE public.sales_channels ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS sales_channels_delete_admins ON public.sales_channels;
DROP POLICY IF EXISTS sales_channels_insert_members ON public.sales_channels;
DROP POLICY IF EXISTS sales_channels_select_members ON public.sales_channels;
DROP POLICY IF EXISTS sales_channels_update_members ON public.sales_channels;
DROP POLICY IF EXISTS sales_channels_subscription_delete ON public.sales_channels;
DROP POLICY IF EXISTS sales_channels_subscription_insert ON public.sales_channels;
DROP POLICY IF EXISTS sales_channels_subscription_select ON public.sales_channels;
DROP POLICY IF EXISTS sales_channels_subscription_update ON public.sales_channels;
CREATE POLICY sales_channels_subscription_select ON public.sales_channels FOR SELECT USING (
  private.has_tenant_permission(tenant_id, auth.uid(), 'selling.view')
  AND private.has_tenant_feature(tenant_id, 'module.selling')
);
CREATE POLICY sales_channels_subscription_insert ON public.sales_channels FOR INSERT WITH CHECK (
  private.has_tenant_permission(tenant_id, auth.uid(), 'selling.manage')
  AND private.has_tenant_feature(tenant_id, 'module.selling')
);
CREATE POLICY sales_channels_subscription_update ON public.sales_channels FOR UPDATE USING (
  private.has_tenant_permission(tenant_id, auth.uid(), 'selling.manage')
  AND private.has_tenant_feature(tenant_id, 'module.selling')
) WITH CHECK (
  private.has_tenant_permission(tenant_id, auth.uid(), 'selling.manage')
  AND private.has_tenant_feature(tenant_id, 'module.selling')
);
CREATE POLICY sales_channels_subscription_delete ON public.sales_channels FOR DELETE USING (
  private.has_tenant_permission(tenant_id, auth.uid(), 'selling.manage')
  AND private.has_tenant_feature(tenant_id, 'module.selling')
);
