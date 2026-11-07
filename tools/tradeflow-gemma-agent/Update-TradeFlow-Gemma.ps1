[CmdletBinding()]
param(
    [string]$InstallPath,
    [string]$EnvFile,
    [switch]$NewInstall,
    [switch]$StartWorker
)

$ErrorActionPreference = 'Stop'
$Repository = 'laurendigitaluk/TradeFlow'
$RawBase = "https://raw.githubusercontent.com/$Repository/production/tools/tradeflow-gemma-agent"
$SourceFiles = @('agent.mjs', 'agent-telemetry.mjs', 'task-worker.mjs', 'task-groups.mjs', 'task-groups.test.mjs', 'source-playbooks.mjs', 'source-playbooks.test.mjs')

if ([string]::IsNullOrWhiteSpace($InstallPath)) {
    $InstallPath = Read-Host 'Enter the dedicated TradeFlow Gemma agent folder (the folder containing src)'
}
if ([string]::IsNullOrWhiteSpace($EnvFile)) {
    $EnvFile = Read-Host 'Enter the FULL PATH to the existing private .env file (it will not be changed)'
}
if (-not (Test-Path -LiteralPath $InstallPath -PathType Container)) {
    if (-not $NewInstall) { throw "Install folder does not exist. Use -NewInstall for a dedicated new TradeFlow Gemma folder: $InstallPath" }
    New-Item -ItemType Directory -Path $InstallPath -Force | Out-Null
}
$InstallPath = (Resolve-Path -LiteralPath $InstallPath).Path
$SourcePath = Join-Path $InstallPath 'src'
if (-not (Test-Path -LiteralPath (Join-Path $SourcePath 'agent.mjs') -PathType Leaf) -and -not $NewInstall) {
    throw "src/agent.mjs was not found. Use -NewInstall only for a dedicated new TradeFlow Gemma folder."
}
if (-not (Test-Path -LiteralPath $SourcePath -PathType Container)) {
    New-Item -ItemType Directory -Path $SourcePath -Force | Out-Null
}
if (-not (Test-Path -LiteralPath $EnvFile -PathType Leaf)) {
    throw "Private environment file not found: $EnvFile"
}
$EnvFile = (Resolve-Path -LiteralPath $EnvFile).Path

$Node = Get-Command node -ErrorAction SilentlyContinue
if (-not $Node) { throw 'Node.js is not installed or is not on PATH.' }
$NodeVersionText = (& node --version).Trim()
if ($LASTEXITCODE -ne 0) { throw 'Could not read the Node.js version.' }
if ($NodeVersionText -notmatch '^v(\d+)\.') { throw "Unrecognised Node.js version: $NodeVersionText" }
if ([int]$Matches[1] -lt 18) { throw "Node.js 18 or later is required. Found $NodeVersionText" }

# Read the existing private environment only to validate the approved TEST/LIVE targets.
# Never print, copy, upload, back up, or overwrite this file or its secret values.
$EnvValues = @{}
foreach ($Line in Get-Content -LiteralPath $EnvFile) {
    if ($Line -match '^\s*([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.*)\s*$') {
        $Value = $Matches[2].Trim().Trim('"').Trim("'")
        $EnvValues[$Matches[1]] = $Value
    }
}
$Required = @('TRADEFLOW_TEST_URL','TRADEFLOW_TEST_SERVICE_ROLE_KEY','TRADEFLOW_LIVE_URL','TRADEFLOW_LIVE_SERVICE_ROLE_KEY')
foreach ($Name in $Required) {
    if ([string]::IsNullOrWhiteSpace($EnvValues[$Name])) { throw "The private .env file is missing required setting: $Name" }
}
if (([uri]$EnvValues['TRADEFLOW_TEST_URL']).Host -ne 'nnsshnfkjcflucjrftzi.supabase.co') {
    throw 'The configured TEST URL is not the approved TradeFlow TEST project.'
}
if (([uri]$EnvValues['TRADEFLOW_LIVE_URL']).Host -ne 'gxsrajtqzdjvmceqcpgv.supabase.co') {
    throw 'The configured LIVE URL is not the approved TradeFlow LIVE project.'
}

$TempRoot = Join-Path ([IO.Path]::GetTempPath()) ('tradeflow-gemma-update-' + [guid]::NewGuid().ToString('N'))
$DownloadPath = Join-Path $TempRoot 'src'
New-Item -ItemType Directory -Path $DownloadPath -Force | Out-Null
try {
    foreach ($Name in $SourceFiles) {
        $Uri = "$RawBase/src/$Name"
        $Destination = Join-Path $DownloadPath $Name
        Invoke-WebRequest -UseBasicParsing -Uri $Uri -OutFile $Destination
        if (-not (Test-Path -LiteralPath $Destination -PathType Leaf)) { throw "Download failed: $Name" }
    }

    foreach ($Name in $SourceFiles | Where-Object { $_ -like '*.mjs' }) {
        & node --check (Join-Path $DownloadPath $Name)
        if ($LASTEXITCODE -ne 0) { throw "Node syntax check failed: $Name" }
    }
    & node --test (Join-Path $DownloadPath 'task-groups.test.mjs') (Join-Path $DownloadPath 'source-playbooks.test.mjs')
    if ($LASTEXITCODE -ne 0) { throw 'Gemma task normalisation or website playbook tests failed; no files were installed.' }

    $BackupPath = Join-Path $InstallPath ('backups\before-common-room-' + (Get-Date -Format 'yyyyMMdd-HHmmss'))
    New-Item -ItemType Directory -Path $BackupPath -Force | Out-Null
    foreach ($Name in $SourceFiles) {
        $Existing = Join-Path $SourcePath $Name
        if (Test-Path -LiteralPath $Existing -PathType Leaf) {
            Copy-Item -LiteralPath $Existing -Destination (Join-Path $BackupPath $Name) -Force
        }
    }

    foreach ($Name in $SourceFiles) {
        Copy-Item -LiteralPath (Join-Path $DownloadPath $Name) -Destination (Join-Path $SourcePath $Name) -Force
    }

    foreach ($Name in $SourceFiles | Where-Object { $_ -like '*.mjs' }) {
        & node --check (Join-Path $SourcePath $Name)
        if ($LASTEXITCODE -ne 0) { throw "Installed Node syntax check failed: $Name" }
    }
    & node --test (Join-Path $SourcePath 'task-groups.test.mjs') (Join-Path $SourcePath 'source-playbooks.test.mjs')
    if ($LASTEXITCODE -ne 0) { throw 'Installed Gemma task or website playbook tests failed.' }

    Write-Host ''
    Write-Host 'TradeFlow Gemma source updated and verified.'
    Write-Host "Install folder: $InstallPath"
    Write-Host "Private .env retained unchanged: $EnvFile"
    Write-Host "Source backup: $BackupPath"
    Write-Host 'No database, tenant, customer, Stripe, or Cloudflare settings were changed.'

    if ($StartWorker) {
        $env:TRADEFLOW_GEMMA_ENV_FILE = $EnvFile
        Write-Host 'Starting the LIVE queue worker. Press Ctrl+C to stop it.'
        & node (Join-Path $SourcePath 'task-worker.mjs')
        if ($LASTEXITCODE -ne 0) { throw "Gemma worker exited with code $LASTEXITCODE" }
    }
}
finally {
    if (Test-Path -LiteralPath $TempRoot) { Remove-Item -LiteralPath $TempRoot -Recurse -Force }
}
