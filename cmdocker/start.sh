#!/bin/bash

DB_PWD=test123456

start_graph() {
	docker run -itd --name falcon-$1 \
		--link=falcon-mysql:db.falcon \
		-p 6070:6070 \
		-p 6071:6071 \
		-e MYSQL_PORT=root:$DB_PWD@tcp\(db.falcon:3306\) \
		-e GRAPH_CLUSTER="\"g0\": \"127.0.0.1:6070\"" \
		-v /home/work/open-falcon/data:/open-falcon/graph/data \
		-v /home/work/open-falcon/logs:/open-falcon/logs \
		falcon-$1

	docker ps -f name=$1

	docker exec falcon-$1 ./falconctl start
	docker exec falcon-$1 ps aux
}

start_hbs() {
	docker run -itd --name falcon-$1 \
		--link=falcon-mysql:db.falcon \
		-p 6030:6030 \
		-p 6031:6031 \
		-e MYSQL_PORT=root:$DB_PWD@tcp\(db.falcon:3306\) \
		-v /home/work/open-falcon/logs:/open-falcon/logs \
		falcon-$1

	docker ps -f name=$1

	docker exec falcon-$1 ./falconctl start
	docker exec falcon-$1 ps aux
}


start_judge() {
	docker run -itd --name falcon-$1 \
		--link=falcon-hbs:hbs.falcon \
		--link=falcon-redis:redis.falcon \
		-p 6080:6080 \
		-p 6081:6081 \
		-e HBS_PORT=hbs.falcon:6030 \
		-e REDIS_PORT=redis.falcon:6379  \
		-v /home/work/open-falcon/logs:/open-falcon/logs \
		falcon-$1

	docker ps -f name=$1

	docker exec falcon-$1 ./falconctl start
	docker exec falcon-$1 ps aux
}


start_transfer() {
	docker run -itd --name falcon-$1 \
		--link=falcon-mysql:db.falcon \
		--link=falcon-graph:g01.falcon \
		--link=falcon-judge:j01.falcon \
		-p 6060:6060 \
		-p 8433:8433 \
		-e MYSQL_PORT=root:$DB_PWD@tcp\(db.falcon:3306\) \
		-e GRAPH_CLUSTER="\"g01\": \"g01.falcon:6070\"" \
		-e JUDGE_CLUSTER="\"j01\": \"j01.falcon:6080\"" \
		-v /home/work/open-falcon/logs:/open-falcon/logs \
		falcon-$1

	docker ps -f name=$1

	docker exec falcon-$1 ./falconctl start
	docker exec falcon-$1 ps aux
}


start_api() {
	## run falcon-api container
	docker run -itd --name falcon-$1 \
		--link=falcon-mysql:db.falcon \
		--link=falcon-graph:g01.falcon \
		-p 8080:8080 \
		-e MYSQL_PORT=root:$DB_PWD@tcp\(db.falcon:3306\) \
		-e GRAPH_CLUSTER="\"g01\": \"g01.falcon:6070\"" \
		-v /home/work/open-falcon/logs:/open-falcon/logs \
		falcon-$1

	docker ps -f name=$1

	docker exec falcon-$1 ./falconctl start
	docker exec falcon-$1 ps aux
}

start_nodata() {
	docker run -itd --name falcon-$1 \
		--link=falcon-mysql:db.falcon \
		--link=falcon-transfer:transfer.falcon \
		--link=falcon-api:api.falcon \
		-p 6090:6090 \
		-e MYSQL_PORT=root:$DB_PWD@tcp\(db.falcon:3306\) \
		-e PLUS_API=http:\\/\\/api.falcon:8080 \
		-e TRANSFER_PORT=transfer.falcon:6060 \
		-v /home/work/open-falcon/logs:/open-falcon/logs \
		falcon-$1

	docker ps -f name=$1

	docker exec falcon-$1 ./falconctl start
	docker exec falcon-$1 ps aux
}


start_aggregator() {
	docker run -itd --name falcon-$1 \
		--link=falcon-mysql:db.falcon \
		--link=falcon-api:api.falcon \
		-p 6055:6055 \
		-e MYSQL_PORT=root:$DB_PWD@tcp\(db.falcon:3306\) \
		-e PLUS_API=http:\\/\\/api.falcon:8080 \
		-e PUSH_API=http:\\/\\/agent.falcon:1988\\/v1\\/push \
		-v /home/work/open-falcon/logs:/open-falcon/logs \
		falcon-$1

	docker ps -f name=$1

	docker exec falcon-$1 ./falconctl start
	docker exec falcon-$1 ps aux
}


start_dashboard() {
	docker run -itd --name falcon-$1 \
		-p 8081:8081 \
		--link=falcon-mysql:db.falcon \
		--link=falcon-api:api.falcon \
		-e API_ADDR=http://api.falcon:8080/api/v1 \
		-e PORTAL_DB_HOST=db.falcon \
		-e PORTAL_DB_PORT=3306 \
		-e PORTAL_DB_USER=root \
		-e PORTAL_DB_PASS=$DB_PWD \
		-e PORTAL_DB_NAME=falcon_portal \
		-e ALARM_DB_HOST=db.falcon \
		-e ALARM_DB_PORT=3306 \
		-e ALARM_DB_USER=root \
		-e ALARM_DB_PASS=$DB_PWD \
		-e ALARM_DB_NAME=alarms \
		-w /open-falcon/dashboard openfalcon/falcon-dashboard:v0.2.1  \
		'./control startfg'

	docker ps -f name=$1
}

start_mail() {
	docker run -itd --name falcon-mail \
		-p 4000:4000 \
		-e SMTP_TYPE=smtp_ssl \
		-e SMTP_SERVER=smtp.exmail.qq.com \
		-e SMTP_PORT=465 \
		-e USERNAME=test@cloudminds.com \
		-e PASSWD=test123 \
		-e FROM=noc@cloudminds.com \
		-v /home/work/open-falcon/logs:/open-falcon/logs \
		falcon-mail

	docker exec falcon-$1 ./falconctl start
	docker ps -f name=$1
}


start_alarm() {
	docker run -itd --name falcon-$1 \
		--link=falcon-mysql:db.falcon \
		--link=falcon-redis:redis.falcon \
		--link=falcon-api:api.falcon \
		--link=falcon-mail:mail.falcon \
		--link=falcon-dashboard:dashboard.falcon \
		-p 9912:9912 \
		-e MYSQL_PORT=root:$DB_PWD@tcp\(db.falcon:3306\) \
		-e REDIS_PORT=redis.falcon:6379  \
		-e PLUS_API=http:\\/\\/api.falcon:8080 \
		-e MAIL_API=http:\\/\\/mail.falcon:4000\\/sender\\/mail \
		-e DASHBOARD=http:\\/\\/dashboard.falcon:8081 \
		-v /home/work/open-falcon/logs:/open-falcon/logs \
		falcon-$1

	docker ps -f name=$1

	docker exec falcon-$1 ./falconctl start
	docker exec falcon-$1 ps aux
}

start_gateway() {
	docker run -itd --name falcon-$1 \
		--link=falcon-transfer:t01.falcon \
		-p 16060:16060 \
		-p 18433:18433 \
		-p 14444:14444 \
		-e TRANSFER_CLUSTER="\"t01\": \"t01.falcon:8433\"" \
		-v /home/work/open-falcon/logs:/open-falcon/logs \
		falcon-$1

	docker ps -f name=$1

	docker exec falcon-$1 ./falconctl start
	docker exec falcon-$1 ps aux
}

start_agent() {
	docker run -itd --name falcon-$1 \
		--link=falcon-transfer:t01.falcon \
		--link=falcon-hbs:hbs.falcon \
		-p 1988:1988 \
		-e TRANSFER_RPC="\"t01.falcon:8433\"" \
		-e HBS_PORT=hbs.falcon:6030 \
		-e HOSTNAME=dockeragent01 \
		-v /home/work/open-falcon/logs:/open-falcon/logs \
		falcon-$1

	docker ps -f name=$1

	docker exec falcon-$1 ./falconctl start
	docker exec falcon-$1 ps aux
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
	 "graph") start_graph $1
	 ;;

	 "hbs") start_hbs $1
	 ;;

	 "judge") start_judge $1
	 ;;

	 "transfer") start_transfer $1
	 ;;

	 "api") start_api $1
	 ;;

	 "nodata") start_nodata $1
	 ;;

	 "aggregator") start_aggregator $1
	 ;;

	 "dashboard") start_dashboard $1
	 ;;

	 "mail") start_mail $1
	 ;;

	 "alarm") start_alarm $1
	 ;;

	 "gateway") start_gateway $1
	 ;;

	 "agent") start_agent $1
	 ;;

	"all")
		start_graph graph
		start_hbs hbs
		start_judge judge
		start_transfer transfer
		start_api api
		start_nodata nodata
		start_aggregator aggregator
		start_dashboard dashboard
		start_mail mail
		start_alarm alarm
		start_gateway gateway
		start_agent agent
	 ;;

	 *) usage
	 ;;
esac
