# ============================================================
# NOVUS OSDCloud - DISM .NET Fix
# ============================================================

$scriptUrl = 'https://raw.githubusercontent.com/novusn/OSDCloud/main/DefaultOSDCloud.ps1'
$configPath = Join-Path $PSHOME 'powershell.exe.config'

# Prevent a second launch from repeating the bootstrap
if ($env:NOVUS_OSD_CHILD -ne '1') {

    try {
        Write-Host "Checking PowerShell .NET configuration..." -ForegroundColor Cyan

        if (Test-Path $configPath) {
            [xml]$xml = Get-Content $configPath -Raw
        }
        else {
            $xml = New-Object System.Xml.XmlDocument
            $xml.LoadXml('<configuration/>')
        }

        $runtime = $xml.SelectSingleNode('/configuration/runtime')

        if ($null -eq $runtime) {
            $runtime = $xml.CreateElement('runtime')
            [void]$xml.DocumentElement.AppendChild($runtime)
        }

        $setting = $runtime.SelectSingleNode('loadFromRemoteSources')

        if ($null -eq $setting) {
            $setting = $xml.CreateElement('loadFromRemoteSources')
            [void]$runtime.AppendChild($setting)
        }

        $setting.SetAttribute('enabled', 'true')
        $xml.Save($configPath)

        Write-Host ".NET configuration updated." -ForegroundColor Green

        # Download the central deployment script
        $localScript = 'X:\NOVUS-OSDCloud.ps1'

        Invoke-WebRequest -Uri $scriptUrl -OutFile $localScript -UseBasicParsing -ErrorAction Stop

        # Mark the new process as the deployment process
        $env:NOVUS_OSD_CHILD = '1'

        Write-Host "Launching NOVUS deployment PowerShell..." -ForegroundColor Yellow

        # Start another PowerShell window without closing this one
        $child = Start-Process `
            -FilePath (Join-Path $PSHOME 'powershell.exe') `
            -ArgumentList @(
                '-NoProfile',
                '-NoExit',
                '-ExecutionPolicy',
                'Bypass',
                '-File',
                $localScript
            ) `
            -PassThru

        Write-Host "Deployment PowerShell launched (PID $($child.Id))." -ForegroundColor Green
        Write-Host "This window is the bootstrap session."

        # Stop executing the deployment menu in this process.
        # This does not terminate the new PowerShell window.
        return
    }
    catch {
        Write-Host "NOVUS bootstrap failed:" -ForegroundColor Red
        Write-Host $_.Exception.ToString() -ForegroundColor Red
        Read-Host "Press Enter to continue"
        return
    }
}

# ============================================================
# SECOND POWERSHELL PROCESS CONTINUES HERE
# ============================================================

Write-Host "Validating DISM PowerShell module..." -ForegroundColor Cyan

try {
    Import-Module DISM -Force -ErrorAction Stop
    Get-Command Get-WindowsImage -ErrorAction Stop | Out-Null
    Write-Host "DISM PowerShell module loaded successfully." -ForegroundColor Green
}
catch {
    Write-Host "DISM PowerShell module failed:" -ForegroundColor Red
    Write-Host $_.Exception.ToString() -ForegroundColor Red
    Read-Host "Press Enter to continue"
    return
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
