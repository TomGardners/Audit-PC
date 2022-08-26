#this checks if a PC has the specified updates, write them in $needed hot fixes and it'll search for them
clear-host

#variables
$NeededHotFixes = @('KB_______','KB_______','KB_______','KB_______')
$ComputerList = Get-Content "C:\Share\Powershell\refrence\hotfixcheck.txt"

#shows what it's searching for
Write-Host "searching for" $neededhotfixes
Read-Host "PC names are located in C:\Share\Powershell\refrence\hotfixcheck.txt
press enter to Start"

#authenticates - this must be domain admin
$cred = get-credential

#defines $PCname variable as item in computer list and runs the check
foreach ($PCname in $ComputerList) 
{
try{
$InstalledHotFixes = (Get-HotFix -ComputerName $PCname -Credential $cred).HotFixId
$NeededHotFixes | foreach {
  if ($InstalledHotFixes -contains $_) {Write-Host -fore Green "$PCName Hotfix $_ installed";} 
  else {Write-Host -fore Red "$PCName Hotfix $_ missing";}
        }
    }catch {"$PCname unavailable"}
}
