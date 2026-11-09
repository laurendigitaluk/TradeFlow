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
  }
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
      'xbox.com': { label: 'Microsoft Xbox UK official', navigation: 'Use the UK Xbox product catalogue and official console pages for exact model, storage, edition and bundle identity. Official pages are not automatically current price evidence; follow UK GBP retail offers where needed.' },
      'nintendo.com': { label: 'Nintendo UK official', navigation: 'Use the UK Nintendo product catalogue and exact console/controller/accessory pages. Preserve generation, Joy-Con configuration, colour and bundle contents.' },
      'playstation.com': { label: 'Sony PlayStation UK official', navigation: 'Use the UK PlayStation product pages for exact model, edition, accessories and compatibility. Keep console, controller, headset and VR product families separate.' },
      'argos.co.uk': { label: 'Argos UK retailer', navigation: 'Use search/category results for discovery, then open each exact product detail page. Capture current GBP price, availability, delivery/collection and package contents.' },
      'currys.co.uk': { label: 'Currys UK retailer', navigation: 'Use search results and gaming console/controller categories for discovery; follow exact product pages and capture the selected variant, GBP price and stock.' },
      'johnlewis.com': { label: 'John Lewis UK retailer', navigation: 'Use UK gaming product search and follow exact console/controller/headset detail pages. Capture current GBP price, stock and delivery information.' },
      'smythstoys.com': { label: 'Smyths Toys UK retailer', navigation: 'Use UK gaming and Nintendo/PlayStation/Xbox product categories as discovery pages; follow exact item pages and preserve bundles and platform variants.' },
      'ee.co.uk': { label: 'EE UK retailer', navigation: 'Use UK gaming hardware product pages only. Distinguish device price from contract, finance, monthly payment or service plan amounts.' },
      'game.co.uk': { label: 'GAME UK retailer', navigation: 'Use console, controller and accessory categories for discovery; inspect individual product pages and preserve new, pre-owned, refurbished and bundle distinctions.' },
      'very.co.uk': { label: 'Very UK retailer', navigation: 'Use gaming product search and category pages for discovery; open exact item pages and capture GBP price, stock, condition and bundle contents.' },
      'selfridges.com': { label: 'Selfridges UK retailer', navigation: 'Use UK gaming product listings for discovery; confirm UK GBP price and exact edition on the individual product page.' },
      'amazon.co.uk': { label: 'Amazon UK marketplace', navigation: 'Search results are discovery only. Follow each matching result to a direct ASIN product page; capture the selected seller/offer, exact edition, GBP price and availability.' },
      'ebay.co.uk': { label: 'eBay UK marketplace', navigation: 'Search exact manufacturer/model and inspect individual active UK item listings only. Capture asking price, condition, completeness, seller location and availability; exclude sold/completed items as current asking prices.' },
      'webuy.com': { label: 'CeX UK used dealer', navigation: 'Use CeX search/category pages for discovery, then open the exact item page. Capture grade, tested/refurbished condition, warranty, store/online availability and current GBP price.' }
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
