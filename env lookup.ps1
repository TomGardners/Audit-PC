clear-host
 <#
 this doesn't work nicely unless it runs without error
 
 #>


function PC {
    $PCname = read-Host -prompt "PC hostname please"
    if (Test-Connection -ComputerName $PCname -Quiet -Count 1) {envlookup}
    else {read-host "$PCname is offline"
    }
    break
    }     

function envlookup 
{
    $Credential = Get-Credential
    write-host "

    ############## PC ENVS ##############
    "
    try 
    {
    Invoke-Command -ComputerName $PCname -Credential $Credential -ScriptBlock {[Environment]::GetEnvironmentVariables("Machine")}
        }
        Finally 
        {
        $error = read-host -prompt "use domain admin... press 'y' to try again"
        if ($error -eq 'y')
            {
            PC
            }
    }
break
}

Clear-Host
pc
