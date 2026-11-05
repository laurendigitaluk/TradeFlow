$ErrorActionPreference = "Stop"
$AgentRoot = $PSScriptRoot
$EnvFile = Join-Path $AgentRoot ".env"
$Supervisor = Join-Path $AgentRoot "Start-TradeFlow-Gemma-Service.ps1"
if (-not (Test-Path -LiteralPath $EnvFile -PathType Leaf)) { throw "TradeFlow .env is missing from the agent folder. No task was installed." }
if (-not (Test-Path -LiteralPath $Supervisor -PathType Leaf)) { throw "TradeFlow Gemma supervisor script is missing." }
$PowerShell = (Get-Command powershell.exe -ErrorAction Stop).Source
$Action = New-ScheduledTaskAction -Execute $PowerShell -Argument "-NoProfile -NonInteractive -ExecutionPolicy Bypass -File `"$Supervisor`"" -WorkingDirectory $AgentRoot
$Trigger = New-ScheduledTaskTrigger -AtLogOn -User ([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)
$Principal = New-ScheduledTaskPrincipal -UserId ([System.Security.Principal.WindowsIdentity]::GetCurrent().Name) -LogonType Interactive -RunLevel Limited
$Settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -RestartCount 999 -RestartInterval (New-TimeSpan -Minutes 1) -ExecutionTimeLimit ([TimeSpan]::Zero) -MultipleInstances IgnoreNew
$Task = New-ScheduledTask -Action $Action -Trigger $Trigger -Principal $Principal -Settings $Settings -Description "Keeps the local TradeFlow Gemma research worker connected to the TEST task queue."
Register-ScheduledTask -TaskName "TradeFlow Gemma Research Agent" -InputObject $Task -Force | Out-Null
Start-ScheduledTask -TaskName "TradeFlow Gemma Research Agent"
Write-Host "TradeFlow Gemma background service installed and started."
Write-Host "It will start automatically whenever this Windows account logs in."
Write-Host "Log file: $AgentRoot\logs\gemma-supervisor.log"
