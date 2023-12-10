package file

import (
	"fmt"
	"github.com/12yanogden/pepr/internal/file"
	"testing"
)

func TestCat(t *testing.T) {
	args := []string{}
    code, out := file.Cat(args)
	fmt.Println(code)
	fmt.Println(out)
}