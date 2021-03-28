package balance

import (
	"strconv"
)

type Instance struct {
	host string
	port int
}

func NewInstance(host string, port int) *Instance {
	return &Instance{
		host: host,
		port: port,
	}
}

//定义Instance结构体的方法GetHost()
func (p *Instance) GetHost() string {
	return p.host
}

//定义方法GetPort()
func (p *Instance) GetPort() int {
	return p.port
}
func (p *Instance) String() string {
	return p.host + ":" + strconv.Itoa(p.port)
}
