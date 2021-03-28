package main

import (
	"fmt"
	"os"
	"os/exec"
)
//检查ntp.conf文件
func check_file(fullPath string) {
	//file_path := BasePath + filename
	file, err := os.Stat(fullPath)
	a := file.Name()  //file.name  file.size可以查看文件属性
	if err != nil {
		fmt.Println(err)
	//}
	//_, err := os.Stat(fullepath)
	//if err != nil {
	//	fmt.Println("%s doesn't exist", filename)
	} else {
     fmt.Printf("file %s is exist", a)
     app_check()
     ntp_status_check()
    }
}

//检查ntp服务，正常则检查误差，异常则重启
func ntp_status_check() {
	a := sys_version()
    if a == "el7" {
		run()
	} else if a == "el6" {
		//statements
		run()
	} else {
		fmt.Printf("%s don't need service", a)
	}
}

//主执行函数
func run() {
	cmd := exec.Command("ps","-ef", "|", "awk", "{print $1}", "|", "grep", "ntp")
	check_offset()
	std, err := cmd.StdoutPipe()
	if std != nil {
		if err != nil {
			fmt.Println(err)
			os.Exit(1)
		}
		fmt.Println("ntp is running")

	} else {
		fmt.Println("ntp is not running")
		cmd1 := exec.Command("systemctl", "restart", "ntp")
		After_check()
		stdr, err1 := cmd1.StdoutPipe()
		if stdr != nil {
			if err1 != nil {
				fmt.Println(err1)
				os.Exit(1)
			}
			fmt.Println("重启失败，请手动调试")
			return
		}
	}
}
    //事后确认
func After_check() {
	cmd := exec.Command("ps","-ef", "|", "awk", "{print $1}", "|", "grep", "ntp")
	//x := `ps -ef | awk {print $1} | grep ntp`
	std, err := cmd.StdoutPipe()
	if std != nil {
		if err != nil {
			fmt.Println(err)
		}
		fmt.Println("重启失败，请手动调试")
		return
	}
} 
//检查数据库server
func app_check() {
	app := exec.Command("ps", "-ef", "|", "awk", "{print $1}", "|", "grep", "-w", "oracle|mysql|db2inst2|informix|mongobd", "|", "sort", "|", "uniq")
	std, err := app.StdoutPipe()
	if std != nil {
		if err != nil {
			os.Exit(1)
		}
		fmt.Println("don't touch")
	} else {
		fmt.Println("OK")
    }
}
//检查系统版本
func sys_version() string {
	var ver string
	a := exec.Command("uname", "-r", "|", "grep", "-w", "el5")
	b := exec.Command("uname", "-r", "|", "grep", "-w", "el6")
	c := exec.Command("uname", "-r", "|", "grep", "-w", "el7")
	std1, err1 := a.StdoutPipe()
	std2, err2 := b.StdoutPipe()
	std3, err3 := c.StdoutPipe()
	if std1 != nil {
		if err1 != nil {
			fmt.Println("err1")
			os.Exit(1)
		}
		ver = "el5"
	}
	if std2 != nil {
		if err2 != nil {
			fmt.Println("err2")
			os.Exit(1)
		}
		ver = "el6"
	}
	if std3 != nil {
		if err3 != nil {
			fmt.Println("err3")
			os.Exit(1)
		}
		ver = "el7"
	}

	return ver
}
//判断误差
func check_offset() {
	//取当前时间
	cur_time := exec.Command("ntpq", "-q", "|", "grep", "*", "|", "awk", "{print $1}", "|", "tr", "-d", "*")
	//确定误差
	offset := exec.Command("ntpq", "-q", "|", "grep", "*", "|", "awk", "{print $1}", "|", "(tr -d - || tr -d +)")
    std1, err1 := cur_time.StdoutPipe()
    std2, err2 := offset.StdoutPipe()
    if err1 != nil || err2 != nil {
    	fmt.Println(err1,err2)
    	os.Exit(1)
	}
	if int(std2) > 60000 && int(std2) < 1200000 {
		// 停ntp服务
		cmd1 := exec.Command("service", "stop", "ntp")
		//同步当前时间
		cmd2 := exec.Command("ntp", "std1")
		//重新启动
		cmd3 := exec.Command("service", "ntp", "start")
		std3, err3 := cmd1.StdoutPipe()
		std4, err4 := cmd2.StdoutPipe()
		std5, err5 := cmd3.StdoutPipe()
		if std3 != nil {
			if err3 != nil {
				fmt.Println(err3)
			}
			fmt.Println("ntp停止失败")
			return
		}
		if std4 != nil {
			if err4 != nil {
				fmt.Println(err4)
			}
			fmt.Println("ntp同步失败")
			return
		}
		if std5 != nil {
			if err5 != nil {
				fmt.Println(err5)
			}
			fmt.Println("ntp启动失败")
			return
		}
		//事后检查
		After_check()
	} else if int(std2) > 120000 {
		//statements
		fmt.Println("ntp need fix")
		os.Exit(1)
	} else if int(std2) < 60000 {
		//statements
		fmt.Println("ntp don't need fix")
		os.Exit(1)
	}
}
//入口main
func main() {
	a := os.Args
	b := a[1]  //BasePath
	c := a[2]  //filename
	check_file(b, c)
	app_check()
	sys_version()
	ntp_status_check()
	check_offset()
}
//执行main
//main()