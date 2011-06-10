require 'fileutils'
require 'forwardable'
require 'set'
require 'thread'
require 'ostruct'
require 'optparse'
require 'erb'
require 'date'
require 'time'

require 'active_support'
require 'active_support/inflector'
require 'net/ssh'
require 'net/scp'
require 'highline'

require 'makitzo/monkeys/array'
require 'makitzo/monkeys/bangify'
require 'makitzo/monkeys/net-ssh'
require 'makitzo/monkeys/string'

module Makitzo
  ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..'))
  
  class ConflictingPropertyError < RuntimeError; end
  class MissingPropertyError < RuntimeError; end
  
  def self.apple?
    !! (RUBY_PLATFORM =~ /darwin/)
  end
  
  autoload :Application,            'makitzo/application'
  autoload :ApplicationAware,       'makitzo/application_aware'
  autoload :CLI,                    'makitzo/cli'
  autoload :Config,                 'makitzo/config'
  autoload :FileSystem,             'makitzo/file_system'
  autoload :MemoizedProc,           'makitzo/memoized_proc'
  autoload :Migration,              'makitzo/migration'
  autoload :MultiplexedReader,      'makitzo/multiplexed_reader'
  autoload :Settings,               'makitzo/settings'
  
  module Logging
    autoload :Blackhole,            'makitzo/logging/blackhole'
    autoload :Collector,            'makitzo/logging/collector'
    autoload :Colorize,             'makitzo/logging/colorize'
  end
  
  module Migrations
    class UnsupportedMigrationError < RuntimeError; end
    class MigrationNotFound < RuntimeError; end
    
    autoload :Commands,             'makitzo/migrations/commands'
    autoload :Generator,            'makitzo/migrations/generator'
    autoload :Migration,            'makitzo/migrations/migration'
    autoload :Migrator,             'makitzo/migrations/migrator'
    autoload :Paths,                'makitzo/migrations/paths'
  end
  
  module SSH
    class CommandFailed < RuntimeError; end
    
    autoload :Context,              'makitzo/ssh/context'
    autoload :Multi,                'makitzo/ssh/multi'
    
    module Commands
      autoload :Apple,              'makitzo/ssh/commands/apple'
      autoload :FileSystem,         'makitzo/ssh/commands/file_system'
      autoload :FileTransfer,       'makitzo/ssh/commands/file_transfer'
      autoload :HTTP,               'makitzo/ssh/commands/http'
      autoload :Makitzo,            'makitzo/ssh/commands/makitzo'
      autoload :Ruby,               'makitzo/ssh/commands/ruby'
      autoload :Unix,               'makitzo/ssh/commands/unix'
    end
  end
  
  module Store
    class OperationFailedError < RuntimeError; end
    class MissingStoreError < RuntimeError; end
    
    autoload :Skeleton,             'makitzo/store/skeleton'
    autoload :MySQL,                'makitzo/store/mysql'
  end
  
  module World
    autoload :Host,                 'makitzo/world/host'
    autoload :NamedEntity,          'makitzo/world/named_entity'
    autoload :Query,                'makitzo/world/query'
    autoload :Role,                 'makitzo/world/role'
  end
end
