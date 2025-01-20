#!/usr/bin/bash

mkdir -p /etc/iptables/

iptables -N COUNTRY-XX

iptables -F
for line in `cat IPRANGE.txt` ; do
    echo iptables -A COUNTRY-XX -s $line -j ACCEPT
    iptables -A COUNTRY-XX -s $line -j ACCEPT
done

iptables -A COUNTRY-XX -j DROP
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -j COUNTRY-XX

iptables-save > /etc/iptables/rules.v4
