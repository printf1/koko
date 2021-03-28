package balance

import "fmt"

//声明一个结构体类型
type BalanceMgr struct {
	allBalancer map[string]Balancer
}

//实例化结构体map类型，用来当作算法库，"random":"randombalance"
var mgr = BalanceMgr{
	allBalancer: make(map[string]Balancer),
}

//将已有算法注册到算法库
func (p *BalanceMgr) registerBalancer(name string, b Balancer) {
	p.allBalancer[name] = b
}

func RegisterBalancer(name string, b Balancer) {
	mgr.registerBalancer(name, b)
}

//开始执行算法逻辑，并返回被算法计算过的负载主机ip
func DoBalance(name string, insts []*Instance) (inst *Instance, err error) {
	//实例化算法
	balancer, ok := mgr.allBalancer[name]
	if !ok {
		err = fmt.Errorf("Not found %s balancer", name)
		return
	}
	fmt.Printf("use %s balancer\n", name)
	//执行算法负载
	inst, err = balancer.DoBalance(insts)
	return
}
