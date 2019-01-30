{
    "debug": false,
    "http": {
        "enabled": true,
        "listen": "0.0.0.0:6090"
    },
    "plus_api":{
        "connectTimeout": 500,
        "requestTimeout": 2000,
        "addr": "%%PLUS_API%%",
        "token": "default-token-used-in-server-side"
    },
    "config": {
        "enabled": true,
        "dsn": "%%MYSQL%%/falcon_portal?loc=Local&parseTime=true&wait_timeout=604800",
        "maxIdle": 4
    },
    "collector":{
        "enabled": true,
        "batch": 200,
        "concurrent": 10
    },
    "sender":{
        "enabled": true,
        "connectTimeout": 500,
        "requestTimeout": 2000,
        "transferAddr": "%%TRANSFER%%",
        "batch": 500
    }
}
