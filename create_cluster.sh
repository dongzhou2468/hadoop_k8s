#!/bin/bash

sudo kubectl create -f hadoop_master_rc.json

sed -i "s/: 2/: $1/" hadoop_slave_rc.json
sudo kubectl create -f hadoop_slave_rc.json
sed -i "s/: $1/: 2/" hadoop_slave_rc.json
