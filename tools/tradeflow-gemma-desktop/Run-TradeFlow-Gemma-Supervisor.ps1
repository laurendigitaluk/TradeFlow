[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$AppRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$ConfigPath = Join-Path $AppRoot 'config.json'
$ServicePath = Join-Path $AppRoot 'service.json'
$StatusPath = Join-Path $AppRoot 'status.json'
$LogPath = Join-Path $AppRoot 'logs'
New-Item -ItemType Directory -Path $LogPath -Force | Out-Null

function Read-JsonFile([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { throw "Required control file is missing: $Path" }
    return (Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json)
}
function Write-SupervisorLog([string]$Message) {
    $line = '[' + (Get-Date -Format 'yyyy-MM-dd HH:mm:ss') + '] ' + $Message
    Add-Content -LiteralPath (Join-Path $LogPath 'supervisor.log') -Value $line -Encoding UTF8
}
function Write-Status([string]$State,[string]$Message) {
    $value = [ordered]@{ schemaVersion=1; updatedAt=(Get-Date).ToUniversalTime().ToString('o'); state=$State; message=$Message }
    $value | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $StatusPath -Encoding UTF8
}

while ($true) {
    $config = Read-JsonFile $ConfigPath
    if (-not $config.serviceEnabled) {
        Write-SupervisorLog 'Background service disabled; supervisor exiting.'
        break
    }

    $service = Read-JsonFile $ServicePath
    $worker = Join-Path $service.installPath 'src\task-worker.mjs'
    if (-not (Test-Path -LiteralPath $worker -PathType Leaf)) {
        Write-Status 'error' 'Gemma worker source is missing. Run the desktop installer again.'
        Write-SupervisorLog 'Worker source missing; supervisor exiting.'
        break
    }
    if (-not (Test-Path -LiteralPath $service.envFile -PathType Leaf)) {
        Write-Status 'error' 'The existing private Gemma .env file could not be found.'
        Write-SupervisorLog 'Private environment file missing; supervisor exiting.'
        break
    }

    $node = Get-Command node -ErrorAction SilentlyContinue
    if (-not $node) {
        Write-Status 'error' 'Node.js is not available on PATH.'
        Write-SupervisorLog 'Node.js missing; supervisor exiting.'
        break
    }

    $env:TRADEFLOW_GEMMA_ENV_FILE = [string]$service.envFile
    $env:TRADEFLOW_GEMMA_ENVIRONMENT = 'LIVE'
    $env:TRADEFLOW_GEMMA_AGENT_CONFIG = $ConfigPath

    $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    $stdout = Join-Path $LogPath ("worker-$stamp.out.log")
    $stderr = Join-Path $LogPath ("worker-$stamp.err.log")
    Write-SupervisorLog 'Starting the single LIVE queue supervisor. Enabled specialist agents are read from config.json.'
    Write-Status 'starting' 'Starting the LIVE queue supervisor.'

    try {
        $argument = '"' + $worker + '"'
        $child = Start-Process -FilePath $node.Source -ArgumentList $argument -PassThru -NoNewWindow -RedirectStandardOutput $stdout -RedirectStandardError $stderr
        Wait-Process -Id $child.Id
    } catch {
        Write-SupervisorLog ('Worker process launch/wait failed: ' + $_.Exception.Message)
    }

    $status = $null
    try { $status = Read-JsonFile $StatusPath } catch {}
    if ($status -and $status.state -eq 'requires_migration') {
        Write-SupervisorLog 'Agent-scoped queue RPC is not installed on LIVE. Worker stopped safely; no unscoped claim fallback was attempted.'
        break
    }

    $config = Read-JsonFile $ConfigPath
    if (-not $config.serviceEnabled) {
        Write-SupervisorLog 'Background service disabled after current task completed; supervisor exiting.'
        break
    }

    Write-SupervisorLog 'Worker exited unexpectedly or restarted; retrying in 15 seconds.'
    Start-Sleep -Seconds 15
}

Write-SupervisorLog 'Supervisor stopped.'
