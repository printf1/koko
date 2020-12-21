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
	err    error
	//host     = utils.RedisHost
	//port     = utils.RedisPort
	_pool    *redis.Pool
	poolsize = 20
)

func InitDb() {
	//fmt.Println(host, port)
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
	_conn.AutoMigrate(&User{}, &Article{}, &Category{}, &Message_obj{})

	fmt.Printf("lianjiechenggong")
	if err != nil {
		fmt.Printf("连接%s:%s数据库实例失败", utils.DbHost, utils.DbName)
	}
}

func GetDB() *gorm.DB {
	return _conn
}

func RedisInit() {
	//d, _ := strconv.Atoi(utils.RedisDB)
	_pool = redis.NewPool(func() (redis.Conn, error) {
		conn, err := redis.Dial("tcp", fmt.Sprintf("%s:%s", utils.RedisHost, utils.RedisPort),
			//最大的空闲连接数，表示即使没有redis连接时依然可以保持N个空闲的连接，而不被清除，随时处于待命状态。
			//MaxIdle: beego.AppConfig.DefaultInt("RedisMaxIdle", 1),
			//最大的激活连接数，表示同时最多有N个连接
			//MaxActive: beego.AppConfig.DefaultInt("RedisMaxActive", 10),
			//最大的空闲连接等待时间，超过此时间后，空闲连接将被关闭
			//IdleTimeout: 300 * time.Second,
			redis.DialConnectTimeout(time.Duration(1000)*time.Millisecond),
			redis.DialReadTimeout(time.Duration(1000)*time.Millisecond),
			redis.DialWriteTimeout(time.Duration(1000)*time.Millisecond),
			//redis.DialDatabase(d),
		)
		if err != nil {
			fmt.Println(err)
			return nil, err
		}
		conn.Do("AUTH", fmt.Sprintf("%s", utils.RedisPasswd))
		return conn, nil
	}, poolsize)
}

func PoolGet() redis.Conn {
	return _pool.Get()
}
