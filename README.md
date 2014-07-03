# Chalk::Boilerplate

Provides generators for various base templates (creating a new gem,
creating a new script, etc.) All generators are available as
subcommands of the `boiler` executable (run `boiler -h` for usage).

The specific generators available are the following:

## `boiler script`

Generates the template of an executable script. The generated script
is built on top of [Escort](https://github.com/skorks/escort), which
should be flexible enough to handle everything from a one-off script
to a git-like CLI.

## `boiler gem`

Generates the template of a gem. Behind the scenes, it shells out to
`bundler gem` and then performs a series of tweaks, including adding a
test suite skeleton, changing a bunch of double quotes to single
quotes, and the like.

## `boiler suite`

Creates a test-suite skeleton. (This is also called in the process of
calling `boiler gem`.) It's rare that you'll need to use `boiler
suite` directly, except maybe to retrofit existing repositories.

## `boiler thrift`

Creates the boilerplate for a Thrift service. There are a number of
moving parts to a new Thrift service (where the Thrift file goes,
setting up the registration thereof, initializing `Chalk::Thrift`, and
the like). A sample client and server are included in `bin`.

# Settings

Settings are persisted in your global git config. You can safely
modify them directly in your global git config file or delete the
entry if you wish.

The following are the settings chalk-boilerplate will manage. (If any
are unset, you'll be prompted to fill them out the first time they're
needed.)

- `chalk.boilerplate.owner`: The entity who owns the copyright (to be
  put at the top of LICENSE.txt during gem generation.
