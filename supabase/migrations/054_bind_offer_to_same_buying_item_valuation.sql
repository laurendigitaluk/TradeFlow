-- TradeFlow migration 054: bind an offer to the valuation belonging to the same buying item.
--
-- Before this repair, offers carried tenant_id + buying_item_id + trading_value_id,
-- but the database only enforced tenant-scoped foreign keys independently. That
-- allowed an offer to reference a valuation belonging to another buying item in
-- the same tenant. The composite key below makes the item/valuation relationship
-- authoritative at database level.

ALTER TABLE public.trading_values
  ADD CONSTRAINT trading_values_tenant_item_id_key
  UNIQUE (tenant_id, buying_item_id, id);

ALTER TABLE public.offers
  ADD CONSTRAINT offers_tenant_item_valuation_fkey
  FOREIGN KEY (tenant_id, buying_item_id, trading_value_id)
  REFERENCES public.trading_values (tenant_id, buying_item_id, id)
  ON DELETE RESTRICT;
