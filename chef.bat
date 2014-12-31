if not exist "C:\Windows\Temp\chef.msi" (
    powershell -Command "(New-Object System.Net.WebClient).DownloadFile('http://www.getchef.com/chef/install.msi', 'C:\Windows\Temp\chef.msi')" <NUL
)

msiexec /qn /i C:\Windows\Temp\chef.msi
