{
    "log_level": "info",
    "http": {
        "enabled": true,
        "listen": "0.0.0.0:9912"
    },
    "redis": {
        "addr": "%%REDIS%%",
        "maxIdle": 5,
        "highQueues": [
            "event:p0",
            "event:p1",
            "event:p2"
        ],
        "lowQueues": [
            "event:p3",
            "event:p4",
            "event:p5",
            "event:p6"
        ],
        "userIMQueue": "/queue/user/im",
        "userSmsQueue": "/queue/user/sms",
        "userMailQueue": "/queue/user/mail"
    },
    "api": {
        "im": "%%IM_API%%",
        "sms": "%%SMS_API%%",
        "mail": "%%MAIL_API%%",
        "dashboard": "%%DASHBOARD%%",
        "plus_api":"%%PLUS_API%%",
        "plus_api_token": "default-token-used-in-server-side"
    },
    "falcon_portal": {
        "addr": "%%MYSQL%%/alarms?charset=utf8&loc=Asia%2FChongqing",
        "idle": 10,
        "max": 100
    },
    "worker": {
        "im": 10,
        "sms": 10,
        "mail": 50
    },
    "housekeeper": {
        "event_retention_days": 7,
        "event_delete_batch": 100
    }
}
