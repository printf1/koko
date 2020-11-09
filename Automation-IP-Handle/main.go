package main

import (
	"Automation-IP-Handle/iph"
	"os"
	"fmt"
)
//"not"代表IP不存在
//"per"代表IP无权限

func main()  {
		v := os.Args[1]
        if v == "not" {
            handle.Start()
    	}else if v == "per" {
			handle.Connect()
		}else {
			fmt.Println("参数格式不正确，请重新输入")
			return
		}

}