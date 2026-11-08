import test from 'node:test';
import assert from 'node:assert/strict';
import { buildExtractionPrompt, compactPrinterObservation } from './agent.mjs';

const printerTask = {
  category_slug: '3d-printers-equipment',
  branch_slug: '3d-printers',
  research_type: 'uk_both',
  manufacturer: 'Bambu Lab',
  model: 'A1',
  package_key: 'ams-lite-combo',
  package_name: 'AMS Lite Combo',
  search_query: 'Bambu Lab A1 AMS Lite Combo UK new and used GBP'
};

const page = {
  source_id: 'S1',
  title: 'Bambu Lab A1 Combo with AMS Lite',
  url: 'https://www.example.co.uk/products/bambu-a1-combo',
  text: 'Bambu Lab A1 Combo with AMS Lite. Brand new and sealed. Current price £349.99. In stock.'
};

test('3D printer prompt explicitly requests page-specific new/used evidence_type', () => {
  const prompt = buildExtractionPrompt(printerTask, [page]);
  assert.match(prompt, /evidence_type, observed_price/);
  assert.match(prompt, /evidence_type must be exactly "uk_new", "uk_used" or null/i);
  assert.match(prompt, /Set evidence_type to uk_new only when/i);
  assert.match(prompt, /Set it to uk_used for explicit used/i);
  assert.match(prompt, /Do not copy the task research_type into evidence_type/i);
});

test('3D printer prompt requires a numeric exact-package price or null and preserves all price contexts', () => {
  const prompt = buildExtractionPrompt(printerTask, [page]);
  assert.match(prompt, /observed_price must be a JSON number or null/i);
  assert.match(prompt, /one current, payable GBP amount/i);
  assert.match(prompt, /preserve all visible GBP amounts/i);
  assert.match(prompt, /sold out\/unavailable, use null/i);
});

test('3D printer prompt supplies a strict findings JSON template and bounded observation fields', () => {
  const prompt = buildExtractionPrompt(printerTask, [page]);
  assert.match(prompt, /STRICT JSON SHAPE/);
  assert.match(prompt, /320 characters or fewer/i);
  assert.match(prompt, /Never omit or reassign a source_id/i);
  assert.match(prompt, /page dumps, HTML or repeated page text/i);
});

test('long model condition output is replaced with short deterministic condition snippets', () => {
  const source = 'Bambu Lab A1 Combo. Brand new and sealed. In stock. ' + 'irrelevant footer content '.repeat(40);
  const rawModelOutput = source.repeat(4);
  const result = compactPrinterObservation(rawModelOutput, source, 'condition');
  assert.ok(result.length <= 320);
  assert.match(result, /Brand new and sealed/i);
  assert.doesNotMatch(result, /irrelevant footer content/i);
});

test('long model availability output is replaced with short deterministic availability snippets', () => {
  const source = 'Bambu Lab A1 Combo. Brand new. In stock and available for dispatch. ' + 'irrelevant footer content '.repeat(40);
  const rawModelOutput = source.repeat(4);
  const result = compactPrinterObservation(rawModelOutput, source, 'availability');
  assert.ok(result.length <= 320);
  assert.match(result, /In stock/i);
  assert.match(result, /available for dispatch/i);
  assert.doesNotMatch(result, /irrelevant footer content/i);
});

test('short factual model observations are preserved unchanged', () => {
  assert.equal(
    compactPrinterObservation('Brand new, sealed', page.text, 'condition'),
    'Brand new, sealed'
  );
  assert.equal(
    compactPrinterObservation('In stock', page.text, 'availability'),
    'In stock'
  );
});

test('non-3D extraction prompt does not receive the 3D-specific evidence contract', () => {
  const prompt = buildExtractionPrompt({
    ...printerTask,
    category_slug: 'drones',
    branch_slug: 'drones'
  }, [page]);
  assert.doesNotMatch(prompt, /NEW\/USED CLASSIFICATION/);
  assert.doesNotMatch(prompt, /STRICT JSON SHAPE/);
});
