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
	"bufio"
	"bytes"
	"fmt"
	"io"
	"io/ioutil"
	"strconv"
	"strings"
	"sync"
	"time"

	log "github.com/Sirupsen/logrus"
	"github.com/open-falcon/falcon-plus/modules/agent/g"
	"github.com/toolkits/file"
)

var (
	portMapTenant = map[int]int{}
	lock          = new(sync.RWMutex)
)

func TenantPortMap() map[int]int {
	lock.RLock()
	defer lock.RUnlock()
	return portMapTenant
}

func MCSTenantUpdate() {
	t := time.NewTicker(time.Second * time.Duration(g.Config().MCSTenant.TTL))
	defer t.Stop()
	for {
		enabled := g.Config().MCSTenant.Enabled
		if enabled {
			newMap, err := getTenants()
			if err == nil {
				lock.Lock()
				portMapTenant = newMap
				lock.Unlock()
			}
		}

		<-t.C
	}
	return
}

func getTenants() (m map[int]int, err error) {
	dir, err := ioutil.ReadDir(g.Config().MCSTenant.Dir)
	if err != nil {
		log.Errorln("MCS", err)
		return
	}

	tens := make(map[int]int)

	for _, f := range dir {
		if f.IsDir() {
			continue
		}
		if strings.HasSuffix(f.Name(), g.Config().MCSTenant.Suffix) == false {
			continue
		}

		id, port, err := getTenantPortID(f.Name())
		if err == nil {
			tens[port] = id
		}
	}

	return tens, nil
}

func getTenantIDbyName(fn string) (id int, err error) {
	// f.name format is :  TenantName-TenantID-ProcID.conf
	tenSlice := strings.Split(fn, "-")
	ln := len(tenSlice)
	if ln < 3 {
		return 0, fmt.Errorf("ignore '%s', fields < 3", fn)
	}

	pidx := strings.Split(tenSlice[ln-1], ".")[0]
	_, err = strconv.Atoi(pidx)
	if err != nil {
		return 0, fmt.Errorf("ignore '%s', invalid PIdx: %s", fn, pidx)
	}

	id, err = strconv.Atoi(tenSlice[ln-2])
	if err != nil {
		return 0, fmt.Errorf("ignore '%s', invalid TenantID: %s", fn, tenSlice[ln-2])
	}

	return id, nil
}

func getTenantPortID(fname string) (id, port int, err error) {
	id, err = getTenantIDbyName(fname)
	if err != nil {
		log.Errorln("MCS", err)
		return
	}

	filePath := fmt.Sprintf("%s/%s", g.Config().MCSTenant.Dir, fname)
	contents, err := ioutil.ReadFile(filePath)
	if err != nil {
		return 0, 0, err
	}

	reader := bufio.NewReader(bytes.NewBuffer(contents))

	for {
		line, err := file.ReadLine(reader)
		if err == io.EOF {
			err = nil
			break
		} else if err != nil {
			return 0, 0, err
		}

		fields := strings.Fields(string(line))
		if fields[0] == "port" {
			port, err = strconv.Atoi(fields[1])
			if err != nil {
				return 0, 0, err
			}
			return id, port, err
		}
	}

	err = fmt.Errorf("lost 'port' in %s.", fname)
	log.Errorln("MCS", err)
	return 0, 0, err
}
