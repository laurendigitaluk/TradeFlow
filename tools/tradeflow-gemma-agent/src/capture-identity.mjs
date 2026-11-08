const PRINTER_CATEGORY = '3d-printers-equipment';
const PRINTER_BRANCH = '3d-printers';

// The Creality UK storefront can return the same product page with or without
// its explicit UK/GBP locale selectors. Those selectors do not identify a
// different product/package, so they must not create separate raw-capture rows.
export function canonicalCaptureSourceUrl(sourceUrl, task = {}) {
  const original = String(sourceUrl || '');
  const isExactPrinterTask =
    String(task?.category_slug || '').trim().toLowerCase() === PRINTER_CATEGORY &&
    String(task?.branch_slug || '').trim().toLowerCase() === PRINTER_BRANCH;
  if (!isExactPrinterTask) return original;

  let url;
  try {
    url = new URL(original);
  } catch {
    return original;
  }

  const host = url.hostname.toLowerCase().replace(/^www\./, '');
  const isCrealityUkProduct =
    url.protocol === 'https:' &&
    host === 'store.creality.com' &&
    /^\/uk\/products\/[^/]+\/?$/i.test(url.pathname);
  if (isCrealityUkProduct) {
    const countries = url.searchParams.getAll('country');
    const currencies = url.searchParams.getAll('currency');
    if (countries.length === 1 && countries[0].toUpperCase() === 'GB' &&
        currencies.length === 1 && currencies[0].toUpperCase() === 'GBP') {
      url.searchParams.delete('country');
      url.searchParams.delete('currency');
    }
    return url.toString();
  }

  // Amazon UK can return the same ASIN with a trailing search-attribution
  // path segment (for example /ref=sxin_14_sbv_search_btf). The ASIN is the
  // product identity; this suffix does not identify a different offer.
  const amazonProductPath = url.pathname.match(/^(.*\/dp\/[A-Z0-9]{10})(?:\/ref=[^/]+)?\/?$/i);
  if (url.protocol === 'https:' && host === 'amazon.co.uk' && amazonProductPath) {
    url.pathname = amazonProductPath[1];
    return url.toString();
  }

  return original;
}
