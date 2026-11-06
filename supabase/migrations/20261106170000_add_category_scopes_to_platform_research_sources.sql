-- Add explicit product-category scope to the approved research source registry.
-- Empty category_slugs means the source is not eligible for any category.
-- '*' is reserved for deliberate general marketplaces/retailers (Amazon UK and eBay UK).
ALTER TABLE public.platform_research_sources
  ADD COLUMN IF NOT EXISTS category_slugs text[] NOT NULL DEFAULT ARRAY[]::text[];

CREATE INDEX IF NOT EXISTS platform_research_sources_category_slugs_gin
  ON public.platform_research_sources USING gin (category_slugs);

COMMENT ON COLUMN public.platform_research_sources.category_slugs IS
  'Explicit TradeFlow catalogue category slugs this website may be searched for. Empty means disabled for research; * means deliberately universal.';

UPDATE public.platform_research_sources
SET category_slugs = CASE domain
    WHEN 'store.creality.com' THEN ARRAY['3d-printers-equipment']::text[]
    WHEN 'mpb.com' THEN ARRAY['cameras','camera-and-video','camera-equipment','camera-accessories','lenses','lens-accessories','action-cameras','action-camera-accessories','video-cameras','video-equipment','optics','drones']::text[]
    WHEN 'brighttangerine.com' THEN ARRAY['camera-accessories','camera-rig','camera-supports','supports-and-stabilisation','video-equipment','video-production-equipment','action-camera-accessories']::text[]
    WHEN 'dji.com' THEN ARRAY['drones','drone-accessories','action-cameras','action-camera-accessories']::text[]
    WHEN 'sony.co.uk' THEN ARRAY['cameras','camera-and-video','camera-equipment','camera-accessories','lenses','lens-accessories','action-cameras','action-camera-accessories','video-cameras','video-equipment','optics','audio','audio-and-video','professional-audio']::text[]
    WHEN 'jessops.com' THEN ARRAY['cameras','camera-and-video','camera-equipment','camera-accessories','lenses','lens-accessories','action-cameras','action-camera-accessories','video-cameras','video-equipment','optics']::text[]
    WHEN 'parkcameras.com' THEN ARRAY['cameras','camera-and-video','camera-equipment','camera-accessories','lenses','lens-accessories','action-cameras','action-camera-accessories','video-cameras','video-equipment','optics']::text[]
    WHEN 'wexphotovideo.com' THEN ARRAY['cameras','camera-and-video','camera-equipment','camera-accessories','lenses','lens-accessories','action-cameras','action-camera-accessories','video-cameras','video-equipment','optics','camera-flash','camera-rig','camera-supports','supports-and-stabilisation','video-production-equipment','lighting','lighting-modifier','lighting-support','photography-lighting-and-studio','studio-equipment','studio-lighting','audio','audio-and-video','professional-audio']::text[]
    WHEN 'amazon.co.uk' THEN ARRAY['*']::text[]
    WHEN 'cameraworld.co.uk' THEN ARRAY['cameras','camera-and-video','camera-equipment','camera-accessories','lenses','lens-accessories','action-cameras','action-camera-accessories','video-cameras','video-equipment','optics']::text[]
    WHEN 'cliftoncameras.co.uk' THEN ARRAY['cameras','camera-and-video','camera-equipment','camera-accessories','lenses','lens-accessories','action-cameras','action-camera-accessories','video-cameras','video-equipment','optics']::text[]
    WHEN 'harrisoncameras.co.uk' THEN ARRAY['cameras','camera-and-video','camera-equipment','camera-accessories','lenses','lens-accessories','action-cameras','action-camera-accessories','video-cameras','video-equipment','optics']::text[]
    WHEN 'lcegroup.co.uk' THEN ARRAY['cameras','camera-and-video','camera-equipment','camera-accessories','lenses','lens-accessories','action-cameras','action-camera-accessories','video-cameras','video-equipment','optics']::text[]
    WHEN 'camerapricebuster.co.uk' THEN ARRAY['cameras','camera-and-video','camera-equipment','camera-accessories','lenses','lens-accessories','action-cameras','action-camera-accessories','video-cameras','video-equipment','optics']::text[]
    WHEN 'castlecameras.co.uk' THEN ARRAY['cameras','camera-and-video','camera-equipment','camera-accessories','lenses','lens-accessories','action-cameras','action-camera-accessories','video-cameras','video-equipment','optics']::text[]
    WHEN 'ffordes.com' THEN ARRAY['cameras','camera-and-video','camera-equipment','camera-accessories','lenses','lens-accessories','action-cameras','action-camera-accessories','video-cameras','video-equipment','optics']::text[]
    WHEN 'heliguy.com' THEN ARRAY['drones','drone-accessories']::text[]
    WHEN 'hobbyrc.co.uk' THEN ARRAY['drones','drone-accessories']::text[]
    WHEN 'dji-retail.co.uk' THEN ARRAY['drones','drone-accessories','action-cameras','action-camera-accessories']::text[]
    WHEN 'store.dji.com' THEN ARRAY['drones','drone-accessories','action-cameras','action-camera-accessories']::text[]
    WHEN 'ebay.co.uk' THEN ARRAY['*']::text[]
    WHEN 'usedlens.co.uk' THEN ARRAY['cameras','camera-equipment','camera-accessories','lenses','lens-accessories','optics']::text[]
    WHEN 'webuy.com' THEN ARRAY['mobile-phones','gaming-consoles-accessories','laptops','cameras','camera-equipment','action-cameras','video-cameras','audio','audio-and-video']::text[]
    WHEN 'vinted.co.uk' THEN ARRAY[]::text[]
    WHEN 'adorama.com' THEN ARRAY[]::text[]
    WHEN 'bhphotovideo.com' THEN ARRAY[]::text[]
    WHEN 'keh.com' THEN ARRAY[]::text[]
    ELSE ARRAY[]::text[]
  END,
  updated_at = now();

INSERT INTO public.platform_research_sources
  (source_name, domain, homepage_url, source_kind, country_code, research_scope, enabled, priority, notes, category_slugs)
VALUES
('Smyths Toys UK','smythstoys.com','https://www.smythstoys.com/uk/en-gb','retailer','GB','new_uk',true,20,'Category-scoped approved source. Discovered/price evidence must still resolve to an exact direct UK product page.',ARRAY['gaming-consoles-accessories']::text[]),
('Argos UK','argos.co.uk','https://www.argos.co.uk/','retailer','GB','new_uk',true,20,'Category-scoped approved source. Discovered/price evidence must still resolve to an exact direct UK product page.',ARRAY['gaming-consoles-accessories','mobile-phones','laptops']::text[]),
('Currys UK','currys.co.uk','https://www.currys.co.uk/','retailer','GB','new_uk',true,20,'Category-scoped approved source. Discovered/price evidence must still resolve to an exact direct UK product page.',ARRAY['gaming-consoles-accessories','mobile-phones','laptops']::text[]),
('John Lewis UK','johnlewis.com','https://www.johnlewis.com/','retailer','GB','new_uk',true,20,'Category-scoped approved source. Discovered/price evidence must still resolve to an exact direct UK product page.',ARRAY['gaming-consoles-accessories','mobile-phones','laptops']::text[]),
('EE UK','ee.co.uk','https://ee.co.uk/','retailer','GB','new_uk',true,25,'Category-scoped approved source. Discovered/price evidence must still resolve to an exact direct UK product page.',ARRAY['gaming-consoles-accessories','mobile-phones']::text[]),
('GAME UK','game.co.uk','https://www.game.co.uk/','retailer','GB','new_uk',true,25,'Category-scoped approved source. Discovered/price evidence must still resolve to an exact direct UK product page.',ARRAY['gaming-consoles-accessories']::text[]),
('Very UK','very.co.uk','https://www.very.co.uk/','retailer','GB','new_uk',true,25,'Category-scoped approved source. Discovered/price evidence must still resolve to an exact direct UK product page.',ARRAY['gaming-consoles-accessories','mobile-phones','laptops']::text[]),
('Selfridges UK','selfridges.com','https://www.selfridges.com/GB/en/','retailer','GB','new_uk',true,30,'Category-scoped approved source. Discovered/price evidence must still resolve to an exact direct UK product page.',ARRAY['gaming-consoles-accessories']::text[]),
('3D Prima UK','3dprima.co.uk','https://www.3dprima.co.uk/','retailer','GB','new_uk',true,15,'Category-scoped approved source. Discovered/price evidence must still resolve to an exact direct UK product page.',ARRAY['3d-printers-equipment']::text[]),
('3DJake UK','3djake.uk','https://www.3djake.uk/','retailer','GB','new_uk',true,20,'Category-scoped approved source. Discovered/price evidence must still resolve to an exact direct UK product page.',ARRAY['3d-printers-equipment']::text[]),
('Regton Metal Detectors','regton.com','https://www.regton.com/','retailer','GB','new_uk',true,10,'Category-scoped approved source. Discovered/price evidence must still resolve to an exact direct UK product page.',ARRAY['metal-detectors']::text[]),
('Spin A Disc Metal Detectors','spinadiscmetaldetectors.com','https://spinadiscmetaldetectors.com/','retailer','GB','new_uk',true,15,'Category-scoped approved source. Discovered/price evidence must still resolve to an exact direct UK product page.',ARRAY['metal-detectors']::text[]),
('UK History Finders','uk-historyfinders.co.uk','https://www.uk-historyfinders.co.uk/','retailer','GB','new_uk',true,20,'Category-scoped approved source. Discovered/price evidence must still resolve to an exact direct UK product page.',ARRAY['metal-detectors']::text[]),
('Unearthed UK','uneartheduk.co.uk','https://www.uneartheduk.co.uk/','retailer','GB','new_uk',true,20,'Category-scoped approved source. Discovered/price evidence must still resolve to an exact direct UK product page.',ARRAY['metal-detectors']::text[]),
('Wolds Detecting','woldsdetecting.co.uk','https://www.woldsdetecting.co.uk/','retailer','GB','new_uk',true,25,'Category-scoped approved source. Discovered/price evidence must still resolve to an exact direct UK product page.',ARRAY['metal-detectors']::text[]),
('Minelab UK','minelab.com','https://uk.minelab.com/','manufacturer','GB','official',true,10,'Category-scoped approved source. Discovered/price evidence must still resolve to an exact direct UK product page.',ARRAY['metal-detectors']::text[]),
('Apple UK','apple.com','https://www.apple.com/uk/','manufacturer','GB','official',true,10,'Category-scoped approved source. Discovered/price evidence must still resolve to an exact direct UK product page.',ARRAY['mobile-phones','laptops']::text[]),
('Samsung UK','samsung.com','https://www.samsung.com/uk/','manufacturer','GB','official',true,10,'Category-scoped approved source. Discovered/price evidence must still resolve to an exact direct UK product page.',ARRAY['mobile-phones','laptops']::text[]),
('Google Store UK','store.google.com','https://store.google.com/gb/','manufacturer','GB','official',true,10,'Category-scoped approved source. Discovered/price evidence must still resolve to an exact direct UK product page.',ARRAY['mobile-phones']::text[]),
('Motorola UK','motorola.com','https://www.motorola.com/gb/en/','manufacturer','GB','official',true,10,'Category-scoped approved source. Discovered/price evidence must still resolve to an exact direct UK product page.',ARRAY['mobile-phones']::text[]),
('OPPO UK','oppo.com','https://www.oppo.com/uk/','manufacturer','GB','official',true,10,'Category-scoped approved source. Discovered/price evidence must still resolve to an exact direct UK product page.',ARRAY['mobile-phones']::text[]),
('Nintendo UK','nintendo.com','https://www.nintendo.com/en-gb/','manufacturer','GB','official',true,10,'Category-scoped approved source. Discovered/price evidence must still resolve to an exact direct UK product page.',ARRAY['gaming-consoles-accessories']::text[]),
('Sony PlayStation UK','playstation.com','https://www.playstation.com/en-gb/','manufacturer','GB','official',true,10,'Category-scoped approved source. Discovered/price evidence must still resolve to an exact direct UK product page.',ARRAY['gaming-consoles-accessories']::text[]),
('Microsoft Xbox UK','xbox.com','https://www.xbox.com/en-GB/','manufacturer','GB','official',true,10,'Category-scoped approved source. Discovered/price evidence must still resolve to an exact direct UK product page.',ARRAY['gaming-consoles-accessories']::text[])
ON CONFLICT (domain) DO UPDATE SET
  source_name = EXCLUDED.source_name,
  homepage_url = EXCLUDED.homepage_url,
  source_kind = EXCLUDED.source_kind,
  country_code = EXCLUDED.country_code,
  research_scope = EXCLUDED.research_scope,
  enabled = true,
  priority = EXCLUDED.priority,
  notes = EXCLUDED.notes,
  category_slugs = EXCLUDED.category_slugs,
  updated_at = now();
