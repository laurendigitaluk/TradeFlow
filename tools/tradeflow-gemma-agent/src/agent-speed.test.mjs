import test from 'node:test';
import assert from 'node:assert/strict';
import { buildExtractionPrompt, extractionBatchSizeForTask, extractRelevantPageText, extractVisibleGbpPriceMentions } from './agent.mjs';

const printerTask = {
  category_slug: '3d-printers-equipment',
  branch_slug: '3d-printers',
  research_type: 'uk_both',
  manufacturer: 'Bambu Lab',
  model: 'A1',
  package_key: 'standard',
  package_name: 'Standard Printer',
  search_query: 'Bambu Lab A1 3D printer UK'
};

test('3D printer captures preserve matching JSON-LD product offers ahead of long page text', () => {
  const product = {
    '@context': 'https://schema.org',
    '@type': 'Product',
    name: 'ELEGOO Neptune 4 Pro FDM 3D Printer',
    brand: { '@type': 'Brand', name: 'ELEGOO' },
    model: 'Neptune 4 Pro',
    offers: {
      '@type': 'Offer',
      price: '169.00',
      priceCurrency: 'GBP',
      availability: 'https://schema.org/InStock',
      itemCondition: 'https://schema.org/NewCondition'
    }
  };
  const longPage = 'Navigation and product detail text. '.repeat(500);
  const html = '<main>' + longPage + '</main>' +
    '<script type="application/ld+json">' + JSON.stringify(product) + '</script>';
  const text = extractRelevantPageText(html, {
    category_slug: '3d-printers-equipment',
    branch_slug: '3d-printers',
    manufacturer: 'Elegoo',
    model: 'Neptune 4 Pro'
  });

  assert.ok(text.startsWith('Product: ELEGOO Neptune 4 Pro FDM 3D Printer'));
  assert.ok(text.indexOf('Product:') < text.indexOf('Navigation and product detail text.'));
  assert.match(text, /Price: GBP 169\.00 Currency: GBP/);
  assert.match(text, /Availability: https:\/\/schema\.org\/InStock/);
  assert.match(text, /Condition: https:\/\/schema\.org\/NewCondition/);
  assert.ok(text.length <= 10000);
  assert.ok(extractVisibleGbpPriceMentions(text).some(price => price.amount === 169));
});

test('non-3D categories retain their existing page-content-first extraction order', () => {
  const product = {
    '@type': 'Product',
    name: 'ELEGOO Neptune 4 Pro FDM 3D Printer',
    brand: { name: 'ELEGOO' },
    model: 'Neptune 4 Pro',
    offers: { price: '169.00', priceCurrency: 'GBP' }
  };
  const longPage = 'Legacy category page content. '.repeat(500);
  const html = '<main>' + longPage + '</main>' +
    '<script type="application/ld+json">' + JSON.stringify(product) + '</script>';
  const text = extractRelevantPageText(html, {
    category_slug: 'drones',
    branch_slug: 'drones',
    manufacturer: 'Elegoo',
    model: 'Neptune 4 Pro'
  });

  assert.ok(text.startsWith('Legacy category page content.'));
  assert.ok(!text.includes('Product: ELEGOO Neptune 4 Pro'));
});

test('3D printer extraction batches two pages while other categories retain two-page batches', () => {
  assert.equal(extractionBatchSizeForTask(printerTask), 2);
  assert.equal(extractionBatchSizeForTask({ ...printerTask, category_slug: 'drones', branch_slug: 'drones' }), 2);
});

test('3D printer extraction prompt requests one findings-array row for every supplied page', () => {
  const prompt = buildExtractionPrompt(printerTask, [
    {
      source_id: 'S1',
      title: 'Bambu Lab A1 3D Printer',
      url: 'https://example.co.uk/products/bambu-a1',
      text: 'Bambu Lab A1 3D Printer. Standard printer £289.00. In stock. New.'
    },
    {
      source_id: 'S2',
      title: 'Bambu Lab A1 Combo',
      url: 'https://example.co.uk/products/bambu-a1-combo',
      text: 'Bambu Lab A1 Combo. Printer with AMS Lite £399.00. In stock. New.'
    }
  ]);

  assert.match(prompt, /one top-level findings array/i);
  assert.match(prompt, /exactly one compact finding for every supplied source_id/i);
  assert.match(prompt, /"source_id":"S1"/);
  assert.match(prompt, /"source_id":"S2"/);
  assert.match(prompt, /Bambu Lab A1 3D Printer/);
  assert.match(prompt, /Bambu Lab A1 Combo/);
});

test('two-page 3D prompt keeps both pages within the reduced per-page excerpt budget', () => {
  const longText = 'Bambu Lab A1 printer £289.00 in stock new. '.repeat(300);
  const prompt = buildExtractionPrompt(printerTask, [
    { source_id: 'S1', title: 'Bambu Lab A1', url: 'https://example.co.uk/a1', text: longText },
    { source_id: 'S2', title: 'Bambu Lab A1 Combo', url: 'https://example.co.uk/a1-combo', text: longText }
  ]);
  // Both page payloads are present; the full page remains stored outside this prompt.
  assert.match(prompt, /"source_id":"S1"/);
  assert.match(prompt, /"source_id":"S2"/);
  assert.ok(prompt.length < 18000, 'two-page prompt should remain compact for the 4k context');
});
