package utils

import (
	"fmt"
	"gopkg.in/ini.v1"
)

var (
	Mode            string
	HttpPort        string
	Db              string
	DbHost          string
	DbPort          string
	DbUser          string
	DbPasswd        string
	DbName          string
	RedisHost       string
	RedisPort       string
	RedisPasswd     string
	RedisDB         string
	RegionID        string
	AccessKeyID     string
	AccessKeySecret string
	SignName        string
	TemplateCode    string
)

func Init() {
	file, err := ini.Load("/Users/gaohui/go/src/go-web/config/config.ini")
	if err != nil {
		fmt.Printf("文件加载错误：%s", err)
	}
	LoadServer(file)
	LoadData(file)
	LoadRedis(file)
	LoadAliyun(file)
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

func LoadRedis(file *ini.File) {
	RedisHost = file.Section("Redis").Key("Host").MustString("139.196.56.88")
	RedisPort = file.Section("Redis").Key("Port").MustString("6379")
	RedisPasswd = file.Section("Redis").Key("Passwd").MustString("123456")
	RedisDB = file.Section("Redis").Key("RedisDB").MustString("0")
}

func LoadAliyun(file *ini.File) {
	RegionID = file.Section("Aliyun").Key("RegionID").MustString("koko")
	AccessKeyID = file.Section("Aliyun").Key("AccessKeyID").MustString("koko")
	AccessKeySecret = file.Section("Aliyun").Key("AccessKeySecret").MustString("koko")
	SignName = file.Section("Aliyun").Key("SignName").MustString("koko")
	TemplateCode = file.Section("Aliyun").Key("TemplateCode").MustString("koko")
}
