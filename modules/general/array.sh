#!/bin/bash
# Provides useful functions for array manipulation

# Returns the intersect of the two arrays given
# intersect "${primary[@]}" ^ "${secondary[@]}" => "${intersection[@]}"
intersect() {
  local args=("$@")
  local primary=()
  local secondary=()
  local isSecondary=0
  local out=()

  for arg in "${args[@]}"
  do
    if [ "$arg" = "^" ]
    then
      isSecondary=1
    else
      if [ $isSecondary -eq 0 ]
      then
        primary+=("$arg")
      else
        secondary+=("$arg")
      fi
    fi
  done

  for i in "${!secondary[@]}"
  do
    for j in "${!primary[@]}"
    do
      if [ "${secondary[i]}" = "${primary[j]}" ]
      then
        out+=("${primary[j]}")
      fi
    done
  done

  echo "${out[@]}"
}

# Returns the subtract of the two arrays given
# subtract "${primary[@]}" - "${secondary[@]}" => "${subtraction[@]}"
subtract() {
  local args=("$@")
  local primary=()
  local secondary=()
  local isSecondary=0

  for arg in "${args[@]}"
  do
    if [ "$arg" = "-" ]
    then
      isSecondary=1
    else
      if [ $isSecondary -eq 0 ]
      then
        primary+=("$arg")
      else
        secondary+=("$arg")
      fi
    fi
  done

  for i in "${!secondary[@]}"
  do
    for j in "${!primary[@]}"
    do
      if [ "${secondary[i]}" = "${primary[j]}" ]
      then
        unset 'primary[j]'
      fi
    done
  done

  echo "${primary[@]}"
}

# Returns the unique values of the array given
# removeDups "${array[@]}" => "${uniques[@]}"
removeDups() {
  local array=("$@")
  local uniques=()

  for item in "${array[@]}"
  do
    local isUnique=1

    for unique in "${uniques[@]}"
    do
      if [ "$item" = "$unique" ]
      then
        isUnique=0
      fi
    done

    if [ "$isUnique" = "1" ]
    then
      uniques+=("$item")
    fi
  done

  echo "${uniques[@]}"
}
