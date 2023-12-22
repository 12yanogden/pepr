package strmaps

import (
	"strconv"
	"testing"

	"github.com/12yanogden/pepr/internal/strmaps"
)

func TestMapEquality(t *testing.T) {
	m1 := map[string]string{"key1": "value1", "key2": "value2", "key3": "value3"}
	m2 := map[string]string{"key1": "value1", "key2": "value2", "key3": "value3"}
	expected := true
	actual := strmaps.Equals(m1, m2)

	if !actual {
		t.Fatalf("\nExpected: '" + strconv.FormatBool(expected) + "', they are equal\nActual: '" + strconv.FormatBool(actual) + "', they are not equal")
	}
}

func TestMapInequalityByLength(t *testing.T) {
	m1 := map[string]string{"key1": "value1", "key2": "value2", "key3": "value3"}
	m2 := map[string]string{"key1": "value1", "key2": "value2"}
	expected := false
	actual := strmaps.Equals(m1, m2)

	if actual {
		t.Fatalf("\nExpected: '" + strconv.FormatBool(expected) + "', they are inequal\nActual: '" + strconv.FormatBool(actual) + "', they are equal")
	}
}

func TestMapInequalityByKeys(t *testing.T) {
	m1 := map[string]string{"key1": "value1", "key2": "value2", "key3": "value3"}
	m2 := map[string]string{"key1": "value1", "key2": "value2", "key": "value3"}
	expected := false
	actual := strmaps.Equals(m1, m2)

	if actual {
		t.Fatalf("\nExpected: '" + strconv.FormatBool(expected) + "', they are inequal\nActual: '" + strconv.FormatBool(actual) + "', they are equal")
	}
}

func TestMapInequalityByValues(t *testing.T) {
	m1 := map[string]string{"key1": "value1", "key2": "value2", "key3": "value3"}
	m2 := map[string]string{"key1": "value1", "key2": "value2", "key3": "value"}
	expected := false
	actual := strmaps.Equals(m1, m2)

	if actual {
		t.Fatalf("\nExpected: '" + strconv.FormatBool(expected) + "', they are inequal\nActual: '" + strconv.FormatBool(actual) + "', they are equal")
	}
}

// Convert string map to string
func TestMapToString(t *testing.T) {
	mapp := map[string]string{"key1": "value1", "key2": "value2", "key3": "value3"}
	expected := "key1: value1\nkey2: value2\nkey3: value3\n"
	actual := strmaps.ToString(mapp)

	if expected != actual {
		t.Fatalf("\nExpected: '" + expected + "'\nActual: '" + actual + "'")
	}
}
