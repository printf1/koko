package main

import (
	"cobraserver"
	"fmt"
	"math/rand"
	"os"
	"time"
)

func main()  {
	rand.Seed(time.Now().UnixNano())
	command := app.NewSchedulerCommand()
    if err := command.Execute(); err != nil {
    	fmt.Println(err)
    	os.Exit(1)
	}
}

