package print

import (
	"fmt"
	"godotenv"
    "os"
)

func main() {
	// Open the .env file
	f, err := os.Open("../.env")
	if err != nil {
		// Handle error
	}

	// Read the contents of the file
	contents, err := ioutil.ReadAll(f)
	if err != nil {
		// Handle error
	}

	// Close the file
	defer f.Close()

	// Do something with the contents
	fmt.Println(contents)
}