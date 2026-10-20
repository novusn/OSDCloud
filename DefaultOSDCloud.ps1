# ============================================================
# NOVUS OSDCloud Deployment Menu
# Includes DISM .NET Assembly Loading Fix
# ============================================================

# ------------------------------------------------------------
# 1. FIX DISM .NET ASSEMBLY LOADING
# ------------------------------------------------------------

$configPath = Join-Path $PSHOME "powershell.exe.config"
$restartMarker = "NOVUS_OSD_CONFIG_RESTARTED"

try {
    Write-Host "Checking PowerShell .NET configuration..." -ForegroundColor Cyan

    if (Test-Path $configPath) {
        [xml]$configXml = Get-Content $configPath -Raw
    }
    else {
        $configXml = New-Object System.Xml.XmlDocument
        $configXml.LoadXml('<configuration/>')
    }

    $runtime = $configXml.SelectSingleNode("/configuration/runtime")

    if ($null -eq $runtime) {
        $runtime = $configXml.CreateElement("runtime")
        [void]$configXml.DocumentElement.AppendChild($runtime)
    }

    $remoteSources = $runtime.SelectSingleNode("loadFromRemoteSources")
    $configChanged = $false

    if ($null -eq $remoteSources) {
        $remoteSources = $configXml.CreateElement("loadFromRemoteSources")
        [void]$runtime.AppendChild($remoteSources)
        $configChanged = $true
    }

    if ($remoteSources.GetAttribute("enabled") -ne "true") {
        $remoteSources.SetAttribute("enabled", "true")
        $configChanged = $true
    }

    if ($configChanged -or -not (Test-Path $configPath)) {
        $configXml.Save($configPath)
        Write-Host ".NET configuration updated successfully." -ForegroundColor Green

        if ([Environment]::GetEnvironmentVariable($restartMarker, "Process") -eq "1") {
            throw "Configuration changed again after restarting PowerShell."
        }

        [Environment]::SetEnvironmentVariable($restartMarker, "1", "Process")

        Write-Host "Restarting PowerShell to apply changes..." -ForegroundColor Yellow

        # Relaunch the central script in a fresh PowerShell process.
        # The script must be invoked using a real script path.
        if ([string]::IsNullOrWhiteSpace($PSCommandPath)) {
            throw "Cannot restart automatically: no script path is available."
        }

        $powerShellExe = Join-Path $PSHOME "powershell.exe"

        & $powerShellExe -NoProfile -ExecutionPolicy Bypass -File $PSCommandPath

        exit $LASTEXITCODE
    }

    Write-Host ".NET remote assembly loading enabled." -ForegroundColor Green
}
catch {
    Write-Host "Failed to configure PowerShell .NET settings:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

# ------------------------------------------------------------
# 2. VALIDATE DISM POWERSHELL MODULE
# ------------------------------------------------------------

Write-Host "Checking DISM PowerShell module..." -ForegroundColor Cyan

try {
    Import-Module DISM -Force -ErrorAction Stop

    Get-Command Get-WindowsImage -ErrorAction Stop | Out-Null

    Write-Host "DISM PowerShell module loaded successfully." -ForegroundColor Green
}
catch {
    Write-Host "DISM PowerShell module failed to load." -ForegroundColor Red
    Write-Host $_.Exception.ToString() -ForegroundColor Red

    Read-Host "Press Enter to exit"
    exit 1
}

# ------------------------------------------------------------
# 3. START OSDCLOUD
# ------------------------------------------------------------

Write-Host  -ForegroundColor Cyan "Starting OSDCloud ..."
Start-Sleep -Seconds 5

#Change Display Resolution for Virtual Machine
if ((Get-MyComputerModel) -match 'Virtual') {
    Write-Host  -ForegroundColor Cyan "Setting Display Resolution to 1366x"
    Set-DisRes 1366
}
cls
Write-Host "===================== Main Menu ======================="
Write-Host "1: Zero-Touch WIN10 22H2 | en-gb | Education" -ForegroundColor Yellow
Write-Host "2: Zero-Touch WIN10 22H2 | en-gb | Enterprise" -ForegroundColor Green
Write-Host "3: Zero-Touch WIN11 24H2 | en-gb | Education" -ForegroundColor Yellow
Write-Host "4: Zero-Touch WIN11 24H2 | en-gb | Enterprise" -ForegroundColor Green
Write-Host "5: Zero-Touch WIN11 24H2 | en-gb | Professional" -ForegroundColor Magenta
Write-Host "6: Zero-Touch WIN11 25H2 | en-gb | Education" -ForegroundColor Yellow
Write-Host "7: Zero-Touch WIN11 25H2 | en-gb | Enterprise" -ForegroundColor Green
Write-Host "8: Zero-Touch WIN11 25H2 | en-gb | Professional" -ForegroundColor Magenta
Write-Host "9: OSDCloudGUI" -ForegroundColor Cyan
Write-Host "0: Exit" -ForegroundColor Red
$input = Read-Host "Please make a selection"
Write-Host  -ForegroundColor Yellow "Loading OSDCloud..."

#Make sure I have the latest OSD Content
Write-Host  -ForegroundColor Cyan "Updating OSD PowerShell Module"
Install-Module OSD -Force

Write-Host  -ForegroundColor Cyan "Importing PowerShell Modules"
Import-Module OSD -Force
$OSDModuleResource.StartOSDCloudGUI.BrandName = 'NOVUS'
$OSDModuleResource.StartOSDCloudGUI.BrandColor = '#F8AE45'
$OSDModuleResource.StartOSDCloudGUI.updateFirmware = $true

switch ($input)
{
    '1' { Start-OSDCloud -OSLanguage en-gb -OSName 'Windows 10 22H2 x64' -OSEdition Education -ZTI } 
    '2' { Start-OSDCloud -OSLanguage en-gb -OSName 'Windows 10 22H2 x64' -OSEdition Enterprise -ZTI } 
    '3' { Start-OSDCloud -OSLanguage en-gb -OSName 'Windows 11 24H2 x64' -OSEdition Education -ZTI }
    '4' { Start-OSDCloud -OSLanguage en-gb -OSName 'Windows 11 24H2 x64' -OSEdition Enterprise -ZTI } 
    '5' { Start-OSDCloud -OSLanguage en-gb -OSName 'Windows 11 24H2 x64' -OSEdition Professional -ZTI } 
    '6' { Start-OSDCloud -OSLanguage en-gb -OSName 'Windows 11 25H2 x64' -OSEdition Education -ZTI }
    '7' { Start-OSDCloud -OSLanguage en-gb -OSName 'Windows 11 25H2 x64' -OSEdition Enterprise -ZTI } 
    '8' { Start-OSDCloud -OSLanguage en-gb -OSName 'Windows 11 25H2 x64' -OSEdition Professional -ZTI } 
    '9' { Start-OSDCloudGUI	-Brand 'NOVUS'} 
    '0' { Exit }
}

#Restart from WinPE
Write-Host  -ForegroundColor Cyan "Restarting in 20 seconds!"
Start-Sleep -Seconds 20
wpeutil reboot
