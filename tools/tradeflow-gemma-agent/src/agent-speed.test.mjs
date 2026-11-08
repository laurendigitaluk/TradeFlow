import test from 'node:test';
import assert from 'node:assert/strict';
import { buildExtractionPrompt, buildGemmaFindingSchema, extractionBatchSizeForTask, selectSafeObservedPrice } from './agent.mjs';

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
