package main

import (
	"bufio"
	"fmt"
	"log"
	"os"

	"github.com/733amir/doctor/grouper"
	"github.com/733amir/doctor/linarian"
)

func main() {
	i := linarian.New(bufio.NewReader(os.Stdin), 2)

	m, err := grouper.Parse(i)
	if err != nil {
		log.Fatal(err)
	}

	// m, err = markdown.GenerateHTML(m)
	// if err != nil {
	// 	log.Fatal(err)
	// }

	fmt.Print(m)
}
