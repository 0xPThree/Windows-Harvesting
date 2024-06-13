<#
.DESCRIPTION
    Loops through all users in C:\Users and dumps roaming Notepad++ files. 
    Needless to say the script should to be run as a *high privileged user* to get as much information as possible.

.EXAMPLE
    PS E:\devop-scripts> powershell.exe -ExecutionPolicy Bypass .\notepad_dump.ps1
    [-] 'Public' doesn't have any roaming Notepad++ data.
    [+] Dumping Notepad++ data from 'user' to: C:\Users\void\AppData\Local\Temp\user\notepad++
    [+] Dumping Notepad++ data from 'user2' to: C:\Users\void\AppData\Local\Temp\user2\notepad++
    [-] 'user3' doesn't have any roaming Notepad++ data.
    [+] Dumping Notepad++ data from 'void' to: C:\Users\void\AppData\Local\Temp\void\notepad++

.NOTES
    Author: 0xPThree @ Exploit.se
    Date: 2024-06-13
    Version: 1.1
#>

try {
    $rootDirectory = "C:\Users"
    $destinationRootDirectory = "$ENV:Temp\"
    $found = $false

    Get-ChildItem $rootDirectory -Directory -ErrorAction SilentlyContinue | ForEach-Object {
        $username = $_.Name
        $backupDirectory = Join-Path -Path $_.FullName -ChildPath "AppData\Roaming\Notepad++\backup"

        if (Test-Path $backupDirectory) {
            $backupItemCount = @(Get-ChildItem -Path $backupDirectory -Recurse -File).Count
            if ($backupItemCount -gt 0) {
                $found = $true
                $destinationDirectory = Join-Path -Path $destinationRootDirectory -ChildPath "$username\notepad++"
                New-Item -ItemType Directory -Path $destinationDirectory -Force -ErrorAction SilentlyContinue | Out-Null
                Copy-Item -Path "$backupDirectory\*" -Destination $destinationDirectory -Recurse -Force
		Write-Host -NoNewline "[+] " -ForegroundColor DarkGreen;  Write-Host -NoNewline "Dumping Notepad++ data from '$username' to: $destinationDirectory"; Write-Host ""
            } else {
                Write-Host -NoNewline "[-] " -ForegroundColor DarkYellow;  Write-Host -NoNewline "'$username' doesn't have any roaming Notepad++ data."; Write-Host ""
            }
        } else {
            Write-Host -NoNewline "[-] " -ForegroundColor DarkYellow;  Write-Host -NoNewline "'$username' doesn't have any roaming Notepad++ data."; Write-Host ""
        }
    }
    if (-not $found) { Write-Host -NoNewline "[!] " -ForegroundColor DarkRed;  Write-Host -NoNewline "No backup directories found under $rootDirectory."; Write-Host "" }
} catch { Write-Host "An error occurred: $_" -ForegroundColor DarkRed }
