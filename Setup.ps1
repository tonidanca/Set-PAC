<#
.SYNOPSIS
  This script creates the Windows Scheduler task to use the Set-PAC.ps1 script.
.ROLE
  Toni D'Anca (toni.danca@eng.it)
#>

Set-ExecutionPolicy Unrestricted

$fileXML = "./$(Get-Random).xml"
Copy-Item $(Get-ChildItem ./Set-PAC.xml) $fileXML
$fileXML = Get-Item $fileXML
$xml = [xml](Get-Content $fileXML)

# Tag XML:
## Date
$dt = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"
$xml.Task.RegistrationInfo.Date = $dt

## UserId
$UserLogin = $env:USERDOMAIN + "\" + $env:USERNAME
$xml.Task.Principals.Principal.UserId = $UserLogin

## Arguments
$filePS1 = (Get-ChildItem ./Set-PAC.ps1).FullName
$PAC = Read-Host -Prompt "Enter the PAC file URL (e.g. https://serv.dom.com/proxy.pac)"
$Net = Read-Host -Prompt "Enter IP address and subnet mask (for example, 192.16.1.0/24)"
$processToStop = Read-Host -Prompt "Enter the name of the process to stop (e.g., the VPN process). Optional"
$Silent = "Y"
$Silent = (Read-Host -Prompt "Do you want the script to inform you with a popup when it is run? [Y]es or [N]o, inform me").ToUpper()
$str = "-WindowStyle Hidden -file $filePS1 -PAC $PAC -NET $Net"
if ($processToStop -ne "") {
  $str += " -processToStop $processToStop"
}
if ($Silent -eq "N" -or $Silent -eq "NO") {
  $str += " -Silent"
}
$xml.Task.Actions.Exec.Arguments = $str

$xml.Save($fileXML)

Register-ScheduledTask -Xml (Get-Content $fileXML | Out-String) -TaskName "Set-PAC test" -TaskPath "\Custom" -Force

Remove-Item $fileXML