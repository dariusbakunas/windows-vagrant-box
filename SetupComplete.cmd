del /q /f c:\windows\system32\sysprep\unattend.xml
del /q /f c:\windows\panther\unattend.xml

pushd c:\Windows\Setup\Scripts

echo %PROCESSOR_ARCHITECTURE% | find /i "x86" > nul
if %errorlevel%==0 (
    :: 32bit Windows
    call puppet32.bat
) else (
    :: 64bit Windows
    call puppet64.bat
)

popd