-- TradeFlow migration 063: harden fulfilment access and status authority.

DROP POLICY IF EXISTS fulfilments_delete ON public.fulfilments;
DROP POLICY IF EXISTS fulfilments_insert ON public.fulfilments;
DROP POLICY IF EXISTS fulfilments_select ON public.fulfilments;
DROP POLICY IF EXISTS fulfilments_update ON public.fulfilments;
DROP POLICY IF EXISTS fulfilments_subscription_delete ON public.fulfilments;
DROP POLICY IF EXISTS fulfilments_subscription_insert ON public.fulfilments;
DROP POLICY IF EXISTS fulfilments_subscription_select ON public.fulfilments;
DROP POLICY IF EXISTS fulfilments_subscription_update ON public.fulfilments;
CREATE POLICY fulfilments_subscription_select ON public.fulfilments FOR SELECT USING (private.has_tenant_permission(tenant_id,auth.uid(),'fulfilment.view') AND private.has_tenant_feature(tenant_id,'module.fulfilment'));
CREATE POLICY fulfilments_subscription_insert ON public.fulfilments FOR INSERT WITH CHECK (private.has_tenant_permission(tenant_id,auth.uid(),'fulfilment.manage') AND private.has_tenant_feature(tenant_id,'module.fulfilment'));
CREATE POLICY fulfilments_subscription_update ON public.fulfilments FOR UPDATE USING (private.has_tenant_permission(tenant_id,auth.uid(),'fulfilment.manage') AND private.has_tenant_feature(tenant_id,'module.fulfilment')) WITH CHECK (private.has_tenant_permission(tenant_id,auth.uid(),'fulfilment.manage') AND private.has_tenant_feature(tenant_id,'module.fulfilment'));
CREATE POLICY fulfilments_subscription_delete ON public.fulfilments FOR DELETE USING (private.has_tenant_permission(tenant_id,auth.uid(),'fulfilment.manage') AND private.has_tenant_feature(tenant_id,'module.fulfilment'));

DROP POLICY IF EXISTS acquisition_fulfilments_delete ON public.acquisition_fulfilments;
DROP POLICY IF EXISTS acquisition_fulfilments_insert ON public.acquisition_fulfilments;
DROP POLICY IF EXISTS acquisition_fulfilments_select ON public.acquisition_fulfilments;
DROP POLICY IF EXISTS acquisition_fulfilments_update ON public.acquisition_fulfilments;
CREATE POLICY acquisition_fulfilments_subscription_select ON public.acquisition_fulfilments FOR SELECT USING (private.has_tenant_permission(tenant_id,auth.uid(),'fulfilment.view') AND private.has_tenant_feature(tenant_id,'module.fulfilment'));
CREATE POLICY acquisition_fulfilments_subscription_insert ON public.acquisition_fulfilments FOR INSERT WITH CHECK (private.has_tenant_permission(tenant_id,auth.uid(),'fulfilment.manage') AND private.has_tenant_feature(tenant_id,'module.fulfilment'));
CREATE POLICY acquisition_fulfilments_subscription_update ON public.acquisition_fulfilments FOR UPDATE USING (private.has_tenant_permission(tenant_id,auth.uid(),'fulfilment.manage') AND private.has_tenant_feature(tenant_id,'module.fulfilment')) WITH CHECK (private.has_tenant_permission(tenant_id,auth.uid(),'fulfilment.manage') AND private.has_tenant_feature(tenant_id,'module.fulfilment'));
CREATE POLICY acquisition_fulfilments_subscription_delete ON public.acquisition_fulfilments FOR DELETE USING (private.has_tenant_permission(tenant_id,auth.uid(),'fulfilment.manage') AND private.has_tenant_feature(tenant_id,'module.fulfilment'));

CREATE OR REPLACE FUNCTION public.guard_fulfilment_status_entry() RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path=pg_catalog,public AS $$
BEGIN IF NEW.status IS DISTINCT FROM OLD.status AND current_user <> 'postgres' THEN RAISE EXCEPTION 'Fulfilment status changes must use transition_workflow_entity'; END IF; RETURN NEW; END; $$;
DROP TRIGGER IF EXISTS fulfilments_status_entry_guard ON public.fulfilments;
CREATE TRIGGER fulfilments_status_entry_guard BEFORE UPDATE OF status ON public.fulfilments FOR EACH ROW EXECUTE FUNCTION public.guard_fulfilment_status_entry();
REVOKE ALL ON FUNCTION public.guard_fulfilment_status_entry() FROM public;

CREATE OR REPLACE FUNCTION public.guard_acquisition_fulfilment_status_entry() RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path=pg_catalog,public AS $$
BEGIN IF NEW.status IS DISTINCT FROM OLD.status AND current_user <> 'postgres' THEN RAISE EXCEPTION 'Acquisition fulfilment status changes must use transition_workflow_entity'; END IF; RETURN NEW; END; $$;
DROP TRIGGER IF EXISTS acquisition_fulfilments_status_entry_guard ON public.acquisition_fulfilments;
CREATE TRIGGER acquisition_fulfilments_status_entry_guard BEFORE UPDATE OF status ON public.acquisition_fulfilments FOR EACH ROW EXECUTE FUNCTION public.guard_acquisition_fulfilment_status_entry();
REVOKE ALL ON FUNCTION public.guard_acquisition_fulfilment_status_entry() FROM public;
