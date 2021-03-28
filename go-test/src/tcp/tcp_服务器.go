package main

import (
	"fmt"
	"net"
	//"os"
	"strings"
)

func client(acc net.Conn)  {
	defer acc.Close()
	//for {
		//获取用户地址
		info := acc.RemoteAddr().String()
		fmt.Println(info, "连接成功")
		c := make([]byte, 2048)
		//获取客户端信息
		for {
		  l, err := acc.Read(c)
		  if err != nil {
		  	fmt.Println("err: ", err)
			return
		  }
		  //fmt.Println(len(string(c[:l])))
		  if string(c[:l]) == "exit" || string(c[:l]) == "Exit" || string(c[:l]) == "EXIT" {
			fmt.Println(info, "退出连接")
			//os.Exit(1)
			return
		  }
		  fmt.Printf("%s发送消息： %s\n", info, string(c[:l]))
		  //处理后返回客户端
		  acc.Write([]byte(strings.ToUpper(string(c[:l]))))
	    }
}

func main()  {
	//监听客户端
	cn, err := net.Listen("tcp", "localhost:8080")
    if err != nil {
    	fmt.Println("err: ", err)
		return
	}
	defer cn.Close()
	//阻塞等待连接
	for {
		acc, err1 := cn.Accept()
		if err1 != nil {
			fmt.Println("err1: ", err1)
			continue
		}
		//最后断开连接
		defer acc.Close()
		//并发处理
		go client(acc)
		//声明一个切片
		//for {
		//	a := make([]byte, 2048)
		//	//接收消息并
		//	ret, err2 := acc.Read(a)
		//	if err2 != nil {
		//		fmt.Println("err2: ", err2)
		//		continue
		//	}
		//	//打印返回的长度
		//	fmt.Println("a: ", string(a[:ret]))
		//	//关闭当前连接
		//}
	}

}