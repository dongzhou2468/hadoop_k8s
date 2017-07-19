#!/bin/bash

let node_count=$#/2
hostname=$HOSTNAME
echo $hostname, $node_count
if [ $hostname = $1 ];then
    echo "modifying host $hostname..."
    #2rd node
    sed "2 i$4    $3" /etc/hosts > /etc/test
    #other nodes
    i=3
    while [ $i -le $node_count ]
    do
	let j=$i*2
	eval ip="$"{$j}""
	let k=$j-1
	eval hn="$"{$k}""
        sed -i "$i i$ip    $hn" /etc/test
	let i++
    done

    sed -i "s/$hostname:50090/$3:50090/" /usr/local/hadoop/etc/hadoop/hdfs-site.xml
    #secondary namenode
    echo $3 > /usr/local/hadoop/etc/hadoop/masters
    #datanodes
    echo $3 > /usr/local/hadoop/etc/hadoop/slaves
    i=3
    while [ $i -le $node_count ]
    do
	let k=$i*2-1
	eval hn="$"{$k}""
    	echo $hn >> /usr/local/hadoop/etc/hadoop/slaves
	let i++
    done

elif [ $hostname = $3 ];then
    echo "modifying host $hostname..."
    sed "2 i$2    $1" /etc/hosts > /etc/test
    i=3
    while [ $i -le $node_count ]
    do
	let j=$i*2
	eval ip="$"{$j}""
	let k=$j-1
	eval hn="$"{$k}""
        sed -i "$i i$ip    $hn" /etc/test
	let i++
    done

    sed -i "s/$hostname/$1/" /usr/local/hadoop/etc/hadoop/core-site.xml
    sed -i "s/$hostname:50070/$1:50070/" /usr/local/hadoop/etc/hadoop/hdfs-site.xml
    sed -i "s/$hostname/$1/" /usr/local/hadoop/etc/hadoop/yarn-site.xml

else
    echo "modifying host $hostname..."
    sed "2 i$2    $1" /etc/hosts > /etc/test
    i=2
    while [ $i -le $node_count ]
    do
	let j=$i*2
	eval ip="$"{$j}""
	let k=$j-1
	eval hn="$"{$k}""
	if [ $hn != $hostname ]
	then
            sed -i "$i i$ip    $hn" /etc/test
	fi
	let i++
    done

    sed -i "s/$hostname/$1/" /usr/local/hadoop/etc/hadoop/core-site.xml
    sed -i "s/$hostname:50070/$1:50070/" /usr/local/hadoop/etc/hadoop/hdfs-site.xml
    sed -i "s/$hostname:50090/$3:50090/" /usr/local/hadoop/etc/hadoop/hdfs-site.xml
    sed -i "s/$hostname/$1/" /usr/local/hadoop/etc/hadoop/yarn-site.xml

fi

cat /etc/test > /etc/hosts
rm /etc/test
echo "configure modified"

rm -rf /tmp/hadoop-root/dfs/*
echo "temp removed"

if [ $hostname = $1 ];then

    /usr/local/hadoop/bin/hdfs namenode -format
    /usr/local/hadoop/sbin/start-all.sh
fi
