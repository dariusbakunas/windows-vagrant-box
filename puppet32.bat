if not exist "C:\Windows\Temp\puppet.msi" (
    powershell -Command "(New-Object System.Net.WebClient).DownloadFile('http://downloads.puppetlabs.com/windows/puppet-3.7.3.msi', 'C:\Windows\Temp\puppet.msi')" <NUL
)

:: http://docs.puppetlabs.com/pe/latest/install_windows.html
msiexec /qn /i C:\Windows\Temp\puppet.msi /log C:\Windows\Temp\puppet.log

setx PATH "%PATH%;C:\Program Files\Puppet Labs\Puppet\bin" /m
