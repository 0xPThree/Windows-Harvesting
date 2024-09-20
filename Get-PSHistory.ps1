Write-Host "[*] Getting PS History for all users."

    $users = Get-ChildItem -Path "C:\Users" -Directory

    Write-Output "[+] PowerShell Console History For All Users!"
    Write-Output "[+] Computer Name: $env:computername"
    Write-Output "[+] Users On Machine:"

    foreach ($user in $users) {
        Write-Output "    $user"

        $historyFile = Join-Path -Path $user.FullName -ChildPath "AppData\Roaming\Microsoft\Windows\PowerShell\PSReadline\ConsoleHost_history.txt"

        if (-not (Test-Path $historyFile)) {
            $errorActionPreference = "Continue"
            if ($SuppressErrors) {
                $errorActionPreference = "SilentlyContinue"
            }

            $psReadlineOptions = Get-PSReadlineOption -Scope "CurrentUser" -ErrorAction $errorActionPreference

            if ($psReadlineOptions -and $psReadlineOptions.HistorySavePath) {
                $historyFile = $psReadlineOptions.HistorySavePath
            }
        }

        if (Test-Path $historyFile) {
            $output += "User: $($user.Name)`n"
            $output += "Command History:`n"
            $output += Get-Content -Path $historyFile | Out-String
            $output += "`n"
        }
        else {
            $output += "User: $($user.Name)`n"
            $output += "No history found.`n`n"
        }
    }

    if ($OutputDirectory) {
        $hostname = $env:COMPUTERNAME
        $date = Get-Date -Format "ddMMMyyyy"
        $time = Get-Date -Format "HHmm"
        $filename = "${hostname}_${date}_${time}_PSHistory.txt"
        $filePath = Join-Path -Path $OutputDirectory -ChildPath $filename

        $output | Out-File -FilePath $filePath
        Write-Output "[+] Output saved to $filePath"
    }
    else {
        Write-Host $output
    }
