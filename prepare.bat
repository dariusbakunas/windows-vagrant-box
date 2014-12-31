@echo off

set sysprep=sysprep.bat
set base_url=https://raw.githubusercontent.com/dariusbakunas/windows-vagrant-box/master
set setup_complete=SetupComplete.cmd

echo %PROCESSOR_ARCHITECTURE% | find /i "x86" > nul
if %errorlevel%==0 (
    :: 32bit Windows
    set puppet_batch=puppet32.bat
    set compact_batch=compact32.bat
    set unattend=Autounattend.xml
) else (
    :: 64bit Windows
    set puppet_batch=puppet64.bat
    set compact_batch=compact64.bat
    set unattend=Autounattend64.xml
)

:: download all necessary files
for %%x in (
        %puppet_batch%,
        %compact_batch%,
        %unattend%,
        %setup_complete%,
        %sysprep%
    ) do (
        if not exist "C:\Windows\Temp\%%x" (
           powershell -Command "(New-Object System.Net.WebClient).DownloadFile('%base_url%/%%x', 'C:\Windows\Temp\%%x')" <NUL
        )
    )

if not exist "C:\Windows\Setup\Scripts" (
    mkdir C:\Windows\Setup\Scripts
)

pushd c:\Windows\Temp

copy %setup_complete% c:\Windows\Setup\Scripts /y
copy %puppet_batch% c:\Windows\Setup\Scripts /y

copy %unattend% c:\Windows\System32\sysprep\unattend.xml /y
copy %sysprep% c:\Windows\System32\sysprep /y

call %compact_batch%

popd

pushd c:\Windows\System32\sysprep
call %sysprep%
popd
