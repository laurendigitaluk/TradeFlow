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

$Switchboard = Join-Path $SharedRoot 'Gemma-Switchboard.ps1'
$SwitchboardContent = @'
$ErrorActionPreference = 'Stop'
$BasePath = Split-Path -Parent $MyInvocation.MyCommand.Path
$Agents = @(
 @{ Label='Gemma 3D Printers'; Folder='Gemma-3D-Printers' },
 @{ Label='Gemma Gaming'; Folder='Gemma-Gaming' },
 @{ Label='Gemma Cameras'; Folder='Gemma-Cameras' },
 @{ Label='Gemma Drones'; Folder='Gemma-Drones' },
 @{ Label='Gemma Metal Detectors'; Folder='Gemma-Metal-Detectors' },
 @{ Label='Gemma Mobile Phones'; Folder='Gemma-Mobile-Phones' },
 @{ Label='Gemma Laptops'; Folder='Gemma-Laptops' }
)
while ($true) {
 Clear-Host
 Write-Host 'TRADEFLOW — SELECT AN INDEPENDENT GEMMA'
 Write-Host ''
 for ($i=0; $i -lt $Agents.Count; $i++) { Write-Host ("{0}. {1}" -f ($i+1),$Agents[$i].Label) }
 Write-Host '0. Exit'
 Write-Host ''
 $Choice = Read-Host 'Select the Gemma to start'
 if ($Choice -eq '0') { break }
 $Index = -1
 if ([int]::TryParse($Choice,[ref]$Index) -and $Index -ge 1 -and $Index -le $Agents.Count) {
  $AgentRoot = Join-Path (Join-Path $BasePath $Agents[$Index-1].Folder) 'tools	radeflow-gemma-agent'
  $Launcher = Join-Path $AgentRoot 'Start-Gemma-Agent.ps1'
  if (Test-Path -LiteralPath $Launcher) {
   Start-Process -FilePath (Join-Path $PSHOME 'powershell.exe') -ArgumentList @('-NoExit','-NoProfile','-ExecutionPolicy','Bypass','-File',('"' + $Launcher + '"'),'-Environment','LIVE') -WorkingDirectory $AgentRoot
  } else { Write-Host 'This Gemma has not been installed yet.'; Start-Sleep -Seconds 2 }
 }
}
'@
Set-Content -LiteralPath $Switchboard -Value $SwitchboardContent -Encoding UTF8
$SwitchShortcut = $WshShell.CreateShortcut((Join-Path $Desktop 'Gemma Switchboard.lnk'))
$SwitchShortcut.TargetPath = $PowerShell
$SwitchShortcut.Arguments = '-NoExit -NoProfile -ExecutionPolicy Bypass -File "' + $Switchboard + '"'
$SwitchShortcut.WorkingDirectory = $SharedRoot
$SwitchShortcut.Description = 'Choose which independent Gemma to start'
$SwitchShortcut.Save()

Write-Host ''
Write-Host 'ISOLATED GEMMA FOLDER INSTALLATION FINISHED'
Write-Host 'Shared ENV path saved as a pointer only. The private ENV file was not copied, printed or changed.'
Write-Host 'No Gemma worker was started. The existing Research PC installation and current processes were not stopped or overwritten.'
$Results | Format-Table -AutoSize
