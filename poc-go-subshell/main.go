package main

import (
    "os"
    "os/exec"
)

// aws-vault のようにサブシェルを開くにはの poc
func main() {
    cmd := exec.Command("zsh")
    // cmd.Dir = os.
    cmd.Env = append(os.Environ(), "MYVAR=hello")

    cmd.Stdin = os.Stdin
    cmd.Stdout = os.Stdout
    cmd.Stderr = os.Stderr

    err := cmd.Run()
    if err != nil {
        panic(err)
    }
}
