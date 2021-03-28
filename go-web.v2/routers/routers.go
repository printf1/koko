package routers

import (
	"github.com/gin-gonic/gin"
	"go-web/api/v1"
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
		router.GET("/user", v1.UserQuery)
		router.PUT("/user:id", v1.UserEdit)
		router.DELETE("/user/:id", v1.UserDel)
		//catagory
		//article
	}
	r.Run()
}
