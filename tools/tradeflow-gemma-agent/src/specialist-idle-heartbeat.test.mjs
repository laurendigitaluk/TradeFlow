import test from 'node:test';
import assert from 'node:assert/strict';
import { buildSpecialistIdleHeartbeatRecord, specialistIdleHeartbeatIntervalMs, shouldEmitSpecialistIdleHeartbeat } from './specialist-idle-heartbeat.mjs';
test('heartbeat cadence is bounded', () => {
 assert.equal(specialistIdleHeartbeatIntervalMs(5000),60000);
 assert.equal(specialistIdleHeartbeatIntervalMs(15000),60000);
 assert.equal(specialistIdleHeartbeatIntervalMs(30000),120000);
 assert.equal(specialistIdleHeartbeatIntervalMs(60000),240000);
 assert.equal(specialistIdleHeartbeatIntervalMs(180000),300000);
});
test('invalid intervals use default', () => {
 assert.equal(specialistIdleHeartbeatIntervalMs(undefined),60000);
 assert.equal(specialistIdleHeartbeatIntervalMs('bad'),60000);
 assert.equal(specialistIdleHeartbeatIntervalMs(1000),60000);
});
test('only healthy idle state emits heartbeat', () => {
 assert.equal(shouldEmitSpecialistIdleHeartbeat({lastPollSucceeded:true}),true);
 for (const key of ['stopping','taskInProgress','pollInProgress','heartbeatInProgress']) assert.equal(shouldEmitSpecialistIdleHeartbeat({[key]:true,lastPollSucceeded:true}),false);
 assert.equal(shouldEmitSpecialistIdleHeartbeat({lastPollSucceeded:false}),false);
});
test('heartbeat retains specialist identity and worker metadata', () => {
 const identity={agent_key:'drones',agent_name:'Gemma Drones',category:'drones'};
 const row=buildSpecialistIdleHeartbeatRecord(identity,'worker-1',15000,'drones');
 assert.equal(row.agent_key,'drones'); assert.equal(row.agent_name,'Gemma Drones'); assert.equal(row.category,'drones');
 assert.equal(row.status,'idle'); assert.equal(row.current_task,null); assert.equal(row.event_type,'heartbeat');
 assert.equal(row.details.worker_id,'worker-1'); assert.equal(row.details.stage,'idle_poll'); assert.equal(row.details.isolated_agent_key,'drones');
});
