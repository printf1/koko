package main

import (
	"fmt"
	"math/rand"
	"strconv"
	"time"
)

func main()  {
	r1 := time.Now().UnixNano()
	rnd_int := rand.Intn(11)
	r2 := time.Now().UnixNano()
	fmt.Println(r1, r2)
	fmt.Println(r2 - r1)
	//转换成字符串类型数字，和string不同在只改变类型，不会改变变量的值
	ran_str := strconv.Itoa(rnd_int)
	fmt.Println(string(112))
	fmt.Println(ran_str)


}