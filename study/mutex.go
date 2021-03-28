package main

import (
	"fmt"
	"flag"
	"bytes"
	"io"
	"io/ioutil"
	"log"
	"sync"
)

var protecting uint

func init() {
	flag.UintVar(&protecting, "protecting", 1, "lalala")
}

func main()  {
	flag.Parse()
	//声明缓冲区
	var buffer bytes.Buffer

	const (
		max1 = 5   //启用goroutine的数量
		max2 = 10  //每个goroutine写入数据库爱的数量
		max3 = 10  //每个数据块中需要有多少个重复的数据
	)
	//mu代表以下流程要用互斥锁
	var mu sync.Mutex
	//sign代表信号通道
	//声明通道sign的时候以chan struct{}作为其类型的。其中的类型字面量struct{}有些类似于空接口类型interface{},它代表了既不包含任何字段也不拥有
	//任何方法的空结构体类型。 struct{}类型值的表示方法只有一个，即:struct{}{}。并且，它占用的内存空间是0字节。确切的说，这个值在整个go程序中
	//永远都只会存一份。虽然我们无数次的使用这个值的字面量，但是用到的却都是同一个值。 当我们仅仅把通道当做传递某种简单信号的介质的时候，
	//用struct{}作为其元素类型是再好不过的了。
	sign := make(chan struct{}, max1)

	for i := 1; i < max1; i++ {
		go func(id int, writer io.Writer) {
			defer func() {
				sign <- struct{}{}
			}()
		    for j := 1; j < max2; j++ {
                //准备数据
				header := fmt.Sprintf("\n[id: %d, interation: %d]", id, j)
				data := fmt.Sprintf(" %d", id * j)
				if protecting > 0 {
					mu.Lock()
				}
				_, err := writer.Write([]byte(header))
				if err != nil {
					log.Printf("error: %s [%d]", err, id)
				}
				for k := 0; k < max3; k++ {
					_, err1 := writer.Write([]byte(data))
					if err1 != nil {
						log.Printf("error: %s [%d]", err1, id)
					}
				}
				if protecting > 0 {
					mu.Unlock()
				}
			}
		
		}(i, &buffer) 
	}	
	for i := 0; i < max1; i++ {
		<- sign
	}
	data, err2 := ioutil.ReadAll(&buffer)
	if err2 != nil {
		log.Fatalf("fatal error: %s", err2)
	}
	log.Printf("the contents: \n%s", data)
}