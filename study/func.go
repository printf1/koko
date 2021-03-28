package main

import "fmt"

/*
func main() {
	array1 := [3][]string{
		[]string{"a", "b", "c"},
		[]string{"d", "e", "f"},
		[]string{"g", "h", "i"},
	}
	fmt.Printf("The array: %v\n", array1)
	array2 := modifyArray(array1[1])
	fmt.Printf("The modified array: %v\n", array2)
	fmt.Printf("The original array: %v\n", array1)
}

func modifyArray(a []string) []string {
	a[0] = "x"
	return a
}
//-----------------------------------------------
*/

type Pet interface {
	SetName(name string)
	Name() string
	Category() string
}
type Dog struct {
	name string
}

func (a *Dog) Name() string {
	fmt.Println(a.name)
	return a.name
}
func (b *Dog) Category() string {
	fmt.Println(b.name)
	return b.name
}
func (x *Dog) SetName(name string) string {
	x.name = name
	fmt.Println(x.name)
	return x.name
}
func op(in Pet) {
	in.SetName("")
	in.Category()
	in.Name()
}
func main() {
	var pet Pet
	dog := Dog{"little pig"}
	fmt.Println(dog.name)
	//pet = &dog
	op(pet)
	//pet.SetName("big pig")
	//fmt.Println(pet.Name())
	//fmt.Println(pet.Category())
	//fmt.Println(dog.name)
}

/*
dog1 := Dog{"little pig"}
dog2 := dog1
dog1.name = "monster"
*/

/*
var dog1 *Dog
fmt.Println("The first dog is nil. [wrap1]")
dog2 := dog1
fmt.Println("The second dog is nil. [wrap1]")
var pet Pet = dog2
if pet == nil {
	fmt.Println("The pet is nil. [wrap1]")
} else {
	fmt.Println("The pet is not nil. [wrap1]")
}
*/
