package main

import (
	"fmt"
	"sync/atomic"
)

func main() {
	var (
		dogcounter uint64
		catcounter uint64
		pigcounter uint64
	)

	dogchan := make(chan struct{}, 1)
	catchan := make(chan struct{}, 1)
	pigchan := make(chan struct{}, 1)
	stopchan := make(chan struct{})

	go do(dogcounter, stopchan, catchan)
	go ca(catcounter, catchan, pigchan)
	go pi(pigcounter, stopchan, pigchan, dogchan)
	dogchan <- struct{}{}
	<-stopchan
}

func do(signal uint64, dogchan, catchan chan struct{}) {
	for {
		if signal >= 100 {
			return
		}
		//99
		<-dogchan
		fmt.Println("dog")
		atomic.AddUint64(&signal, 1)
		//100
		catchan <- struct{}{}
	}
}

func ca(signal uint64, catchan, pigchan chan struct{}) {
	for {
		if signal >= 100 {
			return
		}
		//99
		<-catchan
		fmt.Println("cat")
		atomic.AddUint64(&signal, 1)
		pigchan <- struct{}{}
	}
}

func pi(signal uint64, stopchan, pigchan, dogchan chan struct{}) {
	for {
		if signal >= 100 {
			stopchan <- struct{}{}
			return
		}
		<-pigchan
		fmt.Println("pig")
		atomic.AddUint64(&signal, 1)
		dogchan <- struct{}{}
	}
}
