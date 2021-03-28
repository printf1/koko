package main

import (
	"fmt"
	"os"
	"runtime/trace"
)

//trace可视化调试
func main() {
	f, err := os.Create("trace.out")
	if err != nil {
		panic(err)
	}
	e := trace.Start(f)
	if e != nil {
		panic(e)
	}
	defer f.Close()
	fmt.Println("hello, world")
	trace.Stop()
}
