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
