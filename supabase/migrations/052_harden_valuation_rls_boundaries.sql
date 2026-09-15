-- TradeFlow valuation security hardening.
-- Remove broad tenant-member/admin policies that could bypass valuation permission + module checks.
-- Direct table access is now:
--   SELECT  valuation.view + module.valuation
--   INSERT  valuation.manage + module.valuation
--   UPDATE  valuation.manage + module.valuation
--   DELETE  valuation.manage + module.valuation

DROP POLICY IF EXISTS trading_values_member_select ON public.trading_values;
DROP POLICY IF EXISTS trading_values_member_insert ON public.trading_values;
DROP POLICY IF EXISTS trading_values_member_update ON public.trading_values;
DROP POLICY IF EXISTS trading_values_admin_delete ON public.trading_values;
DROP POLICY IF EXISTS trading_values_subscription_select ON public.trading_values;
DROP POLICY IF EXISTS trading_values_subscription_insert ON public.trading_values;
DROP POLICY IF EXISTS trading_values_subscription_update ON public.trading_values;
DROP POLICY IF EXISTS trading_values_subscription_delete ON public.trading_values;

CREATE POLICY trading_values_valuation_select
  ON public.trading_values
  FOR SELECT TO authenticated
  USING (
    private.has_tenant_permission(tenant_id, auth.uid(), 'valuation.view')
    AND private.has_tenant_feature(tenant_id, 'module.valuation')
  );

CREATE POLICY trading_values_valuation_insert
  ON public.trading_values
  FOR INSERT TO authenticated
  WITH CHECK (
    private.has_tenant_permission(tenant_id, auth.uid(), 'valuation.manage')
    AND private.has_tenant_feature(tenant_id, 'module.valuation')
  );

CREATE POLICY trading_values_valuation_update
  ON public.trading_values
  FOR UPDATE TO authenticated
  USING (
    private.has_tenant_permission(tenant_id, auth.uid(), 'valuation.manage')
    AND private.has_tenant_feature(tenant_id, 'module.valuation')
  )
  WITH CHECK (
    private.has_tenant_permission(tenant_id, auth.uid(), 'valuation.manage')
    AND private.has_tenant_feature(tenant_id, 'module.valuation')
  );

CREATE POLICY trading_values_valuation_delete
  ON public.trading_values
  FOR DELETE TO authenticated
  USING (
    private.has_tenant_permission(tenant_id, auth.uid(), 'valuation.manage')
    AND private.has_tenant_feature(tenant_id, 'module.valuation')
  );

DROP POLICY IF EXISTS trading_value_components_member_select ON public.trading_value_components;
DROP POLICY IF EXISTS trading_value_components_member_insert ON public.trading_value_components;
DROP POLICY IF EXISTS trading_value_components_member_update ON public.trading_value_components;
DROP POLICY IF EXISTS trading_value_components_admin_delete ON public.trading_value_components;

CREATE POLICY trading_value_components_valuation_select
  ON public.trading_value_components
  FOR SELECT TO authenticated
  USING (
    private.has_tenant_permission(tenant_id, auth.uid(), 'valuation.view')
    AND private.has_tenant_feature(tenant_id, 'module.valuation')
  );

CREATE POLICY trading_value_components_valuation_insert
  ON public.trading_value_components
  FOR INSERT TO authenticated
  WITH CHECK (
    private.has_tenant_permission(tenant_id, auth.uid(), 'valuation.manage')
    AND private.has_tenant_feature(tenant_id, 'module.valuation')
  );

CREATE POLICY trading_value_components_valuation_update
  ON public.trading_value_components
  FOR UPDATE TO authenticated
  USING (
    private.has_tenant_permission(tenant_id, auth.uid(), 'valuation.manage')
    AND private.has_tenant_feature(tenant_id, 'module.valuation')
  )
  WITH CHECK (
    private.has_tenant_permission(tenant_id, auth.uid(), 'valuation.manage')
    AND private.has_tenant_feature(tenant_id, 'module.valuation')
  );

CREATE POLICY trading_value_components_valuation_delete
  ON public.trading_value_components
  FOR DELETE TO authenticated
  USING (
    private.has_tenant_permission(tenant_id, auth.uid(), 'valuation.manage')
    AND private.has_tenant_feature(tenant_id, 'module.valuation')
  );

DROP POLICY IF EXISTS valuation_rules_member_select ON public.valuation_rules;
DROP POLICY IF EXISTS valuation_rules_admin_insert ON public.valuation_rules;
DROP POLICY IF EXISTS valuation_rules_admin_update ON public.valuation_rules;
DROP POLICY IF EXISTS valuation_rules_admin_delete ON public.valuation_rules;
DROP POLICY IF EXISTS valuation_rules_subscription_select ON public.valuation_rules;
DROP POLICY IF EXISTS valuation_rules_subscription_insert ON public.valuation_rules;
DROP POLICY IF EXISTS valuation_rules_subscription_update ON public.valuation_rules;
DROP POLICY IF EXISTS valuation_rules_subscription_delete ON public.valuation_rules;

CREATE POLICY valuation_rules_valuation_select
  ON public.valuation_rules
  FOR SELECT TO authenticated
  USING (
    private.has_tenant_permission(tenant_id, auth.uid(), 'valuation.view')
    AND private.has_tenant_feature(tenant_id, 'module.valuation')
  );

CREATE POLICY valuation_rules_valuation_insert
  ON public.valuation_rules
  FOR INSERT TO authenticated
  WITH CHECK (
    private.has_tenant_permission(tenant_id, auth.uid(), 'valuation.manage')
    AND private.has_tenant_feature(tenant_id, 'module.valuation')
  );

CREATE POLICY valuation_rules_valuation_update
  ON public.valuation_rules
  FOR UPDATE TO authenticated
  USING (
    private.has_tenant_permission(tenant_id, auth.uid(), 'valuation.manage')
    AND private.has_tenant_feature(tenant_id, 'module.valuation')
  )
  WITH CHECK (
    private.has_tenant_permission(tenant_id, auth.uid(), 'valuation.manage')
    AND private.has_tenant_feature(tenant_id, 'module.valuation')
  );

CREATE POLICY valuation_rules_valuation_delete
  ON public.valuation_rules
  FOR DELETE TO authenticated
  USING (
    private.has_tenant_permission(tenant_id, auth.uid(), 'valuation.manage')
    AND private.has_tenant_feature(tenant_id, 'module.valuation')
  );
