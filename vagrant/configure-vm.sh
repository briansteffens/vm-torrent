#!/bin/bash

# Load local config.
source /vagrant/local/config.sh

# Special deluge start scripts. Not sure why this is needed.
cp /vagrant/deluge/deluged.conf /etc/init/
cp /vagrant/deluge/deluge-web.conf /etc/init/

# Prevent deluge from auto starting
echo 'manual' > /etc/init/deluged.override
echo 'manual' > /etc/init/deluge-web.override

# Install needed software.
sudo apt-get update
apt-get -y install squid-deb-proxy-client
apt-get -y install openvpn resolvconf deluged deluge-web

# Pre-start deluge (so it sets up .config/deluge)
service deluged start
service deluge-web start
sleep 1
service deluge-web stop
service deluged stop
sleep 1

# Copy config files
cp /vagrant/deluge/{core,web}.conf /home/vagrant/.config/deluge/
chown vagrant:vagrant /home/vagrant/.config/deluge/{core,web}.conf
chmod 666 /home/vagrant/.config/deluge/core.conf
chmod 640 /home/vagrant/.config/deluge/web.conf

# Configure VPN
cp /vagrant/providers/${VPN_PROVIDER}/* /etc/openvpn/
cp /vagrant/local/openvpn.key /etc/openvpn/

SCRIPT_UP="/vagrant/providers/${VPN_PROVIDER}/up"
if [ -f $SCRIPT_UP ]; then
    $SCRIPT_UP
fi

# Bring up the firewall.
apt-get -yd install iptables-persistent

/vagrant/vagrant/firewall.sh

echo "iptables-persistent iptables-persistent/autosave_v4 boolean true" | debconf-set-selections
echo "iptables-persistent iptables-persistent/autosave_v6 boolean true" | debconf-set-selections
apt-get -y install iptables-persistent

# Connect to VPN
openvpn --config /etc/openvpn/openvpn.conf --daemon
