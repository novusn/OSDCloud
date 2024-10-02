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
Write-Host "3: Zero-Touch WIN11 23H2 | en-gb | Education" -ForegroundColor Yellow
Write-Host "4: Zero-Touch WIN11 23H2 | en-gb | Enterprise" -ForegroundColor Green
Write-Host "5: Zero-Touch WIN11 23H2 | en-gb | Professional" -ForegroundColor Magenta
Write-Host "6: OSDCloudGUI" -ForegroundColor Cyan
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
    '3' { Start-OSDCloud -OSLanguage en-gb -OSName 'Windows 11 23H2 x64' -OSEdition Education -ZTI }
    '4' { Start-OSDCloud -OSLanguage en-gb -OSName 'Windows 11 23H2 x64' -OSEdition Enterprise -ZTI } 
    '5' { Start-OSDCloud -OSLanguage en-gb -OSName 'Windows 11 23H2 x64' -OSEdition Professional -ZTI } 
    '6' { Start-OSDCloudGUI	-Brand 'NOVUS'} 
    '0' { Exit }
}

#Run Local Autopilot Registration Script
#Define the possible folder paths
#$Path1 = "D:\OSDCloud\NOVUS"
#$Path2 = "E:\OSDCloud\NOVUS"

#Check if either folder exists
#if (Test-Path -Path $Path1) {
#    $FolderPath = $Path1
#} elseif (Test-Path -Path $Path2) {
#    $FolderPath = $Path2
#} else {
#    Write-Host "Neither directory exists: $Path1 or $Path2"
#    exit 1
#}

#Directory exists, proceed with the script
#Write-Host "Directory exists: $FolderPath"

#Prompt for the computer name
#$OSDComputerName = Read-Host "Please specify the computer name"

#Prompt for the GroupTag
#$Tag = Read-Host "Please specify the GroupTag"

#Define the script path
#$ScriptPath = "$FolderPath\AutopilotRegistration.ps1"

#Check if the script exists and run it
#if (Test-Path -Path $ScriptPath) {
#    Write-Host "Running AutopilotRegistration.ps1 script..."

    #Pass the variables as parameters to the script
#    & $ScriptPath -OSDComputerName $OSDComputerName -Tag $Tag
#} else {
#    Write-Error "Script not found: $ScriptPath"
#}

#Restart from WinPE
Write-Host  -ForegroundColor Cyan "Restarting in 20 seconds!"
Start-Sleep -Seconds 20
wpeutil reboot
