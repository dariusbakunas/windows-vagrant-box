Scripts for creating Windows Vagrant Box
========================================

Some bits are borrowed from https://github.com/joefitzgerald/packer-windows
which uses packer to atomate this process.

This approach allows to preinstall chosen software while booted in Windows audit mode.
All desktop icons and profile settings are preserved. Included answer files are
for Windows 7 Profesional 32/64bit.

After VM is packaged, it can later be provisioned using puppet or chef.

1. Prepare VirtualBox VM for windows, recommended settings:
    * RAM: 1024MB
    * VRAM: 128MB
    * CPU: 2x
    * Name: win7_vm
    * One network adapter

    Also make sure to set 1st network adapter to NAT.

2. Install Widnows 7 32/64bit (included answer files are for Professional edition), don't go past the Welcome Screen (IMPORTANT)
3. On Welcome Screen press CTRL+Shift+F3 to reboot in Audit Mode
4. Install updates, software etc.
5. Install Virtual Box Guest Additions
6. Remove any mounted cd/dvd drives
7. Inside the VM, launch command prompt with administrator privileges and run this command:

```bash
powershell -executionPolicy bypass -Command "(New-Object System.Net.WebClient).DownloadFile('https://raw.githubusercontent.com/dariusbakunas/windows-vagrant-box/master/prepare.ps1','C:\Windows\Temp\prepare.ps1');iex 'c:\Windows\Temp\prepare.ps1'"
```

* VM will shutdown when done. At this point it is ready to be packaged.
* In your host machine, download Vagrant and metadata.json (or checkout the git repo) files and package the vm:

```bash
% vagrant package --base win7_vm —output win7_base.box —vagrantfile _Vagrantfile —include metadata.json
```

'win7_vm' must match the VM name in VirtualBox.

* Import the box:

```bash
% vagrant box add win7_base win7_base.box
```

* Create the project and launch:

```bash
% vagrant init win7_base
% vagrant up
```

* Connect:

```bash
% vagrant rdp
```

If you want to disable local drive redirection, use windows remote desktop gui or supply
configuration.rdp (which can also be generated with windows rdp gui):

```% vagrant rdp -- /edit configuration.rdp```

* User: vagrant
* Password: vagrant
