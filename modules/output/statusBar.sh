#!/bin/bash
# Builds a status bar

include "commands"
include "print"

statusBar() {
  # Exits if printPermission is set to quiet
  if [ $printPermission -eq 0 ]; then
    return 0
  fi

  local args=("$@")
  local status=''
  local text=''
  local color=''
  local width=89

  for (( i=0; i<${#args[@]}; i++ ))
  do
    case "${args[i]}" in
      -d|--debug)
        printPermission=4
      ;;
      -w|--width)
        i=$(($i + 1))
        width=${args[i]}
      ;;
      -c|--color)
        i=$(($i + 1))
        color=${args[i]}
      ;;
      -s|--status)
        i=$(($i + 1))
        status=${args[i]}
      ;;
      *)
        while [[ "${args[i]}" != -* && ! -z "${args[i]}" ]]
        do
          text+="${args[i]} "
          i=$(($i + 1))
        done

        i=$(($i - 1))

        text=$(echo $text | sed 's/ *$//g')
      ;;
    esac
  done

  statusBar_print
}

# Prints the Pass/Fail Bar
statusBar_print() {
  padding=$(($width-${#text}-${#status}-5))

  print3 -n $text
  space $padding
  print3 -n " ["

  if [ ! -z "$color" ]; then
    print3 -ne $color $status $noColor
  else
    print3 -n " $status "
  fi

  print3 "]"
}

statusBar_debug() {
  local msg="$1"

  if [ ! -z "$msg" ]; then
    print4 "$msg"
  fi

  print4 args: "${args[@]}"
  print4 text: $text
  print4 status: $status
  print4 color: $color
  print4 width: $width
  print4 ""
}
