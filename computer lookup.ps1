Clear-Host
<#
this is a PC lookup script, should give you all the information required for the asset database, only if the PC is switched on

change log:
1.8
changed the Hard drive and ram calculations to round to the closest gigabyte giving a nicer number
also added the full ramlook function number lookups

1.8.1
now added ram speed

1.8.2
added os build and condensed repeated varaibles using .
#>

#this keeps a hashtable for the ram lookup, i'm not sure if this can be seperated out but it seems to work like this so for now i'll keep it like this
#the output of the DDR ram type was giving me a nubmer between 19..26, instead of the actual ram number.. which sucks so this should make it a bit easier to use
function ramlook {
$hash = @{
    0="Unknown"
    1="Other"
    2="DRAM"
    3="Syncronous DRAM"
    4="cache DRAM"
    5="EDO"
    6="EDRAM"
    7="VRAM"
    8="SRAM"
    9="RAM"
    10="ROM"
    11="FLASH"
    12="EEPROM"
    13="FEPROM"
    14="EPROM"
    15="CDRAM"
    16="3DRAM"
    17="SDRAM -> https://en.wikipedia.org/wiki/Synchronous_dynamic_random-access_memory"
    18="SGRAM -> https://en.wikipedia.org/wiki/Synchronous_dynamic_random-access_memory#SGRAM"
    19="DDR2 RDRAM -> https://en.wikipedia.org/wiki/RDRAM"
    20="DDR"
    21="DDR2"
    22="DDR2 FB-DIMM -> https://en.wikipedia.org/wiki/Fully_Buffered_DIMM"
    24="DDR3"
    25="FBD2 -> https://en.wikipedia.org/wiki/Fully_Buffered_DIMM"
    26="DDR4"

}

Get-WmiObject -Class win32_physicalmemory -ComputerName $PCname -Credential $Credential  | Format-Table @{
Name="GB"; Expression={[math]::round($_.capacity/1GB, 2)}
},
@{LABEL='Memorytype';

EXPRESSION={
$hash.item([int]$_.SMBIOSMemoryType)}
}, speed
}

#this is the intro to the script, asks user for the host name and pings it to see if it's able to run the whole script, if it is online it will automatically continue
function testpc {
            $PCname = read-Host -prompt "PC hostname please"
            if (Test-Connection -ComputerName $PCname -Quiet -Count 1) {pclookuptable}
            else {write-host "$PCname is offline"
            }
            testpc
            }

#this is where the stuff happens, all the processing and required information is found here mostly using wmi object which isn't amazing, i would prefer to use psexec or cim-instance but i couldn't get those to work
function pclookuptable {

        $Credential = Get-Credential $PCname\administrator
        
        $BiosS = (Get-WmiObject -Class win32_bios -ComputerName $PCname -Credential $Credential).serialnumber
        $MoboM = Get-WmiObject -Class win32_baseboard -ComputerName $PCname -Credential $Credential | format-Table Product,Manufacturer
        $ProcN = (Get-WmiObject -Class Win32_Processor -ComputerName $PCname -Credential $Credential).name
        $RAMST = ramlook
        $HdS = Get-WmiObject -Class MSFT_PhysicalDisk -Namespace root\Microsoft\Windows\Storage -ComputerName $PCname -Credential $Credential | Format-Table @{Name="GB"; Expression={[math]::round($_.size/1GB, 2)}},friendlyname
        $MoboS = (Get-WmiObject -Class win32_baseboard -ComputerName $PCname -Credential $Credential).serialnumber
        $GPUN = (Get-WmiObject -Class Win32_VideoController -ComputerName $PCname -Credential $Credential).description
        $LogN = (Get-WmiObject -Class Win32_Process -ComputerName $PCname -Credential $Credential -Filter 'Name="explorer.exe"').
            GetOwner().
            User
        $Model = (Get-WmiObject -Class:Win32_ComputerSystem -ComputerName $PCname -Credential $Credential)
        $OStype = (get-wmiobject win32_operatingsystem -ComputerName $PCname -Credential $Credential)
        $Prnt = (Get-WMIObject Win32_Printer -ComputerName $PCname -Credential $Credential).Name
        $NetIDs = Get-WmiObject -Class "Win32_NetworkAdapterConfiguration" -ComputerName $PCName -Credential $Credential -Filter "IpEnabled = TRUE"
        
    #not working yet    $Drv = Get-PSDrive -ComputerName $PCname -Credential $Credential

        Write-Host _____________________________________________
        Write-Host ↓ $PCname ↓ Motherboard Serial number ↓
        $MoboS
        Write-Host _____________________________________________
        Write-Host ↓ $PCname ↓ CPU BIOS serialnumber ↓
        $BiosS
        Write-Host _____________________________________________
        Write-Host ↓ $PCname ↓ Motherboard make model ↓
        $MoboM
        Write-Host _____________________________________________
        Write-Host ↓ $PCname ↓ Computer Vendor model ↓
        $Model.Manufacturer
        $Model.Model
        Write-Host _____________________________________________
        Write-Host ↓ $PCname ↓ processor name ↓
        $ProcN
        Write-Host _____________________________________________
        Write-Host ↓ $PCname ↓ RAM size and type ↓
        Write-Host 0=unknown, 20=DDR, 21=DDR2, 22=DDR2, 24=DDR3, 26=DDR4
        $RAMST
        Write-Host _____________________________________________
        Write-Host ↓ $PCname ↓ Hard Drive '(Bytes)' ↓
        $HdS
        Write-Host _____________________________________________
        Write-Host ↓ $PCname ↓ Operating system ↓
        $OStype.caption
        Write-Host _____________________________________________
        Write-Host ↓ $PCname ↓ Graphics card name ↓
        $GPUN
        Write-Host _____________________________________________
        Write-Host ↓ $PCname ↓ logged on username ↓
        $LogN
        Write-Host _____________________________________________
        Write-Host ↓ $PCname ↓ os type ↓ version
        $OStype.OSArchitecture
        $OStype.version
        $OStype.BuildNumber
        Write-Host _____________________________________________
        Write-Host ↓ $PCname ↓ Printers ↓
        $Prnt
        Write-Host _____________________________________________
        Write-Host ↓ $PCname ↓ MACAddress ↓
        $NIDip = write-host "IPaddress" $NetIDs.IPAddress[0]
        $NIDmac = write-host "MAC" $NetIDs.MacAddress
        Write-Host _____________________________________________
        Write-Host                 $PCname   
        Write-Host                 
        read-host "press enter to go again"
        Clear-Host
        $choices = [System.Management.Automation.Host.ChoiceDescription[]] @("&Y","&N")
while ( $true ) {testpc}

    $choice = $Host.UI.PromptForChoice("Repeat the script?","",$choices,0)
      if ( $choice -ne 0 ) {
      break
      }
      }


testpc