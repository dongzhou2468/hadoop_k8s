#!/bin/bash

#pods=`sudo kubectl get pods | grep $1 | sed 's/\(\w\+-\w\+-\w\+\)[^$]*/\1/'`
pods=`sudo kubectl get pods | grep hadoop-service- | sed 's/\(\w\+-\w\+-\w\+-\w\+\)[^$]*/\1/'`

arr=(${pods// /})
pod_count=${#arr[@]}
i=0
j=1
while [ $i -lt $pod_count ]
do
  eval pod$i=${arr[$i]}
  eval tmp="$"pod$i""
  if [[ $tmp == hadoop-service-master* ]];then
    ip0=`sudo kubectl describe pod $tmp | grep IP | sed "s/IP:\s\+\([^.]*\)/\1/"`
    node0=`sudo kubectl describe pod $tmp | grep Node | sed "s|Node:\s\+\([^/]*\)/[^/]*|\1|"`
    param[0]=$tmp
    param[1]=$ip0
  else
    eval ip$j=`sudo kubectl describe pod $tmp | grep IP | sed "s/IP:\s\+\([^.]*\)/\1/"`
    eval node$j=`sudo kubectl describe pod $tmp | grep Node | sed "s|Node:\s\+\([^/]*\)/[^/]*|\1|"`
    eval param[$j*2]=$tmp
    eval param[$j*2+1]="$"ip$j""
    let j++
  fi
  let i++
done

:<<!
ip_temp=$ip0
node_temp=$node0
pod_temp=$pod0
i=0
while [ $i -lt $pod_count ]
do
  eval current_node="$"node$i""
  if [ $current_node == "10.0.0.21" ]
  then
    eval ip0="$"ip$i""
    eval ip$i=$ip_temp
    eval node0="$"node$i""
    eval node$i=$node_temp
    eval pod0="$"pod$i""
    eval pod$i=$pod_temp 
    let i=i+3
  fi
  let i++
done
!

#echo ${param[@]}
#echo ${#param[*]}

while [ $i -gt 0 ]
do
  let i--
  eval echo "$"pod$i"", "$"ip$i"", "$"node$i""
  eval ssh -t -p 2122 root@"$"ip$i"" "/etc/start_cluster_node.sh "${param[@]}""
done
   
#./array_test.sh "${param[@]}"
#eval ssh -t -p 2122 root@$ip2 "/etc/test.sh "${param[@]}""

#ssh -t -p 2122 root@$ip2 "/etc/start_cluster.sh $pod0 $pod1 $pod2 $ip0 $ip1 $ip2"
#ssh -t -p 2122 root@$ip1 "/etc/start_cluster.sh $pod0 $pod1 $pod2 $ip0 $ip1 $ip2"
#ssh -t -p 2122 root@$ip0 "/etc/start_cluster.sh $pod0 $pod1 $pod2 $ip0 $ip1 $ip2"
