package model

import (
	"fmt"
	"go-web/utils/errmsg"
	"strings"
)

type User struct {
	Username string `json:"username"`
	Password string `json:"password"`
	Role     int    `json:"role"`
}

var (
	users User
	code  int
	koko  strings.Builder
)

//查询用户是否存在
func CheckUser(user string) (code int) {
	que := fmt.Sprintf("select * from User where username = '%s';", user)
	err := InitDb()
	defer conn.Close()
	if err != nil {
		fmt.Println("数据库初始化失败")
		fmt.Println(err)
		code = errmsg.ERROR
	}
	/*
		cnn, err1 := conn.Prepare(que)
		if err1 != nil {
			fmt.Println("预处理失败")
			return errmsg.ERROE
		}
		res, err2 := cnn.Exec(user)
		if err2 != nil {
			fmt.Println("添加失败")
			return  errmsg.ERROE
		}
		if res == nil {
			fmt.Println("用户可正常添加")
			return errmsg.SUCCESS
		}

		if res ==  {
			fmt.Println("用户存在")
			return errmsg.USER_EXIST
		}
		return errmsg.SUCCESS
	*/
	cnn := conn.QueryRow(que)
	//fmt.Println(que)
	cnn.Scan(&users.Username, &users.Password, &users.Role)

	if users.Username != "" {
		fmt.Println("用户存在")
		code = errmsg.USER_EXIST
	} else {
		code = errmsg.SUCCESS
	}
	return
}

//新增用户
func AddUser(data *User) (code int) {
	//var infoB int
	add := fmt.Sprintf("insert into User value('%s', '%s', '%s')", data.Username, data.Password, data.Role)
	err := InitDb()
	defer conn.Close()
	if err != nil {
		fmt.Println("数据库初始化失败")
		fmt.Println(errmsg.ERROR)
		code = errmsg.ERROR
	}
	cnn, err1 := conn.Prepare(add)
	if err1 != nil {
		fmt.Println("预处理失败")
		code = errmsg.ERROR
	}
	_, err = cnn.Exec()
	if err != nil {
		fmt.Println("添加失败")
		code = errmsg.ERROR
	} else {
		fmt.Println("添加成功")
		code = errmsg.SUCCESS
	}
	return
}

//查询用户列表
func GetUsers(pageSize int, pageNumber int) (code int, U []string) {
	//var U []string
	que := fmt.Sprintf("select username from User where role > ?")
	//分页
	a, err := conn.Query(que, 0)
	if err != nil {
		code = errmsg.ERROR
		fmt.Println("查询多用户错误")
	}
	for a.Next() {
		a.Scan(&users.Username)
		U = append(U, users.Username)
	}
	code = errmsg.SUCCESS
	return

}

func DelUser(user string) (code int) {
	que := fmt.Sprintf("delete from User where username = ?", user)
	cnn, err := conn.Prepare(que)
	if err != nil {
		fmt.Println("删除失败")
		code = errmsg.ERROR
	}
	cnn.Exec(que)
	code = errmsg.SUCCESS
	return
}

func EditUser(role, user string) (code int) {
	que := fmt.Sprintf("update User set role = ? where username = ?", role, user)
	cnn, err := conn.Prepare(que)
	if err != nil {
		fmt.Println("更新失败")
		code = errmsg.ERROR
	}
	cnn.Exec(que)
	code = errmsg.SUCCESS
	return
}
