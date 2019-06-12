#!/bin/bash

F_M_AGT="agent "
#F_M_HA="agent graph judge transfer"
#F_M_DCA="agent aggregator alarm api hbs nodata"

F_MODULES=${F_M_AGT}

WORK_D=$(cd $(dirname $0)/; pwd)
FALCON_AGENT_LOG_D=$(cd $WORK_D; cd ../agent/logs/; pwd)
LOG=$FALCON_AGENT_LOG_D/falcon-mon.log

CMD=/sbin/falconctl
CTAB=/bin/crontab

# $1 module name
check_module() {

	status=`$CMD check $1 | awk '{print $2}'`
	if [ "$status"x != "UP"x ]; then
		$CMD start $1
		echo `date` "$CMD start $1" >> $LOG
	fi
}


usage() {
echo "Usage:
    $0 [install|remove|<noargs>] 
        install/remove: to/from crontab.
        <noargs> :      check and up the down falcon modules."
}

if [ $# == 1 ]; then
	if [ "$1"x == "install"x ]; then
		$CTAB -l > /tmp/crontab.tmp
		echo "*/1 * * * * sh $WORK_D/falcon-monitor.sh > /dev/null 2>&1" >> /tmp/crontab.tmp
		$CTAB  /tmp/crontab.tmp
		exit 0
	fi

	if [ "$1"x == "remove"x ]; then
		$CTAB -l > /tmp/crontab.tmp
		sed -e '/falcon-monitor/d'  /tmp/crontab.tmp > /tmp/crontab.tmp.new
		$CTAB /tmp/crontab.tmp.new
		exit 0
	fi

	usage

	exit 0
fi


for m in $F_MODULES ;
do
	check_module $m
done

