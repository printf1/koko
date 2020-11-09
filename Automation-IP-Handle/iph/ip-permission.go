package handle

import ( 
	"gopkg.in/ini.v1"
    "database/sql"
	"fmt"
	_ "github.com/go-sql-driver/mysql"
	"log"
	//"sync"
	"bufio"
	"io"
	"strings"
	"os"
	"time"
)

var (
	host string
	user string
	passwd string
	port string
	db string
	conn *sql.DB
	err error
	//l sync.Cond
	ch = make(chan string)
    //ip = make(chan string, 10)
)



func Get_DB()  {
	file, err := ini.Load("/Users/gaohui/go/src/Automation-IP-Handle/config/config.ini")
	if err != nil {
		fmt.Println("配置文件加载出错")
	}
	host = file.Section("DATABASE").Key("host").MustString("139.196.47.104")
	user = file.Section("DATABASE").Key("user").MustString("root")
	passwd = file.Section("DATABASE").Key("passwd").MustString("123456")
	port = file.Section("DATABASE").Key("port").MustString("3306")
	db = file.Section("DATABASE").Key("database").MustString("mysql")
	//fmt.Println(host, user, passwd, port, db)
}

func Connect()  {
	Get_DB()
	conn, err = sql.Open("mysql", fmt.Sprintf("%s:%s@(%s:%s)/%s?charset=utf8mb4", user, passwd, host, port, db))
    if err != nil {
		fmt.Printf("连接%s数据库失败", host)
		log.Fatal(err)
		return
	}
	defer conn.Close()
	fmt.Println("连接成功")
    conn.SetMaxIdleConns(10)
	conn.SetConnMaxLifetime(10 * time.Minute)
	conn.SetMaxOpenConns(100)
	Get_IP()
	//<- ch
    fmt.Println("处理完成，连接关闭")
}

func Update(ho string)  {
	sql := "update mysql.parents set tel = 'MMMMM' where name = ?"
	pre, err1 := conn.Begin()
	if err != nil {
		fmt.Println("Begin失败")
		log.Fatal(err1)
		return 
	}
	stmt, err4 := pre.Prepare(sql)
	if err4 != nil {
		fmt.Printf("prepare失败，回滚:%s", err4)
		pre.Rollback()
		log.Fatal(err4)
		return
	}
	_, err2 := stmt.Exec(ho)
	if err2 != nil {
		fmt.Println("执行失败，回滚")
		pre.Rollback()
		log.Fatal(err2)
	}
	err3 := pre.Commit()
	if err3 != nil {
		fmt.Println("提交失败")
		log.Fatal(err3)
		return
	}
	fmt.Printf("%s 更新成功\n", ho)
}

func Get_IP() {
	//defer func() {
		
	//	}()
	file, err := os.Open("/Users/gaohui/go/src/Automation-IP-Handle/IP")
	if err != nil {
		fmt.Println("打开文件失败")
		log.Fatal(err)
		return 	
	}
	defer file.Close()
	buf := bufio.NewScanner(file)
	for buf.Scan(){
		line := buf.Text()
		err1 := buf.Err()
		line = strings.TrimSpace(line)
		if err1 != nil {
			if err1 == io.EOF {
				fmt.Println("读取完毕")
				log.Fatal(err1)
			}
			fmt.Println("读取失败")
			log.Fatal(err1)
			return
		}
		//fmt.Println(line)
        Update(line)
	}
    //ch <- "OK"
}

