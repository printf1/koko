package main

import (
	"go-web/routers"
	"go-web/utils"
)

func main() {
	utils.Init()
	routers.InitRouter()
}
