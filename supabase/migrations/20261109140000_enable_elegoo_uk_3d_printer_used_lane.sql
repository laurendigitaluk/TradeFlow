-- Make the existing ELEGOO UK manufacturer source available to both 3D-printer research lanes.
-- The category playbook continues to select the FDM collection for new research
-- and the pre-owned collection for used research. Collection pages remain discovery only.
-- This update-only migration does not create or copy a source row into TEST.
UPDATE public.platform_research_sources
SET research_scope = 'all',
    updated_at = now()
WHERE source_name = 'ELEGOO UK'
  AND domain = 'uk.elegoo.com'
  AND source_kind = 'manufacturer'
  AND country_code = 'GB'
  AND enabled = true
  AND category_slugs @> ARRAY['3d-printers-equipment']::text[]
  AND research_scope = 'new_uk';
