package file

import (
	"github.com/12yanogden/pepr/internal/file"
	"testing"
)

// Throw error if no arguments are passed
func TestCatNoArgs(t *testing.T) {
	filepath := ""
	expected := "filepath required" 
    _, actual := file.Cat(filepath)

	if expected != actual.Error() {
		t.Fatalf("\nExpected: '" + expected + "'\nActual: '" + actual.Error() + "'")
	}
}

// Throw error if the file path passed does not exist
func TestCatNoExist(t *testing.T) {
	filepath := "no_exist.txt"
	expected := "no_exist.txt not found"
    _, actual := file.Cat(filepath)

	if expected != actual.Error() {
		t.Fatalf("\nExpected: '" + expected + "'\nActual: '" + actual.Error() + "'")
	}
}

// Throw error if the file is not readable
func TestCatNotReadable(t *testing.T) {
	filepath := "../data/not_readable.txt"
	expected := "../data/not_readable.txt is not readable"
	_, actual := file.Cat(filepath)

	if expected != actual.Error() {
		t.Fatalf("\nExpected: '" + expected + "'\nActual: '" + actual.Error() + "'")
	}
}

// Read a file
func TestCat(t *testing.T) {
	filepath := "../data/text_file.txt"
	expected := "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean m"
	actual, err := file.Cat(filepath)

	if err!= nil {
		t.Fatal(err.Error())
	}

	if expected != actual {
		t.Fatalf("\nExpected: '" + expected + "'\nActual: '" + actual + "'")
	}
}