[CmdletBinding()]
param(
    [ValidateSet('TEST','LIVE')]
    [string]$Environment = 'LIVE'
)

$ErrorActionPreference = 'Stop'
$InstallPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$SourcePath = Join-Path $InstallPath 'src'
$EnvFile = Join-Path $InstallPath '.env'
$DesktopRoot = Join-Path $env:LOCALAPPDATA 'TradeFlow\ResearchControlCentre'
$DesktopServicePath = Join-Path $DesktopRoot 'service.json'
if (Test-Path -LiteralPath $DesktopServicePath -PathType Leaf) {
    try {
        $DesktopService = Get-Content -LiteralPath $DesktopServicePath -Raw | ConvertFrom-Json
        if ([IO.Path]::GetFullPath([string]$DesktopService.installPath) -eq [IO.Path]::GetFullPath($InstallPath)) {
            $EnvFile = [string]$DesktopService.envFile
        }
    } catch {
        throw 'The desktop service configuration is invalid. Re-run the Control Centre installer before starting Gemma.'
    }
}

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
    'desktop-control.test.mjs'
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
$DesktopConfigPath = Join-Path $env:LOCALAPPDATA 'TradeFlow\ResearchControlCentre\config.json'
if (Test-Path -LiteralPath $DesktopConfigPath -PathType Leaf) {
    # When the desktop app is installed, manual starts still respect its per-agent switches.
    $env:TRADEFLOW_GEMMA_AGENT_CONFIG = $DesktopConfigPath
}
Write-Host "Starting the TradeFlow $Environment Gemma queue worker. Press Ctrl+C to stop."
& node (Join-Path $SourcePath 'task-worker.mjs')
if ($LASTEXITCODE -ne 0) {
    throw "Gemma worker exited with code $LASTEXITCODE"
}
