package file

import (
	"errors"
	"os"
	"strconv"
)

func Cat(args []string) (int, string) {
	code := 0
	out := ""
	file := ""

	//region Validate input

	// If no arguments, return with error
	if args == nil || len(args) == 0 || len(args) > 1 {
		return 1, "requires 1 argument, found " + strconv.Itoa(len(args))
	}

	// Analyze file
	file = args[0]
	info, err := os.Stat(file);

	// Return with error if file is invalid
	if errors.Is(err, os.ErrNotExist) {				// Does not exist
		return 2, file + " not found"

	} else if info.Mode().Perm()&0444 != 0444 {		// Is not readable
		return 2, file + " is not readable"

	} else if err != nil {							// Unknown error
		return 2, err.Error()
	}

	//endregion

	// Read & print
	fileContentByteSlice, err := os.ReadFile(file)

	// Validate reading file
	if (err != nil) {
		return 3, err.Error()
	}

	out = string(fileContentByteSlice)
	
	// Return success
	return code, out
}