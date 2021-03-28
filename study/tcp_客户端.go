package main

import (
	"fmt"
	"net"
	"os"
)

func main() {
  //for {
      //连接服务端
	  cn, err := net.Dial("tcp", "localhost:8080")
	  if err != nil {
		fmt.Println("err: ", err)
		return
	  }
	  defer cn.Close()
	  //发送信息
	  go func() {
	      for {
	    	  //var a string
	    	  //fmt.Scan(&a)
	    	  //cn.Write([]byte(a))
	    	  //if a == "exit" || a == "EXIT" || a == "Exit" {
	    	  //	os.Exit(2)
	    	  //}
              //新建切片
	    	  x := make([]byte, 2048)
	    	  y, err1 := cn.Read(x)
	    	  if err1 != nil {
	    		  fmt.Println("err1: ", err1)
	    		  return
	    	  }
	    	  fmt.Println("对方返回: ", string(x[:y]))
	      }
      }()
	  str := make([]byte, 1024)
	  for {
	  	  n, err := os.Stdin.Read(str)
	  	  if err != nil {
	  	  	fmt.Println(err)
	  	  	return
	  	  }
	  	  cn.Write(str[:n])
	  	  if string(str[:n-1]) == "exit" {
	  	  	os.Exit(2)
	  	  }
	  }

}