package main

import "fmt"

//var  cmdLine = flag.NewFlagSet("name", flag.ExitOnError)
//func init()  {
//flag.NewFlagSet("name", flag.ExitOnError)
//	cmdLine.String("name", "everyOne", "sayhi")
//也可以用flag.string，相较于上面，会返回一个分配好用于存储命令值的地址
//flag.String("name", "everyOne", "sayhi")
//}
func main() {
	//	cmdLine.Parse(os.Args[1:])
	//	fmt.Printf("hello, %s")
	slice := []int{1, 2, 3, 4, 5}
	newSlice := slice[1:2:3]

	newSlice = append(newSlice, slice...)
	fmt.Println(newSlice)
	fmt.Println(slice)
	defer fmt.Println("first defer")
	for i := 0; i < 3; i++ {
		defer fmt.Printf("defer in for %d\n", i)
	}
	fmt.Println("last defer")
	//s1 := []int{1, 2, 3, 4, 5}
	//s2 := s1[0, 5]
	//s2 = append(s2, 6)

}
