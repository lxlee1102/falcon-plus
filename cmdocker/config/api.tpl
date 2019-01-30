{
	"log_level": "info",
	"db": {
		"falcon_portal": "%%MYSQL%%/falcon_portal?charset=utf8&parseTime=True&loc=Local",
		"graph": "%%MYSQL%%/graph?charset=utf8&parseTime=True&loc=Local",
		"uic": "%%MYSQL%%/uic?charset=utf8&parseTime=True&loc=Local",
		"dashboard": "%%MYSQL%%/dashboard?charset=utf8&parseTime=True&loc=Local",
		"alarms": "%%MYSQL%%/alarms?charset=utf8&parseTime=True&loc=Local",
		"db_bug": false
	},
	"graphs": {
		"cluster": {
			%%GRAPH_CLUSTER%%
		},
		"max_conns": 100,
		"max_idle": 100,
		"conn_timeout": 1000,
		"call_timeout": 5000,
		"numberOfReplicas": 500
	},
	"metric_list_file": "./api/data/metric",
	"web_port": "0.0.0.0:8080",
	"access_control": true,
	"signup_disable": true,
	"salt": "",
	"skip_auth": false,
	"default_token": "default-token-used-in-server-side",
	"gen_doc": false,
	"gen_doc_path": "doc/module.html"
}
