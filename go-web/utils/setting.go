package utils

import (
	"fmt"
	//"log"
	"gopkg.in/ini.v1"
)

var (
	Mode     string
	HttpPort string
	Db       string
	DbHost   string
	DbPort   string
	DbUser   string
	DbPasswd string
	DbName   string
)

func Init() {
	file, err := ini.Load("/Users/gaohui/go/src/go-web/config/config.ini")
	if err != nil {
		fmt.Printf("文件加载错误：%s", err)
	}
	LoadServer(file)
	LoadData(file)
}

func LoadServer(file *ini.File) {
	Mode = file.Section("Server").Key("Mode").MustString("debug")
	HttpPort = file.Section("Server").Key("HttpPort").MustString("8080")
}

func LoadData(file *ini.File) {
	Db = file.Section("Database").Key("Db").MustString("mysql")
	DbHost = file.Section("Database").Key("DbHost").MustString("139.196.56.88")
	DbPort = file.Section("Database").Key("DbPort").MustString("3307")
	DbUser = file.Section("Database").Key("DbUser").MustString("mysql")
	DbPasswd = file.Section("Database").Key("DbPasswd").MustString("123456")
	DbName = file.Section("Database").Key("DbName").MustString("gin")
}
