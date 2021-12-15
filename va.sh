#!/bin/sh
apt install hostapd isc-dhcp-server
wget https://github.com/arthurfelixgr/hostapd-mx-power/raw/main/hostapd.conf.gz
mv hostapd.conf.gz /etc/hostapd/
gunzip /etc/hostapd/hostapd.conf.gz
sed 's;^#DAEMON_CONF="";DAEMON_CONF="/etc/hostapd/hostapd.conf";' /etc/default/hostapd > hostapd
rm /etc/default/hostapd 
mv hostapd /etc/default/
sed 's;\(INTERFACES.*=\).*;\1"wlan0";' /etc/default/isc-dhcp-server > isc-dhcp-server
rm /etc/default/isc-dhcp-server 
mv isc-dhcp-server /etc/default/
sed -e 's/^option domain/#option domain/' -e 's/^default-lease/#default-lease/' -e 's/^max-lease/#max-lease/' /etc/dhcp/dhcpd.conf > dhcpd.conf
printf "subnet 10.10.0.0 netmask 255.255.255.0 {\n  range 10.10.0.2 10.10.0.251;\n  option domain-name-servers 8.8.8.8, 8.8.4.4;\n  option routers 10.10.0.1;\n}\n" >> dhcpd.conf
rm /etc/dhcp/dhcpd.conf 
mv dhcpd.conf /etc/dhcp/
printf "auto wlan0\niface wlan0 inet static\naddress 10.10.0.1\nnetmask 255.255.255.0\n" >> /etc/network/interfaces
echo net.ipv4.ip_forward=1 >> /etc/sysctl.conf
/usr/sbin/iptables -t nat -A POSTROUTING -s 10.10.0.0/16 -o eth0 -j MASQUERADE
apt install iptables-persistent
apt purge connman
exit
# fonte: https://arnab-k.medium.com/ubuntu-how-to-setup-a-wi-fi-hotspot-access-point-mode-192cbb2eeb90


