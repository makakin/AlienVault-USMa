Steps to use:
Download all files to system.

Make sure Sysmon.exe, nxlog.conf, and inst-nxlog.ps1 exist in the extracted folder. It is important to use the included nxlog.conf file, the script relies on the text [USMIPADDRESS] to be in the file.

Download the latest version of nxlog, and save it to the extracted folder from the previous steps.

Run powershell as admin. (right-click powershell icon, and select run as Administrator)

Enable scripts in powershell by issuing the command "Set-ExecutionPolicy Unrestricted"

Type cd \<location of extracted folder\>

Run the script: ".\inst-nxlog.ps1"

When prompted, input the ip address of the USM anywhere sensor.

Verify the services sysmon, and nxlog are installed and running.

Verify winrm is enabled while in powershell: "Get-ChildItem WSMan:\localhost\Listener" If there is no output, it is not running.
