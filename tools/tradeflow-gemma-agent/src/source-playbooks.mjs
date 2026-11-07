// Website-specific navigation playbooks. Add one category at a time after inspecting
// the real site's public routes. Discovery pages are never evidence; the worker must
// follow matching product/listing links and validate the individual page.
const playbooks = {
  '3d-printers-equipment': {
    categoryInstructions: [
      'Research standalone 3D printers only; reject filament, resin, hotends, build plates, upgrades, spare parts and accessories unless the task explicitly asks for them.',
      'A brand catalogue, collection, search-results page or multi-product category page is a discovery page only. Extract links for the exact requested model, open each individual product/listing page, and validate price, GBP currency, condition and availability there.',
      'On manufacturer sites, search the requested manufacturer and exact model first, then navigate Printers / 3D Printers / product collections if search is weak.',
      'On used marketplaces, inspect individual seller listings. Do not use category averages, completed/sold prices, snippets without a direct listing, or listings for a different model/variant.',
      'Check pagination and load-more links where accessible. Record the route used, number of pages checked, matching links found and any access/robot/login failure.'
    ],
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
      'uk.anycubic.com': {
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
        routes: ['/search?q={query}', '/?s={query}'],
        navigation: 'Search exact model and inspect the individual printer product page. Separate machine-only and package bundles.'
      },
      'idig3dprinting.co.uk': {
        label: 'iDig3DPrinting UK retailer',
        routes: ['/search?search={query}', '/?s={query}', '/search?q={query}'],
        navigation: 'Use site search and printer category navigation. Open the individual exact-model page before recording a price.'
      },
      '3dflo.com': {
        label: '3DFLO UK retailer',
        routes: ['/search?q={query}', '/?s={query}'],
        navigation: 'Search the exact model and use printer category/brand collections as discovery only. Follow the matching model card to its product page.'
      },
      '3djake.uk': {
        label: '3DJake UK retailer',
        routes: ['/search?query={query}', '/search?q={query}'],
        navigation: 'Use the search function and 3D printer category filters. Open the exact product page and verify UK GBP pricing, not another locale.'
      },
      'gumtree.com': {
        label: 'Gumtree UK used marketplace',
        routes: ['/uk/srpsearch%2B{query}', '/for-sale/uk/srpsearch%2B{query}'],
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
  const query = encodeURIComponent([task.manufacturer, task.model].filter(Boolean).join(' '));
  return String(route)
    .replaceAll('{query}', query)
    .replaceAll('{model}', encodeURIComponent(task.model || ''))
    .replaceAll('{manufacturer}', encodeURIComponent(task.manufacturer || ''));
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
  for (const route of site?.routes || []) routes.push('https://' + domain + fillRoute(route, task));
  const root = 'https://' + domain;
  if (domain === 'ebay.co.uk') routes.push(root + '/sch/i.html?_nkw=' + encodeURIComponent([task.manufacturer, task.model].join(' ')));
  if (domain === 'amazon.co.uk') routes.push(root + '/s?k=' + encodeURIComponent([task.manufacturer, task.model].join(' ')));
  routes.push(root + '/search?q=' + encodeURIComponent([task.manufacturer, task.model].join(' ')));
  return [...new Set(routes)].slice(0, 5);
}
