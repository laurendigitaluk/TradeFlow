[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
$script:DashboardMutex = New-Object System.Threading.Mutex($false, 'Local\TradeFlowIndependentGemmaControlCentre')
if (-not $script:DashboardMutex.WaitOne(0, $false)) { $script:DashboardMutex.Dispose(); exit 0 }

$SharedRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$BasePath = Split-Path -Parent $SharedRoot
$LogRoot = Join-Path $SharedRoot 'logs'
New-Item -ItemType Directory -Path $LogRoot -Force | Out-Null

$Agents = @(
    @{ Key='3d-printers-equipment'; Label='3D Printers & Equipment'; Folder='Gemma-3D-Printers'; Branch='gemma/3d-printers' },
    @{ Key='gaming-consoles-accessories'; Label='Gaming Consoles & Accessories'; Folder='Gemma-Gaming'; Branch='gemma/gaming' },
    @{ Key='cameras'; Label='Cameras & Lenses'; Folder='Gemma-Cameras'; Branch='gemma/cameras' },
    @{ Key='drones'; Label='Drones'; Folder='Gemma-Drones'; Branch='gemma/drones' },
    @{ Key='metal-detectors'; Label='Metal Detectors'; Folder='Gemma-Metal-Detectors'; Branch='gemma/metal-detectors' },
    @{ Key='mobile-phones'; Label='Mobile Phones'; Folder='Gemma-Mobile-Phones'; Branch='gemma/mobile-phones' },
    @{ Key='laptops'; Label='Laptops & Computers'; Folder='Gemma-Laptops'; Branch='gemma/laptops' }
)
$script:UpdateProcesses = @{}
$script:Rows = @{}

function Get-AgentPaths($Agent) {
    $Clone = Join-Path $BasePath $Agent.Folder
    $Install = Join-Path $Clone 'tools\tradeflow-gemma-agent'
    return [pscustomobject]@{
        Clone=$Clone
        Install=$Install
        Config=(Join-Path $Install 'agent.config.json')
        Status=(Join-Path $Install 'status.json')
        Worker=(Join-Path $Install 'src\task-worker.mjs')
        Launcher=(Join-Path $Install 'Start-Gemma-Agent.ps1')
        Updater=(Join-Path $Install 'Update-Gemma-Agent.ps1')
    }
}
function Read-AgentJson([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { return $null }
    try { return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json } catch { return $null }
}
function Get-AgentRuntime($Agent,$ProcessSnapshot=$null,[bool]$VerifyBranch=$false) {
    $paths = Get-AgentPaths $Agent
    if (-not (Test-Path -LiteralPath $paths.Config -PathType Leaf) -or -not (Test-Path -LiteralPath $paths.Worker -PathType Leaf)) {
        return [pscustomobject]@{ Installed=$false; Paths=$paths; Config=$null; Status=$null; Process=$null; Branch='—'; State='NOT INSTALLED'; Task=''; Updated=''; Error='Agent folder or worker file is missing.' }
    }
    $config = Read-AgentJson $paths.Config
    $status = Read-AgentJson $paths.Status
    $branch = $Agent.Branch
    if ($VerifyBranch) { try { $branch = (& git -C $paths.Clone branch --show-current 2>$null).Trim() } catch { $branch = 'unknown' } }
    $workerProcess = $null
    if ($ProcessSnapshot) { $workerProcess = $ProcessSnapshot | Where-Object { $_.CommandLine -and $_.CommandLine.IndexOf($paths.Worker,[StringComparison]::OrdinalIgnoreCase) -ge 0 } | Select-Object -First 1 }
    $updateProcess = $script:UpdateProcesses[$Agent.Key]
    $isUpdating = $false
    if ($updateProcess) {
        $p = Get-Process -Id $updateProcess -ErrorAction SilentlyContinue
        if ($p) { $isUpdating = $true } else { $script:UpdateProcesses.Remove($Agent.Key) }
    }
    $state = 'NOT RUNNING'
    if ($isUpdating) { $state = 'UPDATING' }
    elseif ($branch -ne $Agent.Branch) { $state = 'BRANCH MISMATCH' }
    elseif ($workerProcess) {
        if ($status -and $status.state -eq 'processing') { $state = 'PROCESSING' }
        elseif ($status -and $status.state -eq 'error') { $state = 'ERROR' }
        elseif ($status -and $status.state -eq 'requires_migration') { $state = 'BACKEND UPDATE REQUIRED' }
        elseif ($config.serviceEnabled -eq $false) { $state = 'STOPPING AFTER CURRENT TASK' }
        elseif ($status -and $status.state -eq 'waiting') { $state = 'IDLE — CONNECTED' }
        else { $state = 'STARTING / CHECKING' }
    }
    elseif ($config.serviceEnabled -eq $false) { $state = 'STOPPED' }
    elseif ($config.serviceEnabled -eq $true) { $state = 'ENABLED — NOT RUNNING' }
    $updated = ''
    if ($status -and $status.updatedAt) {
        try { $updated = ([datetime]$status.updatedAt).ToLocalTime().ToString('HH:mm:ss') } catch {}
    }
    return [pscustomobject]@{
        Installed=$true; Paths=$paths; Config=$config; Status=$status; Process=$workerProcess
        Branch=$branch; State=$state
        Task=$(if ($status -and $status.activeTaskKey) { [string]$status.activeTaskKey } else { '—' })
        Updated=$updated
        Error=$(if ($status -and $status.lastError) { [string]$status.lastError } else { '' })
    }
}
function Save-AgentConfig($Runtime,[bool]$Enabled) {
    $config = $Runtime.Config
    $config.serviceEnabled = $Enabled
    $config | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $Runtime.Paths.Config -Encoding UTF8
}
function Start-Agent($Agent) {
    $runtime = Get-AgentRuntime $Agent
    if (-not $runtime.Installed) { throw "$($Agent.Label) is not installed." }
    if ($runtime.Branch -ne $Agent.Branch) { throw "Branch mismatch for $($Agent.Label). Expected $($Agent.Branch), found $($runtime.Branch). No worker started." }
    if ($runtime.Process) { throw "$($Agent.Label) is already running. No duplicate worker was started." }
    Save-AgentConfig $runtime $true
    $agentLogs = Join-Path $LogRoot $Agent.Folder
    New-Item -ItemType Directory -Path $agentLogs -Force | Out-Null
    $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    $outLog = Join-Path $agentLogs "worker-$stamp.out.log"
    $errLog = Join-Path $agentLogs "worker-$stamp.err.log"
    $arguments = '-NoProfile -ExecutionPolicy Bypass -File "' + $runtime.Paths.Launcher + '" -Environment LIVE'
    Start-Process -FilePath (Join-Path $PSHOME 'powershell.exe') -ArgumentList $arguments -WorkingDirectory $runtime.Paths.Install -WindowStyle Hidden -RedirectStandardOutput $outLog -RedirectStandardError $errLog | Out-Null
}
function Stop-Agent($Agent) {
    $runtime = Get-AgentRuntime $Agent
    if (-not $runtime.Installed) { throw "$($Agent.Label) is not installed." }
    Save-AgentConfig $runtime $false
}
function Update-Agent($Agent) {
    $runtime = Get-AgentRuntime $Agent
    if (-not $runtime.Installed) { throw "$($Agent.Label) is not installed." }
    if ($runtime.Branch -ne $Agent.Branch) { throw "Branch mismatch for $($Agent.Label). Update cancelled." }
    if ($runtime.Process) { throw "Stop $($Agent.Label) after its current task has finished before updating it." }
    $agentLogs = Join-Path $LogRoot $Agent.Folder
    New-Item -ItemType Directory -Path $agentLogs -Force | Out-Null
    $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    $outLog = Join-Path $agentLogs "update-$stamp.out.log"
    $errLog = Join-Path $agentLogs "update-$stamp.err.log"
    $arguments = '-NoProfile -ExecutionPolicy Bypass -File "' + $runtime.Paths.Updater + '" -Environment LIVE'
    $p = Start-Process -FilePath (Join-Path $PSHOME 'powershell.exe') -ArgumentList $arguments -WorkingDirectory $runtime.Paths.Install -WindowStyle Hidden -RedirectStandardOutput $outLog -RedirectStandardError $errLog -PassThru
    $script:UpdateProcesses[$Agent.Key] = $p.Id
}
function Show-AgentLogs($Agent) {
    $path = Join-Path $LogRoot $Agent.Folder
    New-Item -ItemType Directory -Path $path -Force | Out-Null
    Start-Process explorer.exe -ArgumentList ('"' + $path + '"')
}
function Refresh-Grid {
    foreach ($agent in $Agents) {
        $runtime = Get-AgentRuntime $agent
        $row = $script:Rows[$agent.Key]
        $row.Cells['Agent'].Value = $agent.Label
        $row.Cells['Branch'].Value = $runtime.Branch
        $row.Cells['State'].Value = $runtime.State
        $row.Cells['Task'].Value = $runtime.Task
        $row.Cells['Updated'].Value = $runtime.Updated
        $row.Cells['Start'].Value = 'Start'
        $row.Cells['Stop'].Value = 'Stop'
        $row.Cells['Update'].Value = 'Update'
        $row.Cells['Logs'].Value = 'Logs'
        $row.Cells['Start'].ReadOnly = [bool]($runtime.Process -or -not $runtime.Installed -or $runtime.Branch -ne $agent.Branch)
        $row.Cells['Stop'].ReadOnly = [bool](-not $runtime.Process -or -not $runtime.Installed)
        $row.Cells['Update'].ReadOnly = [bool]($runtime.Process -or -not $runtime.Installed -or $runtime.Branch -ne $agent.Branch)
        $row.DefaultCellStyle.BackColor = if ($runtime.State -eq 'PROCESSING') { [System.Drawing.Color]::FromArgb(226,242,232) } elseif ($runtime.State -match 'ERROR|MISMATCH|REQUIRED') { [System.Drawing.Color]::FromArgb(252,232,232) } else { [System.Drawing.Color]::White }
        $row.Cells['State'].ToolTipText = $runtime.Error
        $row.Cells['Task'].ToolTipText = $runtime.Error
    }
    $active = 0
    $installed = 0
    foreach ($agent in $Agents) {
        $runtime = Get-AgentRuntime $agent
        if ($runtime.Installed) { $installed++ }
        if ($runtime.State -eq 'PROCESSING') { $active++ }
    }
    $summaryLabel.Text = "Installed: $installed / 7    |    Actively researching: $active    |    LIVE"
    $lastRefreshLabel.Text = 'Last refreshed: ' + (Get-Date -Format 'HH:mm:ss')
}
$form = New-Object System.Windows.Forms.Form
$form.Text = 'TradeFlow — Independent Gemma Control Centre'
$form.StartPosition = 'CenterScreen'
$form.Size = New-Object System.Drawing.Size(1180,650)
$form.MinimumSize = New-Object System.Drawing.Size(980,560)
$form.BackColor = [System.Drawing.Color]::FromArgb(246,248,250)
$form.Font = New-Object System.Drawing.Font('Segoe UI',9)
$form.AutoScaleMode = [System.Windows.Forms.AutoScaleMode]::Dpi

$header = New-Object System.Windows.Forms.Panel
$header.Dock = 'Top'
$header.Height = 86
$header.BackColor = [System.Drawing.Color]::FromArgb(28,42,58)
$form.Controls.Add($header)
$title = New-Object System.Windows.Forms.Label
$title.Text = 'TRADEFLOW  |  INDEPENDENT GEMMA CONTROL CENTRE'
$title.ForeColor = [System.Drawing.Color]::White
$title.Font = New-Object System.Drawing.Font('Segoe UI Semibold',15,[System.Drawing.FontStyle]::Bold)
$title.Location = New-Object System.Drawing.Point(22,12)
$title.AutoSize = $true
$header.Controls.Add($title)
$subtitle = New-Object System.Windows.Forms.Label
$subtitle.Text = 'Each specialist runs from its own Git branch and installation. Stop is graceful; the current research task is allowed to finish.'
$subtitle.ForeColor = [System.Drawing.Color]::FromArgb(225,232,239)
$subtitle.Location = New-Object System.Drawing.Point(24,51)
$subtitle.AutoSize = $true
$header.Controls.Add($subtitle)

$toolbar = New-Object System.Windows.Forms.FlowLayoutPanel
$toolbar.Dock = 'Top'
$toolbar.Height = 48
$toolbar.Padding = New-Object System.Windows.Forms.Padding(14,7,8,5)
$toolbar.BackColor = [System.Drawing.Color]::White
$toolbar.WrapContents = $false
$form.Controls.Add($toolbar)
$refreshButton = New-Object System.Windows.Forms.Button
$refreshButton.Text = 'Refresh status'
$refreshButton.Width = 112
$refreshButton.Height = 30
$refreshButton.Add_Click({ Refresh-Grid })
$toolbar.Controls.Add($refreshButton)
$openRootButton = New-Object System.Windows.Forms.Button
$openRootButton.Text = 'Open logs folder'
$openRootButton.Width = 112
$openRootButton.Height = 30
$openRootButton.Add_Click({ Start-Process explorer.exe -ArgumentList ('"' + $LogRoot + '"') })
$toolbar.Controls.Add($openRootButton)
$summaryLabel = New-Object System.Windows.Forms.Label
$summaryLabel.AutoSize = $true
$summaryLabel.Margin = New-Object System.Windows.Forms.Padding(18,8,4,4)
$summaryLabel.ForeColor = [System.Drawing.Color]::FromArgb(45,58,72)
$toolbar.Controls.Add($summaryLabel)
$lastRefreshLabel = New-Object System.Windows.Forms.Label
$lastRefreshLabel.AutoSize = $true
$lastRefreshLabel.Margin = New-Object System.Windows.Forms.Padding(12,8,4,4)
$lastRefreshLabel.ForeColor = [System.Drawing.Color]::DimGray
$toolbar.Controls.Add($lastRefreshLabel)

$grid = New-Object System.Windows.Forms.DataGridView
$grid.Dock = 'Fill'
$grid.AllowUserToAddRows = $false
$grid.AllowUserToDeleteRows = $false
$grid.AllowUserToResizeRows = $false
$grid.ReadOnly = $false
$grid.MultiSelect = $false
$grid.RowHeadersVisible = $false
$grid.SelectionMode = 'FullRowSelect'
$grid.AutoSizeColumnsMode = 'Fill'
$grid.BackgroundColor = [System.Drawing.Color]::White
$grid.BorderStyle = 'FixedSingle'
$grid.EnableHeadersVisualStyles = $false
$grid.ColumnHeadersDefaultCellStyle.BackColor = [System.Drawing.Color]::FromArgb(232,237,242)
$grid.ColumnHeadersDefaultCellStyle.ForeColor = [System.Drawing.Color]::FromArgb(35,48,60)
$grid.ColumnHeadersHeight = 34
$grid.RowTemplate.Height = 42
$grid.Columns.Add('Agent','Gemma specialist') | Out-Null
$grid.Columns.Add('Branch','Git branch') | Out-Null
$grid.Columns.Add('State','Current state') | Out-Null
$grid.Columns.Add('Task','Current task') | Out-Null
$grid.Columns.Add('Updated','Updated') | Out-Null
foreach ($spec in @(@('Start','Start',55),@('Stop','Stop',55),@('Update','Update',62),@('Logs','Logs',52))) {
    $button = New-Object System.Windows.Forms.DataGridViewButtonColumn
    $button.Name = $spec[0]
    $button.HeaderText = $spec[1]
    $button.Text = $spec[1]
    $button.UseColumnTextForButtonValue = $true
    $button.FillWeight = [single]$spec[2]
    $grid.Columns.Add($button) | Out-Null
}
$grid.Columns['Agent'].FillWeight = 145
$grid.Columns['Branch'].FillWeight = 105
$grid.Columns['State'].FillWeight = 125
$grid.Columns['Task'].FillWeight = 190
$grid.Columns['Updated'].FillWeight = 62
foreach ($agent in $Agents) {
    $index = $grid.Rows.Add()
    $row = $grid.Rows[$index]
    $row.Tag = $agent.Key
    $script:Rows[$agent.Key] = $row
}
$grid.Add_CellContentClick({
    param($sender,$eventArgs)
    if ($eventArgs.RowIndex -lt 0) { return }
    $key = [string]$sender.Rows[$eventArgs.RowIndex].Tag
    $agent = $Agents | Where-Object { $_.Key -eq $key } | Select-Object -First 1
    if (-not $agent) { return }
    try {
        switch ($sender.Columns[$eventArgs.ColumnIndex].Name) {
            'Start' { Start-Agent $agent }
            'Stop' { Stop-Agent $agent }
            'Update' { Update-Agent $agent }
            'Logs' { Show-AgentLogs $agent }
        }
        Refresh-Grid
    } catch {
        [System.Windows.Forms.MessageBox]::Show($_.Exception.Message,'TradeFlow Gemma Control Centre',[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Warning) | Out-Null
    }
}.GetNewClosure())
$form.Controls.Add($grid)
$footer = New-Object System.Windows.Forms.Label
$footer.Dock = 'Bottom'
$footer.Height = 34
$footer.Padding = New-Object System.Windows.Forms.Padding(16,8,8,4)
$footer.Text = 'Stop after current task = finish the active queued batch, then stop claiming new work. Update is disabled while that Gemma is running.'
$footer.ForeColor = [System.Drawing.Color]::FromArgb(70,82,94)
$footer.BackColor = [System.Drawing.Color]::FromArgb(246,248,250)
$form.Controls.Add($footer)
# WinForms docking is evaluated in z-order. Keep the fill grid at the front
# so the top header, toolbar and bottom footer reserve their own space.
# This is the same fix used for the earlier Research Control Centre overlap.
$form.Controls.SetChildIndex($grid, 0)

$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 2500
$timer.Add_Tick({ Refresh-Grid })
$form.Add_Shown({ Refresh-Grid; $timer.Start() })
$form.Add_FormClosed({ $timer.Stop() })
[void]$form.ShowDialog()
try { $script:DashboardMutex.ReleaseMutex() } catch {}
$script:DashboardMutex.Dispose()
