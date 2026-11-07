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
        routes: ['/uk/search?q={query}', '/uk/collections/3d-printers'],
        navigation: 'Use the UK storefront search first. If it returns a brand/category page, open the 3D printer collection and follow the exact model card to its individual product page. Ignore accessories and upgrade kits.'
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
