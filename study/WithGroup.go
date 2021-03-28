package main

import (
	"fmt"
	//"go/constant"
	"sync"
	"sync/atomic"
	"time"
)

func main()  {
	coordinateWithChan()
	fmt.Println()
	coordinateWithGroup()
}

func coordinateWithChan() {
	sign := make(chan struct{}, 2)
	num := int32(0)
	fmt.Printf("number %d WithChan struct{}", num)
	max := int32(10)
	go Addnum(&num, 1, max, func() {                      /////原版
		sign <- struct{}{}
	} )
	go Addnum(&num, 2, max, func() {
		sign <- struct{}{}
	})
	<- sign
	<- sign
}

func coordinateWithGroup()  {
	var wg sync.WaitGroup
	wg.Add(2)
	num := int32(0)
	fmt.Printf("number %d WithGroup\n", num)                 ///////改进版
	max := int32(10)
	go Addnum(&num, 3, max, wg.Done)
	go Addnum(&num, 4, max, wg.Done)
	wg.Wait()
}

func Addnum(numP *int32, id, max int32, deferFunc func())  {
	defer func() {
		deferFunc()
	}()
	for i :=0; ; i++ {
		curNum := atomic.LoadInt32(numP)
		if curNum >= max {
			break
		}
		newNum := curNum + 2
		time.Sleep(time.Millisecond * 200)
		if atomic.CompareAndSwapInt32(numP, curNum, newNum) {
			fmt.Printf("%d [%d-%d]\n", newNum, id, i)
		} else {
			fmt.Printf("the CAS operation failed, [%d-%d]\n", id, i)
		}
	}
}