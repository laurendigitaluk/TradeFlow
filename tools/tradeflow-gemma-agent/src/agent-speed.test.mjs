import test from 'node:test';
import assert from 'node:assert/strict';
import { buildExtractionPrompt, buildGemmaFindingSchema, extractionBatchSizeForTask, extractBatch, extractRelevantPageText, extractVisibleGbpPriceMentions, selectSafeObservedPrice, shouldRetainFullPageCapture } from './agent.mjs';

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

test('3D printer capture retains structured GBP offers before long page text and makes the price parseable', () => {
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
  assert.ok(text.includes('Price: GBP 169.00 Currency: GBP'));
  assert.ok(text.includes('Availability: https://schema.org/InStock'));
  assert.ok(text.includes('Condition: https://schema.org/NewCondition'));
  assert.ok(text.length <= 10000);
  assert.equal(extractVisibleGbpPriceMentions('Price: 169.00 Currency: GBP').length, 0);
  assert.equal(extractVisibleGbpPriceMentions(text).filter(price => price.amount === 169).length, 1);
});

test('structured arrays preserve each GBP offer while excluding non-GBP variants', () => {
  const product = {
    '@type': 'Product',
    name: 'ELEGOO Neptune 4 Pro FDM 3D Printer',
    brand: { name: 'ELEGOO' },
    model: 'Neptune 4 Pro',
    offers: [
      { '@type': 'Offer', price: '169.00', priceCurrency: 'GBP' },
      { '@type': 'Offer', price: '179.00', priceCurrency: 'GBP' },
      { '@type': 'Offer', price: '199.00', priceCurrency: 'USD' }
    ]
  };
  const html = '<main>ELEGOO Neptune 4 Pro.</main>' +
    '<script type="application/ld+json">' + JSON.stringify(product) + '</script>';
  const text = extractRelevantPageText(html, {
    category_slug: '3d-printers-equipment',
    branch_slug: '3d-printers',
    manufacturer: 'Elegoo',
    model: 'Neptune 4 Pro'
  });
  const amounts = extractVisibleGbpPriceMentions(text).map(price => price.amount);

  assert.ok(amounts.includes(169));
  assert.ok(amounts.includes(179));
  assert.ok(!amounts.includes(199));
});

test('structured non-GBP offers are not reported as GBP prices', () => {
  const product = {
    '@type': 'Product',
    name: 'ELEGOO Neptune 4 Pro FDM 3D Printer',
    brand: { name: 'ELEGOO' },
    model: 'Neptune 4 Pro',
    offers: { price: '169.00', priceCurrency: 'USD' }
  };
  const html = '<main>ELEGOO Neptune 4 Pro.</main>' +
    '<script type="application/ld+json">' + JSON.stringify(product) + '</script>';
  const text = extractRelevantPageText(html, {
    category_slug: '3d-printers-equipment',
    branch_slug: '3d-printers',
    manufacturer: 'Elegoo',
    model: 'Neptune 4 Pro'
  });

  assert.ok(text.includes('Price: 169.00 Currency: USD'));
  assert.equal(extractVisibleGbpPriceMentions(text).length, 0);
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

test('full-page review retention includes 3D printers and Gaming but leaves other categories bounded', () => {
  assert.equal(shouldRetainFullPageCapture(printerTask), true);
  assert.equal(shouldRetainFullPageCapture({
    category_slug: 'gaming-consoles-accessories',
    branch_slug: 'playstation-consoles'
  }), true);
  assert.equal(shouldRetainFullPageCapture({
    category_slug: 'drones',
    branch_slug: 'drones'
  }), false);
});

test('successful 3D-printer Gemma extraction preserves the complete fetched page for ChatGPT', async () => {
  const originalFetch = globalThis.fetch;
  const sourceText = ('Bambu Lab A1 3D printer product detail. £289.00 in stock. ').repeat(600);
  assert.ok(sourceText.length > 10000);
  const finding = {
    source_id: 'S1',
    page_title: 'Bambu Lab A1 3D Printer',
    product_identity_text: 'Bambu Lab A1 3D printer',
    package_or_variant_text: 'Standard Printer',
    seller_text: 'example.co.uk',
    price_observations: [],
    item_condition_text: 'New',
    availability_text: 'In stock',
    location_text: 'UK',
    identifiers_text: '',
    match_observation: 'Exact requested model page',
    uncertainty_and_conflicts: '',
    notes: ''
  };
  globalThis.fetch = async () => ({
    ok: true,
    text: async () => JSON.stringify({
      message: { content: JSON.stringify({ findings: [finding] }) },
      done_reason: 'stop'
    })
  });
  try {
    const source = {
      source_id: 'S1',
      title: 'Bambu Lab A1 3D Printer',
      url: 'https://example.co.uk/products/bambu-a1',
      text: sourceText
    };
    const env = { OLLAMA_BASE_URL: 'http://127.0.0.1:11434', OLLAMA_MODEL: 'gemma3:4b' };
    const printerResult = await extractBatch(printerTask, [source], env, async () => {});
    assert.equal(printerResult.failures.length, 0);
    assert.equal(printerResult.findings.length, 1);
    assert.equal(printerResult.findings[0].source_excerpt, sourceText);
    assert.equal(printerResult.findings[0].page_capture.captured_text, sourceText);

    const otherResult = await extractBatch({
      ...printerTask,
      category_slug: 'drones',
      branch_slug: 'drones'
    }, [source], env, async () => {});
    assert.equal(otherResult.findings[0].source_excerpt, sourceText.slice(0, 10000));
    assert.equal(otherResult.findings[0].page_capture.captured_text, sourceText.slice(0, 10000));
  } finally {
    globalThis.fetch = originalFetch;
  }
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

  assert.match(prompt, /supplied JSON schema exactly/i);
  assert.match(prompt, /One compact finding per supplied source_id/i);
  assert.match(prompt, /REQUIRED POPULATION/i);
  assert.match(prompt, /Never leave these fields blank/i);
  assert.match(prompt, /copy nearby_context exactly from the matching visible_gbp_price_context entry/i);
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

test('3D printer prompt requires one observation per visible GBP price and forbids inferred price association', () => {
  const prompt = buildExtractionPrompt(printerTask, [{
    source_id: 'S1',
    title: 'Elegoo Neptune 4 Pro',
    url: 'https://example.co.uk/products/neptune-4-pro',
    text: 'Elegoo Neptune 4 Pro £290.00 Standard Printer. Open-box £164.00. Bundle £409.90.'
  }]);
  assert.match(prompt, /one price_observations entry for every visible GBP price/i);
  assert.match(prompt, /never infer association from proximity alone/i);
  assert.match(prompt, /copy condition from the same price\/variant context/i);
  assert.match(prompt, /only label a price as requested_product\/current when its own condition matches/i);
  assert.match(prompt, /ambiguous/i);
  assert.match(prompt, /requested_product/i);
});

test('3D printer extraction uses a bounded strict JSON schema for the exact page count', () => {
  const schema = buildGemmaFindingSchema(2);
  assert.equal(schema.type, 'object');
  assert.equal(schema.additionalProperties, false);
  assert.equal(schema.properties.findings.minItems, 2);
  assert.equal(schema.properties.findings.maxItems, 2);
  assert.equal(schema.properties.findings.items.additionalProperties, false);
  assert.equal(schema.properties.findings.items.properties.page_title.minLength, 1);
  assert.equal(schema.properties.findings.items.properties.product_identity_text.minLength, 1);
  assert.equal(schema.properties.findings.items.properties.match_observation.minLength, 1);
  const finding = schema.properties.findings.items;
  assert.ok(finding.properties.price_observations.maxItems <= 16);
  const observation = finding.properties.price_observations.items;
  assert.equal(observation.additionalProperties, false);
  assert.deepEqual(observation.properties.price_role.enum, ['current','crossed_out','saving','other_variant','accessory','filament','delivery','protection_plan','warranty','unknown']);
  assert.deepEqual(observation.properties.association.enum, ['requested_product','other_variant','accessory','delivery','saving_or_reference','ambiguous']);
  for (const field of ['price_text','nearby_context','product_or_variant','price_role','association','condition','availability']) {
    assert.ok(observation.required.includes(field), 'price observation requires ' + field);
    assert.ok(observation.properties[field]);
  }
  assert.ok(finding.properties.notes.maxLength <= 180);
});

test('only one verified current price for the exact requested product and condition lane can populate observed_price', () => {
  const observations = [
    { amount: 549, source_context_verified: true, association: 'requested_product', price_role: 'current', condition: 'Brand New' },
    { amount: 849, source_context_verified: true, association: 'requested_product', price_role: 'crossed_out', condition: 'Brand New' },
    { amount: 300, source_context_verified: true, association: 'saving_or_reference', price_role: 'saving', condition: 'Brand New' },
    { amount: 749, source_context_verified: true, association: 'other_variant', price_role: 'current', condition: 'Brand New' },
    { amount: 18.49, source_context_verified: true, association: 'accessory', price_role: 'protection_plan', condition: 'N/A' },
    { amount: 345, source_context_verified: false, association: 'requested_product', price_role: 'current', condition: 'Brand New' }
  ];
  assert.equal(selectSafeObservedPrice(observations, 'uk_new'), 549);
  assert.equal(selectSafeObservedPrice([
    { amount: 164, source_context_verified: true, association: 'requested_product', price_role: 'current', condition: 'Open-box' }
  ], 'uk_new'), null);
  assert.equal(selectSafeObservedPrice([
    { amount: 164, source_context_verified: true, association: 'requested_product', price_role: 'current', condition: 'Open-box' }
  ], 'uk_used'), 164);
  assert.equal(selectSafeObservedPrice([
    { amount: 299, source_context_verified: true, association: 'requested_product', price_role: 'current', condition: 'Never used' }
  ], 'uk_new'), 299);
  assert.equal(selectSafeObservedPrice([
    { amount: 299, source_context_verified: true, association: 'requested_product', price_role: 'current', condition: 'Opened - Never Used' }
  ], 'uk_new'), null);
  assert.equal(selectSafeObservedPrice([
    { amount: 549, source_context_verified: true, association: 'requested_product', price_role: 'current', condition: 'Brand New' },
    { amount: 749, source_context_verified: true, association: 'requested_product', price_role: 'current', condition: 'Brand New' }
  ], 'uk_new'), null);
  assert.equal(selectSafeObservedPrice([
    { amount: 849, source_context_verified: true, association: 'requested_product', price_role: 'crossed_out', condition: 'Brand New' }
  ], 'uk_new'), null);
  assert.equal(selectSafeObservedPrice([
    { amount: 345, source_context_verified: false, association: 'requested_product', price_role: 'current', condition: 'Brand New' }
  ], 'uk_new'), null);
});
test('single-page recovery schema requests exactly one compact finding', () => {
  const schema = buildGemmaFindingSchema(1);
  assert.equal(schema.properties.findings.minItems, 1);
  assert.equal(schema.properties.findings.maxItems, 1);
  assert.ok(schema.properties.findings.items.properties.price_observations.maxItems <= 16);
  assert.ok(schema.properties.findings.items.properties.uncertainty_and_conflicts.maxLength <= 180);
});
