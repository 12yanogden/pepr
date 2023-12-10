package main

import (
	"fmt"
	"github.com/12yanogden/pepr/internal/file"
	"os"
)

func main() {
	code, out = file.Cat(os.Args[1:])

	// Print out
	fmt.Printf("%s\n", out)

	// Exit with code
	os.Exit(code)
}
