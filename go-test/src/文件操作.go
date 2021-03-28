package main

import (
	"os"
	"fmt"
	"io"
	"bufio"
)

func writefile(file string) {
	//创建文件
    f, err := os.Create(file)
    //是否创建失败
    if err != nil {
    	return
	}
	//defer最后关闭文件
	defer f.Close()
    //写入内容
    for i := 0; i < 10; i++ {
		//fmt.Sprint把i放入一个变量
		x := fmt.Sprint("i= ", i)
		//将变量写进文件
		f.WriteString(x)
		f.WriteString("\n")
	}
}

func readfile(file string)  {
	//先open打开文件
	f, err := os.Open(file)
	//判断错误
	if err != nil {
		return
	}
	//defer最后关闭文件
	defer f.Close()
	//声明一个byte切片，
	aaa := make([]byte, 1024 * 2)
	//s表示读取文件内容的长度
	s, errors := f.Read(aaa)
	     //err不为空，并且还没有读到结尾位置
        if errors != nil && io.EOF != nil {
        	return
		}
		//aaa[:s]： 如果有小于2k的字符，只打印到该字符
		fmt.Println("s:", string(aaa[:s]))
}

func readOneLine(file string) {
	f, err := os.Open(file)
	if err != nil {
		return
	}
	defer f.Close()
	//bufio新建一个缓冲区，把内容放到缓冲区
	s := bufio.NewReader(f)
    //for循环读取，打印时会把文件内换行符也读取到
	for {
		c, err1 := s.ReadBytes('\n')
		if err1 != nil {
			if err1 == io.EOF {
               break
			}
			return
		}
		//打印时byte转string
		fmt.Printf("c=%s", string(c))
	}
}

func copy(file1, file2 string)  {
    //获取命令行参数
	//li := os.Args
	//判断参数个数
     //if len(li) < 2 || len(li) >= 3 {
     //	fmt.Println("usage: filename1, filename2")
	  //  return
     //}
     //判断参数格式
    // if li[1] == li[2] {
     //	fmt.Println("err: 文件名相同")
     //	return
	// }
	 //只读方式打开文件
	 f, err := os.Open(file1)
	 if err != nil {
	 	return
	 }
	 //新建目的文件
	 g,err1 := os.Create(file2)

	 if err1 != nil {
	 	return
	 }
	 defer f.Close()
	 defer g.Close()
	 //读取内容到目标文件,读多少写多少
	 buf := make([]byte, 1024 * 4)
     for {
     	n, err2 := f.Read(buf)
     	 if err2 != nil {
     	 	if err2 == io.EOF {
     	 		break
			}
			return
		 }
	  g.Write(buf[:n])
	 }
}
func main() {
	//writefile("./demo.txt")
	//fmt.Println("--------------------")
	//readfile("./demo.txt")
    //readOneLine("demo.txt")
    copy("D:/迅雷下载/mesos-1.9.0.tar.gz", "./mesos.tar.gz")

}
