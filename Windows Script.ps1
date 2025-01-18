if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))  
{  
  $arguments = "& '" +$myinvocation.mycommand.definition + "'"
  #Start-Process wt.exe '-p "Windows PowerShell"' -Verb runAs -ArgumentList $arguments
  Start-Process -Verb RunAs powershell $arguments
  Break
}

Clear-Host

$getDay = Get-Date -Format "dddd"
$dayLower = $getDay.toLower()
Write-Host "`nThis may take some time... feel free to take a sip of water and enjoy this beautiful $dayLower"

Install-Module PSWindowsUpdate
Import-Module PSWindowsUpdate
Add-Type -AssemblyName PresentationCore,PresentationFramework

Checkpoint-Computer -Description "Jonathan's Windows Script"

Write-Host "`nRestore point created" -ForegroundColor Green

Write-Host "`nSearching for windows updates..."

Get-WindowsUpdate
Install-WindowsUpdate
Write-Host "`nWindows updates intalled" -ForegroundColor Green

Remove-Item 'C:\Windows\Temp\' -Recurse -Include *.* -ErrorAction Ignore
Remove-Item 'C:\Windows\Prefetch\*' -Recurse -ErrorAction Ignore
Remove-Item 'C:\Users\*\AppData\Local\Temp\*' -Recurse -ErrorAction Ignore
Write-Host "`nTemporary files deleted" -ForegroundColor Green

cleanmgr /sagerun:1 | out-Null
Write-Host "`nDisk cleanup finished" -ForegroundColor Green

sfc /scannow
DISM /Online /Cleanup-Image /CheckHealth
DISM /Online /Cleanup-Image /ScanHealth
DISM /Online /Cleanup-Image /RestoreHealth
Write-Host "`nFinished searching and solving corrupted files" -ForegroundColor Green

Optimize-Volume -DriveLetter C -ReTrim -ErrorAction Ignore
Optimize-Volume -DriveLetter C -Analyze -ErrorAction Ignore
Optimize-Volume -DriveLetter C -Defrag -ErrorAction Ignore
Optimize-Volume -DriveLetter C -SlabConsolidate -ErrorAction Ignore
Optimize-Volume -DriveLetter C -TierOptimize -ErrorAction Ignore
Write-Host "`nDisk optimization finished" -ForegroundColor Green

[System.Windows.MessageBox]::Show('The script was successfull!','Operation Finished',0,'Information')