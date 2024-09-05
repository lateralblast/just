#!/usr/bin/env bash

# Name:         just (Just a UNIX Shell script Template)
# Version:      0.0.2
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

# Grab script args for some initial processing

script_args="$*"
script_file="$0"
script_name="just"
script_file=$( realpath "$script_file" )
script_path=$( dirname "$script_file" )
module_path="$script_path/modules"
script_bin=$( basename "$script_file"" )

# Enable verbose mode

if [[ "$script_args" =~ "verbose" ]]; then
  do_verbose="true"
fi

# Set defaults

set_defaults () {
  do_verbose="false"
  do_actions="false"
  do_options="false"
  do_strict="false"
  do_dryrun="false"
  do_debug="false"
  do_force="false"
}

# Verbose message

verbose_message () {
  message="$1"
  format="$2"
  if [ "$do_verbose" = "true" ] || [ "$format" = "verbose" ]; then
    case "$format" in
      "execute")
        echo "Executing:    $message"
        ;;
      "info")
        echo "Information:  $message"
        ;;
      "notice")
        echo "Notice:       $message"
        ;;
      "verbose")
        echo "$message"
        ;;
      "warn")
        echo "Warning:      $message"
        ;;
      "load")
        echo "Loading:      $message"
        ;;
      *)
        echo "$message"
        ;;
    esac
  fi
}

# Load modules

if [ -d "$module_path" ]; then
  modules=$( find "$module_path" -name "*.sh" )
  for module in $modules; do
    if [[ "$script_args" =~ "verbose" ]]; then
     verbose_message "Module $module" "load"
    fi
    . "$module"
  done
fi

# Reset defaults based on command line options

reset_defaults () {
  if [ "$do_debug" = "true" ]; then
    set -x
  fi
  verbose_message "Enabling debug mode" "notice"
  if [ "$do_strict" = "true" ]; then
    set -u
  fi
  verbose_message "Enabling strict mode" "notice"
  if [ "$do_dryrun" = "true" ]; then
    verbose_message "Enabling dryrun mode" "notice"
  fi
}

# Selective exit (don't exit when we're running in dryrun mode)

do_exit () {
  if [ "$do_dryrun" = "false" ]; then
    exit
  fi
}

# check value (make sure that command line arguments that take values have values)

check_value () {
  parameter="$1"
  value="$2"
  if [[ "$value" =~ "--" ]]; then
    verbose_message "Value '$value' for parameter '$parameter' looks like a parameter" "warn"
    if [ "$do_force" = "false" ]; then
      do_exit
    fi
  fi
}

# Execute command

execute_command () {
  command="$1"
  privilege="$2"
  if [ "$privilege" = "su" ]; then
    command="sudo sh -c \"$command\""
  fi
  if [ "$do_verbose" = "true" ]; then
    verbose_message "$command" "execute"
  fi
  if [ "$do_dryrun" = "false" ]; then
    eval "$command"
  fi
}

# Print help/usage insformation

print_help () {
  script_help=$( grep -A1 "# switch" "$script_file" |sed "s/^--//g" |sed "s/# switch//g" | tr -s " " |grep -Ev "=|echo" |sed "s/#/ /g" | sed "/^\s*$/d" )
  echo "Usage: $script_bin --switch [value]"
  echo ""
  echo "switches:"
  echo "--------"
  echo "$script_help"
  echo ""
}

# Print actions

print_actions () {
  script_actions=$( grep -A1 "# action" "$script_file" |sed "s/^--//g" |sed "s/# action//g" | tr -s " " |grep -Ev "=|echo" |sed "s/#/ /g" |sed "/^\s*$/d" )
  echo "Usage: $script_bin --action(s) [value]"
  echo ""
  echo "actions:"
  echo "-------"
  echo "$script_actions"
  echo ""
}

# Print options

print_options () {
  script_options=$( grep -A1 "# option" "$script_file" |sed "s/^--//g" |sed "s/# option//g" | tr -s " " |grep -Ev "=|echo" |sed "s/#/ /g" |sed "/^\s*$/d" )
  echo "Usage: $script_bin --option(s) [value]"
  echo ""
  echo "options:"
  echo "-------"
  echo "$script_options"
  echo ""
}

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

# Print version information

print_version () {
  script_vers=$( grep '^# Version' < "$0" | awk '{print $3}' )
  echo "$script_vers"
}

# Run Shellcheck

check_shellcheck () {
  bin_test=$( command -v shellcheck | grep -c shellcheck )
  if [ ! "$bin_test" = "0" ]; then
    shellcheck "$script_file"
  fi
}

# Do some early command line argument processing

if [ "$script_args" = "" ]; then
  print_help
  exit
fi

# Handle options

process_options () {
  options="$1"
  case $options in
    debug)                # option
      # Enable debug mode
      do_debug="true"
      ;;
    strict)               # option
      # Enable strict mode
      do_strict="true"
      ;;
    verbose)              # option
      # Enable verbose mode
      do_verbose="true"
      ;;
    *)
      print_options
      exit
      ;;
  esac
}

# Handle actions

process_actions () {
  actions="$1"
  case $actions in
    help)                 # action
      # Print actions help
      print_actions
      exit
      ;;
    version)              # action
      # Print version
      print_version
      exit
      ;;
    *)
      print_actions
      exit
      ;;
  esac
}

# Set defaults

set_defaults

# Handle command line arguments

while test $# -gt 0; do
  case $1 in
    --action*)            # switch
      # Action to perform
      check_value "$1" "$2"
      actions="$2"
      do_actions="true"
      shift 2
      ;;
    --debug)              # switch
      # Enable debug mode
      do_debug="true"
      shift
      ;;
    --strict)             # switch
      # Enable strict mode
      do_strict="true"
      shift
      ;;
    --verbose)            # switch
      # Enable verbos e mode
      do_verbose="true"
      shift
      ;;
    --version|-V)         # switch
      # Print version information
      print_version
      exit
      ;;
    --option*)            # switch
      # Action to perform
      check_value "$1" "$2"
      actions="$2"
      do_options="true"
      shift 2
      ;;
    --usage*)             # switch
      # Action to perform
      check_value "$1" "$2"
      usage="$2"
      print_usage "$usage"
      shift 2
      exit
      ;;
    *|--help|-h)          # switch
      # Print help information
      print_help
      shift
      exit
      ;;
  esac
done


# Process options

if [ "$do_options" = "true" ]; then
  if [[ "$options" =~ "," ]]; then
    IFS="," read -r -a array <<< "$options"
    for option in "${array[@]}"; do
      process_options "$option"
    done
  else
    process_options "$options"
  fi
fi

# Reset defaults based on switches

reset_defaults

# Process actions

if [ "$do_actions" = "true" ]; then
  if [[ "$actions" =~ "," ]]; then
    IFS="," read -r -a array <<< "$actions"
    for action in "${array[@]}"; do
      process_actions "$action"
    done
  else
    process_actions "$actions"
  fi
fi
