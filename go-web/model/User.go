package model

import (
	"github.com/jinzhu/gorm"
	"go-web/utils/errmsg"
	"time"
)

type User struct {
	gorm.Model
	Username string `gorm: "type: varchar(20); not null" json:"username"`
	Password string `gorm: "type: varchar(20); not null" json:"password"`
	Address  string `gorm: "type: varchar(40); not null" json:"address"`
}

func CheckUser(name string) int {
	var users User
	conn.Select("id").Where("username = ?", name).First(&users)
	if users.ID > 0 {
		code := errmsg.USER_EXIST
		return code
	}
	time.Sleep(10 * time.Millisecond)
	return errmsg.SUCCESS
}

func AddUser(data *User) int {
	err := conn.Create(&data).Error
	if err != nil {
		return errmsg.ERROR
	}
	return errmsg.SUCCESS
}

func GetUsers(pageSize, pageNumber int) []User {
	var users []User
	err := conn.Limit(pageSize).Offset((pageNumber - 1) * pageSize).Find(&users).Error
	if err != nil && err != gorm.ErrRecordNotFound {
		return nil
	}
	return users
}

func EditUser() int {
	return 0
}

func DelUser() int {
	return 0
}
