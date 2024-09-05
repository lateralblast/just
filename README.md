JUST
----

Just a Unix Shell script Template

Version
-------

Current version 0.0.2

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
