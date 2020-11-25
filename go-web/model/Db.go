package model

import (
	"fmt"
	_ "github.com/go-sql-driver/mysql"
	"github.com/jinzhu/gorm"
	"go-web/utils"
	"time"
)

var (
	driver = utils.Db
	conn   *gorm.DB
	err    error
)

func InitDb() *gorm.DB {
	//utils.Init()
	//fmt.Println(utils.Db, utils.DbHost, utils.DbPasswd)
	conn, err = gorm.Open(utils.Db, fmt.Sprintf("%s:%s@tcp(%s:%s)/%s?charset=utf8mb4", utils.DbUser, utils.DbPasswd, utils.DbHost, utils.DbPort, utils.DbName))
	//defer conn.Close()
	conn.SingularTable(true)
	//连接池最大闲置数
	conn.DB().SetMaxIdleConns(10)
	//数据库最大连接数
	conn.DB().SetMaxOpenConns(100)
	//最大可服用时间
	conn.DB().SetConnMaxLifetime(10 * time.Second)
	//自动迁移模型
	conn.AutoMigrate(&User{}, &Article{}, &Category{})

	fmt.Printf("lianjiechenggong")
	if err != nil {
		fmt.Printf("连接%s:%s数据库实例失败", utils.DbHost, utils.DbName)
	}
	return conn
}
