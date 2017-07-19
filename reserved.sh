#!/bin/bash

# /etc/hosts

# /usr/local/hadoop/etc/hadoop/
masters
slaves
sed -i 
core-site.xml
hdfs-site.xml
yarn-site.xml

# stop-all.sh in other nodes before scp

scp /etc/hosts $1:/etc/hosts
scp core-site.xml hdfs-site.xml yarn-site.xml $1:/usr/local/hadoop/etc/hadoop/

# start-all.sh
