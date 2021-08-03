#!/bin/bash
# print.sh aims to augment the echo command with prioritization of outputs for debugging.
# Requires that the calling script sets the printPermission variable.

# Sets default globals
printPermission=3

# Print errors
print1() {
  if [ ! -z "$printPermission" ]; then
    if [ $printPermission -ge 1 ]
    then
      printEcho "$@"
    fi
  fi
}

# Print warnings
print2() {
  if [ ! -z "$printPermission" ]; then
    if [ $printPermission -ge 2 ]
    then
      printEcho "$@"
    fi
  fi
}

# Print info
print3() {
  if [ ! -z "$printPermission" ]; then
    if [ $printPermission -ge 3 ]
    then
      printEcho "$@"
    fi
  fi
}

# Print debug
print4() {
  if [ ! -z "$printPermission" ]; then
    if [ "$printPermission" = "4" ]
    then
      printEcho "$@"
    fi
  fi
}

printEcho() {
  local args=("$@")
  local flags=()
  local indent=0
  local indentPrefix=''
  local indentLength=0
  local width=''
  local inputValidation=''
  local out=()
  local i=0

  for (( i=0; $i<${#args[@]}; i++ ))
  do
    case "${args[i]}" in
      -i|--indent)
        i=$((i + 1))

        indent=${args[i]}
      ;;
      -w|--width)
        i=$((i + 1))

        width=${args[i]}
      ;;
      -e|-n|-en|-ne)
        flags+=("${args[i]}")
      ;;
      *)
        out+=("${args[i]}")
      ;;
    esac
  done

  if [ $indent -gt 0 ]; then
    indentPrefix="$(print_calcIndentPrefix)"
  fi

  indentLength=$(($(echo "$indentPrefix" | wc -c) - 1))

  inputValidation="$(print_validateInput)"
  if [ ! -z "$inputValidation" ]; then
    echo "print: $inputValidation"
    return 1
  fi

  if [ ! -z "$width" ]; then
    out=("$(print_applyWidth)")
  fi

  if [ $indent -gt 0 ]; then
    out=("$(print_insertIndentPrefix)")
  fi

  echo "${flags[@]}" "${out[@]}"
}

print_calcIndentPrefix() {
  local indentPrefix=''

  for (( i=0; i<$indent; i++ ))
  do
    indentPrefix+="        "
  done

  echo "$indentPrefix"
}

print_validateInput() {
  local inputValidation=''

  if [ ! -z $width ]; then
    if [ $width -le $indentLength ]
    then
      inputValidation="width must be greater than the indent"
    fi
  fi

  echo "$inputValidation"
}

print_applyWidth() {
  local width=$(($width - $indentLength))

  echo "$(echo "${out[@]}" | sed -e "s/.\{$width\}/&\n/g")"
}

print_insertIndentPrefix() {
  for (( i=0; i<${#out[@]}; i++ ))
  do
    out[$i]=$(echo "${out[i]}" | sed "s/^/$indentPrefix/g")
  done

  echo "${out[@]}"
}
