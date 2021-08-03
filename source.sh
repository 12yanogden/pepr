#!/bin/bash
# Sources all other script moduleraries, prevents source loops, and lists dependent scripts.

init() {
  echo "bash source: ${BASH_SOURCE[0]}"
  pepr_base="$(dirname "${BASH_SOURCE[0]}")"
  local userValidation="$(validateUser)"

  if [ ! -z "$userValidation" ]; then
    echo "pepr: $userValidation"
    return 1
  fi
}

init "$@"

calcDirs() {
  local excludes=".git"
  local dirPaths=($(find "$pepr_base" -mindepth 1 -type d | grep -v "$excludes"))
  declare -A pepr_dirs=()

  for dirPath in "${dirPaths[@]}"; do
    dirs["$(basename "$dirPath")"]="$dirPath"
  done

  declare -p pepr_dirs
}

calcCaches() {
  local cachePaths=($(find "${pepr_dirs[caches]}" -name *.txt -type f))
  declare -A pepr_caches=()

  for cachePath in "${cachePaths[@]}"; do
    caches["$(basename "$cachePath" | sed 's/\.sh//g')"]="$cachePath"
  done

  declare -p pepr_caches
}

calcModules() {
  local modulePaths=($(find "${pepr_dirs[modules]}" -mindepth 1 -name *.sh -type f))
  declare -A pepr_modules=()

  for modulePath in "${modulePaths[@]}"; do
    modules["$(basename "$modulePath" | sed 's/\.sh//g')"]="$modulePath"
  done

  declare -p pepr_modules
}

eval "$(calcDirs)"
echo "$(calcDirs)"
declare -p pepr_dirs
eval "$(calcCaches)"
eval "$(calcModules)"

include() {
  local target="$1"

  if [ $(isModule $target) -eq 1 ]; then
    source_sourceIfNotSourced
  fi

  if [ "$0" != "-bash" ]; then
    source_recordDependent
  fi
}

isModule() {
  local target="$1"
  local isModule=0

  for module in "${modules[@]}"
  do
    if [ "$target" = "$module" ]
    then
      isModule=1
      break
    fi
  done

  echo $isModule
}

# Prevents source loops. Sources the script given if it has not been sourced.
source_sourceIfNotSourced() {
  local moduleAbsPath="$peprDir/$target.sh"
  local isSourced=0

  for bashSource in "${BASH_SOURCE[@]}"
  do
    if [ "$bashSource" = "$moduleAbsPath" ]
    then
      isSourced=1
      break
    fi
  done

  if [ $isSourced -eq 0 ]; then
    source "$moduleAbsPath"
  fi
}
