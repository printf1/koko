package main

import "fmt"
//定义接口类型
type inter interface {
	sayhello()
}
//定义结构体类型，
// kk
type kk struct {
	name string
	tel int
	addr string
}

func (test *kk) sayhello()  {
	fmt.Printf("kk[%s, %d, %s] say hello\n", test.name, test.tel, test.addr)
}
//friends
type friends struct {
	name1 string
	tel1 int
}

func (test1 *friends) sayhello()  {
    fmt.Printf("friends[%s, %d] say hello\n", test1.name1, test1.tel1)
}
//boss
type boss string
//	name2 string
//}

func (test2 *boss) sayhello() {
	fmt.Printf("boss[%s] say hello\n", *test2)
}

func whosayhello(x inter)  {
	x.sayhello()
}
func main() {
	//声明接口变量
	var i inter
    //接口变量赋值
    j := kk{"ko",123456789, "123456789@qq.com"}
    //f := friends{"shuai", 123}
    //b := &boss{"he"}
    i = &j
	i.sayhello()
    i = &friends{"shuai", 123}
	i.sayhello()

    var my boss = "he"
    i = &my
    whosayhello(i)


}