require 'fileutils'
require 'rubysh'
require 'chalk-log'

# The base class for boilerplate generation methods.
class Chalk::Boilerplate::Base
  include Chalk::Log

  attr_reader :options, :arguments

  def initialize(options, arguments)
    @options = options
    @arguments = arguments
  end

  # Override this method in a subclass.
  def execute
    raise NotImplementedError.new('Override in subclass')
  end

  protected

  # Accessor for the base directory for this command. Make sure you've
  # set @directory if your script relies on the relative path helpers
  # in this class. (`suite`, for example, does not set @directory.)
  def directory
    unless @directory
      raise "Must set @directory to the base directory for this command"
    end

    @directory
  end

  def relative_mkdir(subdir)
    path = path(subdir)
    mkdir(path)
  end

  def relative_write_file(file, contents)
    path = path(file)
    write_file(path, contents)
  end

  def relative_rm_r(tree)
    path = path(tree)
    rm_r(path)
  end

  def relative_mv(src, dst)
    src_path = path(src)
    dst_path = path(dst)
    mv(src_path, dst_path)
  end

  def relative_chmod(perms, file)
    path = path(file)
    chmod(perms, path)
  end

  def path(file)
    File.join(directory, file)
  end

  def write_file(file, contents)
    log.info('writing file', :bytes => contents.bytesize, :file => file)
    # TODO: disable O_CREAT
    File.open(file, 'w') {|f| f.print(contents)}
  end

  def append_to_file(file, contents)
    log.info('appending to file', :bytes => contents.bytesize, :file => file)
    # TODO: disable O_CREAT
    File.open(file, 'a') {|f| f.print(contents)}
  end

  def chmod(perms, file)
    log.info('chmod', :perms => '0' + perms.to_s(8), :file => file)
    FileUtils.chmod(perms, file)
  end

  def mkdir(dir)
    log.info('mkdir', :dir => dir)
    FileUtils.mkdir(dir)
  end

  def rm_r(tree)
    log.info('rm -r', :tree => tree)
    FileUtils.rm_r(tree)
  end

  def mv(src, dst)
    log.info('mv', :src => src, :dst => dst)
    FileUtils.mv(src, dst)
  end

  def rubysh(*cmd)
    log.info('rubysh', :cmd => cmd)
    Rubysh.check_call(*cmd)
  end

  def commit(message)
    Rubysh.check_call('git', 'add', '--all', '.', :cwd => directory)
    Rubysh.check_call('git', 'commit', '-m', message, :cwd => directory)
  end

  # Check for files

  def get_gemspec
    glob = path('*.gemspec')
    gemspecs = Dir[glob]
    if gemspecs.length == 0
      raise "No gemspec found matching #{glob}!"
    elsif gemspecs.length > 1
      raise "Found #{gemspecs.length} gemspecs matching #{glob}!"
    end
    gemspecs[0]
  end

  def get_rakefile
    path = path('Rakefile')
    raise "No Rakefile found at #{path}" unless File.exists?(path)
    path
  end

  def get_gemfile
    path = path('Gemfile')
    raise "No Gemfile found at #{path}" unless File.exists?(path)
    path
  end

  # @return [Array] a pair of the path to your LICENSE file and the entity which should be marked as the owner
  def get_license
    path = path('LICENSE.txt')
    raise "No Gemfile found at #{path}" unless File.exists?(path)

    # Look in environment
    owner = ENV['BOILER_OWNER']

    # Look in git config
    unless owner
      begin
        runner = rubysh('git', 'config', 'chalk.boilerplate.owner', Rubysh.>)
      rescue Rubysh::Error::BadExitError
      else
        output = runner.read.chomp
        owner = output if output.length > 0
      end
    end

    unless owner
      log.error("No license owner set (this is used for touching up the LICENSE.txt file). License owner is extracted from ENV['BOILER_OWNER'], followed by `git config boiler.owner'.")
      owner = Readline.readline("Provide your code's license owner: ")
      rubysh('git', 'config', '--global', 'chalk.boilerplate.owner', owner)
    end

    [path, owner]
  end

  def get_gitignore
    path = path('.gitignore')
    raise "No .gitignore found at #{path}" unless File.exists?(path)
    path
  end
end
