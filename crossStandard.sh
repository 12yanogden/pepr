# Created:
# by Ryan Ogden
# on 5/13/21
#
# Prints standardized output structures using perpendicular patterns

include "block"
include "statusBar"

# Prints a divider with dashed arms and crosses on either side
crossDiv() {
  if [ $printPermission -eq 0 ]
  then
    return 0
  fi

  div "$@" -oe "+"
}

# Prints a crossBlock around text
crossBlock() {
  if [ $printPermission -eq 0 ]
  then
    return 0
  fi

  block "$@" -c '+' -se '|' -tbe '-'
}

# Prints a statusBar with the status of PASS
pass() {
  if [ $printPermission -eq 0 ]
  then
    return 0
  fi

  local args=("$@")
  local colorFlagIndex=''

  for (( i=0; i<${#args[@]}; i++ ))
  do
    if [ "${args[i]}" = "-c" ]
    then
      colorFlagIndex=$i
      break
    fi
  done

  if [ ! -z "$colorFlagIndex" ]
  then
    unset 'args[colorFlagIndex]'
    statusBar "${args[@]}" -s "PASS" -c "$green"
  else
    statusBar "${args[@]}" -s "PASS"
  fi
}

# Prints a statusBar with the status of FAILED
fail() {
  if [ $printPermission -eq 0 ]
  then
    return 0
  fi

  local args=("$@")
  local colorFlagIndex=''

  for (( i=0; i<${#args[@]}; i++ ))
  do
    if [ "${args[i]}" = "-c" ]
    then
      colorFlagIndex=$i
      break
    fi
  done

  if [ ! -z "$colorFlagIndex" ]
  then
    unset 'args[colorFlagIndex]'
    statusBar "${args[@]}" -s "FAILED" -c "$red"
  else
    statusBar "${args[@]}" -s "FAILED"
  fi
}