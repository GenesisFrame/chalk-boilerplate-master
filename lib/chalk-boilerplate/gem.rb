# The driver class for generating a new gem.
class Chalk::Boilerplate::Gem < Chalk::Boilerplate::Base
  include Chalk::Boilerplate::Helpers::GemRelated

  def execute
    raise "Must provide a base directory" unless @directory = @arguments.first
    raise "#{directory.inspect} already exists" if File.exists?(directory)

    Rubysh.check_call('bundle', 'gem', directory)
    Chalk::Boilerplate::Touchup.new(options, arguments).execute
    Chalk::Boilerplate::Suite.new(options, arguments).execute

    fix_nesting
    commit("Initial commit (generated via `boiler gem')")
  end

  private

  def fix_nesting
    return unless gem.include?('-')

    # Create lib/chalk-my-thing
    relative_mkdir("lib/#{gem}")

    # Move version file to lib/chalk-my-thing/version.rb
    relative_mv("lib/#{gem.gsub('-', '/')}/version.rb", "lib/#{gem}/version.rb")

    # Create lib/chalk-my-thing.rb
    relative_write_file("lib/#{gem}.rb", <<EOF)
require '#{gem}/version'

module #{self.module}
end
EOF

    # Nuke the now-unneeded lib/chalk/my... directory
    relative_rm_r("lib/#{gem.split('-')[0]}")

    # Update the gemspec to require 'chalk-my-thing/version' rather
    # than 'chalk/my/thing/version'
    gemspec = get_gemspec
    contents = File.read(gemspec)
    contents = contents.gsub(/^require '.*$/, "require '#{gem}/version'")
    write_file(gemspec, contents)
  end
end
