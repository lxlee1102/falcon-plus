#!/bin/bash

WORK_D=$(cd $(dirname $0)/; pwd)
FALCON_AGENT_LOG_D=$(cd $WORK_D; cd ../agent/logs/; pwd)

function install() {
echo "$FALCON_AGENT_LOG_D/*.log
{
        daily
        rotate 100
	minsize 10M
	dateext
        copytruncate
        missingok
        notifempty
        delaycompress
        compress
        postrotate
        endscript

}" > $WORK_D/falcon-agent.logrotate

mv -f $WORK_D/falcon-agent.logrotate  /etc/logrotate.d/falcon-agent
}

function remove() {
	rm -rf /etc/logrotate.d/falcon-agent
}

function help() {
	echo "$0 install|remove"
}

if [ "$1" == "" ]; then
	help
elif [ "$1" == "install" ]; then
	install
elif [ "$1" == "remove" ]; then
	remove
else
	help
fi
