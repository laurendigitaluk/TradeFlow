import test from 'node:test';
import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const sourceDir = dirname(fileURLToPath(import.meta.url));
const updaterPath = process.env.TRADEFLOW_GEMMA_UPDATER_PATH || resolve(sourceDir, '..', 'Update-TradeFlow-Gemma.ps1');
const startPath = process.env.TRADEFLOW_GEMMA_START_PATH || resolve(sourceDir, '..', 'Start-TradeFlow-Gemma.ps1');

const [workerSource, updaterSource, startSource] = await Promise.all([
  readFile(resolve(sourceDir, 'task-worker.mjs'), 'utf8'),
  readFile(updaterPath, 'utf8'),
  readFile(startPath, 'utf8')
]);

const sourceBlock = updaterSource.match(/\$SourceFiles\s*=\s*@\(([\s\S]*?)\)/)?.[1] || '';
const packagedFiles = new Set([...sourceBlock.matchAll(/'([^']+)'/g)].map((match) => match[1]));
const workerImports = [...workerSource.matchAll(/from\s+['"]\.\/([^'"]+\.mjs)['"]/g)].map((match) => match[1]);
const updaterTestCommands = [...updaterSource.matchAll(/& node --test ([^\r\n]+)/g)].map((match) => match[1]);
const startBlock = startSource.match(/\$TestFiles\s*=\s*@\(([\s\S]*?)\)/)?.[1] || '';
const startupTests = new Set([...startBlock.matchAll(/'([^']+\.test\.mjs)'/g)].map((match) => match[1]));
const requiredTests = ['task-result-summary.test.mjs', 'agent-telemetry.test.mjs', 'installer-manifest.test.mjs'];

test('category updater packages every direct task-worker module import', () => {
  assert.ok(workerImports.length > 0, 'task-worker must have inspectable local imports');
  for (const dependency of workerImports) {
    assert.ok(packagedFiles.has(dependency), 'updater must package task-worker dependency: ' + dependency);
  }
});

test('category updater downloads and runs compact-result, telemetry and manifest tests before and after installation', () => {
  assert.ok(packagedFiles.has('task-result-summary.mjs'), 'compact task-result helper must be installed');
  for (const name of requiredTests) {
    assert.ok(packagedFiles.has(name), 'updater must download ' + name);
  }
  assert.equal(updaterTestCommands.length, 2, 'updater must test both downloaded and installed source');
  for (const command of updaterTestCommands) {
    for (const name of requiredTests) {
      assert.match(command, new RegExp(name.replace(/\./g, '\\.'), 'i'), 'node --test must include ' + name);
    }
  }
});

test('category launcher preflight runs the same deployment-critical regression tests', () => {
  for (const name of requiredTests) {
    assert.ok(startupTests.has(name), 'launcher must run ' + name);
  }
});
