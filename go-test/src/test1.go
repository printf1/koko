package main

import (
  "fmt"
  "unsafe"
)
type vo struct{}
var a vo
func main() {
set := make(map[string]vo) // New empty set
fmt.Println(unsafe.Sizeof(set))
set["Foo"] = a           // Add
for k := range set {         // Loop
    fmt.Println(k)
}
fmt.Println(unsafe.Sizeof(set))
fmt.Println(set)
delete(set, "Foo")    // Delete
size := len(set)      // Size
fmt.Println(size)
exists := set["Foo"]  // Membership
fmt.Println(exists)
//fmt.Println()
}
