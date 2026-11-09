[CmdletBinding()]
param(
    [ValidateSet('LIVE','TEST')]
    [string]$Environment = 'LIVE'
)

$ErrorActionPreference = 'Stop'
$InstallPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$ConfigPath = Join-Path $InstallPath 'agent.config.json'
$WorkerPath = Join-Path $InstallPath 'src\task-worker.mjs'
$RepoRoot = [IO.Path]::GetFullPath((Join-Path $InstallPath '..\..'))
$SharedEnvPointer = [IO.Path]::GetFullPath((Join-Path $InstallPath '..\..\..\Gemma-Shared\TradeFlow.env.path'))

if (-not (Test-Path -LiteralPath $ConfigPath -PathType Leaf)) { throw "This Gemma folder has no agent.config.json: $ConfigPath" }
if (-not (Test-Path -LiteralPath $WorkerPath -PathType Leaf)) { throw "This Gemma folder has no task worker: $WorkerPath" }
if (-not (Test-Path -LiteralPath $SharedEnvPointer -PathType Leaf)) { throw "Shared ENV pointer is missing: $SharedEnvPointer. Run Install-Gemma-Agents.ps1 first." }

$Config = Get-Content -LiteralPath $ConfigPath -Raw | ConvertFrom-Json
if ($Config.schemaVersion -ne 1 -or $Config.serviceEnabled -ne $true) { throw 'This Gemma is disabled or has an unsupported configuration.' }
if (@($Config.enabledAgentKeys).Count -ne 1) { throw 'Isolation check failed: this folder must contain exactly one enabled agent.' }
$AgentKey = [string]$Config.enabledAgentKeys[0]
if ([string]::IsNullOrWhiteSpace($AgentKey) -or [string]::IsNullOrWhiteSpace([string]$Config.sourceBranch)) { throw 'Agent key or source branch is missing from agent.config.json.' }

$CurrentBranch = (& git -C $RepoRoot branch --show-current).Trim()
if ($LASTEXITCODE -ne 0 -or $CurrentBranch -ne [string]$Config.sourceBranch) {
    throw "Branch/folder mismatch. This folder is configured for '$($Config.sourceBranch)' but Git reports '$CurrentBranch'. No worker started."
}

$EnvFile = (Get-Content -LiteralPath $SharedEnvPointer -Raw).Trim().Trim('"').Trim("'")
if (-not (Test-Path -LiteralPath $EnvFile -PathType Leaf)) { throw 'The shared private ENV file cannot be found. No worker started.' }
if (-not (Get-Command node -ErrorAction SilentlyContinue)) { throw 'Node.js is not installed or is not on PATH.' }

$Existing = Get-CimInstance Win32_Process -Filter "Name='node.exe'" |
    Where-Object { $_.CommandLine -and $_.CommandLine.Contains($WorkerPath) }
if ($Existing) {
    Write-Host "$($Config.agentLabel) is already running from this folder (PID $($Existing.ProcessId))."
    exit 0
}

Push-Location $InstallPath
try {
    & node --check $WorkerPath
    if ($LASTEXITCODE -ne 0) { throw 'Worker syntax check failed. No worker started.' }
    & node --test (Join-Path $InstallPath 'src\agent-isolation.test.mjs') (Join-Path $InstallPath 'src\desktop-control.test.mjs')
    if ($LASTEXITCODE -ne 0) { throw 'Agent isolation tests failed. No worker started.' }

    $env:TRADEFLOW_GEMMA_ENV_FILE = $EnvFile
    $env:TRADEFLOW_GEMMA_AGENT_CONFIG = $ConfigPath
    $env:TRADEFLOW_GEMMA_ENVIRONMENT = $Environment
    Write-Host "Starting $($Config.agentLabel) from branch $CurrentBranch."
    Write-Host "This process can claim only category '$AgentKey'. Other Gemma folders and branches are independent."
    & node $WorkerPath
    if ($LASTEXITCODE -ne 0) { throw "$($Config.agentLabel) exited with code $LASTEXITCODE." }
}
finally {
    Pop-Location
}
