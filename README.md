Scripts for creating Windows Vagrant Box
========================================

Most scripts are borrowed from https://github.com/joefitzgerald/packer-windows
which uses packer to atomate this process.

1. Prepare VirtualBox VM for windows, recommended settings:
    * RAM: 1024MB
    * VRAM: 128MB
    * CPU: 2x
    * Name: win7_vm

    Also make sure to set 1st network adapter to NAT.

2. Install Widnows 7 32/64bit (included answer files are for Professional edition)
3. On Welcome Screen press CTRL+Shift+F3 to reboot in Audit Mode
4. Install updates, software etc.
5. Inside the VM, download prepare.bat and launch it with Administrator privileges
6. VM will shutdown when done. At this point it is ready to be packaged.
7. In your host machine, download Vagrant and metadata.json (or checkout the git repo) files and package the vm:

```bash
% vagrant package --base win7_vm —output win7_base.box —vagrantfile Vagrantfile —include metadata.json
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

User: vagrant
Password: vagrant
