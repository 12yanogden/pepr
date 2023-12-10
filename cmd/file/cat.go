package cat

import (
	"errors"
	"fmt"
	"os"
	"strconv"
)

func cat(args ...interface{}) {
	file := args[0]

	//region Validate input

	if args == nil || len(args) == 0 || len(args) > 1 {
		fmt.Println("cat: requires 1 argument, found " + strconv.Itoa(len(args)))
		os.Exit(22)
	}

	if _, err := os.Stat(args[0]); errors.Is(err, os.ErrNotExist) {
		fmt.Println("cat: " + args[0] + " not found")
		os.Exit(22)
	}

	//endregion

	// Read & print
	fileContentByteSlice, _ := os.ReadFile(args[0])
	fmt.Println(string(fileContentByteSlice))
	
	// Return success
	os.Exit(0)
}