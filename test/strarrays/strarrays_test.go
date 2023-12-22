package strarrays

import (
	"testing"

	"github.com/12yanogden/pepr/internal/strarrays"
)

// Convert string array to string
func TestArrayToString(t *testing.T) {
	a := []string{"value1", "value2", "value3"}
	expected := "[\n    value1\n    value2\n    value3\n]\n"
	actual := strarrays.ToString(a)

	if expected != actual {
		t.Fatalf("\nExpected: " + expected + "\nActual: " + actual)
	}
}

// Convert a string to a string array
func TestStringToArray(t *testing.T) {
	s := "[\n    value1\n    value2\n    value3\n]\n"
	expected := []string{"value1", "value2", "value3"}
	actual := strarrays.ToArray(s)

	if !strarrays.Equals(expected, actual) {
		t.Fatalf("\nExpected: " + strarrays.ToString(expected) + "\nActual: " + strarrays.ToString(actual))
	}
}
