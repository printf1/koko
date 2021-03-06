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
	Phone    string `gorm: "type: varchar(20); not null" json:"phone"`
}

func CheckUser(name string) int {
	var users User
	c := GetDB()
	c.Select("id").Where("username = ?", name).First(&users)
	if users.ID > 0 {
		code := errmsg.USER_EXIST
		return code
	}
	time.Sleep(10 * time.Millisecond)
	return errmsg.SUCCESS
}

func AddUser(data *User) int {
	//if boo := conn.NewRecord(&data); boo != true {
	//	return errmsg.USER_EXIST
	//}
	c := GetDB()
	err := c.Create(&data).Error
	if err != nil {
		return errmsg.ERROR
	}
	return errmsg.SUCCESS
}

func GetUsers(pageSize, pageNumber int) []User {
	var users []User
	c := GetDB()
	err := c.Limit(pageSize).Offset((pageNumber - 1) * pageSize).Find(&users).Error
	if err != nil && err != gorm.ErrRecordNotFound {
		return nil
	}
	return users
}

func EditUser(UserName string) int {
	return 0
}

func DelUser() int {
	return 0
}
