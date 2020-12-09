package model

import (
	"fmt"
	_ "github.com/go-sql-driver/mysql"
	"github.com/gomodule/redigo/redis"
	"github.com/jinzhu/gorm"
	"go-web/utils"
	"time"
)

var (
	driver = utils.Db
	_conn  *gorm.DB
	//cnn    *redis.Conn
	err  error
	host = utils.RedisHost
	port = utils.RedisPort
	//conn = redis.NewConn()
	_pool    *redis.Pool
	poolsize = 20
)

func InitDb() {
	//utils.Init()
	//fmt.Println(utils.Db, utils.DbHost, utils.DbPasswd)
	_conn, err = gorm.Open(utils.Db, fmt.Sprintf("%s:%s@tcp(%s:%s)/%s?charset=utf8&parseTime=true", utils.DbUser, utils.DbPasswd, utils.DbHost, utils.DbPort, utils.DbName))

	//defer conn.Close()
	_conn.SingularTable(true)
	//连接池最大闲置数
	_conn.DB().SetMaxIdleConns(10)
	//数据库最大连接数
	_conn.DB().SetMaxOpenConns(100)
	//最大可复用时间
	_conn.DB().SetConnMaxLifetime(10 * time.Second)
	//自动迁移模型
	_conn.AutoMigrate(&User{}, &Article{}, &Category{})

	fmt.Printf("lianjiechenggong")
	if err != nil {
		fmt.Printf("连接%s:%s数据库实例失败", utils.DbHost, utils.DbName)
	}
}

func GetDB() *gorm.DB {
	return _conn
}

func RedisInit() {
	_pool = redis.NewPool(func() (redis.Conn, error) {
		conn, err := redis.Dial("tcp", fmt.Sprintf("%s:%s", host, port),
			redis.DialConnectTimeout(time.Duration(1000)*time.Millisecond),
			redis.DialReadTimeout(time.Duration(1000)*time.Millisecond),
			redis.DialWriteTimeout(time.Duration(1000)*time.Millisecond),
			redis.DialDatabase(0),
		)
		if err != nil {
			fmt.Println(err)
			return nil, err
		}
		return conn, nil
	}, poolsize)
}

func PoolGet() redis.Conn {
	return _pool.Get()
}
