package main

import (
	"fmt"
	"sync"
	"sync/atomic"
)

//使用goroutine依次打印cat,dog,pig一百次，
//for， 通道，

func main() {
	var (
		dogcounter uint64
		catcounter uint64
		pigcounter uint64
		wg         sync.WaitGroup
	)

	dogchan := make(chan struct{}, 1)
	catchan := make(chan struct{}, 1)
	pigchan := make(chan struct{}, 1)

	wg.Add(3)
	go dog(&wg, dogcounter, dogchan, catchan)
	go cat(&wg, catcounter, catchan, pigchan)
	go pig(&wg, pigcounter, pigchan, dogchan)

	dogchan <- struct{}{}
	wg.Wait()
}

func dog(wg *sync.WaitGroup, signal uint64, dogchan, catchan chan struct{}) {
	for {
		if signal >= 100 {
			wg.Done()
			return
		}
		<-dogchan
		fmt.Println("dog")
		atomic.AddUint64(&signal, 1)
		catchan <- struct{}{}
	}
}

func cat(wg *sync.WaitGroup, signal uint64, catchan, pigchan chan struct{}) {
	for {
		if signal >= 100 {
			wg.Done()
			return
		}
		<-catchan
		fmt.Println("cat")
		atomic.AddUint64(&signal, 1)
		pigchan <- struct{}{}
	}
}

func pig(wg *sync.WaitGroup, signal uint64, pigchan, dogchan chan struct{}) {
	for {
		if signal >= 100 {
			wg.Done()
			return
		}
		<-pigchan
		fmt.Println("pig")
		atomic.AddUint64(&signal, 1)
		dogchan <- struct{}{}
	}
}
