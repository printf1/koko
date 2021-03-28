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
	  for {
		  var a string
		  fmt.Scan(&a)
		  cn.Write([]byte(a))
		  if a == "exit" {
		  	os.Exit(1)
		  }

		  x := make([]byte, 2048)
		  y, err1 := cn.Read(x)
		  if err1 != nil {
			  fmt.Println("err1: ", err1)
			  return
		  }
		  fmt.Println("服务器返回：", string(x[:y]))
	  }
  //}

}