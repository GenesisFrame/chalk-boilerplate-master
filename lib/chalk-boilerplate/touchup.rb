require 'readline'

# The driver class for touching up a gem created by `bundle gem`. This
# is called under the hood by `boiler gem`, and is not exposed through
# the `boiler` CLI.
class Chalk::Boilerplate::Touchup < Chalk::Boilerplate::Base
  def execute
    raise "Must provide a base directory" unless directory = @arguments.first
    @directory = directory

    # Ensure that these files exist
    gemspec = get_gemspec
    rakefile = get_rakefile
    gemfile = get_gemfile
    license, owner = get_license

    modify_gemspec(gemspec)
    modify_rakefile(rakefile)
    modify_gemfile(gemfile)
    modify_license(license, owner)
  end

  private

  def path(file)
    File.join(@directory, file)
  end

  def modify_gemspec(gemspec)
    lines = File.read(gemspec).gsub('"', "'").
      gsub(%q{'\x0'}, %q{"\x0"}). # bundler 1.5+ includes a null-byte
      split("\n")
    index = lines.index {|line| line =~ /(gem|spec)\.require_paths/}
    raise "Could not find (gem|spec).require_paths line in #{gemspec}" unless index
    name = $1
    addition = <<EOF.rstrip
  #{name}.add_development_dependency 'minitest', '< 5.0'
  #{name}.add_development_dependency 'minitest-reporters'
  #{name}.add_development_dependency 'mocha'
  #{name}.add_development_dependency 'chalk-rake'
EOF
    lines.insert(index + 1, addition)
    modified = lines.join("\n")
    write_file(gemspec, modified + "\n")
  end

  def modify_rakefile(rakefile)
    contents = File.read(rakefile)
    if contents == %Q{require "bundler/gem_tasks"\n}
      write_file(rakefile, %Q{require 'bundler/gem_tasks'\n})
    end

    append_to_file(rakefile, <<EOF)
require 'bundler/setup'
require 'chalk-rake/gem_tasks'
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs = ['lib']
  # t.warning = true
  t.verbose = true
  t.test_files = FileList['test/**/*.rb'].reject do |file|
    file.end_with?('_lib.rb') || file.include?('/_lib/')
  end
end
EOF
  end

  def modify_gemfile(gemfile)
    contents = File.read(gemfile)
    contents = contents.gsub("source 'https://rubygems.org'") do
      <<EOF.rstrip
# Execute bundler hook if present
['~/.', '/etc/'].any? do |file|
 File.lstat(path = File.expand_path(file + 'bundle-gemfile-hook')) rescue next
 eval(File.read(path), binding, path); break true
end || source('https://rubygems.org/')
EOF
    end
    contents = write_file(gemfile, contents)
  end

  def modify_license(license, owner)
    contents = File.read(license)
    contents = contents.gsub(/\A(Copyright.*\d+ )(.*)/, '\1' + owner)
    old_owner = $2

    unless owner == old_owner
      log.info('license update', :old_owner => old_owner, :owner => owner)
      contents = write_file(license, contents)
    end
  end
end
