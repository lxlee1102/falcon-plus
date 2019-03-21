#!/bin/sh

DOCKER_DIR=/open-falcon
of_bin=$DOCKER_DIR/open-falcon
DOCKER_HOST_IP=$(route -n | awk '/UG[ \t]/{print $2}')


#update push_api
if [ -z $PUSH_API ]; then
	PUSH_API=http:\\/\\/127.0.0.1:1988\\/v1\\/push
fi
find $DOCKER_DIR/*/config/*.json -type f -exec sed -i "s/%%PUSH_API%%/$PUSH_API/g" {} \;

#update plus_api
if [ -z $PLUS_API ]; then
	PLUS_API=http:\\/\\/127.0.0.1:8080
fi
find $DOCKER_DIR/*/config/*.json -type f -exec sed -i "s/%%PLUS_API%%/$PLUS_API/g" {} \;

#update mail_api
if [ -z $MAIL_API ]; then
	MAIL_API=http:\\/\\/127.0.0.1:4000\\/sender\\/mail
fi
find $DOCKER_DIR/*/config/*.json -type f -exec sed -i "s/%%MAIL_API%%/$MAIL_API/g" {} \;

#update dashboard api
if [ -z $DASHBOARD_API ]; then
	DASHBOARD_API=http:\\/\\/127.0.0.1:8081
fi
find $DOCKER_DIR/*/config/*.json -type f -exec sed -i "s/%%DASHBOARD_API%%/$DASHBOARD_API/g" {} \;


#use the correct mysql instance
if [ -z $MYSQL_PORT ]; then
    MYSQL_PORT=$DOCKER_HOST_IP:3306
fi
find $DOCKER_DIR/*/config/*.json -type f -exec sed -i "s/%%MYSQL%%/$MYSQL_PORT/g" {} \;


#use the correct redis instance
if [ -z $REDIS_PORT ]; then
    REDIS_PORT=$DOCKER_HOST_IP:6379
fi
find $DOCKER_DIR/*/config/*.json -type f -exec sed -i "s/%%REDIS%%/$REDIS_PORT/g" {} \;

#use absolute path of metric_list_file in docker
TAB=$'\t'; sed -i "s|.*metric_list_file.*|${TAB}\"metric_list_file\": \"$DOCKER_DIR/api/data/metric\",|g" $DOCKER_DIR/api/config/*.json;

supervisorctl $*
