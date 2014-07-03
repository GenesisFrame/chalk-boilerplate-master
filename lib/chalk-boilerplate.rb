require 'chalk-boilerplate/version'

# Base for boilerplate. See `bin/boiler` for the command-line
# interface to boilerplate generation.
module Chalk::Boilerplate
  require 'chalk-boilerplate/helpers/gem_related'

  require 'chalk-boilerplate/base'
  require 'chalk-boilerplate/script'
  require 'chalk-boilerplate/gem'
  require 'chalk-boilerplate/suite'
  require 'chalk-boilerplate/touchup'
  require 'chalk-boilerplate/thrift'
end
