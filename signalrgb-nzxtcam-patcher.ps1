# This script automates the process of allowing SignalRGB and NZXT CAM to run simultaneously.
# It patches files, edits registry entries, and creates a scheduled task for a seamless startup.

#region Global Variables
$sigRgbRegistryPath = "HKCU:\Software\WhirlwindFX\SignalRgb"
$startupRegistryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
$taskName = "SignalRGB-NZXTCAM-Startup"
$logFile = "$env:TEMP\SignalRGBxNZXTCAMPatcher.log"
#endregion

#region Helper Functions
function Write-Log ($message, $logType = "INFO") {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $logFile -Value "[$timestamp] [$logType] $message"
    Write-Host "[$logType] $message"
}
#endregion

Write-Log "Starting the SignalRGB and NZXT CAM Patcher script."

#region Step 1: Find SignalRGB Plugins Folder
Write-Log "Step 1: Finding SignalRGB plugins folder..."

try {
    $pluginsPath = Get-ChildItem -Path "$env:LOCALAPPDATA\VortxEngine" -Filter "app-*" |
        Sort-Object { [version]($_.Name -replace 'app-') } -Descending |
        Select-Object -First 1 |
        ForEach-Object { "$($_.FullName)\Signal-x64\Plugins\Nzxt" }

    if (-not $pluginsPath) {
        Write-Error ("Could not find SignalRGB installation folder.")
        exit
    }
    Write-Log "Found SignalRGB plugins path: $pluginsPath"
} catch {
    Write-Error ("An error occurred while searching for the SignalRGB folder: $($_)")
    exit
}
#endregion

#region Step 2: Patch Plugin Files
Write-Log "Step 2: Patching plugin files..."

$filesToPatch = @(
    "NZXT_Kraken_Elite.js",
    "NZXT_Kraken_Elite_V2_AIO.js",
    "Nzxt_Kraken_X3_AIO.js",
    "Nzxt_Kraken_Z3_AIO.js"
)

# Patching NZXT_Kraken_Elite.js
try {
    $filePath = Join-Path -Path $pluginsPath -ChildPath "NZXT_Kraken_Elite.js"
    if (Test-Path $filePath) {
        $content = Get-Content -Path $filePath -Raw
        $updatedContent = $content -replace "export function SupportsFanControl\(\){ return true; }", "export function SupportsFanControl(){ return false; }"
        $updatedContent | Set-Content $filePath
        Write-Log "Successfully patched: NZXT_Kraken_Elite.js"
    } else {
        Write-Log "File not found: NZXT_Kraken_Elite.js. Skipping."
    }
} catch {
    Write-Error ("An error occurred while patching NZXT_Kraken_Elite.js: $($_)")
}

# Patching NZXT_Kraken_Elite_V2_AIO.js
try {
    $filePath = Join-Path -Path $pluginsPath -ChildPath "NZXT_Kraken_Elite_V2_AIO.js"
    if (Test-Path $filePath) {
        $content = Get-Content -Path $filePath -Raw
        $updatedContent = $content -replace "export function SupportsFanControl\(\){ return true; }", "export function SupportsFanControl(){ return false; }"
        $updatedContent | Set-Content $filePath
        Write-Log "Successfully patched: NZXT_Kraken_Elite_V2_AIO.js"
    } else {
        Write-Log "File not found: NZXT_Kraken_Elite_V2_AIO.js. Skipping."
    }
} catch {
    Write-Error ("An error occurred while patching NZXT_Kraken_Elite_V2_AIO.js: $($_)")
}

# Patching Nzxt_Kraken_X3_AIO.js
try {
    $filePath = Join-Path -Path $pluginsPath -ChildPath "Nzxt_Kraken_X3_AIO.js"
    if (Test-Path $filePath) {
        $content = Get-Content -Path $filePath -Raw
        $updatedContent = $content -replace "export function SupportsFanControl\(\){ return true; }", "export function SupportsFanControl(){ return false; }"
        $updatedContent | Set-Content $filePath
        Write-Log "Successfully patched: Nzxt_Kraken_X3_AIO.js"
    } else {
        Write-Log "File not found: Nzxt_Kraken_X3_AIO.js. Skipping."
    }
} catch {
    Write-Error ("An error occurred while patching Nzxt_Kraken_X3_AIO.js: $($_)")
}

# Patching Nzxt_Kraken_Z3_AIO.js
try {
    $filePath = Join-Path -Path $pluginsPath -ChildPath "Nzxt_Kraken_Z3_AIO.js"
    if (Test-Path $filePath) {
        $content = Get-Content -Path $filePath -Raw
        $updatedContent = $content -replace "export function SupportsFanControl\(\){ return true; }", "export function SupportsFanControl(){ return false; }"
        $updatedContent | Set-Content $filePath
        Write-Log "Successfully patched: Nzxt_Kraken_Z3_AIO.js"
    } else {
        Write-Log "File not found: Nzxt_Kraken_Z3_AIO.js. Skipping."
    }
} catch {
    Write-Error ("An error occurred while patching Nzxt_Kraken_Z3_AIO.js: $($_)")
}
#endregion

#region Step 3: Edit SignalRGB Registry
Write-Log "Step 3: Editing SignalRGB registry entries..."

if (Test-Path $sigRgbRegistryPath) {
    try {
        Set-ItemProperty -Path $sigRgbRegistryPath -Name "StartupLaunch" -Value 0 -Type DWord
        Set-ItemProperty -Path $sigRgbRegistryPath -Name "autoclose_conflicts" -Value 0 -Type DWord
        Write-Log "Successfully set StartupLaunch and autoclose_conflicts to 0."
    } catch {
        Write-Error ("An error occurred while editing SignalRGB registry: $($_)")
    }
} else {
    Write-Log "SignalRGB registry path not found. Skipping."
}
#endregion

#region Step 4: Delete Autostart Registry Entries
Write-Log "Step 4: Deleting autostart registry entries..."

# Deleting SignalRgb autostart entry
try {
    $entryPath = Join-Path -Path $startupRegistryPath -ChildPath "SignalRgb"
    if (Test-Path $entryPath) {
        Remove-ItemProperty -Path $startupRegistryPath -Name "SignalRgb"
        Write-Log "Successfully deleted autostart registry entry for SignalRgb."
    } else {
        Write-Log "Autostart registry entry for SignalRgb not found. Skipping."
    }
} catch {
    Write-Error ("An error occurred while deleting autostart registry entry for SignalRgb: $($_)")
}

# Deleting NZXT.CAM autostart entry
try {
    $entryPath = Join-Path -Path $startupRegistryPath -ChildPath "NZXT.CAM"
    if (Test-Path $entryPath) {
        Remove-ItemProperty -Path $startupRegistryPath -Name "NZXT.CAM"
        Write-Log "Successfully deleted autostart registry entry for NZXT.CAM."
    } else {
        Write-Log "Autostart registry entry for NZXT.CAM not found. Skipping."
    }
} catch {
    Write-Error ("An error occurred while deleting autostart registry entry for NZXT.CAM: $($_)")
}
#endregion

#region Step 5: Create or Update Task Scheduler
Write-Log "Step 5: Creating scheduled task '$taskName'..."

try {
    # Delete existing task if it exists
    if (Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue) {
        Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
        Write-Log "Existing task '$taskName' found and removed."
    }

    # Define paths
    $signalRgbPath = "$env:LOCALAPPDATA\VortxEngine\SignalRgbLauncher.exe"
    $nzxtCamPath = "$env:PROGRAMFILES\NZXT CAM\NZXT CAM.exe"

    # Trigger: When user logs on
    $trigger = New-ScheduledTaskTrigger -AtLogOn

    # Actions: Start SignalRGB, wait 3 minutes, then start NZXT CAM
    $action1 = New-ScheduledTaskAction -Execute $signalRgbPath
    $action2 = New-ScheduledTaskAction -Execute "cmd.exe" -Argument "/c timeout /t 180 && ""$nzxtCamPath"""

    # Settings
    $settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -RunOnlyIfNetworkAvailable:$false
    $principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Highest

    # Register the task
    Register-ScheduledTask -TaskName $taskName -Action $action1, $action2 -Trigger $trigger -Settings $settings -Principal $principal -Description "Launches SignalRGB, waits 3 minutes, then launches NZXT CAM to prevent conflicts."
    Write-Log "Successfully created scheduled task '$taskName'."
} catch {
    Write-Error ("An error occurred while creating the scheduled task: $($_)")
}
#endregion

Write-Log "Script execution completed."
