Write-Host  -ForegroundColor Cyan "Starting OSDCloud ..."
Start-Sleep -Seconds 5

#Change Display Resolution for Virtual Machine
if ((Get-MyComputerModel) -match 'Virtual') {
    Write-Host  -ForegroundColor Cyan "Setting Display Resolution to 1366x"
    Set-DisRes 1366
}
cls
Write-Host "===================== Main Menu =======================" -ForegroundColor Yellow
Write-Host "1: Zero-Touch WIN10 20H2 | en-gb | Enterprise"-ForegroundColor Yellow
Write-Host "2: Zero-Touch WIN10 21H2 | en-gb | Education" -ForegroundColor Yellow
Write-Host "3: Zero-Touch WIN10 21H2 | en-gb | Enterprise" -ForegroundColor Yellow
Write-Host "4: Zero-Touch WIN11 21H2 | en-gb | Education" -ForegroundColor Yellow
Write-Host "5: Zero-Touch WIN11 21H2 | en-gb | Enterprise" -ForegroundColor Yellow
Write-Host "6: OSDCloudGUI | Testing" -ForegroundColor Yellow
Write-Host "7: Exit" -ForegroundColor Yellow
$input = Read-Host "Please make a selection"
Write-Host  -ForegroundColor Yellow "Loading OSDCloud..."

#Make sure I have the latest OSD Content
Write-Host  -ForegroundColor Cyan "Updating OSD PowerShell Module"
Install-Module OSD -Force

Write-Host  -ForegroundColor Cyan "Importing PowerShell Modules"
Import-Module OSD -Force

switch ($input)
{
    '1' { Start-OSDCloud -OSLanguage en-gb -OSName 'Windows 10 20H2 x64' -OSEdition Enterprise -ZTI } 
    '2' { Start-OSDCloud -OSLanguage en-gb -OSName 'Windows 10 21H2 x64' -OSEdition Education -ZTI } 
    '3' { Start-OSDCloud -OSLanguage en-gb -OSName 'Windows 10 21H2 x64' -OSEdition Enterprise -ZTI } 
    '4' { Start-OSDCloud -OSLanguage en-gb -OSName 'Windows 11 21H2 x64' -OSEdition Education -ZTI }
    '5' { Start-OSDCloud -OSLanguage en-gb -OSName 'Windows 11 21H2 x64' -OSEdition Enterprise -ZTI } 
    '6' { Start-OSDCloudGUI	} 
    '7' { Exit }
}

#Restart from WinPE
Write-Host  -ForegroundColor Cyan "Restarting in 20 seconds!"
Start-Sleep -Seconds 20
wpeutil reboot
