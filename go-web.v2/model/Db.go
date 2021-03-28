package model

import (
	"database/sql"
	"fmt"
	_ "github.com/go-sql-driver/mysql"
	"go-web/utils"
	"log"
	"time"

)

var (
	driver = utils.Db
	//dbpath = fmt.Sprintf("%s:%s@(%s:%s)/%s?charset=utf8", utils.DbUser, utils.DbPasswd, utils.DbHost, utils.DbPort, utils.DbName)
    sql_init = "create table web (id int not null primary key, username varchar(20), password varchar(10));"
	conn *sql.DB
	err error
)

func InitDb() {
	//utils.Init()
	//fmt.Println(utils.Db, utils.DbHost, utils.DbPasswd)
    conn, err = sql.Open(utils.Db, fmt.Sprintf("%s:%s@(%s:%s)/%s?charset=utf8mb4", utils.DbUser, utils.DbPasswd, utils.DbHost, utils.DbPort, utils.DbName))
	defer conn.Close()
    conn.SetMaxIdleConns(10)
	conn.SetConnMaxLifetime(10 * time.Minute)
	conn.SetMaxOpenConns(100)
    
	if err != nil {
		fmt.Printf("连接%s:%s数据库实例失败", utils.DbHost, utils.DbName)
	}

	if _, err1 := conn.Exec(sql_init); err1 != nil {
		log.Fatal(err1)
		return
	} else {
		fmt.Println("web table create successful")
	}
}