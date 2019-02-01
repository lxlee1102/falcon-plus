#!/bin/bash

for d in $* 
do
	echo -n -e "$d\t:\t"
	docker inspect --format '{{.NetworkSettings.IPAddress}}' $d
done
