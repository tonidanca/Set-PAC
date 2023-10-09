<#
.SYNOPSIS
  This script sets the PAC for a computer based on the network it is connected to.
.DESCRIPTION
  This script reads the input parameters -Net and -PAC (URL of the PAC file - Proxy Automatic Configuration Script).
  If the computer's IP address belongs to the network specified in the -Net parameter, then the script sets the PAC specified
  in the -PAC parameter and, if the -Process parameter is set, attempts to stop that process (for example, the VPN process).
  If the current IP of the PC does not belong to the specified network, it attempts to remove any PAC files that have been set.
.ROLE
  Toni D'Anca (toni.danca@eng.it)
.PARAMETER PAC
   is the URL of the FILE PAC
.PARAMETER Net
   is the network in which to set the PAC file (e.g. "192.168.0.0/22")
.PARAMETER Process
  is the name of the process to stop when setting the proxy
#>
param (
    [parameter(Mandatory = $true)]
    [string]$PAC,

    [parameter(Mandatory = $true)]
    [string]$Net,

    [string]$processToStop
)
function Convert-BitMaskToNetMask ($BitMask) {
    $NetMask = ""
    for ($i = 0; $i -lt 4; $i++) {
        if ($BitMask -ge 8) {
            $NetMask += "255."
            $BitMask -= 8
        }
        else {
            $NetMask += [math]::Pow(2, 8) - [math]::Pow(2, 8 - $BitMask)
            if ($i -lt 3) {
                $NetMask += "."
            }
            $BitMask = 0
        }
    }
    return $NetMask 
}

[System.Net.IPAddress]$Subnet = $Net.Split("/")[0]
[int]$BitMask = $net.Split("/")[1]
[System.Net.IPAddress]$SubnetMask = Convert-BitMaskToNetMask -BitMask $BitMask

$index = (
    Get-NetIPInterface -ConnectionState Connected -AddressFamily IPv4 | Where-Object {
        $_.InterfaceAlias -notlike "*Loopback*" -and $_.InterfaceAlias -notlike "*vpn*"
    }
).ifIndex
# Verify that the IP and set the proxy
if ($null -eq $index) {
    $msgTxt = "No active connection. No action can be executed."
}
else {
    [System.Net.IPAddress]$CurrentIP = (Get-NetIPAddress -AddressFamily IPv4 -ifIndex $index).IPAddress
    switch ($CurrentIP.count) {
        0 { $msgTxt = "No active connection. No action can be executed." }
        1 {
            $regKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings"
            $pacActual = (Get-ItemProperty -path $regKey).AutoConfigURL
            $msgTxt = "Current IP: $CurrentIP`n"
            $msgTxt += "Proxt Automatic Configuration Script"
            if ($null -eq $CurrentIP -or !($Subnet.Address -eq ($CurrentIP.Address -band $SubnetMask.Address))) {
                $msgTxt += " is not required for the $Net Network"
                if ($pacActual) {
                    Set-ItemProperty -path $regKey AutoConfigURL -Value "" -ErrorAction Stop
                    $msgTxt += ", but $pacActual was set up.`nIt has now been disabled."
                }
                else {
                    $msgTxt += " and was not set.`nNo action required."
                }
            }
            else {
                $msgTxt += " is required for the $Net Network"
                if ($pacActual -ne $PAC) {
                    Set-ItemProperty -path $regKey AutoConfigURL -Value $PAC
                    $msgTxt += ", but was not set.`nNow the value $PAC has been set."
                }
                else {
                    $msgTxt += " and the correct value was already set.`nNo action required."
                }
                if ($processToStop) {
                    try {
                        if (Get-Process -Name $processToStop -ErrorAction SilentlyContinue) {
                            Stop-Process -ProcessName $processToStop
                            $msgTxt += "`n`nStopped process " + $processToStop
                        }
                        else {
                            $msgTxt += "`n`nProcess " + $processToStop + " is not running."
                        }
                    }
                    catch {
                        $msgTxt += "`n`nImpossible to stop the $processToStop process."
                    }
                }
            }
        }
        Default { $msgTxt = "More than one active connection. Test the connection manually." }
    }
}

$wshell = New-Object -ComObject Wscript.Shell
$wshell.Popup("$msgTxt", 0, $MyInvocation.MyCommand.Name, 0x1)
$msgTxt