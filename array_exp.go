package main

import "fmt"

func main() {
	p1 := []int{1, 2, 3}
	p2 := p1[1:]
	fmt.Println(p1)
	fmt.Println(p2)
	p2[0] = 4
	fmt.Println(p1)
	fmt.Println(p2)
	p2 = append(p2, []int{5, 6, 7}...)
	fmt.Println(p1)
	fmt.Println(p2)

	p1[2] = 10
	fmt.Println(p1)
	fmt.Println(p2)

}
