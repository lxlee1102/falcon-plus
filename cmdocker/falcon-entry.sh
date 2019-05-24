#!/bin/sh

DOCKER_DIR=/open-falcon
of_bin=$DOCKER_DIR/open-falcon
DOCKER_HOST_IP=$(route -n | awk '/UG[ \t]/{print $2}')

#use the correct mysql instance
if [ -z $MYSQL_PORT ]; then
    MYSQL_PORT=$DOCKER_HOST_IP:3306
fi
#find $DOCKER_DIR/*/config/*.json -type f -exec sed -i "s/%%MYSQL%%/$MYSQL_PORT/g" {} \;

#use the correct redis instance
if [ -z $REDIS_PORT ]; then
    REDIS_PORT=$DOCKER_HOST_IP:6379
fi
#find $DOCKER_DIR/*/config/*.json -type f -exec sed -i "s/%%REDIS%%/$REDIS_PORT/g" {} \;


if [ -z "$GRAPH_CLUSTER" ]; then
	GRAPH_CLUSTER="\"g01\": \"$DOCKER_HOST_IP:6070\""
fi

if [ -z "$JUDGE_CLUSTER" ]; then
	JUDGE_CLUSTER="\"j01\": \"$DOCKER_HOST_IP:6080\""
fi

if [ -z "$HBS_PORT" ]; then
	HBS_PORT=$DOCKER_HOST_IP:6030
fi

if [ -z "$TRANSFER_CLUSTER" ]; then
	TRANSFER_CLUSTER="\"t01\": \"$DOCKER_HOST_IP:8433\""
fi

if [ -z "$TRANSFER_RPC" ]; then
	TRANSFER_RPC="\"$DOCKER_HOST_IP:8433\""
fi

reset_graph_cfg() {
	PROG=graph
	cp -f $DOCKER_DIR/$PROG/$PROG.tpl  $DOCKER_DIR/$PROG/config/cfg.json
	find $DOCKER_DIR/$PROG/config/*.json -type f -exec sed -i "s/%%GRAPH_CLUSTER%%/$GRAPH_CLUSTER/g" {} \;
	find $DOCKER_DIR/$PROG/config/*.json -type f -exec sed -i "s/%%MYSQL%%/$MYSQL_PORT/g" {} \;
}

reset_hbs_cfg() {
	PROG=hbs
	cp -f $DOCKER_DIR/$PROG/$PROG.tpl  $DOCKER_DIR/$PROG/config/cfg.json
	find $DOCKER_DIR/$PROG/config/*.json -type f -exec sed -i "s/%%MYSQL%%/$MYSQL_PORT/g" {} \;
}

reset_judge_cfg() {
	PROG=judge
	cp -f $DOCKER_DIR/$PROG/$PROG.tpl  $DOCKER_DIR/$PROG/config/cfg.json
	find $DOCKER_DIR/$PROG/config/*.json -type f -exec sed -i "s/%%HBS%%/$HBS_PORT/g" {} \;
	find $DOCKER_DIR/*/config/*.json -type f -exec sed -i "s/%%REDIS%%/$REDIS_PORT/g" {} \;
}

reset_transfer_cfg() {
	PROG=transfer
	cp -f $DOCKER_DIR/$PROG/$PROG.tpl  $DOCKER_DIR/$PROG/config/cfg.json
	find $DOCKER_DIR/$PROG/config/*.json -type f -exec sed -i "s/%%GRAPH_CLUSTER%%/$GRAPH_CLUSTER/g" {} \;
	find $DOCKER_DIR/$PROG/config/*.json -type f -exec sed -i "s/%%JUDGE_CLUSTER%%/$JUDGE_CLUSTER/g" {} \;
}

reset_api_cfg() {
	PROG=api
	cp -f $DOCKER_DIR/$PROG/$PROG.tpl  $DOCKER_DIR/$PROG/config/cfg.json
	find $DOCKER_DIR/$PROG/config/*.json -type f -exec sed -i "s/%%MYSQL%%/$MYSQL_PORT/g" {} \;
	find $DOCKER_DIR/$PROG/config/*.json -type f -exec sed -i "s/%%GRAPH_CLUSTER%%/$GRAPH_CLUSTER/g" {} \;
	#use absolute path of metric_list_file in docker
	TAB=$'\t'; sed -i "s|.*metric_list_file.*|${TAB}\"metric_list_file\": \"$DOCKER_DIR/api/data/metric\",|g" $DOCKER_DIR/api/config/*.json;
}

reset_nodata_cfg() {
	PROG=nodata
	cp -f $DOCKER_DIR/$PROG/$PROG.tpl  $DOCKER_DIR/$PROG/config/cfg.json
	find $DOCKER_DIR/$PROG/config/*.json -type f -exec sed -i "s/%%PLUS_API%%/$PLUS_API/g" {} \;
	find $DOCKER_DIR/$PROG/config/*.json -type f -exec sed -i "s/%%MYSQL%%/$MYSQL_PORT/g" {} \;
	find $DOCKER_DIR/$PROG/config/*.json -type f -exec sed -i "s/%%TRANSFER%%/$TRANSFER_PORT/g" {} \;
}


reset_aggregator_cfg() {
	PROG=aggregator
	cp -f $DOCKER_DIR/$PROG/$PROG.tpl  $DOCKER_DIR/$PROG/config/cfg.json
	find $DOCKER_DIR/$PROG/config/*.json -type f -exec sed -i "s/%%PLUS_API%%/$PLUS_API/g" {} \;
	find $DOCKER_DIR/$PROG/config/*.json -type f -exec sed -i "s/%%PUSH_API%%/$PUSH_API/g" {} \;
	find $DOCKER_DIR/$PROG/config/*.json -type f -exec sed -i "s/%%MYSQL%%/$MYSQL_PORT/g" {} \;
}


reset_alarm_cfg() {
	PROG=alarm
	cp -f $DOCKER_DIR/$PROG/$PROG.tpl  $DOCKER_DIR/$PROG/config/cfg.json
	find $DOCKER_DIR/$PROG/config/*.json -type f -exec sed -i "s/%%REDIS%%/$REDIS_PORT/g" {} \;
	find $DOCKER_DIR/$PROG/config/*.json -type f -exec sed -i "s/%%IM_API%%/$IM_API/g" {} \;
	find $DOCKER_DIR/$PROG/config/*.json -type f -exec sed -i "s/%%SMS_API%%/$SMS_API/g" {} \;
	find $DOCKER_DIR/$PROG/config/*.json -type f -exec sed -i "s/%%MAIL_API%%/$MAIL_API/g" {} \;
	find $DOCKER_DIR/$PROG/config/*.json -type f -exec sed -i "s/%%DASHBOARD%%/$DASHBOARD/g" {} \;
	find $DOCKER_DIR/$PROG/config/*.json -type f -exec sed -i "s/%%PLUS_API%%/$PLUS_API/g" {} \;
	find $DOCKER_DIR/$PROG/config/*.json -type f -exec sed -i "s/%%MYSQL%%/$MYSQL_PORT/g" {} \;
}

reset_gateway_cfg() {
	PROG=gateway
	cp -f $DOCKER_DIR/$PROG/$PROG.tpl  $DOCKER_DIR/$PROG/config/cfg.json
	find $DOCKER_DIR/$PROG/config/*.json -type f -exec sed -i "s/%%TRANSFER_CLUSTER%%/$TRANSFER_CLUSTER/g" {} \;
}

reset_agent_cfg() {
	PROG=agent
	cp -f $DOCKER_DIR/$PROG/$PROG.tpl  $DOCKER_DIR/$PROG/config/cfg.json
	find $DOCKER_DIR/$PROG/config/*.json -type f -exec sed -i "s/%%HOSTNAME%%/$HOSTNAME/g" {} \;
	find $DOCKER_DIR/$PROG/config/*.json -type f -exec sed -i "s/%%HBS%%/$HBS_PORT/g" {} \;
	find $DOCKER_DIR/$PROG/config/*.json -type f -exec sed -i "s/%%TRANSFER_RPC%%/$TRANSFER_RPC/g" {} \;
	
}

reset_configs() {

	m=$FALCON_MODULE
	case $m in
		"graph")
			reset_graph_cfg
			;;
		"hbs")
			reset_hbs_cfg
			;;
		"judge")
			reset_judge_cfg
			;;
		"transfer")
			reset_transfer_cfg
			;;
		"api")
			reset_api_cfg
			;;
		"nodata")
			reset_nodata_cfg
			;;
		"aggregator")
			reset_aggregator_cfg
			;;
		"alarm")
			reset_alarm_cfg
			;;
		"gateway")
			reset_gateway_cfg
			;;
		"agent")
			reset_agent_cfg
			;;
		*)
			;;
	esac
}

# init-config
m=$FALCON_MODULE
if [ ! -f $DOCKER_DIR/$m/config/cfg.json ]; then
	reset_configs
fi

exec "$@"
