-- Shared evidence and exact package alias tables deployed to LIVE on 2026-10-22.
CREATE TABLE IF NOT EXISTS public.shared_market_evidence (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  master_product_id uuid NOT NULL REFERENCES public.catalogue_master_products(id) ON DELETE RESTRICT,
  evidence_type text NOT NULL CHECK (evidence_type IN ('uk_new','uk_used','overseas')),
  source_name text NOT NULL,
  source_url text,
  observed_price numeric(12,2) NOT NULL CHECK (observed_price >= 0),
  price_currency text NOT NULL DEFAULT 'GBP' CHECK (char_length(price_currency)=3),
  item_condition text,
  sales_channel text,
  availability text,
  observed_at timestamptz,
  notes text,
  is_active boolean NOT NULL DEFAULT true,
  source_record_key text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (source_name, source_record_key)
);
CREATE INDEX IF NOT EXISTS shared_market_evidence_product_type_date_idx ON public.shared_market_evidence (master_product_id,evidence_type,observed_at DESC) WHERE is_active;
CREATE INDEX IF NOT EXISTS shared_market_evidence_source_url_idx ON public.shared_market_evidence (source_url) WHERE source_url IS NOT NULL;
ALTER TABLE public.shared_market_evidence ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS shared_market_evidence_read_active ON public.shared_market_evidence;
CREATE POLICY shared_market_evidence_read_active ON public.shared_market_evidence FOR SELECT TO authenticated USING (is_active);
REVOKE ALL PRIVILEGES ON TABLE public.shared_market_evidence FROM anon, authenticated;
GRANT SELECT ON TABLE public.shared_market_evidence TO authenticated;
GRANT ALL PRIVILEGES ON TABLE public.shared_market_evidence TO service_role;
COMMENT ON TABLE public.shared_market_evidence IS 'Platform-managed shared market evidence. Subscriber research remains private in tenant_buying_research; writes must use trusted server-side ingestion.';

CREATE TABLE IF NOT EXISTS public.catalogue_master_product_package_aliases (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  master_product_id uuid NOT NULL REFERENCES public.catalogue_master_products(id) ON DELETE CASCADE,
  alias_name text NOT NULL CHECK (length(trim(alias_name)) > 0),
  alias_key text GENERATED ALWAYS AS (lower(regexp_replace(trim(alias_name), '[^a-zA-Z0-9]+', '-', 'g'))) STORED,
  supplier_name text,
  supplier_url text,
  notes text,
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
CREATE UNIQUE INDEX IF NOT EXISTS uq_master_package_alias_global ON public.catalogue_master_product_package_aliases (master_product_id, alias_key) WHERE supplier_name IS NULL;
CREATE UNIQUE INDEX IF NOT EXISTS uq_master_package_alias_supplier ON public.catalogue_master_product_package_aliases (master_product_id, alias_key, lower(trim(supplier_name))) WHERE supplier_name IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_master_package_alias_active_key ON public.catalogue_master_product_package_aliases (alias_key) WHERE is_active = true;
CREATE INDEX IF NOT EXISTS idx_master_package_alias_product ON public.catalogue_master_product_package_aliases (master_product_id) WHERE is_active = true;
ALTER TABLE public.catalogue_master_product_package_aliases ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE public.catalogue_master_product_package_aliases FROM PUBLIC, anon, authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.catalogue_master_product_package_aliases TO service_role;
