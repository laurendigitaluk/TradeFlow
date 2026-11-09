[CmdletBinding()]
param(
    [string]$BasePath = 'C:\CTFGemma2',
    [string]$SharedEnvFile
)

$ErrorActionPreference = 'Stop'
$Repository = 'https://github.com/laurendigitaluk/TradeFlow.git'
$SharedRoot = Join-Path $BasePath 'Gemma-Shared'
$EnvPointer = Join-Path $SharedRoot 'TradeFlow.env.path'
$Desktop = [Environment]::GetFolderPath('Desktop')
$PowerShell = Join-Path $PSHOME 'powershell.exe'

$Agents = @(
    @{ Branch='gemma/3d-printers'; Folder='Gemma-3D-Printers'; Label='Gemma 3D Printers' },
    @{ Branch='gemma/gaming'; Folder='Gemma-Gaming'; Label='Gemma Gaming' },
    @{ Branch='gemma/cameras'; Folder='Gemma-Cameras'; Label='Gemma Cameras' },
    @{ Branch='gemma/drones'; Folder='Gemma-Drones'; Label='Gemma Drones' },
    @{ Branch='gemma/metal-detectors'; Folder='Gemma-Metal-Detectors'; Label='Gemma Metal Detectors' },
    @{ Branch='gemma/mobile-phones'; Folder='Gemma-Mobile-Phones'; Label='Gemma Mobile Phones' },
    @{ Branch='gemma/laptops'; Folder='Gemma-Laptops'; Label='Gemma Laptops' }
)

if (-not (Get-Command git -ErrorAction SilentlyContinue)) { throw 'Git for Windows is required. Install or enable Git before running this installer.' }
if (-not (Get-Command node -ErrorAction SilentlyContinue)) { throw 'Node.js is required. Install or enable Node.js before running this installer.' }

New-Item -ItemType Directory -Path $BasePath -Force | Out-Null
New-Item -ItemType Directory -Path $SharedRoot -Force | Out-Null

if ([string]::IsNullOrWhiteSpace($SharedEnvFile) -and (Test-Path -LiteralPath $EnvPointer -PathType Leaf)) {
    $SharedEnvFile = (Get-Content -LiteralPath $EnvPointer -Raw).Trim().Trim('"').Trim("'")
}
if ([string]::IsNullOrWhiteSpace($SharedEnvFile)) {
    $KnownEnv = Join-Path $BasePath 'TradeFlow-feature-tradeflow-gemma-agent-foundation-20261105\tools\tradeflow-gemma-agent\.env'
    if (Test-Path -LiteralPath $KnownEnv -PathType Leaf) {
        $SharedEnvFile = $KnownEnv
    } else {
        $SharedEnvFile = Read-Host 'Enter the path to the existing private TradeFlow .env file (it will not be copied or changed)'
    }
}
$SharedEnvFile = [IO.Path]::GetFullPath($SharedEnvFile.Trim().Trim('"').Trim("'"))
if (-not (Test-Path -LiteralPath $SharedEnvFile -PathType Leaf)) { throw 'The selected shared private ENV file does not exist. No agent folders were cloned.' }
Set-Content -LiteralPath $EnvPointer -Value $SharedEnvFile -Encoding UTF8

$WshShell = New-Object -ComObject WScript.Shell
$Results = @()
foreach ($Agent in $Agents) {
    $Target = Join-Path $BasePath $Agent.Folder
    if (Test-Path -LiteralPath $Target) {
        $Results += [pscustomobject]@{ Agent=$Agent.Label; Result='Skipped — folder already exists; nothing overwritten'; Folder=$Target }
        continue
    }

    Write-Host "Cloning $($Agent.Label) from its own branch $($Agent.Branch)..."
    & git clone --depth 1 --filter=blob:none --sparse --single-branch --branch $Agent.Branch $Repository $Target
    if ($LASTEXITCODE -ne 0) {
        $Results += [pscustomobject]@{ Agent=$Agent.Label; Result='Clone failed; no existing folder was changed'; Folder=$Target }
        continue
    }
    & git -C $Target sparse-checkout set tools/tradeflow-gemma-agent
    if ($LASTEXITCODE -ne 0) {
        $Results += [pscustomobject]@{ Agent=$Agent.Label; Result='Sparse checkout failed; folder retained for inspection'; Folder=$Target }
        continue
    }

    $AgentRoot = Join-Path $Target 'tools\tradeflow-gemma-agent'
    $ConfigPath = Join-Path $AgentRoot 'agent.config.json'
    $Launcher = Join-Path $AgentRoot 'Start-Gemma-Agent.ps1'
    if (-not (Test-Path -LiteralPath $ConfigPath -PathType Leaf) -or -not (Test-Path -LiteralPath $Launcher -PathType Leaf)) {
        $Results += [pscustomobject]@{ Agent=$Agent.Label; Result='Branch is missing its isolated config or launcher'; Folder=$Target }
        continue
    }

    $Config = Get-Content -LiteralPath $ConfigPath -Raw | ConvertFrom-Json
    $CurrentBranch = (& git -C $Target branch --show-current).Trim()
    if ($Config.sourceBranch -ne $Agent.Branch -or $CurrentBranch -ne $Agent.Branch -or @($Config.enabledAgentKeys).Count -ne 1) {
        $Results += [pscustomobject]@{ Agent=$Agent.Label; Result='Isolation verification failed; worker not started'; Folder=$Target }
        continue
    }

    $ShortcutPath = Join-Path $Desktop ($Agent.Label + '.lnk')
    $Shortcut = $WshShell.CreateShortcut($ShortcutPath)
    $Shortcut.TargetPath = $PowerShell
    $Shortcut.Arguments = '-NoExit -NoProfile -ExecutionPolicy Bypass -File "' + $Launcher + '" -Environment LIVE'
    $Shortcut.WorkingDirectory = $AgentRoot
    $Shortcut.Description = $Agent.Label + ' — independent branch and local worker'
    $Shortcut.Save()

    $Results += [pscustomobject]@{ Agent=$Agent.Label; Result='Installed — separate clone, branch and shortcut; not started'; Folder=$Target }
}

$ControlCentre = Join-Path $SharedRoot 'Gemma-Control-Centre.ps1'
$ControlCentreUrl = 'https://raw.githubusercontent.com/laurendigitaluk/TradeFlow/production/tools/gemma-agent-isolation/Gemma-Control-Centre.ps1'
Invoke-WebRequest -UseBasicParsing -Uri $ControlCentreUrl -OutFile $ControlCentre
if (-not (Test-Path -LiteralPath $ControlCentre -PathType Leaf)) { throw 'Unified Gemma Control Centre download failed.' }

$WshShell = New-Object -ComObject WScript.Shell
foreach ($ShortcutName in @('Gemma Control Centre.lnk','Gemma Switchboard.lnk')) {
    $ControlShortcut = $WshShell.CreateShortcut((Join-Path $Desktop $ShortcutName))
    $ControlShortcut.TargetPath = $PowerShell
    $ControlShortcut.Arguments = '-WindowStyle Hidden -STA -NoProfile -ExecutionPolicy Bypass -File "' + $ControlCentre + '"'
    $ControlShortcut.WorkingDirectory = $SharedRoot
    $ControlShortcut.Description = 'Manage all seven independent TradeFlow Gemma workers'
    $ControlShortcut.Save()
}

Write-Host ''
Write-Host 'ISOLATED GEMMA FOLDER INSTALLATION FINISHED'
Write-Host 'Shared ENV path saved as a pointer only. The private ENV file was not copied, printed or changed.'
Write-Host 'No Gemma worker was started. The existing Research PC installation and current processes were not stopped or overwritten.'
$Results | Format-Table -AutoSize
