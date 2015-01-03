# Disable all ethernet adapters except the one that is used by Vagrant
$mac = Get-Content 'c:\Windows\Setup\Scripts\mac.txt'
$adapters = gwmi Win32_NetworkAdapter | where {$_.AdapterType -like 'ethernet*' -and $_.MACAddress -ne $mac}
$adapters  | foreach { $_.disable() }

# Enable-PSRemoting -SkipNetworkProfileCheck -Force

winrm quickconfig -q
winrm set winrm/config '@{MaxTimeoutms="1800000"}'
winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="512"}'
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'
winrm set winrm/config/client/auth '@{Basic="true"}'
sc.exe config winrm start= auto

# Enable remote desktop
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -name 'fDenyTSConnections' -Value 0
netsh advfirewall firewall set rule group="remote desktop" new enable=Yes

# Show file extensions in Explorer
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -name 'HideFileExt' -Value 0 -Type DWord

# Zero Hibernation file
Set-ItemProperty -Path 'HKLM\System\CurrentControlSet\Control\Power' -name 'HibernateFileSizePercent' -Value 0 -Type DWord

# Disable Hibernation
Set-ItemProperty -Path 'HKLM\System\CurrentControlSet\Control\Power' -name 'HibernationEnabled' -Value 0 -Type DWord

# Disable vagrant user password expiration
Get-WmiObject Win32_UserAccount | where {$_.name -eq 'vagrant'} | foreach {$_.PasswordExpires = $False}

$puppet_batch = 'c:\Windows\Setup\Scripts\puppet.bat'
$chef_batch = 'c:\Windows\Setup\Scripts\chef.bat'

if (!(Test-Path $puppet_batch)){
    Start-Process "cmd.exe /c $puppet_batch"
}

if (!(Test-Path $chef_batch)){
    Start-Process "cmd.exe /c $chef_batch"
}

$adapters | foreach { $_.enable() }