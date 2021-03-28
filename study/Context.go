package main

import (
	"context"
	"fmt"
	"sync/atomic"
)

func coordinateWithContext() {
	total := 12
	var num int32
	fmt.Printf("the number: %d [with Context.Context]\n", num)
	ctx, cancelFunc := context.WithCancel(context.Background())
	for i := 1; i <= total; i++ {
		go Addnum(&num, i， 3， func(){
			if atomic.LoadInt32(&num) == int32(total) {
				cancelFunc()
			}
		})
	}
	<- ctx.Done()
	fmt.Println("End.")
}
