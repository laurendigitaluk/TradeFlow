[CmdletBinding()]
param(
    [ValidateSet('TEST','LIVE')]
    [string]$Environment = 'LIVE'
)

$ErrorActionPreference = 'Stop'
$InstallPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$SourcePath = Join-Path $InstallPath 'src'
$EnvFile = Join-Path $InstallPath '.env'

if (-not (Test-Path -LiteralPath (Join-Path $SourcePath 'task-worker.mjs') -PathType Leaf)) {
    throw "Gemma worker source is missing: $SourcePath"
}
if (-not (Test-Path -LiteralPath $EnvFile -PathType Leaf)) {
    throw "Private .env file is missing: $EnvFile"
}
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    throw 'Node.js is not installed or is not on PATH.'
}

$TestFiles = @(
    'control-plane.test.mjs',
    'task-groups.test.mjs',
    'source-playbooks.test.mjs',
    'agent-identity.test.mjs',
    'agent-speed.test.mjs',
    'agent.source-selection.test.mjs',
    'worker-heartbeat.test.mjs'
)
foreach ($Name in $TestFiles) {
    $Path = Join-Path $SourcePath $Name
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Required current Gemma test file is missing: $Path"
    }
}
Write-Host 'Checking the installed TradeFlow Gemma source before starting...'
& node --test ($TestFiles | ForEach-Object { Join-Path $SourcePath $_ })
if ($LASTEXITCODE -ne 0) {
    throw 'Current Gemma source tests failed. Worker was not started.'
}

$env:TRADEFLOW_GEMMA_ENV_FILE = $EnvFile
$env:TRADEFLOW_GEMMA_ENVIRONMENT = $Environment
Write-Host "Starting the TradeFlow $Environment Gemma queue worker. Press Ctrl+C to stop."
& node (Join-Path $SourcePath 'task-worker.mjs')
if ($LASTEXITCODE -ne 0) {
    throw "Gemma worker exited with code $LASTEXITCODE"
}
