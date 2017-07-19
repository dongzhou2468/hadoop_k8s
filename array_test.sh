#!/bin/bash

i=1
count=$#
while [ $i -le $count ]
do
    eval echo $i, "$"{$i}""
    let i++
done

echo $10
