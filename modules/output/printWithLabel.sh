#!/bin/bash
# Prepends the label name to its output and prints

include "commands"
include "print"

printWithLabel() {
  local INDENT_LENGTH=8
  local label="$1:"
  local content="$2"
  local firstLineIndent=1
  local labelAndIndentLength=$(((${#label} + 7) & -$INDENT_LENGTH))
  local otherLinesIndent=$(($labelAndIndentLength % $INDENT_LENGTH))
  local out=''

  if [ ${#label} -lt $INDENT_LENGTH ]; then
    firstLineIndent=2
  fi

  out+="$label$(repeat '\t' $firstLineIndent)"

  if [ $(echo "$content" | wc -l) -eq 1 ]; then
    out+="$content"
  else
    local firstLine="$(echo "$content" | head -n 1)"
    local otherLines="$(echo "$content" | tail -n +2)"

    out+="$firstLine\n"
    out+="$(print3 -i 2 "$otherLines")"
  fi

  echo -e "$out"
}
