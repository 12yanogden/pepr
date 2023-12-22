package file

import (
	"testing"

	"github.com/12yanogden/pepr/internal/file"
	"github.com/12yanogden/pepr/internal/strmaps"
)

// Throw error if no arguments are passed
func TestEnvNoArgs(t *testing.T) {
	filepath := ""
	expected := "path to .env required"
	_, actual := file.Env(filepath)

	if expected != actual.Error() {
		t.Fatalf("\nExpected: '" + expected + "'\nActual: '" + actual.Error() + "'")
	}
}

// Throw error if file is not an .env file
func TestEnvNotEnvFile(t *testing.T) {
	filepath := "../data/text_file.txt"
	expected := "../data/text_file.txt is not a .env file"
	_, actual := file.Env(filepath)

	if expected != actual.Error() {
		t.Fatalf("\nExpected: '" + expected + "'\nActual: '" + actual.Error() + "'")
	}
}

// Throw error if .env has invalid line
func TestEnvInvalidLine(t *testing.T) {
	filepath := "../data/invalid_line.env"
	expected := "'invalid = config' (line 1) is not a valid environment variable"
	_, actual := file.Env(filepath)

	if expected != actual.Error() {
		t.Fatalf("\nExpected: '" + expected + "'\nActual: '" + actual.Error() + "'")
	}
}

// Read an.env file
func TestEnv(t *testing.T) {
	filepath := "../data/valid.env"
	expected := map[string]string{
		"valid1": "config1",
		"valid2": "2",
		"valid3": "config3",
	}
	actual, err := file.Env(filepath)

	if err != nil {
		t.Fatal(err.Error())
	}

	if !strmaps.Equals(expected, actual) {
		t.Fatalf("\nExpected:\n" + strmaps.ToString(expected) + "\nActual:\n" + strmaps.ToString(actual))
	}
}
