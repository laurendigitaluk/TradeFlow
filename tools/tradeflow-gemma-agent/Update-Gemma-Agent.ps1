[CmdletBinding()]
param(
    [ValidateSet('LIVE','TEST')]
    [string]$Environment = 'LIVE'
)

$ErrorActionPreference = 'Stop'
$InstallPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$ConfigPath = Join-Path $InstallPath 'agent.config.json'
$SharedEnvPointer = [IO.Path]::GetFullPath((Join-Path $InstallPath '..\..\..\Gemma-Shared\TradeFlow.env.path'))
if (-not (Test-Path -LiteralPath $ConfigPath -PathType Leaf)) { throw 'Agent config is missing.' }
if (-not (Test-Path -LiteralPath $SharedEnvPointer -PathType Leaf)) { throw 'Shared ENV pointer is missing.' }

$Config = Get-Content -LiteralPath $ConfigPath -Raw | ConvertFrom-Json
if (@($Config.enabledAgentKeys).Count -ne 1) { throw 'Refusing to update a folder that is not isolated to exactly one category.' }
$EnvFile = (Get-Content -LiteralPath $SharedEnvPointer -Raw).Trim().Trim('"').Trim("'")
if (-not (Test-Path -LiteralPath $EnvFile -PathType Leaf)) { throw 'Shared private ENV file not found.' }
$Updater = Join-Path $InstallPath 'Update-TradeFlow-Gemma.ps1'
if (-not (Test-Path -LiteralPath $Updater -PathType Leaf)) { throw 'Category-local updater is missing.' }

$RepoRoot = [IO.Path]::GetFullPath((Join-Path $InstallPath '..\..'))
$CurrentBranch = (& git -C $RepoRoot branch --show-current).Trim()
if ($LASTEXITCODE -ne 0 -or $CurrentBranch -ne [string]$Config.sourceBranch) { throw 'Branch/folder mismatch. Update cancelled.' }
$Running = Get-CimInstance Win32_Process -Filter "Name='node.exe'" | Where-Object { $_.CommandLine -and $_.CommandLine.Contains((Join-Path $InstallPath 'src\task-worker.mjs')) }
if ($Running) { throw 'This Gemma is running. Stop its own worker cleanly before updating this folder. Other Gemmas are not affected.' }

& $Updater -InstallPath $InstallPath -EnvFile $EnvFile -SourceBranch $CurrentBranch -Environment $Environment
if ($LASTEXITCODE -ne 0) { throw "Update failed for $($Config.agentLabel)." }
Write-Host "$($Config.agentLabel) updated from its own branch: $CurrentBranch"
