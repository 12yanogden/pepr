#!/bin/bash
# Performs operations on dependentsCache that are complex enough to require other libraries

include "array"
include "remoteCommand"

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


# Returns 1 if dependent is unique among the moduleDependents, else 0
# source_isDependentUnique => 1, else 0
source_isDependentUnique() {
  local isDependentUnique=1

  for moduleDependent in "${moduleDependents[@]}"
  do
    if [ "$moduleDependent" = "$dependent" ]
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
  local module="$1"
  local dependent="$2"
  local lastSourced="$3"
  local lastSourcedIndex=$(($(source_getFieldIndexByHeader "lastSourced") + 1))
  local originalRow="$(source_getRowByTwoFieldsAndValues "module" $module "dependent" $dependent)"
  local newRow=($originalRow)

  if [ "${originalRow[lastSourcedIndex]}" != "$lastSourced" ]; then
    newRow[$lastSourcedIndex]="$lastSourced"
    newRow="$(echo "${newRow[@]}" | sed 's+ +\t+g')"

    sed -n "s+$originalRow+$newRow+g" $dependentsCache
  fi
}

#
source_recordDependent() {
  local dependent="$( cd "$( dirname "$0" )" && pwd )/$(basename "$0")"
  local moduleDependents=($(getDependentsByModule $target))
  local lastSourced=$(date +%d.%m.%Y)

  if [ $(source_isDependentUnique) -eq 1 ]; then
    source_appendToCache $target $dependent $lastSourced
  else
    source_setLastSourced $target $dependent $lastSourced
  fi
}

#------------------------------------------------- Public Use -------------------------------------------------#

# Returns the dependents for the module given
# getDependentsByModule "module" => "dependent1 dependent2 ... dependentN"
getDependentsByModule() {
  local module="$1"
  local dependents=($(source_getFieldValuesByFieldAndValue "dependent" "module" "$module"))

  echo "${dependents[@]}"
}

# Returns the modules for the dependent given
# getModulesByDependent "dependent" => "module1 module2 ... moduleN"
getModulesByDependent() {
  local dependent="$1"
  local modules=($(source_getFieldValuesByFieldAndValue "module" "dependent" "$dependent"))

  echo "${modules[@]}"
}

getAllDependentsByLib() {
  local lib="$1"
  local dependents=($(remoteCommand "source /opt/psscripts/libs/source.sh; getDependentsByLib $lib" -ns -ts dev))

  dependents=($(removeDups "${dependents[@]}"))

  echo "${dependents[@]/ /\n}"
}

getDependentsByLibByServer() {
  local lib="$1"

  remoteCommand "source /opt/psscripts/libs/source.sh; getDependentsByLib $lib" -ts dev
}
