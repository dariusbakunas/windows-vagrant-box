# Disable all ethernet adapters except first one (which is NAT adapter used by vagrant)
$macTxtPath = 'c:\Windows\Setup\Scripts\mac.txt'
$mac = Get-Content $macTxtPath
$adapters = gwmi win32_networkadapter | where {$_.AdapterType -like 'ethernet*' -and $_.MACAddress -ne $mac}
$adapters  | foreach { $_.disable() }

$nlm = [Activator]::CreateInstance([Type]::GetTypeFromCLSID([Guid]"{DCB00C01-570F-4A9B-8D69-199FDBA5723B}"))
$connections = $nlm.getnetworkconnections()
$connections |foreach {
  if ($_.getnetwork().getcategory() -eq 0)
  {
      $_.getnetwork().setcategory(1)
  }
}

Enable-PSRemoting -SkipNetworkProfileCheck -Force

winrm set winrm/config '@{MaxTimeoutms="1800000"}'
winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="512"}'
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'
winrm set winrm/config/client/auth '@{Basic="true"}'
sc.exe config winrm start= auto

# Enable remote desktop
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -name "fDenyTSConnections" -Value 0
netsh advfirewall firewall set rule group="remote desktop" new enable=Yes

# $adapters | foreach { $_.enable() }