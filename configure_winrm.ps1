Start-Transcript -path C:\output.txt -append
$nlm = [Activator]::CreateInstance([Type]::GetTypeFromCLSID([Guid]"{DCB00C01-570F-4A9B-8D69-199FDBA5723B}"))
$connections = $nlm.getnetworkconnections()
$connections |foreach {
  if ($_.getnetwork().getcategory() -eq 0)
  {
      $_.getnetwork().setcategory(1)
  }
}

winrm quickconfig -q
winrm quickconfig -transport:http
winrm set winrm/config @{MaxTimeoutms="1800000"}
winrm set winrm/config/winrs @{MaxMemoryPerShellMB="300"}
winrm set winrm/config/service @{AllowUnencrypted="true"}
winrm set winrm/config/service/auth @{Basic="true"}
winrm set winrm/config/client/auth @{Basic="true"}
winrm set winrm/config/listener?Address=*+Transport=HTTP @{Port="5985"}
netsh advfirewall firewall set rule group="Windows Remote Management" new enable=yes
netsh firewall add portopening TCP 5985 "Port 5985"
net stop winrm
sc config winrm start= auto
net start winrm

Stop-Transcript