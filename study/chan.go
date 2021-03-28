package main

import (
	"fmt"
	"time"
	//"sync"
	//"time"
)

func main() {
	cha := make(chan int, 5)
	//cha = make(chan int)
	go co(cha)
	for i := 0; i < 10; i++ {
		if i == 6 {

			close(cha)
		}
		time.Sleep(1 * time.Second)
		cha <- i
	}

}
func co(cha chan int) {
	//ca := cha
	for ch := range cha {

		fmt.Println(ch)
	}
}
