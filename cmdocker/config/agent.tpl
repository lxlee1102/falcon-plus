{
    "debug": false,
    "hostname": "%%HOSTNAME%%",
    "ip": "",
    "plugin": {
        "enabled": true,
        "dir": "./plugin",
        "git": "git://release.slink.datadn.net/open-falcon/plugin.git",
        "logs": "./logs"
    },
    "heartbeat": {
        "enabled": true,
        "addr": "%%HBS%%",
        "interval": 60,
        "timeout": 1000
    },
    "transfer": {
        "enabled": true,
        "addrs": [
           %%TRANSFER_RPC%%
        ],
        "interval": 60,
        "timeout": 1000
    },
    "http": {
        "enabled": true,
        "listen": ":1988",
        "backdoor": false
    },
    "collector": {
        "ifacePrefix": [],
        "mountPoint": []
    },
    "default_tags": {
    },
    "ignore": {
        "cpu.busy": true,
        "df.bytes.free": true,
        "df.bytes.total": true,
        "df.bytes.used": true,
        "df.bytes.used.percent": true,
        "df.inodes.total": true,
        "df.inodes.free": true,
        "df.inodes.used": true,
        "df.inodes.used.percent": true,
        "mem.memtotal": true,
        "mem.memused": true,
        "mem.memused.percent": true,
        "mem.memfree": true,
        "mem.swaptotal": true,
        "mem.swapused": true,
        "mem.swapfree": true
    },
    "mcstenant": {
        "enabled": true,
        "ttl": 120,
        "dir": "/etc/openvpn",
        "suffix": ".conf",
        "metricPrefix": ["mcs.rcu"]
    }
}
