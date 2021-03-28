package main

import (
	"database/sql"
	 "fmt"
    _ "github.com/go-sql-driver/mysql"
	"log"
)

var (
	drivername = "mysql"
	user = "root"
	passwd = ""
	ipaddress = ""
	port = "3306"
	database = "mysql"
)


var conn *sql.DB   //连接池对象
var u1 parents
var err error

type parents struct {
	id int
	name string
	age int
	job string
	kid_id string
	tel string
	relation string
}

func Query(n int) {
	sqlstr := "select * from parents where id > ?;"
	info, err := conn.Query(sqlstr, n)
	defer info.Close()
	//sel, err1 := conn.Prepare("insert into parents (id, name, age, job, kid_id, tel, relation) values(?, ?, ?, ?, ?, ?, ?)")
	if err != nil {
		fmt.Println(err)
	}
	for info.Next() {
		err := info.Scan(&u1.id, &u1.name, &u1.age, &u1.job, &u1.kid_id, &u1.tel, &u1.relation)
		if err != nil {
			fmt.Println(err)
		}
		fmt.Printf("u1: %#v\n", u1)
	}
}



func Init() {
	conn, err = sql.Open(drivername, fmt.Sprintf("%s:%s@(%s:%s)/%s?charset=utf8mb4", user, passwd, ipaddress, port, database))
	//defer conn.Close()
	if err != nil {
		fmt.Println(err)
		return
	}
	if err1 := conn.Ping(); err1 != nil {
		log.Fatal(err1)
		return
	}
	fmt.Println("Connect Successful")
}

func main() {
	//con, err := sql.Open("mysql", "root:Acc.gh-8@(139.224.65.35:3306)/mysql")
	//fmt.Println(fmt.Sprintf("%s:%s@(%s:%s)/%s?charset=utf8mb4", user, passwd, ipaddress, port, database))
	Init()
	Query(0)
	defer conn.Close()

	//conn.QueryRow("select * from parents").Scan(&u1.id, &u1.name, &u1.age, &u1.job, &u1.kid_id, &u1.tel, &u1.relation)
	//fmt.Printf("u1: %#v\n", u1)
}
