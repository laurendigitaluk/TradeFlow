import test from 'node:test';
import assert from 'node:assert/strict';
import { summarizeTaskOutput, summarizeTaskResults } from './task-result-summary.mjs';
test('summary preserves useful references and metrics without raw capture payloads', () => {
 const raw={worker:'uk_both',product:'Printer A',enqueue:true,candidates:[{source_id:'S1',page_title:'Printer A',source_url:'https://example.co.uk/p',review_classification:'unverified_capture',observed_price:399,price_currency:'GBP',source_excerpt:'x'.repeat(100000),page_capture:{url:'https://example.co.uk/p',captured_text:'x'.repeat(100000)}}],writes:[{id:'capture-1',status:'capture-queued-for-chatgpt-review',dedupe_key:'d1',environment:'LIVE_REVIEW_QUEUE',full_payload:'x'.repeat(100000)}],research_metrics:{captured_pages:1},route_metrics:{approved_source_route_attempts:5},route_failures:[]};
 const summary=summarizeTaskOutput(raw);
 assert.equal(summary.candidate_count,1); assert.equal(summary.candidates[0].observed_price,399); assert.equal(summary.writes[0].id,'capture-1');
 assert.equal(summary.research_metrics.captured_pages,1); assert.equal(summary.route_metrics.approved_source_route_attempts,5);
 assert.equal('page_capture' in summary.candidates[0],false); assert.equal('source_excerpt' in summary.candidates[0],false); assert.ok(JSON.stringify(summary).length<5000);
});
test('result summary preserves batch size',()=>{const r=summarizeTaskResults('batch-1',[{product:'A'},{product:'B'}]);assert.equal(r.subtasks,2);assert.equal(r.results.length,2);});
