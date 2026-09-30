-- TradeFlow migration 053: remove broad tenant-member offer policies that bypass
-- the existing offers.view/offers.manage subscription capability boundary.

DROP POLICY IF EXISTS offers_select_members ON public.offers;
DROP POLICY IF EXISTS offers_insert_members ON public.offers;
DROP POLICY IF EXISTS offers_update_members ON public.offers;
DROP POLICY IF EXISTS offers_delete_admins ON public.offers;

DROP POLICY IF EXISTS offer_events_select_members ON public.offer_events;
DROP POLICY IF EXISTS offer_events_insert_members ON public.offer_events;
DROP POLICY IF EXISTS offer_events_delete_admins ON public.offer_events;

CREATE POLICY offer_events_subscription_select
  ON public.offer_events
  FOR SELECT TO authenticated
  USING (
    private.has_tenant_permission(tenant_id, auth.uid(), 'offers.view')
    AND private.has_tenant_feature(tenant_id, 'module.offers')
  );

CREATE POLICY offer_events_subscription_insert
  ON public.offer_events
  FOR INSERT TO authenticated
  WITH CHECK (
    private.has_tenant_permission(tenant_id, auth.uid(), 'offers.manage')
    AND private.has_tenant_feature(tenant_id, 'module.offers')
    AND ((actor_user_id IS NULL) OR (actor_user_id = auth.uid()))
  );

CREATE POLICY offer_events_subscription_delete
  ON public.offer_events
  FOR DELETE TO authenticated
  USING (
    private.has_tenant_permission(tenant_id, auth.uid(), 'offers.manage')
    AND private.has_tenant_feature(tenant_id, 'module.offers')
  );
