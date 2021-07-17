# Created:
# by Ryan Ogden
# on 9/28/20
#
# Builds a block around text
#
# +-----------------------------------------------------------+
# |                                                           |
# |                      Example Block                        |
# |                                                           |
# +-----------------------------------------------------------+

include "commands"
include "div"
include "print"

block() {
  # Default values of arguments
  local args=("$@")
  local text='X'
  local corners='X'
  local leftEdge='X'
  local rightEdge='X'
  local topEdge='X'
  local bottomEdge='X'
  local width=89
  local out=''

  # Loops through arguments and process them
  for (( i=0; i<${#args[@]}; i++ ))
  do
    case "${args[i]}" in
      -c|--corners)
        i=$(($i + 1))
        corners="${args[i]}"
      ;;
      -e|--edges)
        i=$(($i + 1))
        leftEdge="${args[i]}"
        rightEdge="${args[i]}"
        topEdge="${args[i]}"
        bottomEdge="${args[i]}"
      ;;
      -se|--sideEdges)
        i=$(($i + 1))
        leftEdge="${args[i]}"
        rightEdge="${args[i]}"
      ;;
      -le|--leftEdge)
        i=$(($i + 1))
        leftEdge="${args[i]}"
      ;;
      -re|--rightEdge)
        i=$(($i + 1))
        rightEdge="${args[i]}"
      ;;
      -tbe|--topAndBottomEdges)
        i=$(($i + 1))
        topEdge="${args[i]}"
        bottomEdge="${args[i]}"
      ;;
      -te|--topEdge)
        i=$(($i + 1))
        topEdge="${args[i]}"
      ;;
      -be|--bottomEdge)
        i=$(($i + 1))
        bottomEdge="${args[i]}"
      ;;
      -w|--width)
        i=$(($i + 1))
        width=${args[i]}
      ;;
      -d|--debug)
        printPermission=4
      ;;
      *)
        if [ ! -z "${args[i]}" ]
        then
          if [ "$text" = "X" ]
          then
            text=''
          fi

          while [[ ${args[i]} != -* && ! -z "${args[i]}" ]]
          do
            text+="${args[i]} "
            i=$(($i + 1))
          done

          i=$(($i - 1))

          text=$(echo $text | sed 's/ *$//g')
        fi
      ;;
    esac
  done

  # Stores each line of the block to a single variable
  out+="$(div -oe "$corners" -a "$topEdge" -w $width)\n"
  out+="$(div -oel "$leftEdge" -oer "$rightEdge" -a " " -w $width)\n"
  out+="$(div "$text" -oel "$leftEdge" -oer "$rightEdge" -a " " -w $width)\n"
  out+="$(div -oel "$leftEdge" -oer $rightEdge -a " " -w $width)\n"
  out+="$(div -oe "$corners" -a "$bottomEdge" -w $width)"

  # A single call to stdout reduces processing time
  print3 -e "$out"
}

block_debug() {
  local msg="$1"
  
  if [ ! -z "$msg" ]
  then
    print4 "$msg"
  fi

  print4 "text: $text"
  print4 "corners: $corners"
  print4 "leftEdge: $leftEdge"
  print4 "rightEdge: $rightEdge"
  print4 "topEdge: $topEdge"
  print4 "bottomEdge: $bottomEdge"
  print4 "width: $width"
  print4 ""
}