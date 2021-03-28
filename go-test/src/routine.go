package main

import (
	"fmt"
	"sync"
)

var (
	wg = sync.WaitGroup{}
	mu = sync.Mutex{}
	m  = make(map[int]int)
)

func main() {
	wg.Add(10)
	for i := 0; i < 10; i++ {
		go func(i int) {
			defer wg.Done()
			mu.Lock()
			m[i] = i
			fmt.Println(m)
			mu.Unlock()
		}(i)
	}
	wg.Wait()
	fmt.Println(len(m))
}
