JUST
----

Just a Unix Shell script Template

Version
-------

Current version 0.0.3

Introduction
------------

This is intended to provide a template for writing shell scripts.
It gathers some arguably good and bad practices I've acquired over
the years to handle command line arguments and inline documentation.

Goals
-----

The goals of this script templare are to:

Provide a command line processor that:

- Can handle both short (e.g -h) and long command line arguments (e.g --help)
- Is able to process multiple actions and options so the script doesn't need to be called multiple times
  - Multiple actions and options are comma separated
- Uses inline tags to semi-auto document script for the help/usage argument

Provide a base set of functionality that has:

- Help information
- Version information
- Debug and verbose commandline arguments/options to help with code debuging/quality
- Some additional base code checking capability (call out to shellcheck)
- Dryrun mode capability
- The ability to split larger scripts into modules which are loaded at run time

Choices
-------

This section details some of the choices taken in the template.

- Use true/false as values rather than 0/1 as I often generate YAML and other config files that use these as values
- Put environment variables and command line parameters into variables so that they are given more interpretable names
- Only run inline information gathering (version, help, etc) when called to reduce start up time

Workflow
--------

The script has the following workflow

- Get some environmen variables
- If givven no switches/parameters print help and exit
- Set defaults
- Parse command line switches/parameters
- If options switch has values process them
- Reset/updates defaults base on command line switches/parameters
- Perform action(s)

Modules
-------

Modules can be put in a sub directory (or a defined directory) and loaded at run time.
This gives the ability to break up a largeg script into modules ofr easier management.
The modules need to have a .sh extension to be found by the script. This can be changed.

Defaults
--------

As previously mentioned defaults are specified in the set_defaults function, and updated in the reset_defaults
function once the switches/parameters and their values are processed and options are processed.
As previously stated, I've used true/false as values rather than 0/1 as I often generate YAML and other config
files that use these as values, so it makes coding a bit more straightforward/transparent.

Output
------

In general output is run through the verbose_message function, which handles formating and outputs appropriate
prefixes, e.g. "Notice", "Warning", etc. This is designed to make sure out is consistently formated.
It also allows output to be done only when the verbose mode is set so the script runs quietly if needed.

Exit
----

There is a do_exit function that doesn't ecit when in dryrun mode. This can be handy for debugging your code
when you are running in dryrun mode where you are not executing commands in the shell but want to test the flow.

Check Values
------------

There is a check_values function that can be run with switches that take values.
This is a simple check to see if the value, if it starts with a "--" then it assumes that you haven't provied
a value and it's processing the next switch and exit. This can be overridden by using the --force switch.

Execute
-------

There is an execute_command function that will output the command when run in verbose mode,
and not execute the command when run in dryryn mode. This is useful for debugging and testing workflow.

Help
----

The print_help function outputs information about the standard switches.
To reduce the amount of duplication, i.e. having the case statement, then having to duplicate this in
a seperate help function, and thus have to keep the two in sync, you can use tags in the case
statement, which the print_help function will process to print help information.

The format of the imbedded help information tags is the case followed by a hash, and a commented
description under the case, e.g.

```
--action*)            # switch
  # Action to perform
  check_value "$1" "$2"
  actions="$2"
  do_actions="true"
  shift 2
  ;;
```

When the --help, or --usage switch is used, and the the print_help function called, it parses this to produce:

```
Usage: just.sh --switch [value]

switches:
--------
 --action*)
   Action to perform
```

Options
-------

Like the print_help function, print_options works on tags, e.g.

```
debug)                # option
  # Enable debug mode
  do_debug="true"
  ;;
```

When the --usage switch is used with the options value, this produces:

```
Usage: just.sh --option(s) [value]

options:
-------
 debug)
   Enable debug mode
```

Multiple options can be specified at the one time by separating them with a comma, e.g.

```
./just.sh --options option1,option2
```

Actions
-------

Like the print_help function, print_actions works on tags, e.g.

```
help)                 # action
  # Print actions help
  print_actions
  exit
  ;;
```

When the --usage switch is used with the actions value, this produces:

```
Usage: just.sh --action(s) [value]

actions:
-------
 help)
   Print actions help
```

Multiple actions can be specified at the one time by separating them with a comma, e.g.

```
./just.sh --actions action1,action2
```

The benefit of being able to run multiple actions means you don't need to run the script multiple times.
Obviously some caution needs to be taken in ordering the workflow in sequential operations soe they
proceed in the correct order.
