#!/bin/bash

# Load local config.
source /vagrant/local/config.sh

# Special deluge start scripts. Not sure why this is needed.
cp /vagrant/deluge/deluged.conf /etc/init/
cp /vagrant/deluge/deluge-web.conf /etc/init/

# Install needed software.
sudo apt-get update
apt-get -y install squid-deb-proxy-client
apt-get -y install openvpn resolvconf deluged deluge-web

# Configure deluge.
service deluge-web stop
service deluged stop
cp /vagrant/deluge/{core,web}.conf /home/vagrant/.config/deluge/
sed -i "s#{TORRENT_PORT}#${TORRENT_PORT}#g" /home/vagrant/.config/deluge/core.conf
service deluged start
service deluge-web restart

# Bring up the firewall.
apt-get -yd install iptables-persistent

/vagrant/vagrant/firewall.sh

echo "iptables-persistent iptables-persistent/autosave_v4 boolean true" | debconf-set-selections
echo "iptables-persistent iptables-persistent/autosave_v6 boolean true" | debconf-set-selections
apt-get -y install iptables-persistent

# Configure and connect to the VPN.
cp /vagrant/providers/${VPN_PROVIDER}/* /etc/openvpn/
cp /vagrant/local/openvpn.key /etc/openvpn/
openvpn --config /etc/openvpn/openvpn.conf --daemon
