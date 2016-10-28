#Installer script for Alienvault USM Anywhere NXLog integration
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
#$WebClient = New-Object System.Net.WebClient
Write-Host "Download the latest version of NxLog to this folder.  Your default browser will now connect you"
Start 'https://nxlog.co/products/nxlog-community-edition/download'
Write-Host "Press any key to continue ..."
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
Start-Process -FilePath "./nxlog*.msi" -ArgumentList /quiet -Wait 
#$WebClient.DownloadFile("http://10.60.50.60/nxlog.conf","C:\Program Files (x86)\nxlog\conf\nxlog.conf")
If (Test-Path $nxpath\$nxcfg){
  Copy-Item "$nxpath\$nxcfg" "$nxpath\$nxcfg-$(get-date -f yyyyMMddhhmmss)"
  Copy-Item $nxcfg "$nxpath\$nxcfg"
}Else{
 Copy-Item $nxcfg "$nxpath\$nxcfg"
}
(Get-Content "$nxpath\$nxcfg").replace('[USMIPADDRESS]', $sensorip) | Set-Content "$nxpath\$nxcfg"
#Will install sysmon
Expand-Archive Sysmon.zip $sypath -Force
If (Test-Path $sypath\$sycfg){
  Copy-Item "$sypath\$sycfg" "$sypath\$sycfg-$(get-date -f yyyyMMddhhmmss)"
  Copy-Item $sycfg "$sypath\$sycfg"
}Else{
 Copy-Item $sycfg "$sypath\$sycfg"
}
#$WebClient.DownloadFile("http://10.60.50.60/sysmon_config.xml","C:\Sysmon\sysmon_config.xml")
Start-Process -FilePath "$sypath\Sysmon.exe" -ArgumentList "-accepteula -h md5 -n -l -i $sypath\$sycfg"
#Let's start nxlog too
Start-Service -InputObject nxlog
#OK, let's enable winrm
Enable-PSRemoting –force
#Let's make sure we save the current TrustedHosts and add the USM to the list
$curValue = (get-item wsman:\localhost\Client\TrustedHosts).value 
IF([string]::IsNullOrWhiteSpace($curValue) -or $curValue -contains "*") {          
    Set-Item wsman:\localhost\Client\TrustedHosts -value "$SensorIP"            
} else {            
    Set-Item wsman:\localhost\Client\TrustedHosts -value "$curValue, $SensorIP"            
}     
