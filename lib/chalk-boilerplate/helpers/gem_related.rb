module Chalk::Boilerplate::Helpers; end

# A set of helpers includable into any drivers which operate on gem
# directories.
module Chalk::Boilerplate::Helpers::GemRelated
  def gem
    File.basename(@directory)
  end

  def server
    gem.split('-')[-1]
  end

  def module
    gem.split('-').map {|c| c.capitalize}.join('::')
  end
end
