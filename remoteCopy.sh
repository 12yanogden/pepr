# Created:
# by Ryan Ogden
# on 2/17/21
#
# Copies any file or directory from the source server to the destination servers given 
# remoteCopy "sourcePath" -ts "targetServer(s)"
# remoteCopy "sourcePath" -ss "sourceServer"

include "crossStandard"
include "serverConfigs"
include "validateUser"

rcopy() {
  remoteCopy $@
}

#--------------------------------------------------------------------------------------------------------------#
#                                                                                                              #
#                                                     Main                                                     #
#                                                                                                              #
#--------------------------------------------------------------------------------------------------------------#

remoteCopy() {
  #--------------------------------------------- User Validation ----------------------------------------------#
  local userValidation=$(validateUser "psoft")
  if [ ! -z "$userValidation" ]
  then
    print1 "$userValidation"
    return 1
  fi

  #--------------------------------------------- Default Configs ----------------------------------------------#
  local args=($@)
  local sourceServer=$(hostname)
  local sourcePath=''
  local targetServers=($(hostname))
  local targetPath=''
  local isParallel=0
  local user="psoft"
  local psKey=/home/psoft/.ssh/phire
  local printServers=1
  local width=89
  local inputValidation=''
  local printPermissionCache=$printPermission
  printPermission=3

  #--------------------------------------------- Input Processing ---------------------------------------------#
  for (( i=0; i<${#args[@]}; i++ ))
  do
    case "${args[i]}" in
      -ss|--sourceServer)
        i=$(($i + 1))

        if [ "${args[i]}" != -* ]
        then
          sourceServer="${args[i]}"
        fi
      ;;
      -ts|--targetServers)
        i=$(($i + 1))

        if [[ "${args[i]}" != -* && ! -z "${args[i]}" ]]
        then
          targetServers=()
        fi

        while [[ "${args[i]}" != -* && ! -z "${args[i]}" ]]
        do
          targetServers+=($(getServersByAny ${args[i]}))
          i=$(($i + 1))
        done

        if [ ${#targetServers} -gt 0 ]
        then
          i=$(($i - 1))
        fi
      ;;
      -tp|--targetPath)
        i=$(($i + 1))

        if [ "${args[i]}" != -* ]
        then
          targetPath="${args[i]}"
        fi
      ;;
      -p|--parallel)
        isParallel=1
      ;;
      -d|--debug)
        printPermission=4
      ;;
      -q|--quiet)
        printPermission=0
      ;;
      -ns|--noServers)
        printServers=0
      ;;
      -w|--width)
        i=$(($i + 1))

        if [ "${args[i]}" != -* ]
        then
          width="${args[i]}"
        fi
      ;;
      *)
        if [[ "${args[i]}" != -* && ! -z "${args[i]}" ]]
        then
          sourcePath="${args[i]}"
        fi
      ;;
    esac
  done

  #--------------------------------------------- Input Resolution ---------------------------------------------#
  if [ ! -z "$sourcePath" -a -z "$targetPath" ]
  then
    targetPath="$(dirname $sourcePath)"
  elif [ -z "$sourcePath" -a ! -z "$targetPath" ]
  then
    sourcePath="$targetPath"
  fi

  #--------------------------------------------- Input Validation ---------------------------------------------#
  inputValidation="$(remoteCopy_validateInput)"
  if [ ! -z "$inputValidation" ]
  then
    fail "remoteCopy: $inputValidation" -w $width
    printPermission=$printPermissionCache
    return 1
  fi

  #----------------------------------------------- Copy Process -----------------------------------------------#
  for targetServer in ${targetServers[@]}
  do
    if [ "$targetServer" != "$sourceServer" ]
    then
      if [ "$sourceServer" = "$(hostname)" ]
      then
        remoteCopy_localToRemote
      elif [ "$targetServer" = "$(hostname)" ]
      then
        remoteCopy_remoteToLocal
      else
        remoteCopy_remoteToRemote
      fi
    fi
  done

  printPermission=$printPermissionCache
}

#--------------------------------------------------------------------------------------------------------------#
#                                                                                                              #
#                                               Input Validation                                               #
#                                                                                                              #
#--------------------------------------------------------------------------------------------------------------#

remoteCopy_validateInput() {
  local validations=(
    remoteCopy_validateSourceServer
    remoteCopy_validateTargetServers
    remoteCopy_validateSourcePath
    remoteCopy_validateTargetPath
    remoteCopy_validateTargetWritability
  )
  local inputValidation=''

  for validation in ${validations[@]}
  do
    inputValidation="$("$validation")"

    if [ ! -z "$inputValidation" ]
    then
      break
    fi
  done

  echo "$inputValidation"
}

remoteCopy_validateSourceServer() {
  local sourceServerValidation=''

  if [ $(isServer $sourceServer) -eq 0 ]
  then
    sourceServerValidation="$sourceServer is not a valid source server"
  fi

  echo "$sourceServerValidation"
}

remoteCopy_validateTargetServers() {
  local targetServersValidation=''

  if [ ${#targetServers} -eq 0 ]
  then
    targetServersValidation="please include a valid target server"
  fi

  echo "$targetServersValidation"
}

remoteCopy_validateSourcePath() {
  local sourcePathValidation=''

  if [ ! -z "$sourcePath" ]
  then
    if ssh -p22222 -oLogLevel=error $user@$sourceServer -oIdentityFile=$psKey "[ ! -d $sourcePath -a ! -f $sourcePath ]" 2>/dev/null
    then
      sourcePathValidation="$sourcePath does not exist on $sourceServer"
    fi
  else
    sourcePathValidation="please include a source path"
  fi

  echo "$sourcePathValidation"
}

remoteCopy_validateTargetPath() {
  local targetPathValidation=''

  if [ ! -z "$targetPath" ]
  then
    for targetServer in ${targetServers[@]}
    do
      if ssh -p22222 -oLogLevel=error $user@$targetServer -oIdentityFile=$psKey "[ ! -d $targetPath -a ! -f $targetPath ]" 2>/dev/null
      then
        targetPathValidation="$targetPath does not exist on $targetServer"
      fi
    done
  fi

  echo "$targetPathValidation"
}

remoteCopy_validateTargetWritability() {
  local targetWritabilityValidation=''

  for targetServer in ${targetServers[@]}
  do
    if ssh -p22222 -oLogLevel=error $user@$targetServer -oIdentityFile=$psKey "[ ! -w $targetPath ]" 2>/dev/null
    then
      targetWritabilityValidation="$targetServer:$targetPath is not writable"
    fi
  done

  echo "$targetWritabilityValidation"
}

#--------------------------------------------------------------------------------------------------------------#
#                                                                                                              #
#                                                Copy Processes                                                #
#                                                                                                              #
#--------------------------------------------------------------------------------------------------------------#

remoteCopy_localToRemote() {
  if [ "$isParallel" -eq "0" ]
  then
    scp -rpq -P22222 -oLogLevel=ERROR -i $psKey $sourcePath $user@$targetServer:$targetPath
    remoteCopy_print $?
  else
    local log="/data/share/pswork/tools/logs/deploy/$targetServer.`date +%Y.%m.%d.%H.%M.%S`.log"

    echo "$targetServer:" &>> $log
    nohup scp -rp -P22222 -oLogLevel=ERROR -i $psKey $sourcePath $user@$targetServer:$targetPath &>> $log
  fi
}

remoteCopy_remoteToLocal() {
  if [ "$isParallel" -eq "0" ]
  then
    scp -rpq -P22222 -oLogLevel=ERROR -i $psKey $user@$sourceServer:$sourcePath $targetPath
    remoteCopy_print $?
  else
    local log="/data/share/pswork/tools/logs/deploy/$targetServer.`date +%Y.%m.%d.%H.%M.%S`.log"

    echo "$targetServer:" &>> $log
    nohup scp -rp -P22222 -oLogLevel=ERROR -i $psKey $user@$sourceServer:$sourcePath $targetPath &>> $log
  fi
}

remoteCopy_remoteToRemote() {
  print1 "remoteCopy cannot copy from a remote server to a remote server"                                                     # FIXME
  return 1

  if [ "$isParallel" -eq "0" ]
  then
    scp -rpq -P22222 -oLogLevel=ERROR -i $psKey $user@$sourceServer:$sourcePath $user@$targetServer:$targetPath
    remoteCopy_print $?
  else
    local log="/data/share/pswork/tools/logs/deploy/$targetServer.`date +%Y.%m.%d.%H.%M.%S`.log"              # FIXME: Should serially print the log, store logs in subdir, and clean up old logs

    echo "$targetServer:" &>> $log
    nohup scp -rp -P22222 -oLogLevel=ERROR -i $psKey $user@$sourceServer:$sourcePath $user@$targetServer:$targetPath &>> $log
  fi
}

#--------------------------------------------------------------------------------------------------------------#
#                                                                                                              #
#                                                    Output                                                    #
#                                                                                                              #
#--------------------------------------------------------------------------------------------------------------#

remoteCopy_print() {
  local returnCode=$1
  local message=''
  local out=''

  if [ "$(dirname $sourcePath)" = "$targetPath" ]
  then
    message="Copy $sourceServer:$sourcePath to $targetServer"
  else
    message="Copy $sourceServer:$sourcePath to $targetServer:$targetPath"
  fi

  if [ $returnCode -eq 0 ]
  then
    out="$(pass $message -w $width)"
  else
    out="$(fail $message -w $width)"
  fi

  print3 "$out"
}

#--------------------------------------------------------------------------------------------------------------#
#                                                                                                              #
#                                                    Debug                                                     #
#                                                                                                              #
#--------------------------------------------------------------------------------------------------------------#

remoteCopy_debug() {
  local msg="$1"
  
  if [ ! -z "$msg" ]
  then
    print4 "$msg"
  fi

  print4 psKey: $psKey
  print4 user: $user
  print4 sourceServer: $sourceServer
  print4 sourcePath: $sourcePath
  print4 targetPath: $targetPath
  print4 targetServers: ${targetServers[@]}
  print4 ""
}