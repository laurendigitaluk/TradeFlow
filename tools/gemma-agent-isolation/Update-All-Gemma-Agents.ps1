[CmdletBinding()]
param([ValidateSet('LIVE','TEST')][string]$Environment='LIVE')
$ErrorActionPreference='Stop'
$SharedRoot=Split-Path -Parent $MyInvocation.MyCommand.Path
$BasePath=Split-Path -Parent $SharedRoot
$LogRoot=Join-Path $SharedRoot 'logs'
New-Item -ItemType Directory -Path $LogRoot -Force | Out-Null
$stamp=Get-Date -Format 'yyyyMMdd-HHmmss'
$MasterLog=Join-Path $LogRoot "update-all-$stamp.log"
$Agents=@(
 @{Key='3d-printers-equipment';Label='3D Printers & Equipment';Folder='Gemma-3D-Printers';Branch='gemma/3d-printers'},
 @{Key='gaming-consoles-accessories';Label='Gaming Consoles & Accessories';Folder='Gemma-Gaming';Branch='gemma/gaming'},
 @{Key='cameras';Label='Cameras & Lenses';Folder='Gemma-Cameras';Branch='gemma/cameras'},
 @{Key='drones';Label='Drones';Folder='Gemma-Drones';Branch='gemma/drones'},
 @{Key='metal-detectors';Label='Metal Detectors';Folder='Gemma-Metal-Detectors';Branch='gemma/metal-detectors'},
 @{Key='mobile-phones';Label='Mobile Phones';Folder='Gemma-Mobile-Phones';Branch='gemma/mobile-phones'},
 @{Key='laptops';Label='Laptops & Computers';Folder='Gemma-Laptops';Branch='gemma/laptops'}
)
function Write-Log([string]$Message){$line="[$(Get-Date -Format o)] $Message";Add-Content -LiteralPath $MasterLog -Value $line;Write-Host $line}
function Get-WorkerProcess($InstallPath){
 $worker=Join-Path $InstallPath 'src\task-worker.mjs'
 return @(Get-CimInstance Win32_Process -Filter "Name='node.exe'" -ErrorAction SilentlyContinue | Where-Object {$_.CommandLine -and $_.CommandLine.IndexOf($worker,[StringComparison]::OrdinalIgnoreCase) -ge 0})
}
$EnvPointer=Join-Path $SharedRoot 'TradeFlow.env.path'
if(-not(Test-Path -LiteralPath $EnvPointer -PathType Leaf)){throw 'Shared private ENV pointer is missing. No workers were changed.'}
$EnvFile=(Get-Content -LiteralPath $EnvPointer -Raw).Trim().Trim('"').Trim("'")
if(-not(Test-Path -LiteralPath $EnvFile -PathType Leaf)){throw 'Shared private ENV file cannot be found. No workers were changed.'}
$Plan=@()
foreach($agent in $Agents){
 $clone=Join-Path $BasePath $agent.Folder
 $install=Join-Path $clone 'tools\tradeflow-gemma-agent'
 $configPath=Join-Path $install 'agent.config.json'
 $updater=Join-Path $install 'Update-Gemma-Agent.ps1'
 $launcher=Join-Path $install 'Start-Gemma-Agent.ps1'
 if(-not(Test-Path -LiteralPath $configPath -PathType Leaf) -or -not(Test-Path -LiteralPath $updater -PathType Leaf) -or -not(Test-Path -LiteralPath $launcher -PathType Leaf)){throw "$($agent.Label) is incomplete. Preflight stopped before changing any worker."}
 $branch=(& git -C $clone branch --show-current 2>$null).Trim()
 if($LASTEXITCODE -ne 0 -or $branch -ne $agent.Branch){throw "$($agent.Label) branch mismatch. Expected $($agent.Branch), found $branch. Preflight stopped before changing any worker."}
 $config=Get-Content -LiteralPath $configPath -Raw | ConvertFrom-Json
 if(@($config.enabledAgentKeys).Count -ne 1 -or [string]$config.sourceBranch -ne $agent.Branch){throw "$($agent.Label) isolation configuration mismatch. No workers were changed."}
 $Plan += [pscustomobject]@{Agent=$agent;Install=$install;ConfigPath=$configPath;Updater=$updater;Launcher=$launcher;WasEnabled=($config.serviceEnabled -eq $true);WasRunning=(@(Get-WorkerProcess $install).Count -gt 0);Config=$config}
}
Write-Log "Preflight passed for all seven isolated LIVE workers. No .env contents will be read or changed."
foreach($item in $Plan){
 $item.Config.serviceEnabled=$false
 $item.Config | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $item.ConfigPath -Encoding UTF8
 if($item.WasRunning){Write-Log "Graceful stop requested: $($item.Agent.Label); current task will finish."}
}
$deadline=(Get-Date).AddMinutes(60)
do{
 $running=@($Plan | Where-Object {@(Get-WorkerProcess $_.Install).Count -gt 0})
 if($running.Count -eq 0){break}
 if((Get-Date) -ge $deadline){
  foreach($item in $Plan){$item.Config.serviceEnabled=$item.WasEnabled;$item.Config | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $item.ConfigPath -Encoding UTF8}
  throw "Timed out waiting for workers to finish. No source updates were started; previous enabled settings restored. Still running: $(($running.Agent.Label) -join ', ')"
 }
 Start-Sleep -Seconds 5
}while($true)
Write-Log 'All worker processes have stopped cleanly. Starting category-local updates.'
$Results=@()
foreach($item in $Plan){
 $agentLog=Join-Path $LogRoot $item.Agent.Folder
 New-Item -ItemType Directory -Path $agentLog -Force | Out-Null
 $out=Join-Path $agentLog "update-all-$stamp.out.log"
 $err=Join-Path $agentLog "update-all-$stamp.err.log"
 $args='-NoProfile -ExecutionPolicy Bypass -File "'+$item.Updater+'" -Environment '+$Environment
 try{
  $p=Start-Process -FilePath (Join-Path $PSHOME 'powershell.exe') -ArgumentList $args -WorkingDirectory $item.Install -WindowStyle Hidden -RedirectStandardOutput $out -RedirectStandardError $err -Wait -PassThru
  $ok=($p.ExitCode -eq 0)
  $Results += [pscustomobject]@{Agent=$item.Agent.Label;Success=$ok;ExitCode=$p.ExitCode;WasRunning=$item.WasRunning}
  Write-Log "$($item.Agent.Label) update exit code $($p.ExitCode). Logs: $out ; $err"
 }catch{
  $Results += [pscustomobject]@{Agent=$item.Agent.Label;Success=$false;ExitCode=-1;WasRunning=$item.WasRunning}
  Write-Log "$($item.Agent.Label) update failed: $($_.Exception.Message)"
 }
}
foreach($item in $Plan){
 $result=$Results | Where-Object {$_.Agent -eq $item.Agent.Label} | Select-Object -First 1
 $item.Config.serviceEnabled=($item.WasEnabled -and $result.Success)
 $item.Config | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $item.ConfigPath -Encoding UTF8
 if($result.Success -and $item.WasRunning){
  $agentLog=Join-Path $LogRoot $item.Agent.Folder
  $out=Join-Path $agentLog "restart-all-$stamp.out.log"
  $err=Join-Path $agentLog "restart-all-$stamp.err.log"
  $args='-NoProfile -ExecutionPolicy Bypass -File "'+$item.Launcher+'" -Environment '+$Environment
  try{
   $p=Start-Process -FilePath (Join-Path $PSHOME 'powershell.exe') -ArgumentList $args -WorkingDirectory $item.Install -WindowStyle Hidden -RedirectStandardOutput $out -RedirectStandardError $err -PassThru
   Write-Log "$($item.Agent.Label) restart requested; launcher PID $($p.Id)."
  }catch{Write-Log "$($item.Agent.Label) restart failed: $($_.Exception.Message)"}
 }
}
$successCount=@($Results | Where-Object Success).Count
Write-Log "Finished: $successCount of seven updates succeeded. Workers which were running before the operation were restarted only after their own update succeeded. Previously stopped workers remain stopped."
$Results | Format-Table -AutoSize | Out-String | Add-Content -LiteralPath $MasterLog
if($successCount -ne 7){exit 2}
exit 0
