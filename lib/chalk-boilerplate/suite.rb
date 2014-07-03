# The driver class for generating a new Minitest test suite.
class Chalk::Boilerplate::Suite < Chalk::Boilerplate::Base
  def execute
    raise "Must provide a base directory" unless directory = @arguments.first
    @directory = directory

    make_subdirectories
    write_files
  end

  private

  def make_subdirectories
    [
      'test',
      'test/unit',
      'test/integration',
      'test/functional',
      'test/meta'
    ].each do |subdir|
      relative_mkdir(subdir)
    end
  end

  def write_files
    relative_write_file('test/_lib.rb', <<EOF)
require 'rubygems'
require 'bundler/setup'

# Don't let minitest include helpers like 'must_equal' into Object
ENV['MT_NO_EXPECTATIONS'] = 'true'

require 'minitest/autorun'
require 'minitest/spec'
require 'mocha/setup'

module Critic
  class Test < ::MiniTest::Spec
    def setup
      # Put any stubs here that you want to apply globally
    end
  end
end
EOF

    relative_write_file('test/unit/_lib.rb', <<EOF)
require File.expand_path('../../_lib', __FILE__)

module Critic::Unit
  module Stubs
  end

  class Test < Critic::Test
    include Stubs
  end
end
EOF

    relative_write_file('test/functional/_lib.rb', <<EOF)
require File.expand_path('../../_lib', __FILE__)

module Critic::Functional
  module Stubs
  end

  class Test < Critic::Test
    include Stubs
  end
end
EOF

    relative_write_file('test/integration/_lib.rb', <<EOF)
require File.expand_path('../../_lib', __FILE__)

module Critic::Integration
  module Stubs
  end

  class Test < Critic::Test
    include Stubs
  end
end
EOF

    relative_write_file('test/meta/_lib.rb', <<EOF)
require File.expand_path('../../_lib', __FILE__)

module Critic::Meta
  module Stubs
  end

  class Test < Critic::Test
    include Stubs
  end
end
EOF
  end
end
