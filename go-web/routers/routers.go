package routers

import (
	"github.com/gin-gonic/gin"
	v1 "go-web/api/v1"
	"go-web/utils"
	//"net/http"
)

func InitRouter() {
	gin.SetMode(utils.Mode)
	r := gin.Default()
	router := r.Group("api/v1")
	{
		/*
			v1.GET("hello", func(c *gin.Context) {
				c.JSON(http.StatusOK, gin.H{
					"msg": "200",
				})
			})
		*/
		//uer
		router.POST("/user/add", v1.UserAdd)
		router.GET("/user:id/get", v1.UserQuery)
		router.PUT("/user:id/put", v1.UserEdit)
		router.DELETE("/user:id/del", v1.UserDel)
		//catagory
		//article
	}
	r.Run()
}
