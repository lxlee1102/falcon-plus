## building open-falcon modules docker image

`the latest version in docker hub is v0.2.1-dt1.2.1`

##### 1. Building and running a builder to compile open-falcon in alpine
```

    ## start mysql in container by cammands, and a pure DB will be created.
    docker run -itd \
        --name falcon-mysql \
        -v /home/work/mysql-data:/var/lib/mysql \
        -e MYSQL_ROOT_PASSWORD=test123456 \
        -p 3306:3306 \
        mysql:5.7

    ## init mysql table before the first running, by MGC URL, include default templates.
    wget --no-check-certificate --http-user=vbn --http-passwd=cmvbn@2016 \
        https://release.slink.datadn.net/download/openfalcon/falcon-docker-db-init.sh && \
        sh falcon-docker-db-init.sh test123456 && rm -f falcon-docker-db-init.sh

    ## init mysql table before the first running, by falcon origin URL.
    cd /tmp && \
    git clone --depth=1 https://github.com/open-falcon/falcon-plus && \
    cd /tmp/falcon-plus/ && \
    for x in `ls ./scripts/mysql/db_schema/*.sql`; do
        echo init mysql table $x ...;
        docker exec -i falcon-mysql mysql -uroot -ptest123456 < $x;
    done

    rm -rf /tmp/falcon-plus/
```

##### 2. Start redis in container
```
docker run --name falcon-redis -p6379:6379 -d redis:4-alpine3.8
```

##### 3. Start falcon-plus modules in one container

```
    ## pull images from hub.docker.com/openfalcon
    docker pull 103.235.247.247/vbn/falcon-plus:v0.2.1.dt1.2
    
    ## run falcon-plus container
    docker run -itd --name falcon-plus \
        --link=falcon-mysql:db.falcon \
        --link=falcon-redis:redis.falcon \
        -p 8433:8433 \
        -p 8080:8080 \
        -e MYSQL_PORT=root:test123456@tcp\(db.falcon:3306\) \
        -e REDIS_PORT=redis.falcon:6379  \
        -v /home/work/open-falcon/data:/open-falcon/data \
        -v /home/work/open-falcon/logs:/open-falcon/logs \
        103.235.247.247/vbn/falcon-plus:v0.2.1.dt1.2
    
    ## start falcon backend modules, such as graph,api,etc.
    docker exec falcon-plus sh ctrl.sh start \
            graph hbs judge transfer nodata aggregator agent gateway api alarm
    
    ## or you can just start/stop/restart specific module as: 
    docker exec falcon-plus sh ctrl.sh start/stop/restart xxx

    ## check status of backend modules
    docker exec falcon-plus ./open-falcon check
    
    ## or you can check logs at /home/work/open-falcon/logs/ in your host
    ls -l /home/work/open-falcon/logs/
    
```
##### 4. Start falcon-plus modules in multi-contrainer
```
    ## pull modules
    docker pull $docker-resp/falcon-xxx

    ## run falcon-graph container
    
    docker run -itd --name falcon-graph \
        --link=falcon-mysql:db.falcon \
        -p 6070:6070 \
        -p 6071:6071 \
        -e MYSQL_PORT=root:test123456@tcp\(db.falcon:3306\) \
        -e GRAPH_CLUSTER="\"g01\": \"127.0.0.1:6070\"" \
        -v /home/work/open-falcon/data:/open-falcon/graph/data \
        -v /home/work/open-falcon/logs:/open-falcon/logs \
        falcon-graph

        ### note: add multi graph and judge  
        -e GRAPH_CLUSTER="\"g01\": \"g01.falcon:6070\", \"g02\": \"g02.falcon:6070\"" \


    ## run falcon-hbs container
    docker run -itd --name falcon-hbs \
        --link=falcon-mysql:db.falcon \
        -p 6030:6030 \
        -p 6031:6031 \
        -e MYSQL_PORT=root:test123456@tcp\(db.falcon:3306\) \
        -v /home/work/open-falcon/logs:/open-falcon/logs \
        falcon-hbs


    ## run falcon-judge container
    docker run -itd --name falcon-judge \
        --link=falcon-mysql:db.falcon \
        --link=falcon-hbs:hbs.falcon \
        -p 6080:6080 \
        -p 6081:6081 \
        -e HBS_PORT=hbs.falcon:6030 \
        -e REDIS_PORT=redis.falcon:6379  \
        -v /home/work/open-falcon/logs:/open-falcon/logs \
        falcon-judge

    
    ## run falcon-transfer container
    docker run -itd --name falcon-transfer \
        --link=falcon-mysql:db.falcon \
        --link=falcon-graph:g01.falcon \
        --link=falcon-judge:j01.falcon \
        -p 6060:6060 \
        -p 8433:8433 \
        -e MYSQL_PORT=root:test123456@tcp\(db.falcon:3306\) \
        -e GRAPH_CLUSTER="\"g01\": \"g01.falcon:6070\"" \
        -e JUDGE_CLUSTER="\"j01\": \"j01.falcon:6080\"" \
        -v /home/work/open-falcon/logs:/open-falcon/logs \
        falcon-transfer

        ### note: add multi graph and judge  
        -e TRANSFER_CLUSTER="\"g01\": \"g01.falcon:6070\", \"g02\": \"g02.falcon:6070\"" \
        -e JUDGE_CLUSTER="\"j01\": \"j01.falcon:6080\", \"j02\": \"j02.falcon:6080\"" \


    ## run falcon-api container
    docker run -itd --name falcon-api \
        --link=falcon-mysql:db.falcon \
        -p 8080:8080 \
        -e MYSQL_PORT=root:test123456@tcp\(db.falcon:3306\) \
        -e GRAPH_CLUSTER="\"g01\": \"g01.falcon:6070\"" \
        -v /home/work/open-falcon/logs:/open-falcon/logs \
        falcon-api

        ### note: add multi-GRAPH:
        -e TRANSFER_CLUSTER="\"g01\": \"g01.falcon:6070\", \"g02\": \"g02.falcon:6070\"" \


    ## run falcon-nodata container
    docker run -itd --name falcon-nodata \
        --link=falcon-mysql:db.falcon \
        --link=falcon-transfer:transfer.falcon \
        --link=falcon-api:api.falcon \
        -p 6090:6090 \
        -e MYSQL_PORT=root:test123456@tcp\(db.falcon:3306\) \
        -e PLUS_API=http:\\/\\/api.falcon:8080 \
        -e TRANSFER_PORT=transfer.falcon:6060 \
        -v /home/work/open-falcon/logs:/open-falcon/logs \
        falcon-nodata

    ## run falcon-aggregator container
    docker run -itd --name falcon-aggregator \
        --link=falcon-mysql:db.falcon \
        --link=falcon-api:api.falcon \
        -p 6055:6055 \
        -e MYSQL_PORT=root:test123456@tcp\(db.falcon:3306\) \
        -e PLUS_API=http:\\/\\/api.falcon:8080 \
        -e PUSH_API=http:\\/\\/agent.falcon:1988\\/v1\\/push \
        -v /home/work/open-falcon/logs:/open-falcon/logs \
        falcon-aggregator


    ## run falcon-dashboard container (see chapter 5)


    ## run falcon-mail container (see chapter 6)


    ## run falcon-alarm container
    docker run -itd --name falcon-alarm \
        --link=falcon-mysql:db.falcon \
        --link=falcon-redis:redis.falcon \
        --link=falcon-api:api.falcon \
        --link=falcon-mail:mail.falcon \
        --link=falcon-dashboard:dashboard.falcon \
        -p 9912:9912 \
        -e MYSQL_PORT=root:test123456@tcp\(db.falcon:3306\) \
        -e REDIS_PORT=redis.falcon:6379  \
        -e PLUS_API=http:\\/\\/api.falcon:8080 \
        -e MAIL_API=http:\\/\\/mail.falcon:4000\\/sender\\/mail \
        -e DASHBOARD=http:\\/\\/dashboard.falcon:8081 \
        -v /home/work/open-falcon/logs:/open-falcon/logs \
        falcon-alarm

        ### note: add other option below:
        -e IM_API=xxxxxx
        -e SMS_API=xxxxxx


    ## run falcon-gateway container
    docker run -itd --name falcon-gateway \
        --link=falcon-transfer:t01.falcon \
        -p 16060:16060 \
        -p 18433:18433 \
        -p 14444:14444 \
        -e TRANSFER_CLUSTER="\"t01\": \"t01.falcon:8433\"" \
        -v /home/work/open-falcon/logs:/open-falcon/logs \
        falcon-gateway

        ### note: add multi-transfers:
        -e TRANSFER_CLUSTER="\"t01\": \"t01.falcon:8433\", \"t02\": \"t02.falcon:8433\"" \


    ## run falcon-agent container
    docker run -itd --name falcon-agent \
        --link=falcon-transfer:t01.falcon \
        --link=falcon-hbs:hbs.falcon \
        -p 1988:1988 \
        -e TRANSFER_RPC="\"t01.falcon:8433\"" \
        -e HBS_PORT=hbs.falcon:6030 \
        -v /home/work/open-falcon/logs:/open-falcon/logs \
        falcon-agent

        note: can add option below:
        -e HOSTNAME=xxxx


    ## or you can just start/stop/restart specific module as: 
    docker exec falcon-xxx ./falconctl start/stop/restart xxx

    ## check status of backend modules
    docker exec falcon-xxx ./falconctl check
    
    ## or you can check logs at /home/work/open-falcon/logs/ in your host
    ls -l /home/work/open-falcon/logs/

```

##### 5. Start falcon-dashboard in container
```
    docker run -itd --name falcon-dashboard \
        -p 8081:8081 \
        --link=falcon-mysql:db.falcon \
        --link=falcon-api:api.falcon \
        -e API_ADDR=http://api.falcon:8080/api/v1 \
        -e PORTAL_DB_HOST=db.falcon \
        -e PORTAL_DB_PORT=3306 \
        -e PORTAL_DB_USER=root \
        -e PORTAL_DB_PASS=test123456 \
        -e PORTAL_DB_NAME=falcon_portal \
        -e ALARM_DB_HOST=db.falcon \
        -e ALARM_DB_PORT=3306 \
        -e ALARM_DB_USER=root \
        -e ALARM_DB_PASS=test123456 \
        -e ALARM_DB_NAME=alarms \
        -w /open-falcon/dashboard openfalcon/falcon-dashboard:v0.2.1  \
       './control startfg'
```

##### 6. Start falcon-mail in container
```
    docker run -itd --name falcon-mail \
        -p 4000:4000 \
        -e SMTP_TYPE=smtp_ssl \
        -e SMTP_SERVER=smtp.exmail.qq.com \
        -e SMTP_PORT=465 \
        -e USERNAME=noc@xxxx.com \
        -e PASSWD=123456 \
        -e FROM=falcon@xxxx.com \
        -v /home/work/open-falcon/logs:/open-falcon/logs \
        falcon-mail

    ## or you can just start/stop/restart mail:
    docker exec falcon-mail ./falconctl start/stop/restart xxx

```

----

## Building open-falcon images from source code

##### Building falcon-plus

```
    cd /tmp && \
    git clone https://github.com/open-falcon/falcon-plus && \
    cd /tmp/falcon-plus/ && \
    docker build -t falcon-plus:v0.2.1 .
```

##### Building falcon-dashboard
```
    cd /tmp && \
    git clone https://github.com/open-falcon/dashboard  && \
    cd /tmp/dashboard/ && \
    docker build -t falcon-dashboard:v0.2.1 .
```


##### Building falcon modules
```
    mkdir -p $GOPATH/src/github.com/open-falcon  && \
    cd $GOPATH/src/github.com/open-falcon/ && \
    git clone git@10.11.35.89:vbn/falcon-plus.git && \
    cd ./falcon-plus/cmdocker/ && \
    ./build.sh bin

    ./build.sh all  # or ./build.sh ${modules}

    ## modules: graph hbs judge transfer nodata aggregator agent gateway api alarm

```

##### Building falcon mail
```
    mkdir -p $GOPATH/src/github.com/open-falcon  && \
    cd $GOPATH/src/github.com/open-falcon/ && \
    git clone https://github.com/lxlee1102/mail-provider.git && \
    cd mail-provider.git

    go ./...
    docker build -t falcon-mail .
```
