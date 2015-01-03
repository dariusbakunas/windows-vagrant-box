Enable-PSRemoting -SkipNetworkProfileCheck -Force

# winrm quickconfig -q
# winrm quickconfig -transport:http
winrm set winrm/config '@{MaxTimeoutms="1800000"}'
winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="512"}'
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'
winrm set winrm/config/client/auth '@{Basic="true"}'
set-service winrm -startuptype automatic
# netsh advfirewall firewall set rule group="Windows Remote Management" new enable=yes
#net stop winrm
#sc config winrm start= auto
#net start winrm

Stop-Transcript