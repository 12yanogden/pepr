#!/bin/bash
# Prints standardized output structures using hashes

# Prints a divider with dashed arms and hashes on either side
hashDiv() {
  if [ $printPermission -eq 0 ]; then
    return 0
  fi

  div "$@" -oe "#"
}

# Prints a hashBlock around text
hashBlock() {
  if [ $printPermission -eq 0 ]; then
    return 0
  fi

  block "$@" -c '#' -se '#' -tbe '-'
}
