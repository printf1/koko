package main

import (
	"go-web/model"
	"go-web/routers"
	"go-web/utils"
)

func main() {
	utils.Init()
	cnn := model.InitDb()
	routers.InitRouter()
	cnn.Close()
}
