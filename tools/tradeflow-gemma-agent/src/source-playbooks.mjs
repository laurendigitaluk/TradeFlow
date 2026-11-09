// Website-specific navigation playbooks. Add one category at a time after inspecting
// the real site's public routes. Discovery pages are never evidence; the worker must
// follow matching product/listing links and validate the individual page.
const playbooks = {
  '3d-printers-equipment': {
    categoryInstructions: [
      'Respect the assigned master-catalogue branch. Do not mix standalone printer models with equipment, parts or accessory products; apply the matching branch-specific instructions.',
      'A brand catalogue, collection, search-results page or multi-product category page is a discovery page only. Extract links for the exact requested model, open each individual product/listing page, and validate price, GBP currency, condition and availability there.',
      'On manufacturer sites, search the requested manufacturer and exact model first, then navigate Printers / 3D Printers / product collections if search is weak.',
      'On used marketplaces, inspect individual seller listings. Do not use category averages, completed/sold prices, snippets without a direct listing, or listings for a different model/variant.',
      'Check pagination and load-more links where accessible. Record the route used, number of pages checked, matching links found and any access/robot/login failure.',
      'Work down the category hierarchy: category → branch → product family → manufacturer/model → exact package or variant → individual product/listing page. A category or branch page is only a map; enumerate its relevant product families and model links, then inspect the individual pages for the exact task product.',
      'Do not stop after the first successful route or first matching product. Check every configured search route for this website, inspect pagination and load-more links where available, and merge unique exact-model product URLs across routes before page inspection.' ,
      'Where product cards are loaded dynamically, use the website-specific public catalogue/search endpoint only when its playbook explicitly allows it; otherwise try the site search, category navigation, sitemap or visible product links and report which methods failed. Never invent a URL or bypass login/access controls.',
      'If a direct exact-model listing looks useful but one evidence field is missing or ambiguous, return it as BORDERLINE for ChatGPT inspection with the original URL, captured text and exact uncertainty. Never fill gaps by inference or treat borderline findings as verified evidence.'
    ],
    branchInstructions: {
      '3d-printers': [
        'Research standalone 3D printer machines and exact machine packages only. Reject filament, resin, hotends, build plates, upgrades, spare parts and accessories as mismatches.',
        'Break the printer branch into manufacturer, printer family, exact model and package/bundle variants. Inspect each model/package as a separate catalogue product and preserve Combo, bundle and machine-only distinctions.'
      ],
      '3d-printer-equipment-accessories': [
        'Research the exact equipment/accessory product requested by the catalogue task. Do not reject an accessory merely because it is not a standalone printer.',
        'Identify the exact accessory type, manufacturer, model/part number and compatible printer models. Never substitute a similar-looking part or infer compatibility.',
        'Separate consumables, replacement parts, upgrades and add-ons into their correct product identities; inspect the individual product page for UK GBP price, condition and availability.'
      ]
    },
    sites: {
      'store.creality.com': {
        label: 'Creality UK official store',
        collectionApi: 'shopify',
        routes: ['/uk/search?q={query}', '/uk/collections/fdm-3d-printer', '/uk/collections/ender-3-v3-series'],
        navigation: 'Use the UK storefront search first, then the verified FDM 3D Printer and model-family collections. Creality UK exposes its public Shopify collection products JSON; use it when the HTML contains no product cards, then follow exact standalone printer product handles to their individual UK product pages. Ignore accessories, upgrade kits and sibling printer variants.'
      },
      'bambu-lab-uk.myshopify.com': {
        label: 'Bambu Lab UK official store',
        routes: ['/search?q={query}', '/collections/3d-printers'],
        navigation: 'Use Shopify storefront search, then the 3D printer collection. Open the exact model product page; distinguish standalone printer from Combo/bundle packages.'
      },
      'uk.anycubic3d.com': {
        label: 'Anycubic UK official store',
        routes: ['/search?type=product&q={query}', '/collections/3d-printers'],
        navigation: 'Use product search and the 3D printer collection. Open the exact model page and keep printer-only and bundle variants separate.'
      },
      'uk.elegoo.com': {
        label: 'ELEGOO UK official store',
        collectionApi: 'shopify',
        routes: ['/collections/fdm-printers', '/collections/pre-owned-3d-printer'],
        routesByResearchType: {
          uk_new: ['/collections/fdm-printers'],
          uk_used: ['/collections/pre-owned-3d-printer']
        },
        genericSearchFallback: false,
        navigation: 'Use the FDM 3D Printers collection for uk_new and the dedicated Pre-owned 3D Printers collection for uk_used. Treat both as discovery pages only, follow exact individual printer product pages, preserve package/variant and new versus pre-owned condition, and reject sold-out listings as current used evidence.'
      },
      'uni3dverse.co.uk': {
        label: 'Uni3Dverse used and refurbished',
        routes: ['/used-3d-printers?search={query}', '/used-3d-printers'],
        navigation: 'Start in the used/refurbished printer catalogue. Open each matching listing and preserve the stated used/refurbished grade and warranty status.'
      },
      '3dgbire.com': {
        label: '3DGBIRE reconditioned',
        collectionApi: 'shopify',
        routes: ['/search?q={query}', '/collections/reconditioned-3d-printers-and-3d-scanners'],
        navigation: 'Inspect the reconditioned/ex-demo collection as well as site search. Open the individual product page and retain reconditioned or ex-demo condition; do not classify as new.'
      },
      '3dprima.co.uk': {
        label: '3D Prima UK retailer',
        routes: ['/search?query={query}', '/search?q={query}'],
        navigation: 'Search exact manufacturer and model. From any category results, follow the exact printer product card and exclude consumables and accessories.'
      },
      '123-3d.co.uk': {
        label: '123-3D UK retailer',
        collectionApi: 'shopify',
        routes: ['https://www.123-3d.co.uk/collections/3d-printers', 'https://www.123-3d.co.uk/collections/refurbished-printers'],
        routesByResearchType: {
          uk_new: ['https://www.123-3d.co.uk/collections/3d-printers'],
          uk_used: ['https://www.123-3d.co.uk/collections/refurbished-printers']
        },
        genericSearchFallback: false,
        navigation: 'Use the all-printers collection for uk_new and the dedicated refurbished-printers collection for uk_used. Keep the routes lane-specific, follow exact individual product pages, and preserve refurbished grade/condition and package variants.'
      },
      'idig3dprinting.co.uk': {
        label: 'iDig3DPrinting UK retailer',
        routes: ['https://www.idig3dprinting.co.uk/product-category/3d-printers/'],
        genericSearchFallback: false,
        navigation: 'Use the dedicated WordPress 3D Printers product category as a discovery page. Follow pagination and exact individual printer product links; do not use the general shop/search routes as evidence.'
      },
      '3dflo.com': {
        label: '3DFLO UK retailer',
        routes: ['https://www.3dflo.com/product-category/3d-printers/'],
        genericSearchFallback: false,
        navigation: 'Use the dedicated 3D Printers product category as a discovery page. Follow exact printer product links and exclude filament, spares, upgrades and STL files.'
      },
      '3djake.uk': {
        label: '3DJake UK retailer',
        routes: ['/search?query={query}', '/search?q={query}'],
        navigation: 'Use the search function and 3D printer category filters. Open the exact product page and verify UK GBP pricing, not another locale.'
      },
      'gumtree.com': {
        label: 'Gumtree UK used marketplace',
        routes: ['/uk/srpsearch%2B{slug}', '/for-sale/uk/srpsearch%2B{slug}'],
        navigation: 'Search UK advertisements for the exact model. Open individual adverts, verify seller asking price, location, condition and availability. Exclude wanted ads, accessories, parts and expired listings.'
      },
      'secondhand.org.uk': {
        label: 'SecondHand UK marketplace',
        routes: ['/second-hand-3d-printers?search={query}', '/second-hand-3d-printers'],
        navigation: 'Use the second-hand 3D printer category as a discovery page, then open each exact-model listing and verify the current asking price and condition.'
      },
      'ebay.co.uk': {
        label: 'eBay UK marketplace',
        routes: ['/sch/i.html?_nkw={query}&_sacat=0'],
        navigation: 'Search exact manufacturer/model. Open individual active item pages only. Ignore sold/completed listings for current asking-price evidence; separate used, refurbished and new conditions.'
      },
      'amazon.co.uk': {
        label: 'Amazon UK marketplace',
        routes: ['/s?k={query}'],
        navigation: 'Use search results only to discover products. Follow a matching result to its direct ASIN product page (/dp/ or /gp/product/), verify the exact model, selected seller/offer, GBP price and availability. Do not use search-result prices as evidence.'
      }
    }
  },
  'gaming-consoles-accessories': {
    categoryInstructions: [
      'Follow the master catalogue hierarchy: category → branch → product family → manufacturer/model → exact edition, storage, colour or bundle → individual product/listing page. A category, search page or collection is discovery only, never price evidence.',
      'Capture every relevant individual UK listing and preserve its complete page text, visible GBP price occurrences and nearby contexts, seller, condition, availability, delivery/location clues, identifiers and uncertainty. Do not approve, reject, rank, classify suitability or match evidence to master products; ChatGPT does that.',
      'Keep consoles, handhelds, controllers, headsets, VR equipment, games and accessories in their correct branches. Never treat an accessory as a complete console or merge different product types.',
      'Preserve exact console generation and model, storage capacity, disc versus digital edition, Slim/Pro variants, colour, region, included controllers/games and bundle contents. Standard console, special edition and bundle packages remain separate.',
      'For controllers and accessories, preserve exact manufacturer, model/part number, platform compatibility, wired/wireless connection, single/pair quantity, colour and edition. Do not infer compatibility from appearance or a broad platform label.',
      'Keep UK-new and UK-used research lanes separate. For used listings capture the seller asking price, stated condition, completeness, faults, refurbishment grade, warranty and availability. Sold/completed prices are not current asking-price evidence.',
      'Do not stop after the first successful route. Check all configured source routes, follow matching product links, pagination and load-more pages where accessible, and retain borderline or incomplete pages for ChatGPT review rather than discarding them.'
    ],
    branchInstructions: {
      'playstation-consoles': ['Research complete PlayStation consoles only. Preserve PS generation, exact model/CUH code where shown, storage, disc/digital, Slim/Pro edition, colour and bundle contents.'],
      'xbox-consoles': ['Research complete Xbox consoles only. Preserve Xbox generation, Series S/X, storage, disc/digital edition, colour/Carbon Black, refresh and bundle contents.'],
      'nintendo-consoles': ['Research complete Nintendo home consoles only. Preserve exact generation, model, storage, region, included Joy-Con/controllers, dock and bundle contents.'],
      'nintendo-home-consoles': ['Research complete Nintendo home consoles only. Keep console-only and bundles with games/accessories separate.'],
      'nintendo-handheld-consoles': ['Research Nintendo handheld systems only. Preserve exact generation, screen/model revision, storage, colour and included accessories.'],
      'playstation-handhelds': ['Research PlayStation handheld devices only. Preserve PSP/PS Vita/Portal generation, storage, model revision, connectivity and included accessories.'],
      'playstation-vr': ['Research complete PlayStation VR headsets and sets. Preserve VR generation, headset revision, controller/camera bundle and compatibility.'],
      'playstation-controllers': ['Research PlayStation controllers only. Preserve DualShock/DualSense generation, edition, colour, connection and single/pair quantity.'],
      'xbox-controllers': ['Research Xbox controllers only. Preserve model generation, platform compatibility, wired/wireless, colour, special edition and bundle quantity.'],
      'nintendo-controllers': ['Research Nintendo controllers only. Preserve Joy-Con left/right/pair, Pro Controller generation, colour, edition and included grip/straps.'],
      'playstation-headsets': ['Research PlayStation-compatible gaming headsets only. Preserve exact model, wireless/wired, platform edition and included receiver/accessories.'],
      'xbox-gaming-headsets': ['Research Xbox-compatible gaming headsets only. Preserve exact model, wireless/wired, Xbox compatibility and bundle contents.'],
      'playstation-accessories': ['Research PlayStation accessories only. Identify exact accessory type, model and compatibility; do not substitute a console, controller or similar accessory.'],
      'xbox-accessories': ['Research Xbox accessories only. Identify exact accessory type, model and compatibility; do not substitute a console or controller.'],
      'nintendo-accessories': ['Research Nintendo accessories only. Identify exact accessory type, Switch generation compatibility, model and bundle contents.'],
      'sega-home-consoles': ['Research complete Sega home consoles only. Preserve exact generation/model, region, storage/modification state and bundle contents.'],
      'sega-console-add-ons': ['Research Sega console add-ons only. Identify exact add-on, console generation compatibility and package contents.'],
      'sega-handheld-consoles': ['Research Sega handheld consoles only. Preserve exact model/generation, screen, storage, region and included accessories.'],
      'atari-home-consoles': ['Research complete Atari home consoles only. Preserve exact model/generation, edition, region and bundle contents.'],
      'atari-handheld-consoles': ['Research Atari handheld consoles only. Preserve exact model, screen/storage variant, edition and included accessories.']
    },
    sites: {
      'xbox.com': { label: 'Microsoft Xbox UK official', routes: ['/en-GB/consoles'], genericSearchFallback: false, navigation: 'Use the UK Xbox product catalogue and official console pages for exact model, storage, edition and bundle identity. Official pages are not automatically current price evidence; follow UK GBP retail offers where needed.' },
      'nintendo.com': { label: 'Nintendo UK official', routes: ['/en-gb/'], genericSearchFallback: false, navigation: 'Use the UK Nintendo product catalogue and exact console/controller/accessory pages. Preserve generation, Joy-Con configuration, colour and bundle contents.' },
      'playstation.com': { label: 'Sony PlayStation UK official', routes: ['/en-gb/ps5'], genericSearchFallback: false, navigation: 'Use the UK PlayStation product pages for exact model, edition, accessories and compatibility. Keep console, controller, headset and VR product families separate.' },
      'argos.co.uk': { label: 'Argos UK retailer', routes: ['/browse/technology/video-games-and-consoles/c:29952/'], genericSearchFallback: false, navigation: 'Use search/category results for discovery, then open each exact product detail page. Capture current GBP price, availability, delivery/collection and package contents.' },
      'currys.co.uk': { label: 'Currys UK retailer', routes: ['/gaming/consoles'], genericSearchFallback: false, navigation: 'Use search results and gaming console/controller categories for discovery; follow exact product pages and capture the selected variant, GBP price and stock.' },
      'johnlewis.com': { label: 'John Lewis UK retailer', routes: ['/'], genericSearchFallback: false, navigation: 'Use UK gaming product search and follow exact console/controller/headset detail pages. Capture current GBP price, stock and delivery information.' },
      'smythstoys.com': { label: 'Smyths Toys UK retailer', routes: ['/uk/en-gb/video-games'], genericSearchFallback: false, navigation: 'Use UK gaming and Nintendo/PlayStation/Xbox product categories as discovery pages; follow exact item pages and preserve bundles and platform variants.' },
      'ee.co.uk': { label: 'EE UK retailer', routes: ['/'], genericSearchFallback: false, navigation: 'Use UK gaming hardware product pages only. Distinguish device price from contract, finance, monthly payment or service plan amounts.' },
      'game.co.uk': { label: 'GAME UK retailer', routes: ['/'], genericSearchFallback: false, navigation: 'Use console, controller and accessory categories for discovery; inspect individual product pages and preserve new, pre-owned, refurbished and bundle distinctions.' },
      'very.co.uk': { label: 'Very UK retailer', routes: ['/browse/gaming-consoles'], genericSearchFallback: false, navigation: 'Use gaming product search and category pages for discovery; open exact item pages and capture GBP price, stock, condition and bundle contents.' },
      'selfridges.com': { label: 'Selfridges UK retailer', routes: ['/'], genericSearchFallback: false, navigation: 'Use UK gaming product listings for discovery; confirm UK GBP price and exact edition on the individual product page.' },
      'amazon.co.uk': { label: 'Amazon UK marketplace', routes: [], genericSearchFallback: false, navigation: 'Search results are discovery only. Follow each matching result to a direct ASIN product page; capture the selected seller/offer, exact edition, GBP price and availability.' },
      'ebay.co.uk': { label: 'eBay UK marketplace', routes: [], genericSearchFallback: false, navigation: 'Search exact manufacturer/model and inspect individual active UK item listings only. Capture asking price, condition, completeness, seller location and availability; exclude sold/completed items as current asking prices.' },
      'webuy.com': { label: 'CeX UK used dealer', routes: ['/'], genericSearchFallback: false, navigation: 'Use CeX search/category pages for discovery, then open the exact item page. Capture grade, tested/refurbished condition, warranty, store/online availability and current GBP price.' },
      'cashconverters.co.uk': { label: 'Cash Converters UK used dealer', routes: ['/shop'], genericSearchFallback: false, navigation: 'Use UK gaming-console listings for discovery and open each individual item page. Capture the exact Series/model and storage, visible GBP asking price, seller/store location, condition, included controller/cables, box status, warranty and delivery/collection availability. Keep each individual listing separate; do not average or infer prices.' },
      'cashexp.co.uk': { label: 'Cash Express UK used dealer', routes: ['/product-category/video-games-consoles/'], genericSearchFallback: false, navigation: 'Search UK gaming consoles and inspect the individual item page. Capture exact model/storage, visible GBP price, condition, EAN where shown, included accessories, store location and stock/delivery. Exclude parts-not-working listings from normal working-condition evidence but preserve them as a separate condition only if specifically requested.' },
      'gumtree.com': { label: 'Gumtree UK used marketplace', routes: ['/uk/srpsearch%2B{slug}'], genericSearchFallback: false, navigation: 'Search UK adverts for the exact model and storage. Open individual live adverts and capture asking price, seller location, condition, included controller/cables/box, posting date and availability. Exclude wanted ads, accessories, parts, expired/sold adverts and duplicates; do not treat collection-only as nationwide delivery.' }
    }
  },

  'drones': {
    categoryInstructions: [
      'Research the exact complete drone or drone package requested. Preserve manufacturer, model generation, controller, camera/sensor configuration, region and package contents.',
      'Keep standard, Fly More, Creator, enterprise, FPV and other bundle variants separate. Do not treat a battery, controller, propeller, camera gimbal, frame or spare part as a complete drone.',
      'A manufacturer catalogue, collection or retailer category is discovery only. Follow each matching product card to the individual product page and verify the exact model, visible GBP price and availability there.',
      'For used drones, inspect the individual live seller listing. Capture condition, crash/repair history if stated, battery count/cycle information if stated, included controller and batteries, seller location and asking price. Exclude sold, expired, wanted and parts-only listings.',
      'Keep UK-new and UK-used lanes separate. Official manufacturer pages are useful for identity/specification and discontinued status; use UK GBP retail pages for price when the manufacturer does not publish one.',
      'Preserve regulatory/region variants and exact controller or camera bundles. Never infer that a package includes a controller, batteries, charging hub or carrying case unless the page states it.'
    ],
    branchInstructions: {
      'camera-drones': ['Research complete camera drones only. Preserve exact aircraft model, camera/sensor, controller, transmission generation, standard/Fly More/Creator package and included batteries.'],
      'underwater-drones': ['Research complete underwater ROV/drone units only. Preserve exact model, camera/lighting configuration, tether length, controller, battery and package contents.'],
      'water-drones': ['Research complete surface/water drones only. Preserve exact model, payload/camera configuration, controller, battery and included accessories.']
    },
    sites: {
      'cameraworld.co.uk': { label: 'CameraWorld UK drones', routes: ['/videography-products/drones/drones.html'], genericSearchFallback: false, navigation: 'Use the dedicated Drones category as a discovery page, follow exact product links and inspect each individual product page for the current UK GBP price and stock.' },
      'droneauthority.co.uk': { label: 'Drone Authority UK', routes: ['/collections/pre-built'], genericSearchFallback: false, navigation: 'Use the pre-built drone collection as a discovery page. Follow exact model/configuration links and reject frames, parts and zero-price configuration placeholders.' },
      'unmannedtechshop.co.uk': { label: 'Unmanned Tech UK complete drones', routes: ['/collections/complete-drones-ready-to-fly-kits'], genericSearchFallback: false, navigation: 'Use the Complete Drones / Ready-to-Fly Kits collection. Open exact model/configuration pages and preserve kit contents; exclude components and parts.' },
      'flyingtech.co.uk': { label: 'Flying Tech UK', routes: ['/shop/'], genericSearchFallback: false, navigation: 'Search the UK shop for the exact model, then open the individual product page. Separate complete aircraft from replacement parts and accessories.' },
      'wilko.com': { label: 'Wilko UK drone category', routes: ['/en-uk/toys-sports/outdoor-toys/drone/c/2416'], genericSearchFallback: false, navigation: 'Use the UK drone category as a discovery page and follow exact individual product pages. Verify the current UK price and stock.' },
      'uk.hoverair.com': { label: 'HOVERAir UK official store', routes: ['/collections/all'], genericSearchFallback: false, navigation: 'Use the UK collection and exact product pages. Preserve X1, X1 Pro/Pro Max, AQUA and bundle differences; capture GBP and availability.' },
      'itdroneservices.co.uk': { label: 'IT Drone Services UK', routes: ['https://shop.itdroneservices.co.uk/collections/fimi-store'], genericSearchFallback: false, navigation: 'Use the FIMI collection as a discovery page, then follow exact product pages and preserve model and package contents.' },
      'whoopstore.uk': { label: 'Whoop Store UK', routes: ['/collections/drones-by-geprc'], genericSearchFallback: false, navigation: 'Use the GEPRC drone collection for discovery. Follow the exact drone model and configuration page; exclude frames, motors and other components.' },
      'dji.com': { label: 'DJI UK official', routes: ['/uk'], genericSearchFallback: false, navigation: 'Use the UK DJI product catalogue for model identity, specifications and package differences. Official pages are not automatically price evidence; follow UK GBP retail offers where required.' },
      'modusbrands.com': { label: 'Modus Brands UK Autel distributor', routes: ['/brands-trust-us/autel-robotics-drone-distributor/'], genericSearchFallback: false, navigation: 'Use the listed Autel distributor page for brand/product identity and availability context. Do not infer a GBP price when the page is quote-only.' },
      'aetha.global': { label: 'Aetha UK Skydio provider', genericSearchFallback: false, navigation: 'Use the UK Skydio solutions pages for exact model identity and availability context. Record quote-only pricing as no published price, never estimate.' },
      'mpb.com': { label: 'MPB UK used dealer', routes: ['/en-uk'], genericSearchFallback: false, navigation: 'Use the UK used inventory for exact drone listings. Preserve condition grade, included accessories and the individual GBP asking price.' },
      'amazon.co.uk': { label: 'Amazon UK', genericSearchFallback: false, navigation: 'Search results are discovery only. Open the direct ASIN page and verify the selected seller, exact model/package, GBP price and stock.' },
      'ebay.co.uk': { label: 'eBay UK', genericSearchFallback: false, navigation: 'Inspect individual active UK listings only. Capture seller asking price, condition, location and included equipment; exclude sold/completed listings from current asking-price evidence.' },

      'hobbyrc.co.uk': { label: 'HobbyRC UK', routes: ['/'], genericSearchFallback: false, navigation: 'Use the UK shop navigation to locate complete drones and exact model pages; exclude frames, motors, batteries and other components.' },
      'heliguy.com': { label: 'Heliguy UK', routes: ['/'], genericSearchFallback: false, navigation: 'Use the UK drone catalogue and manufacturer filters for discovery; follow the exact complete aircraft or bundle page.' },
      'dji-retail.co.uk': { label: 'DJI Retail UK', routes: ['/'], genericSearchFallback: false, navigation: 'Use the UK DJI retail catalogue to find exact aircraft and bundle variants; follow individual product pages for GBP price and stock.' },
      'dmtl.co.uk': { label: 'DMTL UK', routes: ['/'], genericSearchFallback: false, navigation: 'Use the UK drone product navigation for complete aircraft and exact packages; distinguish aircraft from payloads and accessories.' },
      'leicesterdrones.com': { label: 'Leicester Drones UK', routes: ['/'], genericSearchFallback: false, navigation: 'Use the UK store navigation for complete drone models; inspect individual model and bundle pages.' },
      'quadcopters.co.uk': { label: 'Quadcopters UK', routes: ['/'], genericSearchFallback: false, navigation: 'Use the UK drone catalogue and exact model pages; keep complete aircraft separate from parts and accessories.' },
    }
  },
  'metal-detectors': {
    categoryInstructions: [
      'Research the exact metal detector model and package requested. Preserve manufacturer, model, search frequency/technology, coil configuration, control unit and included accessories.',
      'Keep complete detector units separate from search coils, headphones, shafts, batteries, pinpointers, covers and replacement parts. Do not treat an accessory listing as a detector.',
      'Distinguish standard packages from bundles containing extra coils, headphones, pinpointers or carry bags. Record each exact package as a separate variant only where the listing clearly identifies its contents.',
      'A brand or retailer category is discovery only. Follow the exact product card to an individual product page and verify the visible GBP price, stock and package contents.',
      'For used detectors, inspect individual active listings and preserve stated condition, faults, coil(s), accessories, warranty and seller location. Exclude sold, expired, wanted and parts-only listings.',
      'Use official manufacturer pages for exact model identity and specifications; use UK retailers/dealers for current GBP pricing when the manufacturer page has no price.'
    ],
    branchInstructions: {
      'metal-detectors': ['Research complete metal detector units only. Preserve exact model, operating technology/frequency, standard or bundle package and included coil/accessories.'],
      'metal-detector-equipment-accessories': ['Research the exact detector accessory or equipment item requested. Record part/model number and stated compatible detector models; never infer compatibility or substitute a similar coil/part.']
    },
    sites: {
      'crawfordsmd.com': { label: 'Crawfords Metal Detectors UK', routes: ['/metal-detectors'], genericSearchFallback: false, navigation: 'Use the dedicated Metal Detectors category for discovery, then follow exact product pages and verify visible GBP price and stock.' },
      'detector-distribution.co.uk': { label: 'Detector Distribution UK', routes: ['/metal-detectors'], genericSearchFallback: false, navigation: 'Use the Metal Detectors category as a discovery page. Open exact individual detector pages and preserve model and package details.' },
      'detecnicks.co.uk': { label: 'Detecnicks UK used detectors', routes: ['/Second-hand_Metal_Detectors.html'], genericSearchFallback: false, navigation: 'Use the second-hand detector listing page. Inspect each individual live listing and retain its exact condition, included coil/accessories and GBP asking price.' },
      'noktauk.com': { label: 'Nokta UK Store', routes: ['/collections/metal-detectors'], genericSearchFallback: false, navigation: 'Use the UK Metal Detectors collection, then follow exact model product pages. Keep detector bundles and accessory products separate.' },
      'minelab.com': { label: 'Minelab UK official', routes: ['https://uk.minelab.com/'], genericSearchFallback: false, navigation: 'Use the UK storefront for exact model identity, specifications and available packages. Follow direct UK product pages for any published GBP price.' },
      'regton.com': { label: 'Regton Metal Detectors UK', genericSearchFallback: false, navigation: 'Search the UK detector retailer for the exact model, then open individual product pages. Preserve package contents, GBP price and stock.' },
      'spinadiscmetaldetectors.com': { label: 'Spin A Disc Metal Detectors', genericSearchFallback: false, navigation: 'Search the UK detector catalogue for the exact model and package. Follow individual product pages and verify visible GBP pricing.' },
      'uk-historyfinders.co.uk': { label: 'UK History Finders', genericSearchFallback: false, navigation: 'Search the UK detector catalogue for the exact model and package. Treat category pages as discovery only and verify the individual product page.' },
      'uneartheduk.co.uk': { label: 'Unearthed UK', genericSearchFallback: false, navigation: 'Search the UK detector catalogue for the exact model and package. Open individual product pages and retain coil and bundle details.' },
      'woldsdetecting.co.uk': { label: 'Wolds Detecting', genericSearchFallback: false, navigation: 'Search the UK detector catalogue for the exact model. Follow the exact product page and capture current GBP price and availability.' },
      'lpmetaldetecting.com': { label: 'LP Metal Detecting UK', genericSearchFallback: false, navigation: 'Search for the exact detector model and package. Open the individual product page; keep accessories separate from complete detector units.' },
      'amazon.co.uk': { label: 'Amazon UK marketplace', routes: [], genericSearchFallback: false, navigation: 'Search results are discovery only. Follow a matching result to a direct ASIN product page and verify the selected seller, exact model, GBP price and availability.' },
      'ebay.co.uk': { label: 'eBay UK marketplace', routes: [], genericSearchFallback: false, navigation: 'Inspect individual active UK listings only. Capture exact detector model, coil/bundle contents, condition, seller location and asking price; exclude sold/completed listings.' },
    }
  },
  'mobile-phones': {
    categoryInstructions: [
      'Match the exact phone model and configuration. Preserve manufacturer, model generation, RAM, internal storage, colour, region, SIM/eSIM configuration and network variant where stated.',
      'Do not merge base, Plus, Pro, Pro Max, Ultra, FE or Lite models. Storage and RAM configurations are separate variants when the catalogue identifies them separately.',
      'A manufacturer product-family page is discovery/identity evidence only unless it displays a current UK GBP price. Follow exact UK retailer product pages for price and stock.',
      'Keep contract, monthly finance, trade-in, network plan and handset-only prices separate. Only record a handset price as such when the page clearly identifies the price basis.',
      'For used phones, inspect individual live listings and preserve grade, battery health where stated, faults, lock/network status, storage, condition, warranty and seller location. Exclude sold, expired, wanted and parts-only listings.',
      'Keep UK-new and UK-used lanes separate. Do not use overseas prices, foreign currency or imported variants as UK GBP evidence.'
    ],
    branchInstructions: {
      'mobile-phones': ['Research complete mobile phone handsets only. Preserve exact model, RAM/storage, colour, region and SIM/network configuration; reject cases, chargers, screens and other accessories.']
    },
    sites: {
      'mi.com': { label: 'Xiaomi UK phone catalogue', routes: ['/uk/product-list/phone/'], genericSearchFallback: false, navigation: 'Use the UK phone product list for Xiaomi, Redmi and POCO discovery. Follow exact model/configuration pages and capture UK GBP handset price.' },
      'honor.com': { label: 'HONOR UK phones', routes: ['/uk/phones/'], genericSearchFallback: false, navigation: 'Use the UK phones catalogue, then follow exact model and storage variants to individual product pages.' },
      'hmd.com': { label: 'HMD UK smartphones', routes: ['/en_gb/smartphones'], genericSearchFallback: false, navigation: 'Use the UK smartphone catalogue for exact model identity and configuration. Follow UK retailer product pages for price where needed.' },
      'doro.com': { label: 'Doro UK phones', routes: ['/en-gb/products/'], genericSearchFallback: false, navigation: 'Use the UK products catalogue and identify exact handset models. Exclude accessories and non-phone products.' },
      'nothing.tech': { label: 'Nothing UK phones', routes: ['/collections/phones'], genericSearchFallback: false, navigation: 'Use the Phones collection and follow exact handset pages. Preserve model generation and storage/colour variants.' },
      'clove.co.uk': { label: 'Clove Technology UK Fairphone', routes: ['/collections/smartphones-fairphone'], genericSearchFallback: false, navigation: 'Use the UK Fairphone smartphone collection. Open exact handset SKU pages and exclude Fairbuds and accessories.' },
      'ballicom.co.uk': { label: 'Ballicom UK Fairphone', routes: ['/manufacturers/fairphone/'], genericSearchFallback: false, navigation: 'Use the Fairphone manufacturer listing for discovery. Verify the exact handset SKU and use the inc-VAT GBP price, not ex-VAT.' },
      'tcl.com': { label: 'TCL UK mobile catalogue', routes: ['/uk/en/mobile'], genericSearchFallback: false, navigation: 'Use the UK mobile catalogue for model identity and specifications. Use a UK retailer page for price when the official page does not publish one.' },
      'apple.com': { label: 'Apple UK', routes: ['/uk/'], genericSearchFallback: false, navigation: 'Use the UK Apple storefront for iPhone model and configuration identity. Follow handset-only UK pricing; exclude monthly finance and trade-in offsets.' },
      'samsung.com': { label: 'Samsung UK', routes: ['/uk/'], genericSearchFallback: false, navigation: 'Use the UK Samsung storefront for exact Galaxy model and storage/colour variants. Distinguish handset-only price from contract and finance offers.' },
      'motorola.com': { label: 'Motorola UK', routes: ['/gb/en/'], genericSearchFallback: false, navigation: 'Use the UK Motorola catalogue for exact model identity, RAM/storage and colour. Verify price on an individual UK product page.' },
      'oneplus.com': { label: 'OnePlus UK Store', routes: ['/uk/store'], genericSearchFallback: false, navigation: 'Use the UK store for exact handset and configuration pages. Preserve model and storage variants.' },
      'store.google.com': { label: 'Google Store UK', routes: ['/gb/'], genericSearchFallback: false, navigation: 'Use the UK Google Store for Pixel model identity and configuration. Follow exact handset pages and capture visible GBP price.' },
      'webuy.com': { label: 'CeX UK used phones', routes: ['/'], genericSearchFallback: false, navigation: 'Use CeX search/category discovery, then inspect the exact handset item page. Capture grade, storage, network lock status, warranty and current GBP price.' },
      'amazon.co.uk': { label: 'Amazon UK', genericSearchFallback: false, navigation: 'Search results are discovery only. Follow each matching result to the direct ASIN page and verify exact storage/colour, seller, handset-only GBP price and availability.' },
      'ebay.co.uk': { label: 'eBay UK', genericSearchFallback: false, navigation: 'Inspect individual active UK handset listings. Capture storage, condition, lock status, battery health if stated, seller location and asking price; exclude sold/completed listings.' },
      'argos.co.uk': { label: 'Argos UK mobile phones', routes: ['/'], genericSearchFallback: false, navigation: 'Use the dedicated mobile phones and accessories category as discovery, then follow SIM-free or handset product pages. Exclude cases and phone accessories.' },
      'currys.co.uk': { label: 'Currys UK mobile phones', routes: ['/'], genericSearchFallback: false, navigation: 'Use the UK mobile-phone catalogue and site search for the exact handset. Follow the individual model page and separate outright price from airtime or finance.' },
      'johnlewis.com': { label: 'John Lewis UK mobile phones', routes: ['/'], genericSearchFallback: false, navigation: 'Use the UK mobile-phone catalogue and site search for exact model/storage. Follow individual handset pages and preserve SIM-free versus contract.' },
      'ee.co.uk': { label: 'EE UK mobile phones', routes: ['/'], genericSearchFallback: false, navigation: 'Use the UK handset catalogue for model identity. Distinguish outright device price from monthly airtime, contract and finance.' },
      'very.co.uk': { label: 'Very UK mobile phones', routes: ['/'], genericSearchFallback: false, navigation: 'Use the UK mobile-phone catalogue and exact handset product pages. Record outright GBP price separately from instalment plans.' },
      'oppo.com': { label: 'OPPO UK smartphones', routes: ['/'], genericSearchFallback: false, navigation: 'Use the verified UK Smartphones catalogue and follow exact Find, Reno or A-series handset pages.' },
      'realme.com': { label: 'realme UK phones', routes: ['/'], genericSearchFallback: false, navigation: 'Use the UK storefront navigation to find exact smartphone model and configuration pages; do not infer UK price from another region.' },
    }
  },
  'laptops': {
    categoryInstructions: [
      'Match the exact laptop model and hardware configuration. Preserve manufacturer, model family, generation, CPU, RAM, SSD capacity, GPU, screen size/resolution, operating system and manufacturer SKU/part number where available.',
      'Different CPU, RAM, storage, GPU, screen or chassis configurations are not interchangeable. Do not use a generic family page or a different configuration as exact price evidence.',
      'Use official manufacturer UK catalogues for model/configuration identity and current/discontinued status. Follow exact configuration or retailer product pages for current UK GBP pricing.',
      'A laptop category or search-results page is discovery only. Open individual product pages and capture the selected configuration, visible GBP price, stock and delivery status.',
      'For used laptops, inspect individual active listings and preserve condition grade, battery/charger status if stated, faults, specification, warranty and seller location. Exclude sold, expired, wanted and parts-only listings.',
      'Separate new, refurbished, ex-display and used condition. Do not treat ex-VAT prices, monthly finance or contract amounts as the consumer handset/laptop price.'
    ],
    branchInstructions: {
      'laptops-notebooks': ['Research complete laptop/notebook computers only. Match CPU generation, RAM, SSD, GPU and display configuration exactly; exclude docks, chargers, batteries, screens and other accessories.']
    },
    sites: {
      'dell.com': { label: 'Dell UK laptop catalogue', routes: ['/en-gb/shop/dell-laptops/scr/laptop'], genericSearchFallback: false, navigation: 'Use the UK laptop catalogue, select the exact model/configuration and follow its direct page. Record CPU, RAM, SSD, GPU and visible GBP price.' },
      'hp.com': { label: 'HP UK laptop catalogue', routes: ['/gb-en/shop/listings/laptops'], genericSearchFallback: false, navigation: 'Use the UK laptop listings and follow exact model/configuration pages. Preserve CPU, RAM, SSD, graphics and stock.' },
      'lenovo.com': { label: 'Lenovo UK laptop catalogue', routes: ['/gb/en/laptops/subseries-results/'], genericSearchFallback: false, navigation: 'Use the UK laptop catalogue and exact machine type/configuration pages. Do not substitute another CPU, RAM or SSD configuration.' },
      'apple.com': { label: 'Apple UK Mac', routes: ['/uk/'], genericSearchFallback: false, navigation: 'Use the UK Apple storefront for exact MacBook family and chip/configuration identity. Follow the exact product configuration for current GBP pricing.' },
      'samsung.com': { label: 'Samsung UK laptops', routes: ['/uk/'], genericSearchFallback: false, navigation: 'Use the UK Samsung storefront for exact Galaxy Book model and configuration. Preserve processor, RAM, storage and screen size.' },
      'webuy.com': { label: 'CeX UK used laptops', routes: ['/'], genericSearchFallback: false, navigation: 'Use CeX search/category discovery, then inspect the exact laptop item page. Capture specification, grade, charger, warranty and current GBP price.' },
      'currys.co.uk': { label: 'Currys UK laptops', routes: ['/'], genericSearchFallback: false, navigation: 'Search the UK retailer for the exact laptop SKU/configuration and open its individual product page. Capture the selected specification and GBP price.' },
      'argos.co.uk': { label: 'Argos UK laptops', routes: ['/'], genericSearchFallback: false, navigation: 'Search UK laptop listings and follow the exact product page. Preserve model/configuration, current GBP price and stock.' },
      'johnlewis.com': { label: 'John Lewis UK laptops', routes: ['/'], genericSearchFallback: false, navigation: 'Search the UK laptop range and open the exact model page. Preserve specification and visible GBP price.' },
      'very.co.uk': { label: 'Very UK laptops', routes: ['/'], genericSearchFallback: false, navigation: 'Search UK laptop listings and follow exact model/configuration pages. Distinguish outright price from finance.' },
      'amazon.co.uk': { label: 'Amazon UK', genericSearchFallback: false, navigation: 'Search results are discovery only. Follow the exact ASIN page and verify CPU, RAM, SSD, GPU, seller, GBP price and stock.' },
      'ebay.co.uk': { label: 'eBay UK', genericSearchFallback: false, navigation: 'Inspect individual active UK laptop listings only. Capture exact specification, condition, battery/charger, seller location and asking price; exclude sold/completed listings.' }
    }
  },
  'cameras': {
    categoryInstructions: [
      'Match the exact camera model, generation and kit configuration. Preserve sensor format/resolution, mount, body-only versus lens kit, included lens model, colour and regional SKU where stated.',
      'Keep film cameras, mirrorless cameras, compact cameras, cinema cameras and other camera types in their assigned master-catalogue branches. Do not substitute a similar body or a different mount.',
      'A manufacturer catalogue or retailer category is discovery only. Follow the exact individual product page and verify visible UK GBP price, selected kit/bundle and availability.',
      'For used camera listings, preserve condition grade, shutter count where stated, sensor/optical condition, included battery/charger/box, warranty and seller location. Do not infer shutter count or condition.',
      'Separate body-only, kit lens, multi-lens bundles and special editions. Never attribute a kit price to the body-only master product or vice versa.',
      'Use official manufacturer pages for exact model, specifications and discontinued status; use UK retailer/dealer pages for current GBP prices. Used marketplace sold prices are not current asking-price evidence.'
    ],
    branchInstructions: {
      'film-cameras': ['Research film cameras only. Preserve exact camera model, format, lens mount, lens included, operating condition and any stated light-meter/shutter faults.'],
      'photography-cameras': ['Research digital photography cameras only. Preserve exact body model, sensor, mount, body-only versus kit lens and package contents. Keep cinema/video cameras in their own master branch.']
    },
    sites: {
      'canon.co.uk': { label: 'Canon UK camera store', routes: ['/store/cameras/'], genericSearchFallback: false, navigation: 'Use the UK camera store category for discovery, then follow the exact camera body or kit product page.' },
      'nikon.co.uk': { label: 'Nikon UK cameras', routes: ['/en_GB/product/cameras/mirrorless'], genericSearchFallback: false, navigation: 'Use the UK mirrorless camera catalogue and follow exact body/kit pages. Preserve mount and kit-lens differences.' },
      'eshop.fujifilm-x.com': { label: 'FUJIFILM UK eShop', routes: ['/uk/cameras.html'], genericSearchFallback: false, navigation: 'Use the UK cameras catalogue and follow exact model pages. Preserve X/GFX model, lens kit and colour variants.' },
      'explore.omsystem.com': { label: 'OM SYSTEM UK cameras', routes: ['/gb/en/cameras/om-d'], genericSearchFallback: false, navigation: 'Use the UK camera catalogue and follow exact OM SYSTEM body and kit pages.' },
      'uk.store.eu.panasonic.com': { label: 'Panasonic UK cameras', routes: ['/cameras-and-camcorders'], genericSearchFallback: false, navigation: 'Use the UK cameras and camcorders catalogue, then follow exact model and kit pages.' },
      'polaroid.com': { label: 'Polaroid UK cameras', routes: ['/en_gb/cameras'], genericSearchFallback: false, navigation: 'Use the UK cameras catalogue. Keep instant camera models separate from film, bundles and accessories.' },
      'blackmagicdesign.com': { label: 'Blackmagic Design UK', routes: ['/uk/products'], genericSearchFallback: false, navigation: 'Use the UK products catalogue for exact cinema camera model identity and specifications. Follow direct product/retailer pages for GBP price.' },
      'z-cam.com': { label: 'Z CAM official', routes: ['/products/professional-cameras/'], genericSearchFallback: false, navigation: 'Use the professional camera catalogue for exact model identity and configuration. Do not infer UK price from a global product page.' },
      'mpb.com': { label: 'MPB UK used camera dealer', routes: ['/en-uk'], genericSearchFallback: false, navigation: 'Search UK used inventory and open exact individual body/lens kit listings. Preserve grade, shutter count if stated, accessories and GBP asking price.' },
      'webuy.com': { label: 'CeX UK used cameras', routes: ['/'], genericSearchFallback: false, navigation: 'Use CeX search/category discovery, then open the exact item page. Capture grade, included accessories, warranty and current GBP price.' },
      'usedlens.co.uk': { label: 'Used Lens UK', routes: ['/'], genericSearchFallback: false, navigation: 'Use the UK used-camera and lens catalogue. Open exact individual listings and preserve condition and included accessories.' },
      'ffordes.com': { label: 'Ffordes Photographic', routes: ['/'], genericSearchFallback: false, navigation: 'Search the UK used/dealer inventory and inspect individual exact-model pages. Preserve condition grade and visible GBP price.' },
      'lcegroup.co.uk': { label: 'London Camera Exchange', routes: ['/'], genericSearchFallback: false, navigation: 'Search the UK camera inventory and inspect individual used listings. Preserve exact model, condition, shutter count if stated and price.' },
      'wexphotovideo.com': { label: 'Wex Photo Video UK', routes: ['/'], genericSearchFallback: false, navigation: 'Search the UK camera catalogue and open the exact model/kit product page. Capture selected configuration, GBP price and stock.' },
      'amazon.co.uk': { label: 'Amazon UK', genericSearchFallback: false, navigation: 'Search results are discovery only. Follow the exact ASIN page and verify body/kit configuration, seller, GBP price and availability.' },
      'ebay.co.uk': { label: 'eBay UK', genericSearchFallback: false, navigation: 'Inspect individual active UK camera listings. Preserve body/kit, mount, condition, shutter count if stated and asking price; exclude sold/completed listings.' },
      'sony.co.uk': { label: 'Sony UK cameras', routes: ['/'], genericSearchFallback: false, navigation: 'Use Sony UK's camera catalogue and product navigation for exact body and lens identity; follow individual product pages.' },
      'jessops.com': { label: 'Jessops UK cameras', routes: ['/'], genericSearchFallback: false, navigation: 'Use the UK camera and lens catalogue navigation; follow exact model and body/kit product pages.' },
      'parkcameras.com': { label: 'Park Cameras UK', routes: ['/'], genericSearchFallback: false, navigation: 'Use the UK cameras and lenses catalogue; inspect individual model pages and preserve body-only versus kit variants.' },
      'cliftoncameras.co.uk': { label: 'Clifton Cameras UK', routes: ['/'], genericSearchFallback: false, navigation: 'Use the camera catalogue and exact manufacturer/model navigation; follow individual body and kit pages.' },
      'harrisoncameras.co.uk': { label: 'Harrison Cameras UK', routes: ['/'], genericSearchFallback: false, navigation: 'Use the UK camera catalogue to locate exact models; follow individual product pages for GBP price and stock.' },
      'camerapricebuster.co.uk': { label: 'Camera Price Buster UK', routes: ['/'], genericSearchFallback: false, navigation: 'Use the camera model comparison pages for discovery only. Follow through to the original retailer product page before recording price evidence.' },
      'castlecameras.co.uk': { label: 'Castle Cameras UK', routes: ['/'], genericSearchFallback: false, navigation: 'Use the UK camera catalogue and exact model pages; preserve kit lens and body-only differences.' },
      'productiongear.co.uk': { label: 'Production Gear UK', routes: ['/'], genericSearchFallback: false, navigation: 'Use the camera and video equipment catalogue for exact camera products; exclude rigs, accessories and unrelated production equipment.' },
    }
  },

};

function fillRoute(route, task) {
  const searchText = [task.manufacturer, task.model].filter(Boolean).join(' ');
  const query = encodeURIComponent(searchText);
  const slug = searchText.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '');
  return String(route)
    .replaceAll('{query}', query)
    .replaceAll('{model}', encodeURIComponent(task.model || ''))
    .replaceAll('{manufacturer}', encodeURIComponent(task.manufacturer || ''))
    .replaceAll('{slug}', slug);
}

export function getCategoryWebsitePlaybook(categorySlug) {
  return playbooks[String(categorySlug || '').toLowerCase()] || null;
}

export function getWebsiteInstructions(categorySlug, domain) {
  const category = getCategoryWebsitePlaybook(categorySlug);
  const host = String(domain || '').toLowerCase().replace(/^www\./, '');
  return category?.sites?.[host] || null;
}

export function buildWebsiteSearchRoutes(source, task) {
  const domain = String(source?.domain || '').toLowerCase().replace(/^www\./, '');
  const site = getWebsiteInstructions(task?.category_slug, domain);
  const routes = [];
  const configured = String(source?.search_url_template || '').trim();
  // A historical direct product URL is not a search route. Never keep revisiting
  // it as the only route for every product in the category.
  if (configured && !/\/products?\/[^/]+/i.test(configured)) routes.push(fillRoute(configured, task));
  const researchType = String(task?.research_type || '').toLowerCase();
  const configuredRoutes = site?.routesByResearchType?.[researchType] || site?.routes || [];
  for (const route of configuredRoutes) {
    const filledRoute = fillRoute(route, task);
    routes.push(/^https?:\/\//i.test(filledRoute) ? filledRoute : 'https://' + domain + filledRoute);
  }
  const root = 'https://' + domain;
  if (domain === 'ebay.co.uk') routes.push(root + '/sch/i.html?_nkw=' + encodeURIComponent([task.manufacturer, task.model].join(' ')));
  if (domain === 'amazon.co.uk') routes.push(root + '/s?k=' + encodeURIComponent([task.manufacturer, task.model].join(' ')));
  if (site?.genericSearchFallback !== false) routes.push(root + '/search?q=' + encodeURIComponent([task.manufacturer, task.model].join(' ')));
  return [...new Set(routes)].slice(0, 5);
}
