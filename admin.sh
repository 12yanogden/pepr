# Created:
# by Ryan Ogden
# on 5/28/21
#
# Provides useful functions for Peoplesoft Administration

include "array"
include "print"

autoboot() {
  local args=($@)
  local psDomains="/opt/psoft/config/PS_DOMAINS.cfg"
  local targetServers=($(hostname))
  local action=''
  local actionDeclared=0
  local width=89

  for (( i=0; i<${#args[@]}; i++ ))
  do
    case "${args[i]}" in
      -ts|--targetServers)
        i=$(($i + 1))

        if [[ "${args[i]}" != -* && ! -z "${args[i]}" ]]
        then
          targetServers=()
        fi

        while [[ "${args[i]}" - ]]                                        # FIXME: include isServerGroupType
        do
          targetServers+=(${args[i]})
          i=$(($i + 1))
        done

        if [ ${#targetServers} -gt 0 -o -z "${args[i]}" ]
        then
          i=$(($i - 1))
        fi
      ;;
      on|off|status|help)
        if [ $actionDeclared -eq 0 ]
        then
          action="${args[i]}"
          actionDeclared=1
        else
          print1 "autoboot: the action \"autoboot $action\" has already been declared. \"autoboot ${args[i]}\" is invalid"
          return 1
        fi
      ;;
      -q|--quiet)
        printPermission=0
      ;;
      -e|--errorOnly)
        printPermission=1
      ;;
      -d|--debug)
        printPermission=4
      ;;
      *)
        print1 "autoboot: unrecognized argument: ${args[i]}"
        return 1
      ;;
    esac
  done

  if [ -z "$action" ]
  then
    print1 "autoboot: please include an action command"
    autoboot_help
    return 1
  else
    case "$action" in
      on)
        remoteCommand "sed -i 's/N:/Y:/g' $psDomains" -ts ${targetServers[@]} -q
        autoboot_status
      ;;
      off)
        remoteCommand "sed -i 's/Y:/N:/g' $psDomains" -ts ${targetServers[@]} -q
        autoboot_status
      ;;
      status)
        autoboot_status
      ;;
      help)
        autoboot_help
      ;;
    esac
  fi
}

autoboot_status() {
  local status="$(remoteCommand "grep 'Y:\|N:' /opt/psoft/config/PS_DOMAINS.cfg" -ts ${targetServers[@]})"
      
  status="${status//Y:app/APP  [ ACTIVE ]}"
  status="${status//N:app/APP  [ INACTIVE ]}"
  status="${status//Y:prcs/PRCS [ ACTIVE ]}"
  status="${status//N:prcs/PRCS [ INACTIVE ]}"
  status="${status//Y:web/WEB  [ ACTIVE ]}"
  status="${status//N:web/WEB  [ INACTIVE ]}"
  
  print3 "$status"
}

autoboot_help() {
  declare -A arguments=(
    [on]="Sets autoboot to on"
    [off]="Sets autoboot to off"
    [status]="Prints status of autoboot"
    [help]="Prints help"
    [-ts|--targetServers \[targetServers\]]="Executes on the target server(s) given"
    [-q|--quiet]="Suppresses all output"
    [-e|--errorOnly]="Suppresses all output, except errors"
    [-d|--debug]="Includes debug messages in output"
  )

  print3 -w $width "autoboot is a function for managing psmonitor's autoboot functionality."
  print3 -w $width "autoboot [action]"
  skip
  print 3 -w $width "The available arguments include:"

  for i in ${!arguments[@]}
  do
    print3 -i 1 -w $width "$(printWithLabel "$i" "${arguments[i]}")"
  done
}

startServer() {
  local args=($@)
  local targetServers=($(hostname))
  local serverTypes=()
  local width=89

  for (( i=0; i<${#args[@]}; i++ ))
  do
    case "${args[i]}" in
      -ts|--targetServers)
        i=$(($i + 1))

        if [[ "${args[i]}" != -* && ! -z "${args[i]}" ]]
        then
          targetServers=()
        fi

        while [[ "${args[i]}" - ]]                                        # FIXME: include isServerGroupType
        do
          targetServers+=(${args[i]})
          i=$(($i + 1))
        done

        if [ ${#targetServers} -gt 0 -o -z "${args[i]}" ]
        then
          i=$(($i - 1))
        fi
      ;;
      app|application)
        serverTypes+=(app)
      ;;
      prcs|process)
        serverTypes+=(prcs)
      ;;
      web|pia)
        serverTypes+=(web)
      ;;
      all)
        serverTypes+=(app prcs web)
      ;;
      -q|--quiet)
        printPermission=0
      ;;
      -e|--errorOnly)
        printPermission=1
      ;;
      -d|--debug)
        printPermission=4
      ;;
      *)
        print1 "startServer: unrecognized argument: ${args[i]}"
        return 1
      ;;
    esac
  done

  serverTypes=($(removeDups ${serverTypes[@]}))

  $PS_HOME/appserv/psadmin -c parallelboot -d $app_domain
  $PS_HOME/appserv/psadmin -p start -d $prcs_domain
  $PS_HOME/appserv/psadmin -w start -d $web_domain
}

startServer_status() {
  local status="$(remoteCommand "grep 'Y:\|N:' /opt/psoft/config/PS_DOMAINS.cfg" -ts ${targetServers[@]})"
      
  status="${status//Y:app/APP  [ ACTIVE ]}"
  status="${status//N:app/APP  [ INACTIVE ]}"
  status="${status//Y:prcs/PRCS [ ACTIVE ]}"
  status="${status//N:prcs/PRCS [ INACTIVE ]}"
  status="${status//Y:web/WEB  [ ACTIVE ]}"
  status="${status//N:web/WEB  [ INACTIVE ]}"
  
  print3 "$status"
}

startServer_help() {
  declare -A arguments=(
    [serverType(s)]="Specifies the server type(s) to be started. Can be app, prcs, web, all, or a combination separated by spaces."
    [help]="Prints help"
    [-ts|--targetServers \[targetServers\]]="Executes on the target server(s) given"
    [-q|--quiet]="Suppresses all output"
    [-e|--errorOnly]="Suppresses all output, except errors"
    [-d|--debug]="Includes debug messages in output"
  )

  print3 -w $width "startServer will start the servers types given."
  print3 -w $width "startServer [serverType(s)]"
  skip
  print 3 -w $width "The available arguments include:"

  for i in ${!arguments[@]}
  do
    print3 -i 1 -w $width "$(printWithLabel "$i" "${arguments[i]}")"
  done
}

getServerStatus() {
  local args=($@)
  local targetServers=($(hostname))
  local serverTypes=()
  local width=89

  for (( i=0; i<${#args[@]}; i++ ))
  do
    case "${args[i]}" in
      -ts|--targetServers)
        i=$(($i + 1))

        if [[ "${args[i]}" != -* && ! -z "${args[i]}" ]]
        then
          targetServers=()
        fi

        while [[ "${args[i]}" - ]]                                        # FIXME: include isServerGroupType
        do
          targetServers+=(${args[i]})
          i=$(($i + 1))
        done

        if [ ${#targetServers} -gt 0 -o -z "${args[i]}" ]
        then
          i=$(($i - 1))
        fi
      ;;
      app|application)
        serverTypes+=(app)
      ;;
      prcs|process)
        serverTypes+=(prcs)
      ;;
      web|pia)
        serverTypes+=(web)
      ;;
      all)
        serverTypes+=(app prcs web)
      ;;
      -q|--quiet)
        printPermission=0
      ;;
      -e|--errorOnly)
        printPermission=1
      ;;
      -d|--debug)
        printPermission=4
      ;;
      *)
        print1 "getServerStatus: unrecognized argument: ${args[i]}"
        return 1
      ;;
    esac
  done

  serverTypes=($(removeDups ${serverTypes[@]}))

  for serverType in ${serverTypes[@]}
  do
    case "$serverType" in
      app)
        local hasApps=($(intersect ${targetServers[@]} ^ $(getHasApps)))
        local hasAppsProcessCounts="$(remoteCommand "ps -u psoft -o cmd= | grep -E 'BBL.*dom=app' | grep -v 'grep' | wc -l" -ts ${hasApps[@]})"
        local hasAppsStatus="$(echo "$hasAppsProcessCounts" | sed s/'0'/'[ INACTIVE ]'/g)" # FIXME: Need to highlight [ ACTIVE ]

      ;;
      prcs)
      ;;
      web)
      ;;
    esac
  done
}