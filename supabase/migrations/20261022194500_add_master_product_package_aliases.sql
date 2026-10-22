-- Canonical master products may have supplier-specific package labels.
-- Keep aliases attached to one exact master product so bundle/controller variants never collapse together.
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

CREATE UNIQUE INDEX IF NOT EXISTS uq_master_package_alias_global
  ON public.catalogue_master_product_package_aliases (master_product_id, alias_key)
  WHERE supplier_name IS NULL;

CREATE UNIQUE INDEX IF NOT EXISTS uq_master_package_alias_supplier
  ON public.catalogue_master_product_package_aliases (master_product_id, alias_key, lower(trim(supplier_name)))
  WHERE supplier_name IS NOT NULL;

ALTER TABLE public.catalogue_master_product_package_aliases ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE public.catalogue_master_product_package_aliases FROM PUBLIC, anon, authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.catalogue_master_product_package_aliases TO service_role;

CREATE INDEX IF NOT EXISTS idx_master_package_alias_active_key
  ON public.catalogue_master_product_package_aliases (alias_key)
  WHERE is_active = true;

CREATE INDEX IF NOT EXISTS idx_master_package_alias_product
  ON public.catalogue_master_product_package_aliases (master_product_id)
  WHERE is_active = true;
