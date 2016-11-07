#Installer script for Alienvault USM Anywhere NXLog integration
#Tested with Powershell v2 - v5.
#Author: Scott Mace Nov.2016
#Version 3 
#Must allow script execution in powershell, and must be run as administrator
#Note that webclient commented out stuff is testing potential autodownloading of configs.
# Set Some variables
[CmdletBinding()]
Param(
  [Parameter(Mandatory=$True,Position=1)]
   [System.Net.IPAddress]$SensorIP
)
$nxpath = "C:\Program Files (x86)\nxlog\conf\"
$nxcfg = "nxlog.conf"
$sypath = "C:\Sysmon"
$sycfg = "sysmon_config.xml"
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
#Test if files and script are in the same directory
If (-Not (Test-Path "$scriptPath\$nxcfg") -or (-Not(Test-Path "$scriptPath\$sycfg")) -or (-Not(Test-Path "$scriptPath\Sysmon.zip"))) {
Write-Host "You must run this script from within a folder containing the supplied $nxcfg $sycfg and Sysmon.zip"
exit 1 
} Else {
#Function to expand file in PSv2
function Expand-ZIPFile($file, $destination)
{
$shell = new-object -com shell.application
$zip = $shell.NameSpace($file)
foreach($item in $zip.items())
{
$shell.Namespace($destination).copyhere($item, 0x14)
}
}
#$WebClient = New-Object System.Net.WebClient
Write-Host "Download the latest version of NxLog to this folder: $scriptPath.  Your default browser will now connect you"
Start 'https://nxlog.co/products/nxlog-community-edition/download'
Write-Host "Press any key to continue ..."
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
Start-Process (Resolve-Path "$scriptPath\nxlog*.msi") -ArgumentList /quiet -Wait
#$WebClient.DownloadFile("http://<someurl>/nxlog.conf","$scriptPath")
If (Test-Path $nxpath\$nxcfg){
  Copy-Item "$nxpath\$nxcfg" "$nxpath\$nxcfg-$(get-date -f yyyyMMddhhmmss)"
  Copy-Item $scriptPath\$nxcfg "$nxpath\$nxcfg"
}Else{
 Copy-Item $scriptPath\$nxcfg "$nxpath\$nxcfg"
}
(Get-Content "$nxpath\$nxcfg") -replace '\[USMIPADDRESS\]', $sensorip | Set-Content $nxpath\$nxcfg
#Will install sysmon
 New-Item -ItemType Directory -Path C:\Sysmon -Force
 Expand-ZIPFile "$scriptpath\Sysmon.zip" -destination $sypath -Force
 #$WebClient.DownloadFile("http://<someurl>/sysmon_config.xml","$scriptPath")
If (Test-Path $sypath\$sycfg){
  Copy-Item "$sypath\$sycfg" "$sypath\$sycfg-$(get-date -f yyyyMMddhhmmss)"
  Copy-Item $scriptPath\$sycfg "$sypath\$sycfg"
}Else{
 Copy-Item $scriptPath\$sycfg "$sypath\$sycfg"
}
Start-Process -FilePath "$sypath\Sysmon.exe" -ArgumentList "-accepteula -h md5 -n -l -i $sypath\$sycfg"
#Let's start nxlog too
Start-Service -InputObject nxlog
#OK, let's enable winrm
Enable-PSRemoting –force
#Let's make sure we save the current TrustedHosts and add the USM to the list
$curValue = (get-item wsman:\localhost\Client\TrustedHosts).value 
IF([string]::IsNullOrEmpty($curValue) -or $curValue -contains "*") {         
    Set-Item wsman:\localhost\Client\TrustedHosts -value "$SensorIP"            
} else {            
    Set-Item wsman:\localhost\Client\TrustedHosts -value "$curValue, $SensorIP"            
} 
}    
}    
