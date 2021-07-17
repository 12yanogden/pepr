# Created:
# by Ryan Ogden
# on 9/28/20
#
# Sources all other script libraries, prevents source loops, and lists dependent scripts.

if [ "$(whoami)" != "psoft" -a "$(whoami)" != "root" ]
then
  echo "You must be logged in as psoft. You are currently logged in as $(whoami)."
  return 1
fi

libs=("admin"
      "array"
      "block"
      "commands"
      "crossStandard"
      "dependents"
      "div"
      "hashStandard"
      "print"
      "printWithLabel"
      "remoteCommand"
      "remoteCopy"
      "remoteRoot"
      "serverConfigs"
      "statusBar"
      "validateHost"
      "validateUser")
dependentsCache="/var/opt/logs/psoft/status/libs/dependents.txt"
if [ ! -f "$dependentsCache" ]
then
  touch "$dependentsCache"
  echo -e "libs\tdependents\tlastSourced" > "$dependentsCache"
fi

include() {
  local target="$1"
  local rootPath="$(dirname "${BASH_SOURCE[0]}")"

  if [ $(isLib $target) -eq 1 ]
  then
    source_sourceIfNotSourced
  fi

  if [ "$0" != "-bash" ]
  then
    source_recordDependent
  fi
}

isLib() {
  local target="$1"
  local isLib=0

  for lib in ${libs[@]}
  do
    if [ "$target" = "$lib" ]
    then
      isLib=1
      break
    fi
  done

  echo $isLib
}

# Prevents source loops. Sources the script given if it has not been sourced.
source_sourceIfNotSourced() {
  local libAbsPath="$rootPath/$target.sh"
  local isSourced=0

  for bashSource in "${BASH_SOURCE[@]}"
  do
    if [ "$bashSource" = "$libAbsPath" ]
    then
      isSourced=1
      break
    fi
  done

  if [ $isSourced -eq 0 ]
  then
    source "$libAbsPath"
  fi
}

#--------------------------------------------------------------------------------------------------------------#
#                                                                                                              #
#                                            Dependents Management                                             #
#                                                                                                              #
#--------------------------------------------------------------------------------------------------------------#

#------------------------------------------------ Private Use -------------------------------------------------#

# Returns the field index of the header given
# source_getFieldIndexByHeader "header" => "fieldIndex"
source_getFieldIndexByHeader() {
  local headers=($(head -1 $dependentsCache | sed 's/\t/ /g'))
  local targetHeader="$1"
  local out=-1

  for (( i=0; i<${#headers[@]}; i++ ))
  do
    if [ "$targetHeader" = "${headers[i]}" ]
    then
      out=$i
      break
    fi
  done

  echo "$out"
}

# Returns the values of the fieldToGet associated with the value of the field given
# source_getFieldByFieldValue "fieldToGet" "field" "value" => "value1 value2 ... valueN"
source_getFieldValuesByFieldAndValue() {
  local fieldToGet="$1"
  local field="$2"
  local value="$3"
  local fieldToGetIndex=$(($(source_getFieldIndexByHeader $fieldToGet) + 1))
  local fieldIndex=$(($(source_getFieldIndexByHeader $field) + 1))

  awk -F '\t' -v "fieldToGetIndex=$fieldToGetIndex" -v "fieldIndex=$fieldIndex" -v "value=$value" '{
    if (NR > 1 && $fieldIndex == value)
      print $fieldToGetIndex;
    }' "$dependentsCache"
}

source_getRowByTwoFieldsAndValues() {
  local field1="$1"
  local value1="$2"
  local field2="$3"
  local value2="$4"
  local field1Index=$(($(source_getFieldIndexByHeader $field1) + 1))
  local field2Index=$(($(source_getFieldIndexByHeader $field2) + 1))

  awk -F '\t' -v "field1Index=$field1Index" -v "value1=$value1" -v "field2Index=$field2Index" -v "value2=$value2" '{
      if (NR > 1 && $field1Index == value1 && $field2Index == value2)
        print;
    }' "$dependentsCache"
}


# Returns 1 if dependent is unique among the libDependents, else 0
# source_isDependentUnique => 1, else 0
source_isDependentUnique() {
  local isDependentUnique=1
  
  for libDependent in ${libDependents[@]}
  do
    if [ "$libDependent" = "$dependent" ]
    then
      isDependentUnique=0
      break
    fi
  done

  echo $isDependentUnique
}

source_appendToCache() {
  local args=($@)
  args="$(echo "${args[@]}" | sed 's+ +\t+g')"

  echo "$args" >> $dependentsCache
}

source_setLastSourced() {
  local lib="$1"
  local dependent="$2"
  local lastSourced="$3"
  local lastSourcedIndex=$(($(source_getFieldIndexByHeader "lastSourced") + 1))
  local originalRow="$(source_getRowByTwoFieldsAndValues "lib" $lib "dependent" $dependent)"
  local newRow=($originalRow)
  
  if [ "${originalRow[lastSourcedIndex]}" != "$lastSourced" ]
  then
    newRow[$lastSourcedIndex]="$lastSourced"
    newRow="$(echo "${newRow[@]}" | sed 's+ +\t+g')"

    sed -n "s+$originalRow+$newRow+g" $dependentsCache
  fi
}

#
source_recordDependent() {
  local dependent="$( cd "$( dirname "$0" )" && pwd )/$(basename "$0")"
  local libDependents=($(getDependentsByLib $target))
  local lastSourced=$(date +%d.%m.%Y)

  if [ $(source_isDependentUnique) -eq 1 ]
  then
    source_appendToCache $target $dependent $lastSourced
  else
    source_setLastSourced $target $dependent $lastSourced
  fi
}

#------------------------------------------------- Public Use -------------------------------------------------#

# Returns the dependents for the lib given
# getDependentsByLib "lib" => "dependent1 dependent2 ... dependentN"
getDependentsByLib() {
  local lib="$1"
  local dependents=($(source_getFieldValuesByFieldAndValue "dependent" "lib" "$lib"))

  echo "${dependents[@]}"
}

# Returns the libs for the dependent given
# getLibsByDependent "dependent" => "lib1 lib2 ... libN"
getLibsByDependent() {
  local dependent="$1"
  local libs=($(source_getFieldValuesByFieldAndValue "lib" "dependent" "$dependent"))

  echo "${libs[@]}"
}
