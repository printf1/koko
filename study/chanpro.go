package main

import (
	"fmt"
    "math/rand"
    "sync"
    "time"
)

//var sum int
var k sync.Cond

    //sendCond = sync.NewCond(&k)             
    //recvCond = sync.NewCond(k.RLock())

func produce(in chan<- int, idx int, co sync.Mutex) {
	for {
	  co.Lock()
      for len(in) == 5 {
	     k.Wait()
	  }
	  num := rand.Intn(100)
	  in <- num
	  fmt.Printf("第%2d个生产者，数据为%2d, 通道剩余%d个\n", idx, num, len(in))
	  co.Unlock()
	  k.Signal()
	  time.Sleep(time.Second)
	}
}
func consumer(out <-chan int, idx int, co sync.Mutex) {
    for {
	   co.Lock()
	   for len(out) == 0 {
		   k.Wait()
	   } 
	   num := <- out
	   fmt.Printf("第%2d个消费者，数据为%2d, 通道剩余%d个\n", idx, num, len(out))
	   co.Unlock()
	   k.Signal()
	   time.Sleep(time.Millisecond * 500)
    }
}
func main() {

	quit := make(chan bool)
	var co sync.Mutex  //创建互斥锁
	rand.Seed(time.Now().UnixNano())  
    ch := make(chan int, 5)
    for i := 0; i < 13; i++ {
		go produce(ch, i + 1, co)
	}
    for i := 0; i < 7; i++ {
		go consumer(ch, i + 1, co)
	}
    <- quit   
}