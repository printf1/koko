package main

import (
	"fmt"
	"github.com/gomodule/redigo/redis"
)

var (
	_pool *redis.Pool
	err   error
)

func InitDb() {
	//d, _ := strconv.Atoi(utils.RedisDB)
	_pool = redis.NewPool(func() (redis.Conn, error) {
		conn, err := redis.Dial("tcp", "139.196.56.88:6379")

		if err != nil {
			fmt.Println(err)
			return nil, err
		}
		//conn.Do("AUTH", "123456")
		return conn, nil
	}, 20)

	if err != nil {
		fmt.Printf("连接%s:%s数据库实例失败", "139.196.56.88", "0")
		return
	}
	fmt.Printf("lianjiechenggong\n")
}

func PoolGet() redis.Conn {
	return _pool.Get()
}

func Rd() {
	InitDb()
	x := PoolGet()
	_, err1 := x.Do("AUTH", "123456")
	if err1 != nil {
		fmt.Printf("err1: %s", err1)
	}
	_, err := x.Do("SET", "koko", "gaohui", "EX", 10)
	if err != nil {
		fmt.Printf("err: %s", err)
		return
	}
}
