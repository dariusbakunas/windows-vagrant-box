[CmdletBinding()]
Param(
    [switch]$SkipCompact,
    [switch]$SkipPuppet,
    [switch]$SkipChef
)

Function ConfigureVariables{
    $script:baseUrl = 'https://raw.githubusercontent.com/dariusbakunas/windows-vagrant-box/develop'
    $script:sdeleteUrl = 'http://download.sysinternals.com/files/SDelete.zip'
    $script:setupComplete = 'SetupComplete.cmd'
    $script:chefBatch = 'chef.bat'

    $script:scriptPath = 'c:\Windows\Setup\Scripts'
    $script:sysprepPath = 'c:\Windows\System32\sysprep'

    if ((Get-WmiObject Win32_OperatingSystem).OSArchitecture -eq "64-bit") {
        # 64bit Windows
        $script:puppetBatch = 'puppet64.bat'
        $script:unattend = 'Autounattend64.xml'
        $script:zipUrl = 'http://downloads.sourceforge.net/sevenzip/7z920-x64.msi'
        $script:zipExec = 'C:\Program Files (x86)\7-Zip\7z.exe'
        $script:defragUrl = 'http://downloads.sourceforge.net/ultradefrag/ultradefrag-portable-6.0.2.bin.amd64.zip'
        $script:defragPath = './ultradefrag-portable-6.0.2.amd64'
    } else {
        # 32bit Windows
        $script:puppetBatch = 'puppet32.bat'
        $script:unattend = 'Autounattend.xml'
        $script:zipUrl = 'http://downloads.sourceforge.net/sevenzip/7z920.msi'
        $script:zipExec = 'C:\Program Files\7-Zip\7z.exe'
        $script:defragUrl = 'http://downloads.sourceforge.net/ultradefrag/ultradefrag-portable-6.0.2.bin.i386.zip'
        $script:defragPath = './ultradefrag-portable-6.0.2.i386'
    }
}

Function DownloadFile{
    param(
        [string]$url,
        [string]$destination,
        [string]$rename
    )

    $filename = $url.Substring($url.LastIndexOf("/") + 1)
    Write-Host "[*] Downloading $filename"

    if ($rename){
        (New-Object System.Net.WebClient).DownloadFile("$url", "$destination/$rename")
    }else{
        (New-Object System.Net.WebClient).DownloadFile("$url", "$destination/$filename")
    }
}

Function Compact{
    Write-Host "[*] Running compact"
    $updatePath = 'C:\Windows\SoftwareDistribution\Download'

    DownloadFile $zipUrl $env:temp '7z.msi'
    DownloadFile $defragUrl $env:temp 'ultradefrag.zip'
    DownloadFile $sdeleteUrl $env:temp

    Push-Location $env:temp

    Start-Process -FilePath 'msiexec.exe' -ArgumentList '/qb /i 7z.msi' -Wait
    Start-Process -FilePath $zipExec -ArgumentList 'x ultradefrag.zip' -Wait
    Start-Process -FilePath $zipExec -ArgumentList 'x SDelete.zip' -Wait

    # Cleanup updates
    Stop-Service wuauserv
    Remove-Item -path $updatePath -Force -Recurse -ErrorAction SilentlyContinue
    New-Item $updatePath -type directory > $null
    Start-Service wuauserv

    # Defragment drive
    Start-Process -FilePath "$defragPath/udefrag.exe" -ArgumentList '--optimize --repeat C:' -Wait

    # Run sdelete
    New-Item -Path HKCU:\Software -Name Sysinternals -Force > $null
    New-Item -Path HKCU:\Software\Sysinternals -Name SDelete -Force > $null
    New-ItemProperty -Path HKCU:\Software\Sysinternals\SDelete -Name EulaAccepted -PropertyType Dword -Value 1 -Force > $null

    Start-Process -FilePath "sdelete.exe" -ArgumentList '-q -z C:' -Wait

    Pop-Location
}

Function Sysprep{
    Write-Host "[*] Running sysprep"
    DownloadFile "$baseUrl/$unattend" $sysprepPath 'unattend.xml'
    Push-Location $sysprepPath

    Start-Process -FilePath "./sysprep.exe" -ArgumentList '/generalize /oobe /shutdown /unattend:unattend.xml'

    Pop-Location
}

Function Cleanup{
    Write-Host "[*] Running cleanup"
    Push-Location $env:temp
    Remove-Item -path $defragPath -Force -Recurse -ErrorAction SilentlyContinue
    Remove-Item -path '7z.msi' -ErrorAction SilentlyContinue
    Remove-Item -path 'sdelete.zip' -ErrorAction SilentlyContinue
    Remove-Item -path 'ultradefrag.zip' -ErrorAction SilentlyContinue
    Remove-Item -path 'sdelete.exe' -ErrorAction SilentlyContinue
    Remove-Item -path 'Eula.txt' -ErrorAction SilentlyContinue
    Pop-Location

    # delete itself
    Remove-Item $MyINvocation.InvocationName
}

ConfigureVariables

if (!(Test-Path $scriptPath)){
    New-Item $scriptPath -type directory > $null
}

if ($skipPuppet -eq $false){
    DownloadFile "$baseUrl/$puppetBatch" $scriptPath
}

if ($skipChef -eq $false){
    DownloadFile "$baseUrl/$chefBatch" $scriptPath
}

DownloadFile "$baseUrl/$setupComplete" $scriptPath

if ($skipCompact -eq $false){
    Compact
}

Cleanup

Sysprep
