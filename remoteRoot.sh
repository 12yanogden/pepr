# Created:
# by Ryan Ogden
# on 2/17/21
#
# Runs any command on any server(s)

include "crossStandard"
include "serverConfigs"
include "print"
include "printWithLabel"

remoteRoot() {
  #--------------------------------------------- User Validation ----------------------------------------------#
  local userValidation=$(validateUser "psoft")
  if [ ! -z "$userValidation" ]
  then
    print1 "$userValidation"
    return 1
  fi

  #--------------------------------------------- Default Configs ----------------------------------------------#
  local args=($@)
  local targetServers=()
  local command=''
  local isParallel=0
  local user="psoft"
  local psKey="/home/psoft/.ssh/phire"
  local ansible="/opt/psscripts/ansible/remoteRoot.yaml"
  local printServers=1
  local width=89
  local inputValidation=''
  local printPermissionCache=$printPermission
  printPermission=3

  #--------------------------------------------- Input Processing ---------------------------------------------#
  for (( i=0; i<${#args[@]}; i++ ))
  do
    case "${args[i]}" in
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

        if [ ${#targetServers} -gt 0 -o -z "${args[i]}" ]
        then
          i=$(($i - 1))
        fi
      ;;
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
      -w|--width)
        i=$(($i + 1))

        if [ "${args[i]}" != -* ]
        then
          width="${args[i]}"
        fi
      ;;
      help)
        remoteRoot_help
        return 0
      ;;
      *)
        if [ ${args[i]} != -* -a ! -z "${args[i]}" ]
        then
          command+="${args[i]}"
          i=$(($i + 1))

          if [ ${args[i]} != -* -a ! -z "${args[i]}" ]
          then
            command+=" "
          fi
        fi

        i=$(($i - 1))
      ;;
    esac
  done

  #--------------------------------------------- Input Validation ---------------------------------------------#
  inputValidation="$(remoteRoot_validateInput)"
  if [ ! -z "$inputValidation" ]
  then
    fail "remoteRoot: $inputValidation" -w $width
    printPermission=$printPermissionCache
    return 1
  fi

  #--------------------------------------------- Command Process ----------------------------------------------#
  for i in "${!targetServers[@]}"
  do
    
  done

  ssh -p22222 -oLogLevel=error $user@$targetServer -oIdentityFile=$psKey "ansible-playbook $ansible -e \"command=$command\""

  printPermission=$printPermissionCache
}

#--------------------------------------------------------------------------------------------------------------#
#                                                                                                              #
#                                               Input Validation                                               #
#                                                                                                              #
#--------------------------------------------------------------------------------------------------------------#

remoteRoot_validateInput() {
  local validations=(
    remoteRoot_validateTargetServers
    remoteRoot_validateCommand
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

remoteRoot_validateTargetServers() {
  local targetServersValidation=''

  if [ ${#targetServers[@]} -eq 0 ]
  then
    targetServersValidation="please include a valid target server"
  fi

  echo "$targetServersValidation"
}

remoteRoot_validateCommand() {
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

remoteRoot_print() {
  local result="$1"
  local returnCode=$2
  local out=''

  if [ $printServers -eq 1 -a ${#targetServers[@]} -gt 1 ]
  then
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

  print3 -e "$out"
}

remoteRoot_help() {
  crossBlock "remoteRoot Help" -w $width
  print3 "remoteRoot runs any command on any server(s). It was created to help PeopleSoft Administrators manage a large network of servers. Below are a list of flags and example variations for remoteRoot." -w $width
  skip
  print3 "Flags:"
  print3 "-ts|--targetServers)"
  print3 -i 1 "Specifies what server(s) the command will run on. Can input server(s), app(s), env(s), appEnv(s), nonprd, or all. Uses input standardization to accomodate for name variations. remoteRoot will run on each server alphabetically, and output in that same order. Use -dmo to include dmo servers." -w $width
  print3 -i 1 "remoteRoot \"hostname\" -ts pound1 hr" -w $width
  print3 -i 1 "remoteRoot \"hostname\" -ts dev" -w $width
  print3 -i 1 "remoteRoot \"hostname\" -ts cOpy psacmPROD nonprod" -w $width
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

remoteRoot_debug() {
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