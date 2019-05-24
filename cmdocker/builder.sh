#!/bin/bash


check_bin() {
	if [ ! -f "../open-falcon" ]; then
		echo "You need build bin-files in falcon-builder firstly."
		exit 1;
	fi
}

check_out() {
	check_bin
	rm -rf ./out && mkdir -p ./out
	if [ $? != 0 ]; then
		exit 1;
	fi
}

#build_graph() {
#	check_out
#
#	tar -zxf ../open-falcon-v*.tar.gz -C ./out ./graph  && rm -f ./out/graph/config/cfg.json
#	cp ./config/graph.tpl ./out/graph/config/
#	cp ./falconctl ../open-falcon ./Dockerfile.graph ./supervisord.conf.graph ./out/
#	if [ $? != 0 ]; then
#		exit 1;
#	fi
#
#	cd ./out
#	docker build -t falcon-$1 . -f Dockerfile.graph
#	cd ../ && rm -rf ./out
#}


# $1 module_name
# $2 docker image name[:version], such as falcon-$2
build_agent() {
	PROG=$1
	check_out

	tar -zxf ../open-falcon-v*.tar.gz -C ./out ./$PROG ./public ./plugin  && rm -f ./out/$PROG/config/cfg.json
	cp ./config/$PROG.tpl ./out/$PROG/
	cp ./falcon-entry.sh ./Dockerfile.$PROG ./zoneinfo.zip ./out/
	if [ $? != 0 ]; then
		exit 1;
	fi

	cd ./out
	docker build -t falcon-$2 . -f Dockerfile.$PROG
	cd ../ && rm -rf ./out
}

# $1 module_name
# $2 docker image name[:version], such as falcon-$2
build_module() {
	PROG=$1
	check_out

	tar -zxf ../open-falcon-v*.tar.gz -C ./out ./$PROG  && rm -f ./out/$PROG/config/cfg.json
	cp ./config/$PROG.tpl ./out/$PROG/
	cp ./falcon-entry.sh ./Dockerfile.$PROG ./zoneinfo.zip ./out/
	if [ $? != 0 ]; then
		exit 1;
	fi

	cd ./out
	docker build -t falcon-$2 . -f Dockerfile.$PROG
	cd ../ && rm -rf ./out
}



check_image() {
	echo "check and made falcon-builder image ..."

	is_exist=`docker image ls | grep falcon-builder | wc -l`
	if [ "$is_exist" == "0" ] ; then
		echo "make falcon-builder images ..."
		docker build -t falcon-builder . -f Dockerfile.builder
		if [ $? != 0 ]; then
			return 1;
		fi
	fi

	return 0;
}

check_container() {
	echo "check and run falcon-builder container ..."
	is_exist=`docker ps -a -qf name=falcon-builder | wc -l`
	if [ "$is_exist" == "0" ]; then
		echo "run falcon-builder container..."
		docker run -tid --name falcon-builder \
			-v $GOPATH/src/github.com/open-falcon/falcon-plus:/go/src/github.com/open-falcon/falcon-plus \
			-w /go/src/github.com/open-falcon/falcon-plus falcon-builder
		if [ $? != 0 ]; then
			return 1;
		fi
	fi

	is_running=`docker ps -qf name=falcon-builder | wc -l`
	if [ "$is_running" == "0" ]; then
		echo "start falcon-builder container..."
		docker start falcon-builder
		if [ $? != 0 ]; then
			return 1;
		fi
	fi

	return 0
}

build_bin() {
	check_image
	if [ $? != 0 ]; then
		echo "check image (falcon-builder) failed."
		exit 1;
	fi

	check_container
	if [ $? != 0 ]; then
		echo "check container (falcon-builder) start failed."
		exit 1;
	fi

	docker exec falcon-builder make all 
	docker exec falcon-builder make pack
}

usage() {
	script=$0
	echo "Ver: 1.0.0 20190124
Usage:
    ${script#*/} [commands:[version]]

commands:
    graph hbs judge transfer nodata aggregator agent gateway api alarm
    bin        check and build falcon builder and bin-files
    all        all modules of falcon
    "
}

var=$1
module=${var%:*}
version=${var##*:}

case $module in
	"graph") build_module graph $1
	;;

	"hbs") build_module hbs $1
	;;

	"judge") build_module judge $1
	;;

	"transfer") build_module transfer $1
	;;

	"api") build_module api $1
	;;

	"nodata") build_module nodata $1
	;;

	"aggregator") build_module aggregator $1
	;;

	"alarm") build_module alarm $1
	;;

	"gateway") build_module gateway $1
	;;

	"agent") build_agent agent $1
	;;

	"bin") build_bin
	;;

	"all")
		if [ "$version" = "$module" ] ; then
			version=
		else
			version=":$version"
		fi

		build_module graph graph$version
		build_module hbs hbs$version
		build_module judge judge$version
		build_module transfer transfer$version
		build_module api api$version
		build_module nodata nodata$version
		build_module aggregator aggregator$version
		build_module alarm alarm$version
		build_module gateway gateway$version
		build_agent agent agent$version
	;;

	*)
	usage
	;;
esac

exit 0
