[CmdletBinding()]
param(
    [string]$InstallPath,
    [string]$EnvFile,
    [string]$SourceBranch = 'production',
    [ValidateSet('TEST','LIVE')]
    [string]$Environment = 'LIVE',
    [switch]$NewInstall,
    [switch]$StartWorker
)

$ErrorActionPreference = 'Stop'
$Repository = 'laurendigitaluk/TradeFlow'
if ($SourceBranch -notmatch '^[A-Za-z0-9._/-]+$') { throw 'SourceBranch contains unsupported characters.' }
$RawBase = "https://raw.githubusercontent.com/$Repository/$SourceBranch/tools/tradeflow-gemma-agent"
$SourceFiles = @('control-plane.mjs', 'control-plane.test.mjs', 'agent.mjs', 'agent-speed.test.mjs', 'agent.source-selection.test.mjs', 'agent-identity.mjs', 'agent-identity.test.mjs', 'agent-isolation.mjs', 'agent-isolation.test.mjs', 'agent-telemetry.mjs', 'task-worker.mjs', 'task-groups.mjs', 'task-groups.test.mjs', 'source-playbooks.mjs', 'source-playbooks.test.mjs', 'desktop-control.mjs', 'desktop-control.test.mjs')
$LauncherName = 'Start-TradeFlow-Gemma.ps1'
$LegacyShortcutLauncherName = 'Start-Gemma-Worker.ps1'

if ([string]::IsNullOrWhiteSpace($InstallPath)) {
    # When launched from the installed Gemma folder, use it automatically.
    $CurrentFolder = (Get-Location).Path
    if (Test-Path -LiteralPath (Join-Path $CurrentFolder 'src/agent.mjs') -PathType Leaf) {
        $InstallPath = $CurrentFolder
    } else {
        $InstallPath = Read-Host 'Enter the dedicated TradeFlow Gemma agent folder (the folder containing src)'
    }
}
# Copy-Path in Windows may include surrounding quotes; remove only those wrappers.
if (-not [string]::IsNullOrWhiteSpace($InstallPath)) {
    $InstallPath = $InstallPath.Trim().Trim('"').Trim("'")
}
if ([string]::IsNullOrWhiteSpace($EnvFile)) {
    # Prefer the existing private .env beside the installed source; prompt only if absent.
    $CandidateEnvFile = Join-Path $InstallPath '.env'
    if (Test-Path -LiteralPath $CandidateEnvFile -PathType Leaf) {
        $EnvFile = $CandidateEnvFile
    } else {
        $EnvFile = Read-Host 'Enter the FULL PATH to the existing private .env file (it will not be changed)'
    }
}
if (-not [string]::IsNullOrWhiteSpace($EnvFile)) {
    $EnvFile = $EnvFile.Trim().Trim('"').Trim("'")
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
$LauncherDownload = Join-Path $TempRoot $LauncherName
$LegacyShortcutLauncherDownload = Join-Path $TempRoot $LegacyShortcutLauncherName
New-Item -ItemType Directory -Path $DownloadPath -Force | Out-Null
try {
    Invoke-WebRequest -UseBasicParsing -Uri "$RawBase/$LauncherName" -OutFile $LauncherDownload
    Set-Content -LiteralPath $LegacyShortcutLauncherDownload -Value @'
[CmdletBinding()]
param(
    [ValidateSet('TEST','LIVE')]
    [string]$Environment = 'LIVE'
)

$ErrorActionPreference = 'Stop'
$InstallPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$CanonicalLauncher = Join-Path $InstallPath 'Start-TradeFlow-Gemma.ps1'
if (-not (Test-Path -LiteralPath $CanonicalLauncher -PathType Leaf)) {
    throw "Canonical TradeFlow Gemma launcher is missing: $CanonicalLauncher. Run Update-TradeFlow-Gemma.ps1 first."
}
Write-Host "Starting TradeFlow Gemma through the canonical $Environment queue-worker launcher."
& $CanonicalLauncher -Environment $Environment
if ($LASTEXITCODE -ne 0) { throw "Canonical TradeFlow Gemma launcher exited with code $LASTEXITCODE" }
'@ -Encoding UTF8
    if (-not (Test-Path -LiteralPath $LauncherDownload -PathType Leaf)) { throw 'Current Gemma launcher download failed.' }
    $LegacyTokens = $null
    $LegacyErrors = $null
    [System.Management.Automation.Language.Parser]::ParseFile($LegacyShortcutLauncherDownload, [ref]$LegacyTokens, [ref]$LegacyErrors) | Out-Null
    if ($LegacyErrors.Count -gt 0) { throw 'Generated desktop-shortcut compatibility launcher has PowerShell syntax errors.' }
    $LauncherTokens = $null
    $LauncherErrors = $null
    [System.Management.Automation.Language.Parser]::ParseFile($LauncherDownload, [ref]$LauncherTokens, [ref]$LauncherErrors) | Out-Null
    if ($LauncherErrors.Count -gt 0) { throw 'Downloaded Gemma launcher has PowerShell syntax errors.' }

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
    & node --test (Join-Path $DownloadPath 'control-plane.test.mjs') (Join-Path $DownloadPath 'task-groups.test.mjs') (Join-Path $DownloadPath 'source-playbooks.test.mjs') (Join-Path $DownloadPath 'agent-identity.test.mjs') (Join-Path $DownloadPath 'agent-isolation.test.mjs') (Join-Path $DownloadPath 'agent-speed.test.mjs') (Join-Path $DownloadPath 'agent.source-selection.test.mjs') (Join-Path $DownloadPath 'desktop-control.test.mjs')
    if ($LASTEXITCODE -ne 0) { throw 'Gemma task normalisation or website playbook tests failed; no files were installed.' }

    $BackupPath = Join-Path $InstallPath ('backups\before-common-room-' + (Get-Date -Format 'yyyyMMdd-HHmmss'))
    New-Item -ItemType Directory -Path $BackupPath -Force | Out-Null
    $ExistingLauncher = Join-Path $InstallPath $LauncherName
    $ExistingLegacyLauncher = Join-Path $InstallPath $LegacyShortcutLauncherName
    if (Test-Path -LiteralPath $ExistingLegacyLauncher -PathType Leaf) {
        Copy-Item -LiteralPath $ExistingLegacyLauncher -Destination (Join-Path $BackupPath $LegacyShortcutLauncherName) -Force
    }
    if (Test-Path -LiteralPath $ExistingLauncher -PathType Leaf) {
        Copy-Item -LiteralPath $ExistingLauncher -Destination (Join-Path $BackupPath $LauncherName) -Force
    }
    foreach ($Name in $SourceFiles) {
        $Existing = Join-Path $SourcePath $Name
        if (Test-Path -LiteralPath $Existing -PathType Leaf) {
            Copy-Item -LiteralPath $Existing -Destination (Join-Path $BackupPath $Name) -Force
        }
    }

    foreach ($Name in $SourceFiles) {
        Copy-Item -LiteralPath (Join-Path $DownloadPath $Name) -Destination (Join-Path $SourcePath $Name) -Force
    }
    Copy-Item -LiteralPath $LauncherDownload -Destination (Join-Path $InstallPath $LauncherName) -Force
    Copy-Item -LiteralPath $LegacyShortcutLauncherDownload -Destination (Join-Path $InstallPath $LegacyShortcutLauncherName) -Force

    foreach ($Name in $SourceFiles | Where-Object { $_ -like '*.mjs' }) {
        & node --check (Join-Path $SourcePath $Name)
        if ($LASTEXITCODE -ne 0) { throw "Installed Node syntax check failed: $Name" }
    }
    & node --test (Join-Path $SourcePath 'control-plane.test.mjs') (Join-Path $SourcePath 'task-groups.test.mjs') (Join-Path $SourcePath 'source-playbooks.test.mjs') (Join-Path $SourcePath 'agent-identity.test.mjs') (Join-Path $SourcePath 'agent-isolation.test.mjs') (Join-Path $SourcePath 'agent-speed.test.mjs') (Join-Path $SourcePath 'agent.source-selection.test.mjs') (Join-Path $SourcePath 'desktop-control.test.mjs')
    if ($LASTEXITCODE -ne 0) { throw 'Installed Gemma task or website playbook tests failed.' }

    Write-Host ''
    $InstalledLauncher = Join-Path $InstallPath $LauncherName
    $InstalledLegacyLauncher = Join-Path $InstallPath $LegacyShortcutLauncherName
    $LegacyTokens = $null
    $LegacyErrors = $null
    [System.Management.Automation.Language.Parser]::ParseFile($InstalledLegacyLauncher, [ref]$LegacyTokens, [ref]$LegacyErrors) | Out-Null
    if ($LegacyErrors.Count -gt 0) { throw 'Installed legacy desktop-shortcut compatibility launcher has PowerShell syntax errors.' }
    $LauncherTokens = $null
    $LauncherErrors = $null
    [System.Management.Automation.Language.Parser]::ParseFile($InstalledLauncher, [ref]$LauncherTokens, [ref]$LauncherErrors) | Out-Null
    if ($LauncherErrors.Count -gt 0) { throw 'Installed Gemma launcher has PowerShell syntax errors.' }

    Write-Host 'TradeFlow Gemma source and matching launcher updated and verified.'
    Write-Host "Source branch: $SourceBranch"
    Write-Host "Install folder: $InstallPath"
    Write-Host "Private .env retained unchanged: $EnvFile"
    Write-Host "Source backup: $BackupPath"
    Write-Host 'No database, tenant, customer, Stripe, or Cloudflare settings were changed.'

    if ($StartWorker) {
        $env:TRADEFLOW_GEMMA_ENV_FILE = $EnvFile
        $env:TRADEFLOW_GEMMA_ENVIRONMENT = $Environment
        $DesktopConfigPath = Join-Path $env:LOCALAPPDATA 'TradeFlow\ResearchControlCentre\config.json'
        if (Test-Path -LiteralPath $DesktopConfigPath -PathType Leaf) {
            $env:TRADEFLOW_GEMMA_AGENT_CONFIG = $DesktopConfigPath
        }
        Write-Host "Starting the $Environment queue worker. Press Ctrl+C to stop it."
        & node (Join-Path $SourcePath 'task-worker.mjs')
        if ($LASTEXITCODE -ne 0) { throw "Gemma worker exited with code $LASTEXITCODE" }
    }
}
finally {
    if (Test-Path -LiteralPath $TempRoot) { Remove-Item -LiteralPath $TempRoot -Recurse -Force }
}
