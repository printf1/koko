package handle

import ( 
	//"gopkg.in/ini.v1"
	//"database/sql"
	"sync"
	//"Automation-IP-Handle/iph"
	"fmt"
	//_ "github.com/go-sql-driver/mysql"
	"time"
	"strconv"
	//"reflect"
	"math/rand"
)

func GetTime() int64 {
	//获取当前时间
	
	a := time.Now().Format("2006-01-02 15:04:05")
	fmt.Println(a, myname)
	//当前时间戳
	b := time.Now().Unix()
	return b 

}


func Get_IP(ip chan<- string, co sync.Mutex, l sync.Cond)  {
	//ip chan<- string, co *sync.Mutex, l *sync.Cond
	for {
		co.Lock()
		for len(ip) == 3 {
			l.Wait()
		}
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
		ip <- line
		co.Unlock()
		l.Broadcast()
		time.Sleep(time.Second)
				
	}
	
}

func Insert(ip <-chan string, co sync.Mutex, l sync.Cond, name string, age string) {	
	handle.Get_DB()
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
	for {
	   co.Lock()
	   for len(ip) == 0 {
		   l.Wait()
	   }
	   
	   sql = "insert into mysql.parentd (id, name, age, job, kid_id, tel, relation) value(?, ?, ?, ?, ?, ?, ?)"
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
	   ho := <- ip
	   _, err2 := stmt.Exec(rand.Intn(100), "name", "age", "Linux", 5, ho, "CS")
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
	   fmt.Printf("%s 更新成功\n", ip)
	   co.Unlock()
	   l.Broadcast()
	   time.Sleep(time.Millisecond * 500)
	}
	
}

func Start() {
	myname := "admin"
	rand.Seed(time.Now().UnixNano())
	var (
		ch = make(chan bool)
		ip = make(chan string, 3)
		l sync.Cond
		co sync.Mutex
	)
	x := strconv.FormatInt(int64, GetTime())

	for {
		go Get_IP(ip, co, l)
	}
	for {
		go Insert(ip, co, l, myname, x)
	}
	<- ch
	
}