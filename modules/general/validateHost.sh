#!/bin/bash
# Verifies that the current hostname matches the hostname given

include "commands"
include "print"

validateHost() {
  local expected="$1"
  local actual=$(hostname)

  if [[ $expected != $actual ]]; then
    print1 "You must be on the server $expected to run this script."
    print1 -e "You are currently on the server" $red$actual$noColor"."
    exit
  fi
}
