# Created:
# by Ryan Ogden
# on 2/17/21
#
# Runs any command on any server(s)

include "crossStandard"
include "serverConfigs"
include "print"
include "printWithLabel"

rc() {
  remoteCommand $@
}

remoteCommand() {
  #--------------------------------------------- Default Configs ----------------------------------------------#
  local args=($@)
  local targetServers=()
  local isTrusted=0
  local command=''
  local isParallel=0
  local user=$(whoami)
  local psKey=/home/psoft/.ssh/phire
  local printServers=1
  local outOnly=0
  local width=89
  local inputValidation=''
  local printPermissionCache=$printPermission
  printPermission=3
  local returnCode=0

  #--------------------------------------------- Input Processing ---------------------------------------------#
  for (( i=0; i<${#args[@]}; i++ ))
  do
    case "${args[$i]}" in
      -p|-pl|--parallel)
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
      -oo)
        outOnly=1
      ;;
      --trust)
        isTrusted=1
      ;;
      -w|--width)
        i=$(($i + 1))

        if [ "${args[i]}" != -* ]
        then
          width="${args[i]}"
        fi
      ;;
      help)
        remoteCommand_help
        printPermission=$printPermissionCache
        return 0
      ;;
      -ts|--targetServers)
        i=$(($i + 1))

        while [[ "${args[$i]}" != -* && ! -z "${args[$i]}" ]]
        do
          if [ $isTrusted -eq 1 ]
          then
            targetServers+=(${args[$i]})
          else
            targetServers+=($(getServersByAny ${args[$i]}))
          fi

          i=$(($i + 1))
        done

        if [ ${#targetServers} -gt 0 -o -z "${args[$i]}" ]
        then
          i=$(($i - 1))
        fi
      ;;
      *)
        if [ -z "$command" ]
        then
          command="${args[$i]}"
        else
          command+=" ${args[$i]}"
        fi
      ;;
    esac
  done

  #--------------------------------------------- Input Validation ---------------------------------------------#
  inputValidation="$(remoteCommand_validateInput)"
  if [ ! -z "$inputValidation" ]
  then
    fail "remoteCommand: $inputValidation" -w $width
    printPermission=$printPermissionCache
    return 1
  fi

  #--------------------------------------------- Command Process ----------------------------------------------#
  for targetServer in "${targetServers[@]}"
  do
    if [ $isParallel -eq 0 ]
    then
      local returnCodeByTarget=0

      remoteCommand_print "$(ssh -p22222 -oLogLevel=error $user@$targetServer -oIdentityFile=$psKey "$command" 2>&1)" $?
      returnCodeByTarget=$?

      if [ $returnCodeByTarget -ne 0 ]
      then
        returnCode=$returnCodeByTarget
      fi
    else
      local log="/data/share/pswork/tools/logs/deploy/$targetServer.`date +%Y.%m.%d.%H.%M.%S`.log"              # FIXME: Should serially print the log, store logs in subdir, and clean up old logs

      echo "$targetServer:" &>> $log

      if [ "$user" = "psoft" ]
      then 
        nohup ssh -q -p22222 -oLogLevel=error $user@$targetServer -oIdentityFile=$psKey "$command" &>> $log
      else
        nohup ssh -q -p22222 -oLogLevel=error $user@$targetServer "$command" &>> $log
      fi
    fi
  done

  printPermission=$printPermissionCache
  return $returnCode
}

#--------------------------------------------------------------------------------------------------------------#
#                                                                                                              #
#                                               Input Validation                                               #
#                                                                                                              #
#--------------------------------------------------------------------------------------------------------------#

remoteCommand_validateInput() {
  local validations=(
    remoteCommand_validateTargetServers
    remoteCommand_validateCommand
  )
  local inputValidation=''

  for validation in ${validations[@]}
  do
    inputValidation="$($validation)"

    if [ ! -z "$inputValidation" ]
    then
      break
    fi
  done

  echo "$inputValidation"
}

remoteCommand_validateTargetServers() {
  local targetServersValidation=''

  if [ ${#targetServers[@]} -eq 0 ]
  then
    targetServersValidation="please include a valid target server"
  fi

  echo "$targetServersValidation"
}

remoteCommand_validateCommand() {
  local commandValidation=''

  if [ -z "$command" ]
  then
    commandValidation="please include a command"
  fi

  echo "$commandValidation"
}

#--------------------------------------------------------------------------------------------------------------#
#                                                                                                              #
#                                                    Output                                                    #
#                                                                                                              #
#--------------------------------------------------------------------------------------------------------------#

remoteCommand_print() {
  local result="$1"
  local returnCode=$2
  local out=''

  if [ $outOnly -eq 1 ]
  then
    out="$result"
  else
    if [ $printServers -eq 1 -a ${#targetServers[@]} -gt 1 ]
    then
      width=$(($width - 16))

      if [ -z "$result" ]
      then
        if [ $returnCode -eq 0 ]
        then
          out+=$(pass "$command" -w $width)
        else
          out+=$(fail "$command" -w $width)
        fi

        out="$(printWithLabel "$targetServer" "$out")"
      else
        out+="$(printWithLabel "$targetServer" "$result")"
      fi
    else
      if [ -z "$result" ]
      then
        if [ $returnCode -eq 0 ]
        then
          out+=$(pass "$command" -w $width)
        else
          out+=$(fail "$command" -w $width)
        fi
      else
        out+="$result"
      fi
    fi
  fi

  print3 -e "$out"

  return $returnCode
}

remoteCommand_help() {
  crossBlock "remoteCommand Help" -w $width
  print3 "remoteCommand runs any command on any server(s). It was created to help PeopleSoft Administrators manage a large network of servers. Below are a list of flags and example variations for remoteCommand." -w $width
  skip
  print3 "Flags:"
  print3 "-ts|--targetServers)"
  print3 -i 1 "Specifies what server(s) the command will run on. Can input server(s), app(s), env(s), appEnv(s), nonprd, or all. Uses input standardization to accomodate for name variations. remoteCommand will run on each server alphabetically, and output in that same order. Use -dmo to include dmo servers." -w $width
  print3 -i 1 "remoteCommand \"hostname\" -ts pound1 hr" -w $width
  print3 -i 1 "remoteCommand \"hostname\" -ts dev" -w $width
  print3 -i 1 "remoteCommand \"hostname\" -ts cOpy psacmPROD nonprod" -w $width
  skip
  print3 "-p|--parallel)"
  skip
  print3 "-d|--debug)"
  skip
  print3 "-q|--quiet)"
  skip
  print3 "-ns|--noServers)"
  skip
  print3 "-w|--width)"
  skip
  crossDiv -w $width
}

#--------------------------------------------------------------------------------------------------------------#
#                                                                                                              #
#                                                    Debug                                                     #
#                                                                                                              #
#--------------------------------------------------------------------------------------------------------------#

remoteCommand_debug() {
  local msg="$1"
  
  if [ ! -z "$msg" ]
  then
    print4 "$msg"
  fi

  print4 command: $command
  print4 isParallel: $isParallel
  print4 user: $user
  print4 psKey: $psKey
  print4 targetServers: ${targetServers[@]}
  print4 targetServer: $targetServer
  print4 ""
}