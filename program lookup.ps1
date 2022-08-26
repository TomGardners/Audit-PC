<#
 Author Tomdav
 This will remotely lookup all installed programs on a PC
 
 #>
 function proglookup {
    $PCname = read-Host -prompt "PC hostname please"
    if (Test-Connection -ComputerName $PCname -Quiet -Count 1) {prog}
    else {write-host "$PCname is offline"
    }
    proglookup
    }     

function prog {
    $Credential = Get-Credential $PCname\administrator
    Get-WmiObject -Class Win32_Product -ComputerName $PCname -Credential $Credential | Format-Table Name
    }

Clear-Host
proglookup
