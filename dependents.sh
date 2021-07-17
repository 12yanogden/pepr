# Created:
# by Ryan Ogden
# on 5/31/21
#
# Performs operations on dependentsCache that are complex enough to require other libraries

include "array"
include "remoteCommand"

getAllDependentsByLib() {
  local lib="$1"
  local dependents=($(remoteCommand "source /opt/psscripts/libs/source.sh; getDependentsByLib $lib" -ns -ts dev))

  dependents=($(removeDups ${dependents[@]}))
  
  echo ${dependents[@]/ /\n}
}

getDependentsByLibByServer() {
  local lib="$1"
  
  remoteCommand "source /opt/psscripts/libs/source.sh; getDependentsByLib $lib" -ts dev
}