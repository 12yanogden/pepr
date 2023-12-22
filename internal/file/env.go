package file

import (
	"errors"
	"regexp"
	"strconv"
	"strings"
)

func Env(file string) (map[string]string, error) {
	lines := []string{}
	out := make(map[string]string)

	//region Validate input

	// If no arguments, return with error
	if len(file) == 0 {
		return out, errors.New("path to .env required")
	}

	if !strings.HasSuffix(file, ".env") {
		return out, errors.New(file + " is not a .env file")
	}

	//endregion

	//region Collect variables

	// Read env file
	envContents, err := Cat(file)
	if err != nil { return out, err }

	// Split env contents into lines
	lines = strings.Split(envContents, "\n")

	// Collect each line as a variable
	for i, line := range lines {

		// Validate line
		isValidLine, err := regexp.MatchString("[a-zA-Z_]+=[a-zA-Z0-9]+", line)

		// Handle issues
		if err != nil {
			return out, err
		} else if (!isValidLine) {
			return out, errors.New("'" + line + "' (line " + strconv.Itoa(i + 1) + ") is not a valid environment variable")
        }

		// Explode to key and value
		config := strings.Split(line, "=")
		
		out[config[0]] = config[1]
	}

	//endregion
	
	// Return success
	return out, nil
}