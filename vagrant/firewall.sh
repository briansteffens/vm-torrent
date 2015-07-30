#!/bin/bash

source /vagrant/local/config.sh

iptables -F

iptables -P OUTPUT ACCEPT
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT

iptables -A OUTPUT -o lo -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT

# SSH from NAT
iptables -A INPUT -i eth0 -s 10.0.2.2/32 -p tcp --dport 22 -j ACCEPT
iptables -A OUTPUT -o eth0 -d 10.0.2.2/32 -p tcp --sport 22 -j ACCEPT

# NAT (WAN) can be used for VPN.
iptables -A OUTPUT -o eth0 -p udp --dport 1194 -j ACCEPT
iptables -A INPUT -i eth0 -p udp --sport 1194 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# No local/LAN traffic over the VPN.
iptables -A INPUT -i tun0 -s 10.0.0.0/16 -j REJECT
iptables -A OUTPUT -o tun0 -d 10.0.0.0/16 -j REJECT
iptables -A INPUT -i tun0 -s 192.168.0.0/16 -j REJECT
iptables -A OUTPUT -o tun0 -d 192.168.0.0/16 -j REJECT

# Traffic over the VPN to other networks is fine if outgoing.
iptables -A OUTPUT -o tun0 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -i tun0 -m conntrack --ctstate ESTABLISHED -j ACCEPT

# Allow deluge-web UI from NAT
iptables -A INPUT -i eth0 -s 10.0.2.2/32 -p tcp --dport 8112 -j ACCEPT
iptables -A OUTPUT -o eth0 -d 10.0.2.2/32 -p tcp --sport 8112 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# BitTorrent traffic through VPN tunnel.
iptables -A INPUT -i tun0 -p tcp --dport $TORRENT_PORT -j ACCEPT
iptables -A INPUT -i tun0 -p udp --dport $TORRENT_PORT -j ACCEPT
iptables -A OUTPUT -o tun0 -p tcp --sport $TORRENT_PORT -j ACCEPT
iptables -A OUTPUT -o tun0 -p udp --sport $TORRENT_PORT -j ACCEPT

iptables -P OUTPUT DROP
iptables -P INPUT DROP
iptables -P FORWARD DROP
