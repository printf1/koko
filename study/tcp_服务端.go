package main

import (
	"fmt"
	"log"
	"net"
	"strings"
)

func conn(co net.Conn)  {
    addr := co.RemoteAddr().String()
    fmt.Printf("用户%s链接Successful\n", addr)
	defer co.Close()
    sli := make([]byte, 2048)
	for {
		n, err2 := co.Read(sli)
		if err2 != nil {
			log.Println("err2: %s\n", err2)
		}
		//fmt.Println((string(sli[:n])))
		//fmt.Println(len(string(sli[:n])))
		//fmt.Println((string(sli[:n-2])))
		//fmt.Println(len(string(sli[:n-2])))
		if "exit" == string(sli[:n-1]) {
			fmt.Printf("用户%s离开聊天室\n", addr)
			continue
		}
		//转字符串，转大写，转字节，返回
		fmt.Printf("%s: 发送 %s\n", addr, string(sli[:n]))
		co.Write([]byte(strings.ToUpper(string(sli[:n]))))
	}
}

func main()  {
	//go func() {
		cnn, err := net.Listen("tcp", "localhost:8080")
		if err != nil {
			log.Println("监听服务失败: &s\n", err)}
	    	defer cnn.Close()
		for  {
	    	co, err1 := cnn.Accept()
	    	if err1 != nil {
	    		log.Println("连接失败: %s\n", err1)
	    		return
	    	}
	    go conn(co)

	    }
	//}()
}


