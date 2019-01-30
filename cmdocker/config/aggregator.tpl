{
    "debug": true,
    "http": {
        "enabled": true,
        "listen": "0.0.0.0:6055"
    },
    "database": {
        "addr": "%%MYSQL%%/falcon_portal?loc=Local&parseTime=true",
        "idle": 10,
        "ids": [1, -1],
        "interval": 55
    },
    "api": {
        "connect_timeout": 500,
        "request_timeout": 2000,
        "plus_api": "%%PLUS_API%%",
        "plus_api_token": "default-token-used-in-server-side",
        "push_api": "%%PUSH_API%%"
    }
}
