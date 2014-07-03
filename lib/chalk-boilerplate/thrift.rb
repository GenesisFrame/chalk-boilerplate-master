# The driver class for generating a new Thrift service.
class Chalk::Boilerplate::Thrift < Chalk::Boilerplate::Base
  include Chalk::Boilerplate::Helpers::GemRelated

  def execute
    Chalk::Boilerplate::Gem.new(options, arguments).execute

    @directory = @arguments.first
    @port = rand(8976) + 1024

    relative_mkdir('bin')
    create_server
    create_client
    create_config_rb
    create_thrift_rb
    create_thrift_dir
    add_dependencies
    add_rake_target
    commit("Add thrift boilerplate (generated via `boiler thrift')")
  end

  private

  def create_server
    relative_write_file("bin/#{server}_srv.rb", <<EOF)
#!/usr/bin/env ruby
require 'bundler/setup'
require '#{gem}'

Thrifty.require('#{server}_interface')

class #{self.module}::#{server.capitalize}Srv < Chalk::Thrift::Server::Base
  interface #{self.module}::Thrift::#{server.capitalize}Interface
  set :port, #{@port}

  def example(arg)
    'hi'
  end
end

def einhorn_main
  main
end

def main
  #{self.module}::#{server.capitalize}Srv.run!
  return 0
end

if $0 == __FILE__
  ret = main
  begin
    exit(ret)
  rescue TypeError
    exit(0)
  end
end
EOF
    relative_chmod(0755, "bin/#{server}_srv.rb")
  end

  def create_client
    relative_write_file("bin/#{server}_client.rb", <<EOF)
#!/usr/bin/env ruby

require 'bundler/setup'
require 'chalk-cli'
require '#{gem}'

Thrifty.require('#{server}_interface')

class #{self.module}::Client < Chalk::CLI::Command
  def invoke
    thrift_client = Chalk::Thrift::Client::Base.new(
      ['127.0.0.1:#{@port}'],
      interface: #{self.module}::Thrift::#{server.capitalize}Interface
      )
    result = thrift_client.example('argument')
    puts result
  end

  App = Chalk::CLI::App.new("Usage: #{$0} [OPTIONS] ARGS")
  App.action(self)
end

#{self.module}::Client::App.run_if_invoked(__FILE__)
EOF
    relative_chmod(0755, "bin/#{server}_client.rb")
  end

  def create_config_rb
    relative_write_file("lib/#{gem}/config.rb", <<EOF)
require 'chalk-thrift'
Chalk::Thrift.init
EOF

    gem_rb = path("lib/#{gem}.rb")
    contents = File.read(gem_rb)
    contents << "\n"
    contents << "require '#{gem}/config'\n"
    contents << "require '#{gem}/thrift'\n"
    write_file(gem_rb, contents)
  end

  def create_thrift_rb
    relative_write_file("lib/#{gem}/thrift.rb", <<EOF)
require 'thrifty'
Thrifty.register('thrift/#{server}.thrift',
  relative_to: File.join(__FILE__, '../..')
  )
EOF

    gem_rb = path("lib/#{gem}.rb")
    contents = File.read(gem_rb)
    contents << "\n"
    contents << "require '#{gem}/config'\n"
    contents << "require '#{gem}/thrift'\n"
    write_file(gem_rb, contents)
  end

  def create_thrift_dir
    relative_mkdir('thrift')
    relative_write_file("thrift/#{server}.thrift", <<EOF)
namespace rb #{self.module.gsub('::', '.')}.Thrift

include "fb303.thrift"

service #{server.capitalize}Interface extends fb303.FacebookService {
  string example(1: string arg);
}
EOF
  end

  def add_dependencies
    gemspec = get_gemspec
    contents = File.read(gemspec)
    contents = contents.gsub(/^end$/, <<EOF.chomp)
  spec.add_dependency 'chalk-thrift', '>= 0.1.9'
  spec.add_dependency 'thrifty'
  spec.add_dependency 'chalk-cli'
end
EOF
    write_file(gemspec, contents)
  end

  def add_rake_target
    rakefile = get_rakefile
    append_to_file(rakefile, <<EOF)

task :build do
  Rake::Task['build:thrift'].invoke
end

namespace :build do
  desc 'Compile thrift'
  task :thrift do
    require '#{gem}/thrift'
    Thrifty.compile_all
  end
end
EOF
  end
end
