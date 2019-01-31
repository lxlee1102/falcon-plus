#!/bin/bash

DB_PWD=test123456


stop_all() {
	docker stop falcon-graph
	docker stop falcon-hbs
	docker stop falcon-judge
	docker stop falcon-transfer
	docker stop falcon-api
	docker stop falcon-nodata
	docker stop falcon-aggregator
	docker stop falcon-dashboard
	docker stop falcon-alarm
	docker stop falcon-gateway
	docker stop falcon-agent
	docker stop falcon-mail
}

rm_all() {
	stop_all
	docker rm falcon-graph
	docker rm falcon-hbs
	docker rm falcon-judge
	docker rm falcon-transfer
	docker rm falcon-api
	docker rm falcon-nodata
	docker rm falcon-aggregator
	docker rm falcon-dashboard
	docker rm falcon-alarm
	docker rm falcon-gateway
	docker rm falcon-agent
	docker rm falcon-mail
}


usage() {
	script=$0
	echo "Ver: 1.0.0 20190128
Usage:
    ${script#*/} [commands:[version]]

commands:
    graph hbs judge transfer nodata aggregator agent gateway api alarm
    all        all module start in order.
    "
}

var=$1
module=${var%:*}

case $module in 

 	"all")
		stop_all
	 ;;

 	"rm")
		rm_all
	;;

	"-h")
		usage
	;;

	 *) 
	 	docker stop falcon-$1
	 ;;
esac
