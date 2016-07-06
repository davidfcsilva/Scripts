#!/bin/sh

iptables -t nat -A PREROUTING -p tcp --dport 80 -j DNAT --to-destination 192.168.12.77:80
iptables -t nat -A PREROUTING -s 10.38.0.0/24 -p tcp --dport 81 -j DNAT --to-destination 10.21.5.66:80

iptables -t nat -A POSTROUTING -p tcp -d 192.168.12.77 --dport 80 -j SNAT --to-source 192.168.12.87
iptables -t nat -A POSTROUTING -p tcp -d 10.21.5.66 --dport 81 -j SNAT --to-source 10.31.65.111
