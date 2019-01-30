{
    "debug": false,
    "http": {
        "enabled": true,
        "listen": "0.0.0.0:6071"
    },
    "rpc": {
        "enabled": true,
        "listen": "0.0.0.0:6070"
    },
    "rrd": {
        "storage": "./data/6070"
    },
    "db": {
        "dsn": "%%MYSQL%%/graph?loc=Local&parseTime=true",
        "maxIdle": 4
    },
    "callTimeout": 5000,
    "ioWorkerNum": 64,
    "migrate": {
            "enabled": false,
            "concurrency": 2,
            "replicas": 500,
            "cluster": {
                    %%GRAPH_CLUSTER%%
            }
    }
}
