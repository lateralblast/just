# Changelog

All notable changes to `just.bash` will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Dates are in AEST/AEDT (Australia/Sydney), the timezone changes were made in.

## [0.4.5] - 2026-09-28
### Fixed
- Fixed `process_actions` unconditionally exiting after every action, which meant comma-separated multiple actions (e.g. `--action printenv,printdefaults`) never ran past the first one.
- Fixed `--force` only taking effect when it appeared before the switch/action it was meant to override; `--force` (as a switch or `--option force`) is now detected up front so it applies regardless of argument order.

## [0.4.4] - 2026-09-28
### Changed
- Relicensed from CC-BA/CC BY-SA (inconsistently stated between README and script headers) to CC BY-NC-SA 4.0.

## [0.4.3] - 2026-09-21
### Changed
- Simplified `check_shellcheck` existence check.

## [0.4.2] - 2026-09-21
### Fixed
- Fixed sudo command quoting in `execute_command` to survive embedded quotes.

## [0.4.1] - 2026-09-21
### Fixed
- Made `print_version` read from the resolved script path instead of `$0`.

## [0.4.0] - 2026-09-21
### Changed
- Tightened early mask detection to avoid matching `nomask`/`unmask`.

## [0.3.9] - 2026-09-21
### Changed
- Made `execute_command` dryrun check consistent with `do_exit`/`check_value`.

## [0.3.8] - 2026-09-21
### Changed
- Moved `yes` option into the defaults array for consistency.

## [0.3.7] - 2026-09-21
### Fixed
- Fixed module load verbose message by loading modules after options are parsed.

## [0.3.6] - 2026-09-21
### Fixed
- Fixed mask feature by setting the previously-unassigned script user.

## [0.3.5] - 2026-09-21
### Fixed
- Fixed `--usage`/`--help` printing blank defaults by priming options early.

## [0.3.4] - 2026-09-21
### Fixed
- Fixed `do_exit`/`check_value` not exiting when dryrun/force are unset.

## [0.3.3] - 2026-09-21
### Fixed
- Fixed `process_options` leaving stray unstripped negated option entries.

## [0.3.2] - 2026-09-21
### Fixed
- Fixed `print_defaults` to read from the defaults array instead of options.

## [0.3.1] - 2026-01-12
### Changed
- Updated `set_defaults` and `reset_defaults` functions.

## [0.3.0] - 2026-01-10
### Fixed
- Fixed OS distro detection.

## [0.2.9] - 2026-01-10
### Changed
- Improved mask check.

## [0.2.8] - 2026-01-10
### Fixed
- Fixed `information_message` and `notice_message` functions.

## [0.2.7] - 2025-10-06
### Changed
- Improved options processing.

## [0.2.6] - 2025-09-26
### Changed
- Improved options processing.

## [0.2.5] - 2025-09-26
### Changed
- Improved parameter value checking.

## [0.2.4] - 2025-09-26
### Changed
- Updated usage output.

## [0.2.3] - 2025-09-11
### Fixed
- Fixed processing of options.

## [0.2.2] - 2025-09-11
### Added
- Added message functions.

## [0.2.1] - 2025-09-10
### Changed
- Updated documentation.

## [0.2.0] - 2025-09-10
### Added
- Added mask function.

## [0.1.9] - 2025-09-10
### Changed
- Updated `print_info` routines.

## [0.1.8] - 2025-09-10
### Changed
- Updated options, actions and switches.

## [0.1.7] - 2025-09-10
### Changed
- Updated documentation.

## [0.1.6] - 2025-09-09
### Fixed
- Bug fixes.
### Changed
- Improvements.

## [0.1.5] - 2025-08-15
### Fixed
- Bug fixes.
### Changed
- Improvements.

## [0.1.4] - 2025-04-16
### Changed
- Updated options processing.

## [0.1.3] - 2025-04-14
### Added
- Added `execute_command` function.

## [0.1.2] - 2025-04-13
### Added
- Added warning message function.

## [0.1.1] - 2025-04-13
### Changed
- Formatting updates.

## [0.1.0] - 2025-04-13
### Changed
- Updates.

## [0.0.9] - 2024-12-23
### Fixed
- Bug fixes.
### Changed
- Improvements.

## [0.0.8] - 2024-12-22
### Changed
- Improved verbose message routine.

## [0.0.7] - 2024-12-22
### Changed
- Improved defaults and options handling.

## [0.0.6] - 2024-12-22
### Fixed
- Bug fixes.
### Added
- Added associative arrays.

## [0.0.5] - 2024-12-20
### Fixed
- Fixed force switch.

## [0.0.4] - 2024-12-13
### Changed
- Improved handling for switches that take values.

## [0.0.3] - 2024-09-05
### Added
- Added force switch/option.
### Changed
- Updated documentation.

## [0.0.2] - 2024-09-05
### Added
- Added modules support.

## [0.0.1] - 2024-09-05
### Added
- Initial version with some documentation.
