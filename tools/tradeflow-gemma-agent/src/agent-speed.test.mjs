import test from 'node:test';
import assert from 'node:assert/strict';
import { buildCaptureEnrichmentPatch, buildEvidenceCaptureDedupeKey, buildEvidenceCaptureSnapshotDedupeKey, buildEvidenceCaptureSnapshotFingerprint, buildExtractionPrompt, buildGemmaFindingSchema, buildLegacyEvidenceCaptureLookupPath, extractionBatchSizeForTask, extractBatch, extractRelevantPageText, extractVisibleGbpPriceMentions, getEvidenceCaptureRepeatAction, getGemmaExtractionTimeoutMs, selectExistingEvidenceCaptureRecord, selectSafeObservedPrice, shouldRetainFullPageCapture } from './agent.mjs';

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
  assert.match(prompt, /Populate page_title, product_identity_text and match_observation/i);
  assert.match(prompt, /Use empty values only when facts are genuinely absent/i);
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
  assert.match(prompt, /price_observations field with up to eight distinct relevant options/i);
  assert.match(prompt, /do not infer association from proximity alone/i);
  assert.match(prompt, /Copy condition from the same option/i);
  assert.match(prompt, /only mark a price requested_product\/current when that same option matches the requested new or used lane/i);
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
  assert.equal(finding.properties.price_observations.maxItems, 8);
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
  assert.equal(schema.properties.findings.items.properties.price_observations.maxItems, 8);
  assert.ok(schema.properties.findings.items.properties.uncertainty_and_conflicts.maxLength <= 180);
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
  const sourceText = 'Bambu Lab A1 3D printer £289.00 in stock. ' + 'Detailed product specification and technical information. '.repeat(700);
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


test('3D-printer Gemma inference is capped at 45 seconds; other agents retain their configured timeout', () => {
  assert.equal(getGemmaExtractionTimeoutMs(printerTask, {}), 45000);
  assert.equal(getGemmaExtractionTimeoutMs(printerTask, { OLLAMA_TIMEOUT_MS: 300000 }), 45000);
  assert.equal(getGemmaExtractionTimeoutMs(printerTask, { GEMMA_3D_EXTRACTION_TIMEOUT_MS: 30000 }), 30000);
  assert.equal(getGemmaExtractionTimeoutMs(printerTask, { GEMMA_3D_EXTRACTION_TIMEOUT_MS: 999999 }), 45000);
  assert.equal(getGemmaExtractionTimeoutMs(printerTask, { GEMMA_3D_EXTRACTION_TIMEOUT_MS: 5000 }), 15000);
  assert.equal(getGemmaExtractionTimeoutMs({ ...printerTask, category_slug: 'drones', branch_slug: 'drones' }, { OLLAMA_TIMEOUT_MS: 300000 }), 300000);
});

test('3D-printer Gemma timeout uses one bounded attempt and returns complete raw evidence without per-page retries', async () => {
  const originalFetch = globalThis.fetch;
  let requests = 0;
  const events = [];
  const sources = [
    {
      source_id: 'S1',
      title: 'Bambu Lab A1 UK product page',
      url: 'https://www.bambulab.com/uk/products/a1',
      text: 'Bambu Lab A1 standard printer £289.00 in stock. ' + 'Full product page text. '.repeat(550)
    },
    {
      source_id: 'S2',
      title: 'Bambu Lab A1 Combo UK product page',
      url: 'https://www.bambulab.com/uk/products/a1-combo',
      text: 'Bambu Lab A1 Combo printer £399.00 in stock. ' + 'Full Combo product page text. '.repeat(550)
    }
  ];
  globalThis.fetch = async () => {
    requests++;
    throw new Error('The operation was aborted due to timeout');
  };
  try {
    const result = await extractBatch(printerTask, sources, {
      OLLAMA_BASE_URL: 'http://127.0.0.1:11434',
      OLLAMA_MODEL: 'gemma3:4b'
    }, event => events.push(event));
    assert.equal(requests, 1, 'a failed 3D batch must not trigger sequential single-page retries');
    assert.equal(result.gemmaHttpRequests, 1, 'count actual Ollama HTTP requests');
    assert.equal(result.gemmaRecoverySkipped, 2, 'count both pages retained as raw fallback after the failed batch');
    assert.equal(result.batches, 1);
    assert.equal(result.failures.length, 1);
    assert.equal(result.findings.length, 2);
    assert.equal(result.findings[0].source_excerpt, sources[0].text);
    assert.equal(result.findings[1].source_excerpt, sources[1].text);
    assert.equal(result.findings[0].page_capture.captured_text, sources[0].text);
    assert.equal(result.findings[1].page_capture.captured_text, sources[1].text);
    assert.equal(result.findings[0].review_classification, 'unverified_capture');
    assert.equal(result.findings[1].review_classification, 'unverified_capture');
    assert.ok(events.some(event => event.stage === 'extraction_batch_failed'));
    assert.ok(events.some(event => event.stage === 'extraction_batch_completed' && event.fallback_pages === 2));
  } finally {
    globalThis.fetch = originalFetch;
  }
});

test('3D-printer Gemma prompt includes the approved website navigation note but still preserves full-page source evidence', () => {
  const prompt = buildExtractionPrompt(printerTask, [{
    source_id: 'S1',
    title: 'ELEGOO Neptune 4 Pro',
    url: 'https://uk.elegoo.com/products/elegoo-neptune-4-pro-fdm-3d-printer',
    text: 'ELEGOO Neptune 4 Pro Standard Printer £189.00 New. In stock.'
  }]);
  assert.match(prompt, /SOURCE-SPECIFIC SITE NOTES/);
  assert.match(prompt, /dedicated Pre-owned 3D Printers collection/);
  assert.match(prompt, /do not attempt new browsing or invent URLs/i);
});


test('same product can retain multiple evidence captures of the same type from distinct source listings', () => {
  const task = {
    manufacturer: 'Bambu Lab',
    model: 'A1',
    package_key: 'standard',
    category_slug: '3d-printers-equipment',
    branch_slug: '3d-printers'
  };
  const retailer = { source_url: 'https://retailer-a.co.uk/products/bambu-a1' };
  const marketplace = { source_url: 'https://www.ebay.co.uk/itm/123456789' };
  const sameRetailerPage = { source_url: retailer.source_url };
  assert.equal(
    buildEvidenceCaptureDedupeKey(task, retailer),
    buildEvidenceCaptureDedupeKey(task, sameRetailerPage),
    'repeat research of one exact page remains idempotent'
  );
  assert.notEqual(
    buildEvidenceCaptureDedupeKey(task, retailer),
    buildEvidenceCaptureDedupeKey(task, marketplace),
    'a second source/listing for the same product is a separate evidence capture'
  );
});


test('3D-printer review snapshots are idempotent until material page observations change', () => {
  const task = {
    manufacturer: 'Elegoo',
    model: 'Neptune 4 Pro',
    package_key: 'standard',
    category_slug: '3d-printers-equipment',
    branch_slug: '3d-printers'
  };
  const original = {
    page_title: 'Elegoo Neptune 4 Pro',
    evidence_type: null,
    package_or_variant_text: 'Standard Printer',
    item_condition_text: 'Brand new',
    availability_text: 'In stock',
    page_capture: {
      title: 'Elegoo Neptune 4 Pro',
      captured_text: 'Elegoo Neptune 4 Pro standard printer £189.00. '.repeat(180),
      gbp_price_mentions: [
        { amount: 189, display: '£189.00', context: 'Elegoo Neptune 4 Pro standard printer £189.00' }
      ]
    }
  };
  const unchanged = JSON.parse(JSON.stringify(original));
  const changedPrice = {
    ...original,
    page_capture: {
      ...original.page_capture,
      gbp_price_mentions: [
        { amount: 169, display: '£169.00', context: 'Elegoo Neptune 4 Pro standard printer £169.00' }
      ]
    }
  };
  const expandedPage = {
    ...original,
    page_capture: {
      ...original.page_capture,
      captured_text: 'Elegoo Neptune 4 Pro standard printer £189.00. '.repeat(900)
    }
  };

  const originalFingerprint = buildEvidenceCaptureSnapshotFingerprint(original);
  assert.equal(buildEvidenceCaptureSnapshotFingerprint(unchanged), originalFingerprint);
  assert.notEqual(buildEvidenceCaptureSnapshotFingerprint(changedPrice), originalFingerprint);
  assert.notEqual(buildEvidenceCaptureSnapshotFingerprint(expandedPage), originalFingerprint);

  const originalSnapshotKey = buildEvidenceCaptureSnapshotDedupeKey(task, original, originalFingerprint);
  assert.equal(
    buildEvidenceCaptureSnapshotDedupeKey(task, unchanged, buildEvidenceCaptureSnapshotFingerprint(unchanged)),
    originalSnapshotKey
  );
  assert.notEqual(
    buildEvidenceCaptureSnapshotDedupeKey(task, changedPrice, buildEvidenceCaptureSnapshotFingerprint(changedPrice)),
    originalSnapshotKey
  );
});

test('changed captures create a new review snapshot without modifying imported or rejected history', () => {
  const evidence = {
    page_title: 'Elegoo Neptune 4 Pro',
    evidence_type: null,
    package_or_variant_text: 'Standard Printer',
    item_condition_text: 'Brand new',
    availability_text: 'In stock',
    page_capture: {
      title: 'Elegoo Neptune 4 Pro',
      captured_text: 'Elegoo Neptune 4 Pro £189.00. '.repeat(400),
      gbp_price_mentions: [{ amount: 189, display: '£189.00', context: 'Elegoo Neptune 4 Pro standard £189.00' }]
    }
  };
  const changed = {
    ...evidence,
    page_capture: {
      ...evidence.page_capture,
      gbp_price_mentions: [{ amount: 169, display: '£169.00', context: 'Elegoo Neptune 4 Pro standard £169.00' }]
    }
  };
  const incomingFingerprint = buildEvidenceCaptureSnapshotFingerprint(changed);
  const oldPayload = {
    task: { task_key: 'older-task' },
    evidence,
    page_capture: evidence.page_capture,
    review_classification: 'unverified_capture'
  };
  const imported = { status: 'imported', raw_payload: oldPayload };
  const rejected = { status: 'rejected', raw_payload: oldPayload };
  const pending = {
    status: 'needs_research',
    reviewed_at: null,
    reviewed_by: null,
    approved_at: null,
    imported_at: null,
    raw_payload: oldPayload
  };
  const reviewedPending = { ...pending, reviewed_at: '2026-11-09T12:00:00Z' };

  const importedBefore = JSON.stringify(imported);
  const rejectedBefore = JSON.stringify(rejected);
  assert.equal(getEvidenceCaptureRepeatAction(imported, buildEvidenceCaptureSnapshotFingerprint(evidence)), 'duplicate');
  assert.equal(getEvidenceCaptureRepeatAction(imported, incomingFingerprint), 'new_snapshot');
  assert.equal(getEvidenceCaptureRepeatAction(rejected, incomingFingerprint), 'new_snapshot');
  assert.equal(getEvidenceCaptureRepeatAction(pending, incomingFingerprint), 'enrich');
  assert.equal(getEvidenceCaptureRepeatAction(reviewedPending, incomingFingerprint), 'new_snapshot');
  assert.equal(JSON.stringify(imported), importedBefore, 'the imported evidence row is never mutated');
  assert.equal(JSON.stringify(rejected), rejectedBefore, 'the rejected history is never mutated');
});

test('repeat research of the same changed snapshot is idempotent even when reviewer metadata is absent', () => {
  const evidence = {
    page_title: 'Elegoo Neptune 4 Pro',
    page_capture: {
      title: 'Elegoo Neptune 4 Pro',
      captured_text: 'Elegoo Neptune 4 Pro £169.00 in stock. '.repeat(400),
      gbp_price_mentions: [{ amount: 169, display: '£169.00', context: 'Elegoo Neptune 4 Pro £169.00 in stock' }]
    }
  };
  const fingerprint = buildEvidenceCaptureSnapshotFingerprint(evidence);
  const revision = {
    status: 'needs_research',
    reviewed_by: null,
    reviewed_at: null,
    approved_at: null,
    imported_at: null,
    raw_payload: { evidence, page_capture: evidence.page_capture, snapshot_fingerprint: fingerprint }
  };
  assert.equal(getEvidenceCaptureRepeatAction(revision, fingerprint), 'duplicate');
});


test('3D-printer legacy review lookup is constrained to exact category, branch, product, package and source URL', () => {
  const task = {
    category_slug: '3d-printers-equipment',
    branch_slug: '3d-printers',
    manufacturer: 'Creality',
    model: 'K1',
    package_key: 'standard'
  };
  const evidence = { source_url: 'https://store.creality.com/uk/products/k1-speedy-3d-printer' };
  const path = buildLegacyEvidenceCaptureLookupPath(task, evidence);

  assert.match(path, /record_type=eq\.evidence_candidate/);
  assert.match(path, /category_slug=eq\.3d-printers-equipment/);
  assert.match(path, /branch_slug=eq\.3d-printers/);
  assert.match(path, /manufacturer=eq\.Creality/);
  assert.match(path, /model=eq\.K1/);
  assert.match(path, /package_key=eq\.standard/);
  assert.ok(path.includes('source_url=eq.https%3A%2F%2Fstore.creality.com%2Fuk%2Fproducts%2Fk1-speedy-3d-printer'));
  assert.match(path, /order=updated_at\.desc&limit=50/);
});

test('legacy imported and rejected captures remain idempotent when the page snapshot is unchanged', () => {
  const task = {
    category_slug: '3d-printers-equipment',
    branch_slug: '3d-printers',
    manufacturer: 'Creality',
    model: 'K1',
    package_key: 'standard'
  };
  const pageCapture = {
    title: 'Creality K1 Speedy 3D Printer',
    url: 'https://store.creality.com/uk/products/k1-speedy-3d-printer',
    captured_text: 'Creality K1 Speedy 3D Printer £299.00 Brand new In stock. '.repeat(30),
    gbp_price_mentions: [{ amount: 299, display: '£299.00', context: 'Creality K1 Speedy 3D Printer £299.00 Brand new' }]
  };
  const evidence = {
    ...task,
    source_url: pageCapture.url,
    page_title: pageCapture.title,
    evidence_type: null,
    package_or_variant_text: 'Standard printer',
    item_condition_text: 'Brand new',
    availability_text: 'In stock',
    source_excerpt: pageCapture.captured_text,
    page_capture: pageCapture
  };
  const fingerprint = buildEvidenceCaptureSnapshotFingerprint(evidence);
  const legacy = {
    ...task,
    source_url: pageCapture.url,
    status: 'imported',
    dedupe_key: 'review-legacy-imported-key',
    reviewed_at: '2026-11-08T22:01:06.564Z',
    approved_at: '2026-11-08T22:07:33.163Z',
    imported_at: '2026-11-08T22:07:33.163Z',
    raw_payload: { task, evidence, page_capture: pageCapture, review_classification: 'unverified_capture' }
  };
  const rejected = {
    ...legacy,
    status: 'rejected',
    dedupe_key: 'borderline-legacy-rejected-key',
    approved_at: null,
    imported_at: null
  };
  const before = JSON.stringify([legacy, rejected]);

  const selected = selectExistingEvidenceCaptureRecord([legacy, rejected], fingerprint);
  assert.equal(selected.action, 'duplicate');
  assert.ok([legacy, rejected].includes(selected.record));
  assert.equal(JSON.stringify([legacy, rejected]), before);
});

test('materially changed capture beside a legacy terminal row becomes a new snapshot without changing history', () => {
  const task = {
    category_slug: '3d-printers-equipment',
    branch_slug: '3d-printers',
    manufacturer: 'Creality',
    model: 'K1',
    package_key: 'standard'
  };
  const pageCapture = {
    title: 'Creality K1 Speedy 3D Printer',
    url: 'https://store.creality.com/uk/products/k1-speedy-3d-printer',
    captured_text: 'Creality K1 Speedy 3D Printer £299.00 Brand new In stock. '.repeat(30),
    gbp_price_mentions: [{ amount: 299, display: '£299.00', context: 'Creality K1 Speedy 3D Printer £299.00 Brand new' }]
  };
  const oldEvidence = {
    ...task, source_url: pageCapture.url, page_title: pageCapture.title,
    package_or_variant_text: 'Standard printer', item_condition_text: 'Brand new',
    availability_text: 'In stock', source_excerpt: pageCapture.captured_text, page_capture: pageCapture
  };
  const oldFingerprint = buildEvidenceCaptureSnapshotFingerprint(oldEvidence);
  const legacy = {
    ...task, source_url: pageCapture.url, status: 'imported', dedupe_key: 'review-legacy-imported-key',
    reviewed_at: '2026-11-08T22:01:06.564Z', approved_at: '2026-11-08T22:07:33.163Z',
    imported_at: '2026-11-08T22:07:33.163Z',
    raw_payload: { task, evidence: oldEvidence, page_capture: pageCapture, review_classification: 'unverified_capture' }
  };
  const changedPage = {
    ...pageCapture,
    gbp_price_mentions: [{ amount: 279, display: '£279.00', context: 'Creality K1 Speedy 3D Printer £279.00 Brand new' }]
  };
  const changedEvidence = {
    ...oldEvidence,
    page_capture: changedPage,
    source_excerpt: changedPage.captured_text,
    observed_price: null
  };
  const changedFingerprint = buildEvidenceCaptureSnapshotFingerprint(changedEvidence);
  const before = JSON.stringify(legacy);

  assert.notEqual(changedFingerprint, oldFingerprint);
  const selected = selectExistingEvidenceCaptureRecord([legacy], changedFingerprint);
  assert.equal(selected.action, 'new_snapshot');
  assert.equal(selected.record, legacy);
  assert.equal(JSON.stringify(legacy), before);
  assert.notEqual(
    buildEvidenceCaptureSnapshotDedupeKey(task, changedEvidence, changedFingerprint),
    buildEvidenceCaptureSnapshotDedupeKey(task, oldEvidence, oldFingerprint)
  );
});

test('unreviewed legacy pending captures can be safely enriched without changing their legacy dedupe key', () => {
  const task = {
    category_slug: '3d-printers-equipment',
    branch_slug: '3d-printers',
    manufacturer: 'Creality',
    model: 'K1',
    package_key: 'standard'
  };
  const url = 'https://store.creality.com/uk/products/k1-speedy-3d-printer';
  const oldEvidence = {
    page_title: 'Creality K1 Speedy 3D Printer',
    source_url: url,
    item_condition_text: 'Brand new',
    availability_text: 'In stock',
    package_or_variant_text: 'Standard printer',
    page_capture: { title: 'Creality K1', url, captured_text: 'K1 £299.00 in stock', gbp_price_mentions: [{ amount: 299, display: '£299.00', context: 'K1 £299.00' }] }
  };
  const changedEvidence = {
    ...oldEvidence,
    page_capture: { ...oldEvidence.page_capture, captured_text: 'K1 £279.00 in stock', gbp_price_mentions: [{ amount: 279, display: '£279.00', context: 'K1 £279.00' }] }
  };
  const pending = {
    ...task, source_url: url, status: 'needs_research', dedupe_key: 'borderline-legacy-pending-key',
    reviewed_by: null, reviewed_at: null, approved_at: null, imported_at: null,
    raw_payload: { evidence: oldEvidence, page_capture: oldEvidence.page_capture, review_classification: 'unverified_capture' }
  };
  const incoming = {
    ...task, source_url: url, dedupe_key: 'capture-new-base-key',
    raw_payload: { task, evidence: changedEvidence, page_capture: changedEvidence.page_capture, review_classification: 'unverified_capture' }
  };
  const patch = buildCaptureEnrichmentPatch(pending, incoming, '2026-11-09T18:00:00.000Z');

  assert.ok(patch);
  assert.equal(patch.raw_payload.enrichment_history.length, 1);
  assert.equal(patch.raw_payload.enrichment_history[0].snapshot_fingerprint, buildEvidenceCaptureSnapshotFingerprint(changedEvidence));
  assert.equal(pending.dedupe_key, 'borderline-legacy-pending-key');
  assert.equal(patch.reviewed_by, undefined);
  assert.equal(patch.approved_at, undefined);
});
