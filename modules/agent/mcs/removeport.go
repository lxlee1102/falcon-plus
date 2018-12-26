// Copyright 2020 CloudMinds, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package mcs

import (
	"bytes"
	"strconv"
	"strings"

	log "github.com/Sirupsen/logrus"
	"github.com/open-falcon/falcon-plus/modules/agent/g"
)

func HasMetricPrefix(m string) bool {
	// default nil, is match all
	if len(g.Config().MCSTenant.MetricPrefix) == 0 {
		return true
	}

	for _, x := range g.Config().MCSTenant.MetricPrefix {
		if strings.HasPrefix(m, x) {
			return true
		}
	}

	return false
}

func MCSRemovePortTag(otags string) string {
	var err error
	var id, port int = -1, -1
	var (
		b1, b2 bytes.Buffer
		buf    *bytes.Buffer
	)

	b1.Reset()
	b2.Reset()
	buf = &b1

	flds := strings.Split(otags, ",")
	for idx, fv := range flds {
		if strings.HasPrefix(fv, "port=") {
			port, err = strconv.Atoi(strings.Split(fv, "=")[1])
			if err != nil {
				log.Errorf("MCS invalid tag '%s', %v", fv, err)
				return otags
			}
			// dont writeString 'port='
		} else if strings.HasPrefix(fv, "tenant=") {
			id, err = strconv.Atoi(strings.Split(fv, "=")[1])
			if err != nil {
				log.Errorf("MCS invalid tag '%s', %v", fv, err)
				return otags
			}
			buf = &b2
			// dont writeString tenant=
		} else {
			if idx == 0 {
				buf.WriteString(fv)
			} else {
				buf.WriteString(",")
				buf.WriteString(fv)
			}
		}
	}

	if port < 0 || id < 0 {
		return otags
	}

	if id == 0 {
		nid, ok := TenantPortMap()[port]
		if ok {
			id = nid
		} else {
			log.Errorf("MCS: cannot found port(%d)'s tenant",
				port)
		}
	}

	if b1.Len() == 0 {
		b1.WriteString("tenant=" + strconv.Itoa(id))
	} else {
		b1.WriteString("," + "tenant=" + strconv.Itoa(id))
	}

	if b2.Len() > 0 {
		b1.WriteString(b2.String())
	}

	log.Debugf("MCS: origin-tag:%s, new-tag:%s", otags, b1.String())

	return b1.String()
}
