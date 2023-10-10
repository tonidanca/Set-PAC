<#
.SYNOPSIS
  This script creates the Windows Scheduler task to use the Set-PAC.ps1 script.
.ROLE
  Toni D'Anca (toni.danca@eng.it)
#>

Set-ExecutionPolicy Unrestricted

$fileXML = Get-ChildItem ./Set-PAC.xml
$xml = [xml](Get-Content $fileXML)

$UserLogin = $env:USERDOMAIN + "\" + $env:USERNAME
$xml.Task.Principals.Principal.UserId = $UserLogin

$dt = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"
$xml.Task.RegistrationInfo.Date = $dt

$filePS1 = (Get-ChildItem ./Set-PAC.ps1).FullName
$PAC = Read-Host -Prompt "Enter the PAC file URL (e.g. https://serv.dom.com/proxy.pac)"
$Net = Read-Host -Prompt "Enter IP address and subnet mask (for example, 192.16.1.0/24)"
$processToStop = Read-Host -Prompt "Enter the name of the process to stop (e.g., the VPN process). Optional"
$str = "-file $filePS1 -PAC $PAC -NET $Net"
if ($processToStop -ne "") {
    $str += " -processToStop $processToStop"
}
$xml.Task.Actions.Exec.Arguments = $str

$xml.Save($fileXML)

Register-ScheduledTask -Xml (Get-Content $fileXML | Out-String) -TaskName "Set-PAC test" -TaskPath "\Custom" -Force
