# Created:
# by Ryan Ogden
# on 9/28/20
#
# Builds a customized divider
#
# +--------------------- Example Divider ---------------------+

include "commands"
include "print"

div() {
  # Exits if printPermission is set to quiet
  if [ $printPermission -eq 0 ]
  then
    return 0
  fi

  # Default values of arguments
  local height=1
  local width=89
  local upperPadding=0
  local outerPaddingLeft=0
  local outerEdgeLeft=''
  local leftArm='-'
  local leftArmLength=0
  local innerEdgeLeft=''
  local innerPaddingLeft=0
  local text=''
  local justify="center"
  local innerPaddingRight=0
  local innerEdgeRight=''
  local rightArmLength=0
  local rightArm='-'
  local outerEdgeRight=''
  local outerPaddingRight=0
  local lowerPadding=0
  local newLine=1
  local contentWidth=0

  # Loops through arguments and processes them
  for arg in "$@"
  do
    case $arg in
      -op|--outerPadding)
        outerPaddingLeft=$2
        outerPaddingRight=$2
        shift # Removes flag from processing
        shift # Removes value from processing
      ;;
      -opl|--outerPaddingLeft)
        outerPaddingLeft=$2
        shift 
        shift 
      ;;
      -opr|--outerPaddingRight)
        outerPaddingRight=$2
        shift 
        shift 
      ;;
      -oe|--outerEdges)
        outerEdgeLeft="$2"
        outerEdgeRight="$2"
        shift 
        shift 
      ;;
      -oel|--outerEdgeLeft)
        outerEdgeLeft="$2"
        shift 
        shift 
      ;;
      -oer|--outerEdgeRight)
        outerEdgeRight="$2"
        shift 
        shift 
      ;;
      -a|--arms)
        leftArm="$2"
        rightArm="$2"
        shift 
        shift 
      ;;
      -la|--leftArm)
        leftArm="$2"
        shift 
        shift 
      ;;
      -ra|--rightArm)
        rightArm="$2"
        shift 
        shift 
      ;;
      -ie|--innerEdge)
        innerEdgeLeft="$2"
        innerEdgeRight="$2"
        shift 
        shift 
      ;;
      -iel|--innerEdgeLeft)
        innerEdgeLeft="$2"
        shift 
        shift 
      ;;
      -ier|--innerEdgeRight)
        innerEdgeRight="$2"
        shift 
        shift 
      ;;
      -ip|--innerPadding)
        innerPaddingLeft=$2
        innerPaddingRight=$2
        shift 
        shift 
      ;;
      -ipl|--innerPaddingLeft)
        innerPaddingLeft=$2
        shift 
        shift 
      ;;
      -ipr|--innerPaddingRight)
        innerPaddingRight=$2
        shift 
        shift 
      ;;
      -j|--justify)
        justify=$2
        shift 
        shift 
      ;;
      -vp|--verticalPadding)
        upperPadding=$2
        lowerPadding=$2
        shift 
        shift 
      ;;
      -up|--upperPadding)
        upperPadding=$2
        shift 
        shift 
      ;;
      -lp|--lowerPadding)
        lowerPadding=$2
        shift 
        shift 
      ;;
      -w|--width)
        width=$2
        shift 
        shift 
      ;;
      -h|--height)
        height=$2
        shift 
        shift 
      ;;
      -n|--noNewLine)
        newLine=0
        shift
      ;;
      -d|--debug)
        printPermission=4
        shift
      ;;
      *)
        while [[ $1 != -* && ! -z "$1" ]]
        do
          text+="$1 "
          shift
        done
        
        text=$(echo $text | sed 's/ *$//g')
      ;;
    esac
  done

  # If justify is not center, eliminates corresponding outerEdge
  case $justify in
    l|left)
      outerEdgeLeft=''
    ;;
    r|right)
      outerEdgeRight=''
    ;;
  esac

  # Calculates inner padding length by text length and justification
  innerPaddingLeft=$(div_calcInnerPadding -l)
  innerPaddingRight=$(div_calcInnerPadding -r)

  # Reconciles width with width of contents
  contentWidth=$(($outerPaddingLeft + ${#outerEdgeLeft} + ${#innerEdgeLeft} + $innerPaddingLeft + ${#text} + $innerPaddingRight + ${#innerEdgeLeft} + ${#outerEdgeRight} + $outerPaddingRight))
  
  if [ "$contentWidth" -gt "$width" ]
  then
    width=$contentWidth
  fi

  # Calculates final arm length
  if [ "$contentWidth" -lt "$width" ]
  then
    local armLengths=($(calcArmLengths))
    
    leftArmLength=${armLengths[0]}
    rightArmLength=${armLengths[1]}
  fi

  # Calculates vertical padding
  verticalPaddings=($(div_calcVerticalPadding))

  upperPadding=$(($upperPadding + ${verticalPaddings[0]}))
  lowerPadding=$(($lowerPadding + ${verticalPaddings[1]}))

  div_debug "Pre-print"

  # Prints the divider
  div_print
}

div_calcInnerPadding() {
  local lr=$1
  local innerPadding=0

  if [ "${#text}" != "0" ]
  then
    case $lr in
      -l)
        case $justify in
          c|m|center|middle)
            innerPadding=1
          ;;
          r|right)
            innerPadding=1
          ;;
        esac
      ;;
      -r)
        case $justify in
          c|m|center|middle)
            innerPadding=1
          ;;
          l|left)
            innerPadding=1
          ;;
        esac
      ;;
    esac
  fi

  echo $innerPadding
}

calcArmLengths() {
  local lengthOfArms=$(($width - $contentWidth))
  
  case $justify in
    l|left)
      rightArmLength=$lengthOfArms
    ;;
    c|m|center|middle)
      local lesserHalf=$(divide lengthOfArms)
      local greaterHalf=$(divide -r lengthOfArms)

      leftArmLength=$(($leftArmLength + $lesserHalf))
      rightArmLength=$(($rightArmLength + $greaterHalf))
    ;;
    r|right)
      leftArmLength=$lengthOfArms
    ;;
  esac

  echo $leftArmLength $rightArmLength
}

div_calcVerticalPadding() {
  local contentHeight=$(($upperPadding + $lowerPadding + 1))
  local upperPadding=0
  local lowerPadding=0

  if [ "$contentHeight" -lt "$height" ]
  then
    local difference=$(($height - $contentHeight))
    upperPadding=$(divide difference)
    lowerPadding=$(divide -r difference)
  fi

  echo $upperPadding $lowerPadding
}

div_calcArmRepCount() {
  local armRepCount=$1
  local characterCount=$2

  if [ "$characterCount" -gt 1 ]
  then
    armRepCount=$(($armRepCount / $characterCount))
  fi

  echo $armRepCount
}

# Prints the divider
div_print() {
  local out=''

  out+=$(skip $upperPadding)
  out+=$(space $outerPaddingLeft)
  out+=$(echo -n "${outerEdgeLeft}")

  if [ "$leftArm" = " " ]
  then
    out+=$(space $leftArmLength)
  else
    out+=$(repeat "$leftArm" $(div_calcArmRepCount $leftArmLength ${#leftArm}))
  fi

  out+=$(echo -n "$innerEdgeLeft")
  out+=$(space $innerPaddingLeft)
  out+=$(echo -n "$text")
  out+=$(space $innerPaddingRight)
  out+=$(echo -n "$innerEdgeRight")

  if [ "$rightArm" = " " ]
  then
    out+=$(space $rightArmLength)
  else
    out+=$(repeat "$rightArm" $(div_calcArmRepCount $rightArmLength ${#rightArm}))
  fi

  out+=$(echo -n "$outerEdgeRight")
  out+=$(space $outerPaddingRight)
  out+=$(skip $lowerPadding)

  if [ "$newLine" = "1" ]
  then
    print3 "$out"
  else
    print3 -n "$out"
  fi
}

div_debug() {
  local msg="$1"
  
  if [ ! -z "$msg" ]
  then
    print4 "$msg"
  fi

  print4 "height: $height"
  print4 "width: $width"

  print4 "upperPadding: $upperPadding"
  
  print4 "outerPaddingLeft: $outerPaddingLeft"
  print4 "outerEdgeLeft: ${outerEdgeLeft}"

  print4 "leftArm: $leftArm"
  print4 "leftArmLength: $leftArmLength"

  print4 "innerEdgeLeft: $innerEdgeLeft"
  print4 "innerPaddingLeft: $innerPaddingLeft"

  print4 "text: $text"
  print4 "justify: $justify"

  print4 "innerPaddingRight: $innerPaddingRight"
  print4 "innerEdgeRight: $innerEdgeRight"

  print4 "rightArmLength: $rightArmLength"
  print4 "rightArm: $rightArm"

  print4 "outerEdgeRight: $outerEdgeRight"
  print4 "outerPaddingRight: $outerPaddingRight"
  
  print4 "lowerPadding: $lowerPadding"

  print4 "newLine: $newLine"

  print4 ""
}