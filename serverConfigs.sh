# Created:
# by Ryan Ogden
# on 4/29/21
#
# Manages data in serverConfigs

include "array"
include "print"

#--------------------------------------------------------------------------------------------------------------#
#                                                                                                              #
#                                               Global Variables                                               #
#                                                                                                              #
#--------------------------------------------------------------------------------------------------------------#
serverConfigs="/data/share/pswork/tools/config/scriptConfig/serverConfigs.txt"

#--------------------------------------------------------------------------------------------------------------#
#                                                                                                              #
#                                            Private Use Functions                                             #
#                                                                                                              #
#--------------------------------------------------------------------------------------------------------------#

# Returns the field index of the header given
# serverConfigs_getFieldIndexByHeader "header" => "fieldIndex"
serverConfigs_getFieldIndexByHeader() {
  local headers=($(head -1 $serverConfigs | sed 's/\t/ /g'))
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

# Returns the servers whose field value match the field and value given
# serverConfigs_getServersByFieldValue "field" "value" => "server1 server2 ... serverN"
serverConfigs_getServersByFieldValue() {
  local field="$1"
  local value="$2"
  local fieldIndex="$(($(serverConfigs_getFieldIndexByHeader $field) + 1))"

  awk -F '\t' -v "fieldIndex=$fieldIndex" -v "value=$value" '{
    if (NR > 1 && $fieldIndex == value)
      print $1;
    }' $serverConfigs
}

# Returns the servers whose field values match the two pairs of fields and values given
# serverConfigs_getServersByTwoFieldValues "field1" "value1" "field2" "value2" => "server1 server2 ... serverN"
serverConfigs_getServersByTwoFieldValues() {
  local field1="$1"
  local value1="$2"
  local field2="$3"
  local value2="$4"
  local fieldIndex1="$(($(serverConfigs_getFieldIndexByHeader $field1) + 1))"
  local fieldIndex2="$(($(serverConfigs_getFieldIndexByHeader $field2) + 1))"

  awk -F '\t' -v "fieldIndex1=$fieldIndex1" -v "value1=$value1" -v "fieldIndex2=$fieldIndex2" -v "value2=$value2" '{
    if (NR > 1 && $fieldIndex1 == value1 && $fieldIndex2 == value2)
      print $1;
    }' $serverConfigs
}

# This function is under development
# Returns the servers whose field values match the pairs of fields and values given
# serverConfigs_getServersByFieldValues "field1" "value1" "field2" "value2" ... "fieldN" "valueN" => "server1 server2 ... serverN"
serverConfigs_getServersByFieldValues() {
  local args=("$@")
  local headers=()
  local values=()
  local isHeader=1
  local headerIndexes=()
  
  #for arg in "${args[@]}"
  #do
  #done

  
  "$(($(serverConfigs_getFieldIndexByHeader $header) + 1))"

  awk -F '\t' -v "headerIndex=$headerIndex" -v "value=$value" '{
    if (NR > 1 && $headerIndex == value)
      print $1;
    }' $serverConfigs
}

# Returns the fieldValue of the server and field given
# serverConfigs_getFieldValueByServer "server" "field" => "fieldValue"
serverConfigs_getFieldValueByServer() {
  local server="$1"
  local field="$2"
  local fieldIndex="$(($(serverConfigs_getFieldIndexByHeader "$field") + 1))"

  awk -F '\t' -v "server=$server" -v "fieldIndex=$fieldIndex" '{
    if (NR > 1 && $1 == server)
      print $fieldIndex;
    }' $serverConfigs
}

# Sets the fieldValue of the server and field given to the value given
# serverConfigs_setFieldValueByServer "server" "field" "value"
serverConfigs_setFieldValueByServer() {
  local server="$1"
  local field="$2"
  local value="$3"
  local fieldIndex="$(serverConfigs_getFieldIndexByHeader "environment")"
  local originalConfigs=("$(getAllByServer "$server")")
  local editConfigs=(${originalConfigs[@]})
  local tabulatedOriginalConfigs=""
  local tabulatedEditConfigs=""
  local user="$(whoami)"

  if [ "$user" != "psoft" -o "$user" != "root" ]
  then
    echo "Must be psoft or root to modify $serverConfigs"
    return 1
  fi

  editConfigs[$fieldIndex]="$value"

  tabulatedOriginalConfigs="$(echo ${originalConfigs[@]} | sed 's/ /\t/g')"
  tabulatedEditConfigs="$(echo ${editConfigs[@]} | sed 's/ /\t/g')"

  sed -i "s/$tabulatedOriginalConfigs/$tabulatedEditConfigs/g" $serverConfigs
}

#--------------------------------------------------------------------------------------------------------------#
#                                                                                                              #
#                                             Public Use Functions                                             #
#                                                                                                              #
#--------------------------------------------------------------------------------------------------------------#

# Returns all of the configs of the server given
# getAllByServer "server" => "config1 config2 ... configN"
getAllByServer() {
  local server="$1"
  local all=("$(awk -F '\t' -v "server=$server" '{
    if (NR > 1 && $1 == server)
      print;
    }' $serverConfigs)")
  
  echo "$(echo ${all[@]} | sed 's/\t/ /g')"
}

# Returns the servers of the application given, excludes demo servers by default
# getServersByApp "application" [--dmo to include demo servers] => "server1 server2 ... serverN"
getServersByApp() {
  local args=($@)
  local app=''
  local includeDmo=''
  local dmoServers=()
  local servers=()

  for arg in ${args[@]}
  do
    case "$arg" in
      --dmo)
        includeDmo="$arg"
      ;;
      *)
        if [ "$arg" != -* ]
        then
          app="$(standardizeAny $arg)"
        fi
      ;;
    esac
  done

  servers=($(serverConfigs_getServersByFieldValue "application" "$app"))

  if [ -z "$includeDmo" ]
  then
    dmoServers=($(serverConfigs_getServersByFieldValue "environment" "dmo"))
    servers=("$(subtract "${servers[@]}" - "${dmoServers[@]}")")
  fi

  echo "${servers[@]}"
}

# Returns the servers of the environment given
# getServersByEnv "environment" => "server1 server2 ... serverN"
getServersByEnv() {
  local env="$1"
  local servers=($(serverConfigs_getServersByFieldValue "environment" "$env"))

  if [ "$env" = "pch" ]
  then
    servers+=($(serverConfigs_getServersByFieldValue "environment" "tmpl"))
  fi

  echo "${servers[@]}"
}

getServersByAppEnv() {
  local appEnv="$(standardizeAny $1)"
  eval $(calcAppAndEnvByAppEnv $appEnv)
  local servers=()

  servers=($(serverConfigs_getServersByTwoFieldValues "application" ${appAndEnv[app]} "environment" ${appAndEnv[env]}))

  if [ "${appAndEnv[app]}" = "pacm" -a "${appAndEnv[env]}" = "pch" ]
  then
    servers+=($(serverConfigs_getServersByTwoFieldValues "application" ${appAndEnv[app]} "environment" "tmpl"))
  fi

  echo ${servers[@]}
}

# Returns app and env of the appEnv given
# calcAppAndEnvByAppEnv "appEnv" => "app env"
calcAppAndEnvByAppEnv() {
  local target="$1"
  local apps=($(getApps))
  local envs=($(getEnvs))
  declare -A appAndEnv=([app]='' [env]='')

  for app in ${apps[@]}
  do
    for env in ${envs[@]}
    do
      if [ "$env" != "tmpl" ]
      then
        if [ "${app}${env}" = "$target" ]
        then
          appAndEnv[app]=$app
          appAndEnv[env]=$env
          break
        fi
      fi
    done
  done

  if [ "${app}${env}" = "pacmtmpl" ]
  then
    appAndEnv[app]="pacm"
    appAndEnv[env]="tmpl"
  fi

  declare -p appAndEnv
}

getServersByGroup() {
  local args=($@)
  local group=''
  local includeDmo=''
  local servers=()

  for arg in ${args[@]}
  do
    case "$arg" in
      --dmo)
        includeDmo="$arg"
      ;;
      *)
        if [ "$arg" != -* ]
        then
          group="$(standardizeAny $arg)"
        fi
      ;;
    esac
  done

  case $group in
    nonprd)
      local envs=($(getEnvs))

      for env in ${envs[@]}
      do
        if [ "$env" != "prd" -a "$env" != "tmpl" ]
        then
          if [ -z "$includeDmo" ]
          then
            if [ "$env" != "dmo" ]
            then
              servers+=($(getServersByEnv $env))
            fi
          else
            servers+=($(getServersByEnv $env))
          fi
        fi
      done
    ;;
    all)
      if [ -z "$includeDmo" ]
      then
        servers=($(getServers))
      else
        servers=($(getServers $includeDmo))
      fi
    ;;
  esac

  echo ${servers[@]}
}

# Returns the application of the server given
# getAppByServer "server" => "application"
getAppByServer() {
  local server="$1"
  local app="$(serverConfigs_getFieldValueByServer "$server" "application")"

  echo "$app"
}

# Returns the DBName of the server given
# getDBNameByServer "server" => "DBName"
getDBNameByServer() {
  local server="$1"
  local db="$(serverConfigs_getFieldValueByServer "$server" "DBName")"

  echo "$db"
}

# Returns the domain of the server given
# getDomainByServer "server" => "domain"
getDomainByServer() {
  local server="$1"
  local domain="$(serverConfigs_getFieldValueByServer "$server" "domain")"

  echo "$domain"
}

# Returns the environment of the server given
# getEnvByServer "server" => "environment"
getEnvByServer() {
  local server="$1"
  local env="$(serverConfigs_getFieldValueByServer "$server" "environment")"

  echo "$env"
}

# Returns the agent server of the server given
# getAgentByServer "server" => "agent"
getAgentByServer() {
  local server="$1"
  local app="$(getAppByServer "$server")"
  local agent="$(serverConfigs_getServersByTwoFieldValues "application" "$app" "isAgent" "T")"

  echo "$agent"
}

# Returns the Tuxedo version of the server given
# getTuxVersionByServer "server" => "tuxVersion"
getTuxVersionByServer() {
  local server="$1"
  local tuxVersion="$(serverConfigs_getFieldValueByServer "$server" "tuxVersion")"

  echo "$tuxVersion"
}

# Returns the gateway server of the server given
# getGatewayByServer "server" => "gateway server"
getGatewayByServer() {
  local server="$1"
  local env="$(getEnvByServer $server)"
  local gateway="$(serverConfigs_getServersByTwoFieldValues "environment" $env "isGateway" "T")"

  echo "$gateway"
}

# Returns all servers
# getServers => "server1 server2 ... serverN"
getServers() {
  local includeDmo="$1"
  local field="server"
  local fieldIndex="$(($(serverConfigs_getFieldIndexByHeader $field) + 1))"
  local envIndex="$(($(serverConfigs_getFieldIndexByHeader "environment") + 1))"
  local servers=()

  if [ -z "$includeDmo" ]
  then
    servers=($(awk -F '\t' -v "fieldIndex=$fieldIndex" -v "envIndex=$envIndex" '{
    if (NR > 1 && $envIndex != "dmo")
      print $fieldIndex;
    }' $serverConfigs))
  elif [ "$includeDmo" = "--dmo" ]
  then
    servers=($(awk -F '\t' -v "fieldIndex=$fieldIndex" '{
    if (NR > 1)
      print $fieldIndex;
    }' $serverConfigs))
  fi

  echo "${servers[@]}"
}

# Returns all apps
# getApps => "app1 app2 ... appN"
getApps() {
  local field="application"
  local fieldIndex="$(($(serverConfigs_getFieldIndexByHeader $field) + 1))"
  local apps=($(awk -F '\t' -v "fieldIndex=$fieldIndex" '{
    if (NR > 1)
      print $fieldIndex;
    }' $serverConfigs))
  
  apps=($(removeDups ${apps[@]}))

  echo "${apps[@]}"
}

# Returns all envs
# getEnvs => "env1 env2 ... envN"
getEnvs() {
  local field="environment"
  local fieldIndex="$(($(serverConfigs_getFieldIndexByHeader $field) + 1))"
  local envs=($(awk -F '\t' -v "fieldIndex=$fieldIndex" '{
    if (NR > 1)
      print $fieldIndex;
    }' $serverConfigs))

  envs=($(removeDups ${envs[@]}))

  echo "${envs[@]}"
}

# Returns all appEnvs
# getAppEnvs => "appEnv1 appEnv2 ... appEnvN"
getAppEnvs() {
  local apps=($(getApps))
  local envs=($(getEnvs))
  local appEnvs=()

  for app in ${apps[@]}
  do
    for env in ${envs[@]}
    do
      if [ "$env" != "tmpl" ]
      then
        appEnvs+=("${app}${env}")
      fi
    done
  done
  
  appEnvs+=("pacmtmpl")

  echo "${appEnvs[@]}"
}

# Returns standarized version of app, env, appEnv, or server group given
# standardizeAny "app/env/appEnv/group" => standardized "app/env/appEnv/group"
standardizeAny() {
  local any="$@"
    
  # Sets all characters to lower case
  any="$(echo "$any" | awk '{print tolower($0)}')"

  # Removes all spaces
  any=${any//[[:blank:]]/}

  # Removes surrounding quotes
  any=${any%\"}
  any=${any#\"}

  # Replaces common invalid inputs
  any=${any/psacm/pacm}
  any=${any/hrms/hr}
  any=${any/demo/dmo}
  any=${any/prod/prd}
  any=${any/copy/cpy}
  any=${any/patch/pch}
  any=${any/pch2/cstm}
  any=${any/custom/cstm}

  echo "$any"
}

# Returns 1 if the server given is valid, else 0
# isServer "server" => 1, else 0
isServer() {
  local args=($@)
  local target=''
  local includeDmo=''
  local servers=()
  local isServer=0

  for arg in ${args[@]}
  do
    case "$arg" in
      --dmo)
        includeDmo="$arg"
      ;;
      *)
        target="$arg"
      ;;
    esac
  done

  servers=($(getServers $includeDmo))

  for server in ${servers[@]}
  do
    if [ "$server" = "$target" ]
    then
      isServer=1
      break
    fi
  done

  echo "$isServer"
}

# Returns 1 if the app given is valid, else 0
# isApp "app" => 1, else 0
isApp() {
  local target="$(standardizeAny "$1")"
  local apps=($(getApps))
  local isApp=0

  for app in ${apps[@]}
  do
    if [ "$app" = "$target" ]
    then
      isApp=1
      break
    fi
  done

  echo "$isApp"
}

# Returns 1 if the env given is valid, else 0
# isEnv "env" => 1, else 0
isEnv() {
  local target="$(standardizeAny "$1")"
  local envs=($(getEnvs))
  local isEnv=0

  for env in ${envs[@]}
  do
    if [ "$env" = "$target" ]
    then
      isEnv=1
      break
    fi
  done

  echo "$isEnv"
}

# Returns 1 if the appEnv given is valid, else 0
# isAppEnv "appEnv" => 1, else 0
isAppEnv() {
  local target="$(standardizeAny "$1")"
  local appEnvs=($(getAppEnvs))
  local isAppEnv=0

  for appEnv in ${appEnvs[@]}
  do
    if [ "$appEnv" = "$target" ]
    then
      isAppEnv=1
      break
    fi
  done

  echo "$isAppEnv"
}

isAbstract() {
  local target="$(standardizeAny "$1")"
  local groups=("all" "nonprd")
  local isAbstract=0

  for group in ${groups[@]}
  do
    if [ "$group" = "$target" ]
    then
      isAbstract=1
      break
    fi
  done

  echo "$isAbstract"
}

isAny() {
  local target="$(standardizeAny "$1")"
  local validations=(
    isServer
    isApp
    isEnv
    isAppEnv
    isAbstract
  )
  local isAny=0

  for validation in ${validations[@]}
  do
    if [ $($validation $target) -eq 1 ]
    then
      isAny=1
      break
    fi
  done

  echo $isAny 
}

getServerGroupType() {
  local target="$(standardizeAny "$1")"
  declare -A serverGroupTypes=(
    [server]=isServer
    [app]=isApp
    [env]isEnv
    [appEnv]=isAppEnv
    [abstract]=isAbstract
  )
  local serverGroupType=0

  for i in ${!serverGroupTypes[@]}
  do
    if [ $(${serverGroupTypes[i]} $target) -eq 1 ]
    then
      serverGroupType="$i"
      break
    fi
  done

  echo "$serverGroupType"
}

isGateway() {
  local gatewayServers=($(serverConfigs_getServersByFieldValue "isGateway" "T"))
  local target="$1"
  local isGateway=0

  for gatewayServer in ${gatewayServers[@]}
  do
    if [ "$gatewayServer" = "$target" ]
    then
      isGateway=1
      break
    fi
  done

  echo "$isGateway"
}

isIntegration() {
  local integrationServers=($(serverConfigs_getServersByFieldValue "isIntegration" "T"))
  local target="$1"
  local isIntegration=0

  for integrationServer in ${integrationServers[@]}
  do
    if [ "$integrationServer" = "$target" ]
    then
      isIntegration=1
      break
    fi
  done

  echo "$isIntegration"
}

isJRAD() {
  local JRADServers=($(serverConfigs_getServersByFieldValue "isJRAD" "T"))
  local target="$1"
  local isJRAD=0

  for JRADServer in ${JRADServers[@]}
  do
    if [ "$JRADServer" = "$target" ]
    then
      isJRAD=1
      break
    fi
  done

  echo "$isJRAD"
}

hasApp() {
  local appServers=($(serverConfigs_getServersByFieldValue "hasApp" "T"))
  local target="$1"
  local hasApp=0

  for appServer in ${appServers[@]}
  do
    if [ "$appServer" = "$target" ]
    then
      hasApp=1
      break
    fi
  done

  echo "$hasApp"
}

hasProcess() {
  local prcsServers=($(serverConfigs_getServersByFieldValue "hasProcess" "T"))
  local target="$1"
  local hasProcess=0

  for prcsServer in ${prcsServers[@]}
  do
    if [ "$prcsServer" = "$target" ]
    then
      hasProcess=1
      break
    fi
  done

  echo "$hasProcess"
}

getAppServers() {
  local appServers=($(serverConfigs_getServersByFieldValue "hasApp" "T"))

  echo "${appServers[@]}"
}

getPrcsServers() {
  local prcsServers=($(serverConfigs_getServersByFieldValue "hasProcess" "T"))

  echo "${prcsServers[@]}"
}

# Returns servers that belong to the given app, env, or appEnv given
# getServersByAny "server/app/env/appEnv" => "server1 server2 ... serverN"
getServersByAny() {
  local args=($@)
  local includeDmo=''
  local in=''
  local servers=()

  for ((i=0; i<${#args[@]}; i++))
  do
    case "${args[i]}" in
      --dmo)
        includeDmo="${args[i]}"
      ;;
      *)
        in="$(standardizeAny "${args[i]}")"
      ;;
    esac
  done

  if [ $(isServer $in $includeDmo) -eq 1 ]
  then
    servers=($in)
  elif [ $(isApp $in) -eq 1 ]
  then
    servers=($(getServersByApp $in $includeDmo))
  elif [ $(isEnv $in) -eq 1 ]
  then
    servers=($(getServersByEnv $in))
  elif [ $(isAppEnv $in) -eq 1 ]
  then
    servers=($(getServersByAppEnv $in))
  elif [ $(isAbstract $in) -eq 1 ]
  then
    servers=($(getServersByGroup $in $includeDmo))
  fi

  echo "${servers[@]}"
}

# Sets the Tuxedo version of the server given
# setTuxVersionByServer "server" "version"
setTuxVersionByServer() {
  local server="$1"
  local version="$2"

  if [[ "$version" =~ ^[0-9]{2,}(\.[0-9]{1,}){4}$ ]]
  then
    serverConfigs_setFieldValueByServer "$server" "tuxVersion" "$version"
  else
    print1 "setTuxVersionByServer: $version is an invalid version"
  fi
}