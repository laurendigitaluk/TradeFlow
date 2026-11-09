[CmdletBinding()]
param(
    [string]$InstallPath,
    [string]$EnvFile,
    [string]$SourceBranch = 'production'
)

$ErrorActionPreference = 'Stop'
$Repository = 'laurendigitaluk/TradeFlow'
if ($SourceBranch -notmatch '^[A-Za-z0-9._/-]+$') { throw 'SourceBranch contains unsupported characters.' }
$RawBase = "https://raw.githubusercontent.com/$Repository/$SourceBranch"

if ([string]::IsNullOrWhiteSpace($InstallPath)) {
    $CurrentFolder = (Get-Location).Path
    if (Test-Path -LiteralPath (Join-Path $CurrentFolder 'src/task-worker.mjs') -PathType Leaf) {
        $InstallPath = $CurrentFolder
    } else {
        $InstallPath = Read-Host 'Enter the existing TradeFlow Gemma folder (the folder containing src)'
    }
}
$InstallPath = $InstallPath.Trim().Trim('"').Trim("'")
if (-not (Test-Path -LiteralPath $InstallPath -PathType Container)) { throw "Gemma installation folder not found: $InstallPath" }
$InstallPath = (Resolve-Path -LiteralPath $InstallPath).Path
if (-not (Test-Path -LiteralPath (Join-Path $InstallPath 'src/task-worker.mjs') -PathType Leaf)) {
    throw 'The selected folder does not contain the existing Gemma queue worker.'
}
if ([string]::IsNullOrWhiteSpace($EnvFile)) {
    $candidate = Join-Path $InstallPath '.env'
    if (Test-Path -LiteralPath $candidate -PathType Leaf) { $EnvFile = $candidate }
    else { $EnvFile = Read-Host 'Enter the full path to the existing private Gemma .env file' }
}
$EnvFile = $EnvFile.Trim().Trim('"').Trim("'")
if (-not (Test-Path -LiteralPath $EnvFile -PathType Leaf)) { throw 'The existing private Gemma .env file was not found.' }
$EnvFile = (Resolve-Path -LiteralPath $EnvFile).Path

# Refuse to overwrite an active legacy worker. It must be stopped cleanly first.
$task = Get-ScheduledTask -TaskName 'TradeFlow Gemma Research Supervisor' -ErrorAction SilentlyContinue
$taskInfo = if ($task) { Get-ScheduledTaskInfo -TaskName 'TradeFlow Gemma Research Supervisor' -ErrorAction SilentlyContinue } else { $null }
$desktopTaskRunning = $taskInfo -and $taskInfo.State -eq 'Running'
if ($desktopTaskRunning) {
    throw 'The desktop supervisor is already running. In the Control Centre choose Stop after current task, wait until the service shows stopped, then rerun the installer. This installer will not update worker files while a task may be active.'
}
$legacy = Get-CimInstance Win32_Process -Filter "name='node.exe'" -ErrorAction SilentlyContinue |
    Where-Object { $_.CommandLine -match 'task-worker\.mjs' }
if ($legacy) { throw 'A Gemma task-worker process is already running outside the desktop supervisor. Stop it cleanly with Ctrl+C before installing; this installer will not terminate it.' }

# Read only to validate approved project targets. Secret values are never printed or copied.
$envValues = @{}
foreach ($line in Get-Content -LiteralPath $EnvFile) {
    if ($line -match '^\s*([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.*)\s*$') {
        $envValues[$Matches[1]] = $Matches[2].Trim().Trim('"').Trim("'")
    }
}
if ([string]::IsNullOrWhiteSpace($envValues['TRADEFLOW_LIVE_URL']) -or [string]::IsNullOrWhiteSpace($envValues['TRADEFLOW_LIVE_SERVICE_ROLE_KEY'])) {
    throw 'The private .env must contain the existing TradeFlow LIVE URL and service-role key.'
}
if (([uri]$envValues['TRADEFLOW_LIVE_URL']).Host -ne 'gxsrajtqzdjvmceqcpgv.supabase.co') {
    throw 'The existing private .env does not point to the approved TradeFlow LIVE project.'
}

$TempRoot = Join-Path ([IO.Path]::GetTempPath()) ('tradeflow-desktop-install-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $TempRoot -Force | Out-Null
try {
    $Updater = Join-Path $TempRoot 'Update-TradeFlow-Gemma.ps1'
    Invoke-WebRequest -UseBasicParsing -Uri "$RawBase/tools/tradeflow-gemma-agent/Update-TradeFlow-Gemma.ps1" -OutFile $Updater
    & $Updater -InstallPath $InstallPath -EnvFile $EnvFile -SourceBranch $SourceBranch -Environment LIVE
    if ($LASTEXITCODE -ne 0) { throw 'Gemma worker update failed. Desktop installation was not continued.' }

    $AppRoot = Join-Path $env:LOCALAPPDATA 'TradeFlow\ResearchControlCentre'
    New-Item -ItemType Directory -Path $AppRoot -Force | Out-Null
    $DesktopFiles = @('agents.json','TradeFlow-Research-Control-Centre.ps1','Run-TradeFlow-Gemma-Supervisor.ps1','Launch-TradeFlow-Control-Centre.vbs')
    foreach ($name in $DesktopFiles) {
        Invoke-WebRequest -UseBasicParsing -Uri "$RawBase/tools/tradeflow-gemma-desktop/$name" -OutFile (Join-Path $AppRoot $name)
    }

    $agents = Get-Content -LiteralPath (Join-Path $AppRoot 'agents.json') -Raw | ConvertFrom-Json
    $configPath = Join-Path $AppRoot 'config.json'
    if (Test-Path -LiteralPath $configPath -PathType Leaf) {
        $config = Get-Content -LiteralPath $configPath -Raw | ConvertFrom-Json
        $known = @($agents.agents | ForEach-Object { $_.agentKey })
        $config.enabledAgentKeys = @($config.enabledAgentKeys | Where-Object { $known -contains $_ } | Select-Object -Unique)
    } else {
        $config = [pscustomobject]@{
            schemaVersion = 1
            serviceEnabled = $true
            autoStart = $true
            enabledAgentKeys = @($agents.agents | ForEach-Object { $_.agentKey })
        }
    }
    if ($null -eq $config.serviceEnabled) { $config | Add-Member -NotePropertyName serviceEnabled -NotePropertyValue $true }
    if ($null -eq $config.autoStart) { $config | Add-Member -NotePropertyName autoStart -NotePropertyValue $true }
    $config.schemaVersion = 1
    $config | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $configPath -Encoding UTF8

    $service = [pscustomobject]@{ installPath=$InstallPath; envFile=$EnvFile; environment='LIVE' }
    $service | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath (Join-Path $AppRoot 'service.json') -Encoding UTF8
    New-Item -ItemType Directory -Path (Join-Path $AppRoot 'logs') -Force | Out-Null

    $supervisorPath = Join-Path $AppRoot 'Run-TradeFlow-Gemma-Supervisor.ps1'
    $action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument ('-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "' + $supervisorPath + '"')
    $trigger = New-ScheduledTaskTrigger -AtLogOn -User ($env:USERDOMAIN + '\' + $env:USERNAME)
    $principal = New-ScheduledTaskPrincipal -UserId ($env:USERDOMAIN + '\' + $env:USERNAME) -LogonType Interactive -RunLevel Limited
    $settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -RestartCount 3 -RestartInterval (New-TimeSpan -Minutes 1)
    Register-ScheduledTask -TaskName 'TradeFlow Gemma Research Supervisor' -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Description 'Starts the TradeFlow LIVE Gemma background queue supervisor at Windows sign-in.' -Force | Out-Null

    $shell = New-Object -ComObject WScript.Shell
    $desktop = [Environment]::GetFolderPath('Desktop')
    $shortcut = $shell.CreateShortcut((Join-Path $desktop 'TradeFlow Research Control Centre.lnk'))
    $shortcut.TargetPath = "$env:SystemRoot\System32\wscript.exe"
    $shortcut.Arguments = '"' + (Join-Path $AppRoot 'Launch-TradeFlow-Control-Centre.vbs') + '" "' + (Join-Path $AppRoot 'TradeFlow-Research-Control-Centre.ps1') + '"'
    $shortcut.WorkingDirectory = $AppRoot
    $shortcut.Save()

    foreach ($agent in $agents.agents) {
        $safeLabel = [regex]::Replace([string]$agent.shortLabel,'[^A-Za-z0-9 -]','').Trim()
        $agentShortcut = $shell.CreateShortcut((Join-Path $desktop ('Gemma - ' + $safeLabel + '.lnk')))
        $agentShortcut.TargetPath = "$env:SystemRoot\System32\wscript.exe"
        $agentShortcut.Arguments = '"' + (Join-Path $AppRoot 'Launch-TradeFlow-Control-Centre.vbs') + '" "' + (Join-Path $AppRoot 'TradeFlow-Research-Control-Centre.ps1') + '" -AgentKey "' + $agent.agentKey + '" -EnableAgent'
        $agentShortcut.WorkingDirectory = $AppRoot
        $agentShortcut.Save()
    }

    Write-Host ''
    Write-Host 'TradeFlow Research Control Centre installed.'
    Write-Host "Gemma folder: $InstallPath"
    Write-Host "Control Centre: $AppRoot"
    Write-Host 'Existing private .env was validated but not changed, copied, backed up or displayed.'
    Write-Host 'Seven specialist agent shortcuts were created on the Windows desktop.'
    Write-Host 'The background service starts at sign-in and processes only enabled agent categories.'
    Write-Host 'If the LIVE agent-scoped queue migration is not yet deployed, the worker will stop safely and the app will show Backend update required.'
    try { Start-ScheduledTask -TaskName 'TradeFlow Gemma Research Supervisor' -ErrorAction Stop } catch { Write-Warning ('The supervisor did not start immediately: ' + $_.Exception.Message) }
}
finally {
    if (Test-Path -LiteralPath $TempRoot) { Remove-Item -LiteralPath $TempRoot -Recurse -Force }
}
