package main

import (
	"fmt"
	"math/rand"
	"time"
)

type test struct {
	mm int
}

//定义接口类型
type doBalance interface {
	DoBalance([]*test, ...string) ([]*test, error)
	//com([]*test) []*test
}

func Newelement(a int) *test {
	return &test{
		a,
	}
}

type Balance struct {
	allban map[string]doBalance
}

type maopao struct {
}

var all = Balance{
	allban: make(map[string]doBalance),
}

//注册算法
func Newarr() []*test {
	rand.Seed(time.Now().UnixNano())
	var pro []*test
	for i := 0; i < 10; i++ {
		number := rand.Intn(100)
		num := Newelement(number)
		pro = append(pro, num)
	}
	return pro

}

//绑定算法
func (b *Balance) RegistryAlgor(name string, mp doBalance) {
	b.allban[name] = mp
}

//初始化算法
func init() {
	Registry("mp", &maopao{})
}

func Registry(name string, mp doBalance) {
	all.RegistryAlgor(name, mp)
}

//执行算法
func (a *maopao) DoBalance(arr []*test, x ...string) ([]*test, error) {
	//fmt.Println(*arr[0])
	for _, val := range arr {
		fmt.Println(*val)
	}
	fmt.Println("冒泡")
	return arr, nil
}

func DoBalance(name string, arr []*test) ([]*test, error) {
	//找算法
	b, ok := all.allban[name]
	if !ok {
		fmt.Println("没有可用算法")
		return nil, nil
	}
	//执行算法
	te, err := b.DoBalance(arr)
	return te, err
}

func main() {
	te, err := DoBalance("mp", Newarr())
	if err != nil {
		fmt.Println(err)
		return
	}
	fmt.Println(te)
}
