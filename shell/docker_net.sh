#!/bin/bash
pkill docker 
iptables -t nat -F 
ifconfig docker0 down 
brctl delbr docker0 
/bin/systemctl restart  docker.service
service iptables save
/bin/systemctl restart iptables
