-- TradeFlow migration 062: harden retail order access and status authority.
-- Customer order reads remain exposed through the existing customer RPCs.
-- Subscriber writes require orders permissions and the orders capability.

DROP POLICY IF EXISTS retail_orders_delete_admins ON public.retail_orders;
DROP POLICY IF EXISTS retail_orders_insert_members ON public.retail_orders;
DROP POLICY IF EXISTS retail_orders_select_members ON public.retail_orders;
DROP POLICY IF EXISTS retail_orders_update_members ON public.retail_orders;
DROP POLICY IF EXISTS retail_orders_subscription_delete ON public.retail_orders;
DROP POLICY IF EXISTS retail_orders_subscription_insert ON public.retail_orders;
DROP POLICY IF EXISTS retail_orders_subscription_select ON public.retail_orders;
DROP POLICY IF EXISTS retail_orders_subscription_update ON public.retail_orders;
CREATE POLICY retail_orders_subscription_select ON public.retail_orders FOR SELECT USING (private.has_tenant_permission(tenant_id,auth.uid(),'orders.view') AND private.has_tenant_feature(tenant_id,'module.orders'));
CREATE POLICY retail_orders_subscription_insert ON public.retail_orders FOR INSERT WITH CHECK (private.has_tenant_permission(tenant_id,auth.uid(),'orders.manage') AND private.has_tenant_feature(tenant_id,'module.orders'));
CREATE POLICY retail_orders_subscription_update ON public.retail_orders FOR UPDATE USING (private.has_tenant_permission(tenant_id,auth.uid(),'orders.manage') AND private.has_tenant_feature(tenant_id,'module.orders')) WITH CHECK (private.has_tenant_permission(tenant_id,auth.uid(),'orders.manage') AND private.has_tenant_feature(tenant_id,'module.orders'));
CREATE POLICY retail_orders_subscription_delete ON public.retail_orders FOR DELETE USING (private.has_tenant_permission(tenant_id,auth.uid(),'orders.manage') AND private.has_tenant_feature(tenant_id,'module.orders'));

DROP POLICY IF EXISTS retail_order_items_delete_admins ON public.retail_order_items;
DROP POLICY IF EXISTS retail_order_items_insert_members ON public.retail_order_items;
DROP POLICY IF EXISTS retail_order_items_select_members ON public.retail_order_items;
DROP POLICY IF EXISTS retail_order_items_update_members ON public.retail_order_items;
DROP POLICY IF EXISTS retail_order_items_subscription_delete ON public.retail_order_items;
DROP POLICY IF EXISTS retail_order_items_subscription_insert ON public.retail_order_items;
DROP POLICY IF EXISTS retail_order_items_subscription_select ON public.retail_order_items;
DROP POLICY IF EXISTS retail_order_items_subscription_update ON public.retail_order_items;
CREATE POLICY retail_order_items_subscription_select ON public.retail_order_items FOR SELECT USING (private.has_tenant_permission(tenant_id,auth.uid(),'orders.view') AND private.has_tenant_feature(tenant_id,'module.orders'));
CREATE POLICY retail_order_items_subscription_insert ON public.retail_order_items FOR INSERT WITH CHECK (private.has_tenant_permission(tenant_id,auth.uid(),'orders.manage') AND private.has_tenant_feature(tenant_id,'module.orders'));
CREATE POLICY retail_order_items_subscription_update ON public.retail_order_items FOR UPDATE USING (private.has_tenant_permission(tenant_id,auth.uid(),'orders.manage') AND private.has_tenant_feature(tenant_id,'module.orders')) WITH CHECK (private.has_tenant_permission(tenant_id,auth.uid(),'orders.manage') AND private.has_tenant_feature(tenant_id,'module.orders'));
CREATE POLICY retail_order_items_subscription_delete ON public.retail_order_items FOR DELETE USING (private.has_tenant_permission(tenant_id,auth.uid(),'orders.manage') AND private.has_tenant_feature(tenant_id,'module.orders'));

DROP POLICY IF EXISTS retail_order_trade_ins_delete_admins ON public.retail_order_trade_ins;
DROP POLICY IF EXISTS retail_order_trade_ins_insert_members ON public.retail_order_trade_ins;
DROP POLICY IF EXISTS retail_order_trade_ins_select_members ON public.retail_order_trade_ins;
DROP POLICY IF EXISTS retail_order_trade_ins_update_members ON public.retail_order_trade_ins;
DROP POLICY IF EXISTS retail_order_trade_ins_subscription_delete ON public.retail_order_trade_ins;
DROP POLICY IF EXISTS retail_order_trade_ins_subscription_insert ON public.retail_order_trade_ins;
DROP POLICY IF EXISTS retail_order_trade_ins_subscription_select ON public.retail_order_trade_ins;
DROP POLICY IF EXISTS retail_order_trade_ins_subscription_update ON public.retail_order_trade_ins;
CREATE POLICY retail_order_trade_ins_subscription_select ON public.retail_order_trade_ins FOR SELECT USING (private.has_tenant_permission(tenant_id,auth.uid(),'orders.view') AND private.has_tenant_feature(tenant_id,'module.trade_in'));
CREATE POLICY retail_order_trade_ins_subscription_insert ON public.retail_order_trade_ins FOR INSERT WITH CHECK (private.has_tenant_permission(tenant_id,auth.uid(),'orders.manage') AND private.has_tenant_feature(tenant_id,'module.trade_in'));
CREATE POLICY retail_order_trade_ins_subscription_update ON public.retail_order_trade_ins FOR UPDATE USING (private.has_tenant_permission(tenant_id,auth.uid(),'orders.manage') AND private.has_tenant_feature(tenant_id,'module.trade_in')) WITH CHECK (private.has_tenant_permission(tenant_id,auth.uid(),'orders.manage') AND private.has_tenant_feature(tenant_id,'module.trade_in'));
CREATE POLICY retail_order_trade_ins_subscription_delete ON public.retail_order_trade_ins FOR DELETE USING (private.has_tenant_permission(tenant_id,auth.uid(),'orders.manage') AND private.has_tenant_feature(tenant_id,'module.trade_in'));

CREATE OR REPLACE FUNCTION public.guard_retail_order_status_entry()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path=pg_catalog,public AS $$
BEGIN
  IF NEW.status IS DISTINCT FROM OLD.status AND current_user <> 'postgres' THEN
    RAISE EXCEPTION 'Retail order status changes must use transition_workflow_entity';
  END IF;
  RETURN NEW;
END;
$$;
DROP TRIGGER IF EXISTS retail_orders_status_entry_guard ON public.retail_orders;
CREATE TRIGGER retail_orders_status_entry_guard BEFORE UPDATE OF status ON public.retail_orders FOR EACH ROW EXECUTE FUNCTION public.guard_retail_order_status_entry();
REVOKE ALL ON FUNCTION public.guard_retail_order_status_entry() FROM public;
