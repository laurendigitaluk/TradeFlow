import test from 'node:test';
import assert from 'node:assert/strict';
import { canonicalCaptureSourceUrl } from './capture-identity.mjs';

const printerTask = {
  category_slug: '3d-printers-equipment',
  branch_slug: '3d-printers'
};

test('canonicalises the same Creality UK product with and without GB/GBP locale selectors', () => {
  const plain = 'https://store.creality.com/uk/products/k1-max-ai-fast-3d-printer';
  const localised = plain + '?country=GB&currency=GBP';
  assert.equal(canonicalCaptureSourceUrl(localised, printerTask), plain);
  assert.equal(canonicalCaptureSourceUrl(plain, printerTask), plain);
  assert.equal(
    canonicalCaptureSourceUrl(localised, printerTask),
    canonicalCaptureSourceUrl(plain, printerTask)
  );
});

test('preserves product variant parameters while removing only the exact GB/GBP locale pair', () => {
  const url = 'https://store.creality.com/uk/products/k1-max-ai-fast-3d-printer?variant=123&country=GB&currency=GBP';
  assert.equal(
    canonicalCaptureSourceUrl(url, printerTask),
    'https://store.creality.com/uk/products/k1-max-ai-fast-3d-printer?variant=123'
  );
});

test('does not remove a different country or currency selection', () => {
  const url = 'https://store.creality.com/uk/products/k1-max-ai-fast-3d-printer?country=US&currency=USD';
  assert.equal(canonicalCaptureSourceUrl(url, printerTask), url);
});

test('does not remove a partial or duplicated locale selector pair', () => {
  const partial = 'https://store.creality.com/uk/products/k1-max-ai-fast-3d-printer?country=GB';
  const duplicated = 'https://store.creality.com/uk/products/k1-max-ai-fast-3d-printer?country=GB&country=GB&currency=GBP';
  assert.equal(canonicalCaptureSourceUrl(partial, printerTask), partial);
  assert.equal(canonicalCaptureSourceUrl(duplicated, printerTask), duplicated);
});

test('does not canonicalise other hosts or non-product Creality routes', () => {
  const otherHost = 'https://www.creality.com/uk/products/k1-max-ai-fast-3d-printer?country=GB&currency=GBP';
  const collection = 'https://store.creality.com/uk/collections/3d-printers?country=GB&currency=GBP';
  assert.equal(canonicalCaptureSourceUrl(otherHost, printerTask), otherHost);
  assert.equal(canonicalCaptureSourceUrl(collection, printerTask), collection);
});

test('leaves other categories and branches completely unchanged', () => {
  const url = 'https://store.creality.com/uk/products/k1-max-ai-fast-3d-printer?country=GB&currency=GBP';
  assert.equal(canonicalCaptureSourceUrl(url, { category_slug: 'drones', branch_slug: 'drones' }), url);
  assert.equal(canonicalCaptureSourceUrl(url, { ...printerTask, branch_slug: '3d-printer-equipment-accessories' }), url);
});

test('returns malformed URLs unchanged', () => {
  const url = 'not a url?country=GB&currency=GBP';
  assert.equal(canonicalCaptureSourceUrl(url, printerTask), url);
});


test('canonicalises an Amazon UK ASIN with and without a trailing search-attribution ref segment', () => {
  const plain = 'https://www.amazon.co.uk/Bambu-Combo-Lamp-Multi-Color-Printing-Grey/dp/B0GQMN8VLS';
  const tracked = plain + '/ref=sxin_14_sbv_search_btf';
  assert.equal(canonicalCaptureSourceUrl(tracked, printerTask), plain);
  assert.equal(canonicalCaptureSourceUrl(plain, printerTask), plain);
  assert.equal(canonicalCaptureSourceUrl(tracked, printerTask), canonicalCaptureSourceUrl(plain, printerTask));
});

test('Amazon capture identity keeps product selection query parameters and distinct ASINs', () => {
  const base = 'https://www.amazon.co.uk/Bambu-Combo-Lamp-Multi-Color-Printing-Grey/dp/B0GQMN8VLS';
  const selected = base + '/ref=sxin_14_sbv_search_btf?th=1&psc=1';
  assert.equal(
    canonicalCaptureSourceUrl(selected, printerTask),
    base + '?th=1&psc=1'
  );
  assert.notEqual(
    canonicalCaptureSourceUrl(base, printerTask),
    canonicalCaptureSourceUrl('https://www.amazon.co.uk/Bambu-A1/dp/B0D17TMWFB/ref=sxin_14_sbv_search_btf', printerTask)
  );
});

test('Amazon tracking-path normalisation is restricted to direct Amazon UK product pages and the 3D printer branch', () => {
  const search = 'https://www.amazon.co.uk/s?k=Bambu+A1/ref=sxin_14_sbv_search_btf';
  const otherDomain = 'https://www.amazon.com/Bambu-Combo/dp/B0GQMN8VLS/ref=sxin_14_sbv_search_btf';
  const otherBranch = 'https://www.amazon.co.uk/Bambu-Combo/dp/B0GQMN8VLS/ref=sxin_14_sbv_search_btf';
  assert.equal(canonicalCaptureSourceUrl(search, printerTask), search);
  assert.equal(canonicalCaptureSourceUrl(otherDomain, printerTask), otherDomain);
  assert.equal(canonicalCaptureSourceUrl(otherBranch, { ...printerTask, branch_slug: '3d-printer-equipment-accessories' }), otherBranch);
});
