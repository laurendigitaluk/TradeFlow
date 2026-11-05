$ErrorActionPreference = "Stop"
$AgentRoot = $PSScriptRoot
$EnvFile = Join-Path $AgentRoot ".env"
$Supervisor = Join-Path $AgentRoot "Start-TradeFlow-Gemma-Service.ps1"
$Worker = Join-Path $AgentRoot "src\task-worker.mjs"
if (-not (Test-Path -LiteralPath $EnvFile -PathType Leaf)) { throw "TradeFlow .env is missing from the agent folder. No task was installed." }
if (-not (Test-Path -LiteralPath $Supervisor -PathType Leaf)) { throw "TradeFlow Gemma supervisor script is missing." }
if (-not (Test-Path -LiteralPath $Worker -PathType Leaf)) { throw "TradeFlow Gemma task worker is missing." }

$null = Get-Command node -ErrorAction Stop
$null = Get-Command npm -ErrorAction Stop
& node --check $Worker
if ($LASTEXITCODE -ne 0) { throw "Gemma task worker syntax check failed. No scheduled task was installed." }

Push-Location $AgentRoot
try {
    & npm test
    if ($LASTEXITCODE -ne 0) { throw "Gemma validation tests failed. No scheduled task was installed." }
}
finally {
    Pop-Location
}

$PowerShell = (Get-Command powershell.exe -ErrorAction Stop).Source
$CurrentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
$Action = New-ScheduledTaskAction -Execute $PowerShell -Argument "-NoProfile -NonInteractive -ExecutionPolicy Bypass -File `"$Supervisor`"" -WorkingDirectory $AgentRoot
$Trigger = New-ScheduledTaskTrigger -AtLogOn -User $CurrentUser
$Principal = New-ScheduledTaskPrincipal -UserId $CurrentUser -LogonType Interactive -RunLevel Limited
$Settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -RestartCount 999 -RestartInterval (New-TimeSpan -Minutes 1) -ExecutionTimeLimit ([TimeSpan]::Zero) -MultipleInstances IgnoreNew
$Task = New-ScheduledTask -Action $Action -Trigger $Trigger -Principal $Principal -Settings $Settings -Description "Keeps the local TradeFlow Gemma research worker connected to the TEST task queue."
Register-ScheduledTask -TaskName "TradeFlow Gemma Research Agent" -InputObject $Task -Force | Out-Null
Start-ScheduledTask -TaskName "TradeFlow Gemma Research Agent"
Write-Host "TradeFlow Gemma background service installed and started."
Write-Host "It will start automatically whenever this Windows account logs in."
Write-Host "Log file: $AgentRoot\logs\gemma-supervisor.log"
