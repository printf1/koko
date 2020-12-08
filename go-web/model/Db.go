package model

import (
	"fmt"
	//"github.com/go-redis/redis"
	_ "github.com/go-sql-driver/mysql"
	"github.com/gomodule/redigo/redis"
	"github.com/jinzhu/gorm"
	"go-web/utils"
	"time"
)

var (
	driver = utils.Db
	conn   *gorm.DB
	//cnn    *redis.Conn
	err  error
	host = utils.RedisHost
	port = utils.RedisPort
	//conn = redis.NewConn()
	pool     *redis.Pool
	poolsize = 20
)

func InitDb() *gorm.DB {
	//utils.Init()
	//fmt.Println(utils.Db, utils.DbHost, utils.DbPasswd)
	conn, err = gorm.Open(utils.Db, fmt.Sprintf("%s:%s@tcp(%s:%s)/%s?charset=utf8&parseTime=true", utils.DbUser, utils.DbPasswd, utils.DbHost, utils.DbPort, utils.DbName))

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

func RedisInit() {
	pool = redis.NewPool(func() (redis.Conn, error) {
		conn, err := redis.Dial("tcp", fmt.Sprintf("%s:%s", host, port))
		if err != nil {
			fmt.Println(err)
			return nil, err
		}
		return conn, nil
	}, poolsize)
}

func PoolGet() redis.Conn {
	return pool.Get()
}
