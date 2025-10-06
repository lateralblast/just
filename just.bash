#!/usr/bin/env bash

# Name:         just (Just a UNIX Shell script Template [with bash features])
# Version:      0.2.7
# Release:      1
# License:      CC-BA (Creative Commons By Attribution)
#               http://creativecommons.org/licenses/by/4.0/legalcode
# Group:        System
# Source:       N/A
# URL:          https://github.com/lateralblast/just
# Distribution: UNIX
# Vendor:       UNIX
# Packager:     Richard Spindler <richard@lateralblast.com.au>
# Description:  A template for writing shell scripts

# Insert some shellcheck disables
# Depending on your requirements, you may want to add/remove disables
# shellcheck disable=SC2034
# shellcheck disable=SC1090
# shellcheck disable=SC2129

# Create arrays

declare -A os
declare -A script
declare -A options 
declare -a options_list
declare -a actions_list

# Grab script information and put it into an associative array

script['args']="$*"
script['file']="$0"
script['name']="just"
script['file']=$( realpath "${script['file']}" )
script['path']=$( dirname "${script['file']}" )
script['modulepath']="${script['path']}/modules"
script['bin']=$( basename "${script['file']}" )

# Function: set_defaults
#
# Set defaults

set_defaults () {
  options['verbose']="false"  # option : Verbose mode
  options['strict']="false"   # option : Strict mode
  options['dryrun']="false"   # option : Dryrun mode
  options['debug']="false"    # option : Debug mode
  options['force']="false"    # option : Force actions
  options['mask']="false"     # option : Mask identifiers
  options['yes']="false"      # option : Answer yes to questions
  os['name']=$( uname -s )
  if [ "${os['name']}" = "Linux" ]; then
    lsb_check=$( command -v lsb_release )
    if [ -n "${lsb_check}" ]; then 
      os['distro']=$( lsb_release -i -s 2 | sed 's/"//g' > /dev/null )
    else
      os['distro']=$( hostnamectl | grep "Operating System" | awk '{print $3}' )
    fi
  fi
}

set_defaults

# Function: print_message
#
# Print message

print_message () {
  message="$1"
  format="$2"
  if [ "${format}" = "verbose" ]; then
    echo "${message}"
  else
    if [[ "${format}" =~ warn ]]; then
      echo -e "Warning:\t${message}"
    else
      if [ "${options['verbose']}" = "true" ]; then
        if [[ "${format}" =~ ing$ ]]; then
          format="${format^}"
        else
          if [[ "${format}" =~ t$ ]]; then
            if [ "${format}" = "test" ]; then
              format="${format}ing"
            else
              format="${format^}ting"
            fi
          else
            if [[ "${format}" =~ e$ ]]; then
              if [[ ! "${format}" =~ otice ]]; then
                format="${format::-1}"
                format="${format^}ing"
              fi
            fi
          fi
        fi 
        format="${format^}"
        length="${#format}"
        if [ "${length}" -lt 7 ]; then
          tabs="\t\t"
        else
          tabs="\t"
        fi
        echo -e "${format}:${tabs}${message}"
      fi
    fi
  fi
}

# Function: verbose_message
#
# Verbose message

verbose_message () {
  message="$1"
  print_message "${message}" "verbose"
}

# Function: warning_message
#
# Warning message

warning_message () {
  message="$1"
  print_message "${message}" "warn"
}

# Function: execute_message
#
#  Print command

execute_message () {
  message="$1"
  print_message "${message}" "execute"
}

# Function: notice_message
#
# Notice message

notice_message () {
  message="$1"
  verbose_message "${message}" "notice"
}

# Function: notice_message
#
# Information Message

information_message () {
  message="$1"
  verbose_message "${message}" "info"
}

# Load modules

if [ -d "${script['modulepath']}" ]; then
  modules=$( find "${script['modulepath']}" -name "*.sh" )
  for module in ${modules}; do
    if [[ "${script['args']}" =~ "verbose" ]]; then
     print_message "Module ${module}" "load"
    fi
    . "${module}"
  done
fi

# Function: reset_defaults
#
# Reset defaults based on command line options

reset_defaults () {
  if [ "${options['debug']}" = "true" ]; then
    print_message "Enabling debug mode" "notice"
    set -x
  fi
  if [ "${options['strict']}" = "true" ]; then
    print_message "Enabling strict mode" "notice"
    set -u
  fi
  if [ "${options['dryrun']}" = "true" ]; then
    print_message "Enabling dryrun mode" "notice"
  fi
}

# Function: do_exit
#
# Selective exit (don't exit when we're running in dryrun mode)

do_exit () {
  if [ "${options['dryrun']}" = "false" ]; then
    exit
  fi
}

# Function: check_value
#
# check value (make sure that command line arguments that take values have values)

check_value () {
  param="$1"
  value="$2"
  if [[ ${value} =~ ^-- ]]; then
    print_message "Value '$value' for parameter '$param' looks like a parameter" "verbose"
    echo ""
    if [ "${options['force']}" = "false" ]; then
      do_exit
    fi
  else
    if [ "${value}" = "" ]; then
      print_message "No value given for parameter $param" "verbose"
      echo ""
      if [[ "${param}" =~ "option" ]]; then
        print_options
      else
        if [[ "${param}" =~ "action" ]]; then
          print_actions
        else
          print_help
        fi
      fi
      exit
    fi
  fi
}

# Function: execute_command
#
# Execute command

execute_command () {
  command="$1"
  privilege="$2"
  if [[ "${privilege}" =~ su ]]; then
    command="sudo sh -c \"${command}\""
  fi
  if [ "${options['verbose']}" = "true" ]; then
    execute_message "${command}"
  fi
  if [ "${options['dryrun']}" = "false" ]; then
    eval "${command}"
  fi
}

# Function: print_info
#
# Print information

print_info () {
  info="$1"
  echo ""
  echo "Usage: ${script['bin']} --action(s) [action(,action)] --option(s) [option(,option)]"
  echo ""
  if [[ ${info} =~ switch ]]; then
    echo "${info}(es):"
    echo "-----------"
  else
    echo "${info}(s):"
    echo "----------"
  fi
  while read -r line; do
    if [[ "${line}" =~ .*"# ${info}".* ]]; then
      if [[ "${info}" =~ option ]]; then
        IFS=':' read -r param desc <<< "${line}"
        IFS=']' read -r param default <<< "${param}"
        IFS='[' read -r _ param <<< "${param}"
        param="${param//\'/}"
        default="${options[${param}]}"
        if [ "${param}" = "mask" ]; then
          default="false"
        else
          if [ "${options['mask']}" = "true" ]; then
            default="${default/${script['user']}/user}"
          fi
        fi
        param="${param} (default = ${default})"
      else
        IFS='#' read -r param desc <<< "${line}"
        desc="${desc/${info} :/}"
      fi
      echo "${param}"
      echo "  ${desc}"
    fi
  done < "${script['file']}"
  echo ""
}

# Function: print_help
#
# Print help/usage insformation

print_help () {
  print_info "switch"
}

# Function print_actions
#
# Print actions

print_actions () {
  print_info "action"
}

# Function: print_options
#
# Print options

print_options () {
  print_info "option"
}

# Function: print_usage
#
# Print Usage

print_usage () {
  usage="$1"
  case $usage in
    all|full)
      print_help
      print_actions
      print_options
      ;;
    help)
      print_help
      ;;
    action*)
      print_actions
      ;;
    option*)
      print_options
      ;;
    *)
      print_help
      shift
      ;;
  esac
}

# Function: print_version
#
# Print version information

print_version () {
  script['version']=$( grep '^# Version' < "$0" | awk '{print $3}' )
  echo "${script['version']}"
}

# Function: check_shellcheck
#
# Run Shellcheck

check_shellcheck () {
  bin_test=$( command -v shellcheck | grep -c shellcheck )
  if [ ! "$bin_test" = "0" ]; then
    shellcheck "${script['file']}"
  fi
}

# Do some early command line argument processing

if [ "${script['args']}" = "" ]; then
  print_help
  exit
fi

# Function: process_options
#
# Handle options

process_options () {
  option="$1"
  if [[ "${option}" =~ ^no|^un|^dont ]]; then
    options["${option}"]="true"
    if [[ "${option}" =~ ^dont ]]; then
      option="${option:4}"
    else
      option="${option:2}"
    fi
    value="false"
  else
    value="true"
  fi
  options["${option}"]="${value}"
  print_message "${option} to ${value}" "set"
}

# Function: print_environment
#
# Print environment

print_environment () {
  echo "Environment (Options):"
  for option in "${!options[@]}"; do
    value="${options[${option}]}"
    echo -e "Option ${option}\tis set to ${value}"
  done
}

# Function: print_defaults
#
# Print defaults

print_defaults () {
  echo "Defaults:"
  for default in "${!options[@]}"; do
    value="${options[${default}]}"
    echo -e "Default ${default}\tis set to ${value}"
  done
}

# Function: process_actions
#
# Handle actions

process_actions () {
  actions="$1"
  case $actions in
    help)                 # action : Print actions help
      print_actions
      exit
      ;;
    version)              # action : Print version
      print_version
      exit
      ;;
    printenv*)            # action : Print environment
      print_environment
      exit
      ;;
    printdefaults)        # action : Print defaults
      print_defaults
      exit
      ;;
    shellcheck)           # action : Shellcheck script
      check_shellcheck
      exit
      ;;
    *)
      print_actions
      exit
      ;;
  esac
}

# Handle mask option

if [[ $@ =~ --option ]] && [[ $@ =~ mask ]]; then
  options['mask']="true"
fi

# Handle command line arguments

while test $# -gt 0; do
  case $1 in
    --action*)              # switch : Action to perform
      check_value "$1" "$2"
      actions_list+=("$2")
      shift 2
      ;;
    --debug)                # switch : Enable debug mode
      options['debug']="true"
      shift
      ;;
    --dryrun)               # switch : Enable debug mode
      options['dryrun']="true"
      shift
      ;;
    --force)                # switch : Enable force mode
      options['force']="true"
      shift
      ;;
    --help|-h)              # switch : Print help information
      print_help
      shift
      exit
      ;;
    --mask)                 # switch : Mask identifiers
      options['mask']="true"
      shift
      ;;
    --option*)              # switch : Action to perform
      check_value "$1" "$2"
      options_list+=("$2")
      shift 2
      ;;
    --shellcheck)           # switch - Run shellcheck
      actions_list+=("shellcheck")
      shift
      ;;
    --strict)               # switch : Enable strict mode
      options['strict']="true"
      shift
      ;;
    --usage)                # switch : Action to perform
      check_value "$1" "$2"
      usage="$2"
      print_usage "${usage}"
      shift 2
      exit
      ;;
    --verbose)              # switch : Enable verbose mode
      options['verbose']="true"
      shift
      ;;
    --version|-V)           # switch : Print version information
      print_version
      exit
      ;;
    *)
      print_help
      shift
      exit
      ;;
  esac
done

# Process options

if [ -n "${options_list[*]}" ]; then
  for list in "${options_list[@]}"; do
    if [[ "${list}" =~ "," ]]; then
      IFS="," read -r -a array <<< "${list[*]}"
      for item in "${array[@]}"; do
        process_options "${item}"
      done
    else
      process_options "${list}"
    fi
  done
fi

# Reset defaults based on switches

reset_defaults

# Process actions

if [ -n "${actions_list[*]}" ]; then
  for list in "${actions_list[@]}"; do
    if [[ "${list}" =~ "," ]]; then
      IFS="," read -r -a array <<< "${list[*]}"
      for item in "${array[@]}"; do
        process_actions "${item}"
      done
    else
      process_actions "${list}"
    fi
  done
fi
