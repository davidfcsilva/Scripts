#!/bin/bash
for host in `cat serverlist2.txt`;
do
ip="$(host $host|awk '{print $4}')"
echo "$host as the ip $ip"
ssh-keyscan -H $host >> /home/dsilva/.ssh/known_hosts
ssh-keyscan -H $ip >> /home/dsilva/.ssh/known_hosts
echo "$host done"
done
