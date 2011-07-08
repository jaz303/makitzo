module Makitzo; module SSH
  class Context
    def self.protected_context_methods
      %w(x exec sudo host connection logger) + Migrations::Migration.protected_context_methods
    end
    
    attr_reader :host
    attr_reader :connection
    attr_accessor :connection_error
    
    def initialize(host, connection)
      @host, @connection = host, connection
    end
    
    def logger
      @logger ||= (connection[:logger] || Logging::Blackhole.new)
    end
    
    # escape an argument for use in shell
    # http://stackoverflow.com/questions/1306680/shellwords-shellescape-implementation-for-ruby-1-8
    def x(arg)
      arg = arg.strip
      return "''" if arg.empty?
      arg.gsub!(/([^A-Za-z0-9_\-.,:\/@\n])/n, "\\\\\\1")
      arg.gsub!(/\n/, "'\n'")
      arg
    end
    
    def quote(arg)
      "#{x(arg)}"
    end

    # wrapper to connection.exec2!
    # generates necessary sudo command if we're in a sudo block
    # returns a status object with various useful data about command (output, status code)
    def exec(command, options = {})
      log_command = true

      if @sudo
        password = @sudo[:password] || host.read_merged(:sudo_password)
        user     = @sudo[:user]
        group    = @sudo[:group]

        sudo  = "sudo"

        # TODO: if user/group is spec'd as int (ID), prefix it with #
        sudo << " -u #{x(user)}" if user
        sudo << " -g #{x(group)}" if group

        log_sudo = sudo

        if password
          sudo = "echo #{x(password)} | #{sudo} -S --"
          log_sudo = "echo [PASSWORD REMOVED] | #{log_sudo} -S --"
        end

        log_command = "#{log_sudo} #{command}"
        command = "#{sudo} #{command}"
      end

      connection.exec2!(command, {:log => log_command}.update(options))
    end
    
    def exec!(command, options = {})
      res = exec(command, options)
      raise CommandFailed unless res.success?
    end

    def sudo(options = {})
      raise "can't nest calls to sudo with different options" if (@sudo && (@sudo != options))
      begin
        @sudo = options
        yield if block_given?
        # reset sudo timestamp so password will be required next time
        connection.exec2!("sudo -k")
      ensure
        @sudo = nil
      end
    end

    include Commands::Apple
    include Commands::FileSystem
    include Commands::FileTransfer
    include Commands::HTTP
    include Commands::Ruby
    include Commands::Unix
    include Commands::Makitzo

    include Migrations::Commands
  end
end; end