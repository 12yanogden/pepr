#!/bin/bash
# Returns message if the current user does not match the user given, else blank

include "commands"

validateUser() {
  local expected="psoft"
  local actual=$(whoami)

  for arg in "$@"
  do
    case $arg in
      -d|--debug)
        printPermission=4
        shift
      ;;
      -c|--color)
        actual="$red$actual$noColor"
        shift
      ;;
      *)
        expected="$1"
        shift
      ;;
    esac
  done

  if [ "$expected" != "$actual" ]; then
    echo "You must be logged in as $expected. You are currently logged in as $actual."
  elif [ "$actual" = "psoft" ]; then
    psKey="/home/psoft/.ssh/phire"
  fi
}
