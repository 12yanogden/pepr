package main

import (
    "fmt"
	"os"
	"golang.org/x/term"
)

func main() {
	args := os.Args[1:]
	msg := args[0]
	status := args[1]

	if term.IsTerminal(int(os.Stdout.Fd())) {
		fmt.Println("Terminal detected")
	} else {
		fmt.Println("Terminal not detected")
	}

	fmt.Println(msg, status)
}