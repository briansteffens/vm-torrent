vm-torrent
===========

This is a set of configuration files to quickly build a VPN-only virtual machine
for torrents. It will use Vagrant and VirtualBox to provision an Ubuntu virtual
machine, OpenVPN to encrypt traffic, iptables to force traffic through the VPN,
and Deluge to download torrents. Deluge has a web UI, which is accessible
through any browser by going to `http://localhost:8112/` (once the VM is up).


Prerequisites and download
==========================

Git is used to download the project. VirtualBox and Vagrant are used to run it.
On Debian-based systems, something like the following should install everything
necessary:

```
$ sudo apt-get install git virtualbox vagrant
```

To download the project, run the following:

```
git clone https://github.com/briansteffens/vm-torrent
cd vm-torrent
```


Configuration
=============

Before the VM can be built, some configuration must be done. The following files
must be created:

* __local/config.sh__ - Controls how the VM is built.
* __local/login.conf__ - Your OpenVPN credentials.

An example `config.sh` file is included. Copy and edit it with the
following:

```
$ cp local/config.sh.example local/config.sh
$ nano local/config.sh
```

An example `login.conf` file is also included. Copy and edit it with
the following:

```
$ cp local/login.conf.example local/login.conf
$ nano local/login.conf
```

Building the VM
===============

Now that everything is configured, we can try to build the VM. Make sure you're
in the root of the git repository (probably the folder
`vm-torrent/`) and run:

```
$ vagrant up
```

If all goes well (and it probably won't) you should be able to access the Deluge client with a web browser by visiting `http://localhost:8112/`.
