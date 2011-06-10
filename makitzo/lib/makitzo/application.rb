module Makitzo
  class Application
    include SSH::Multi
    
    attr_reader :config
    attr_reader :logger
    attr_accessor :query
    attr_accessor :root_directory
    
    def initialize
      @config = Config.new(self)
      @logger = Logging::Collector.new
      @root_directory = '.'
    end
    
    def target_hosts
      query = @query || World::Query.all
      query.exec(config)
    end
    
    def valid_commands
      %w(install uninstall exec migrate create_migration list compare shell stream sudo)
    end
    
    def invoke(command, *args)
      raise ArgumentError, "unknown command: #{command}" unless valid_commands.include?(command)
      success = false
    
      old_wd = Dir.getwd
      Dir.chdir(@root_directory)
      success = send(command.to_sym, *args)
    
      result = @logger.result
      puts @logger.result unless result.length == 0
      
      success
    ensure
      Dir.chdir(old_wd)
    end
    
    def install;      exec(:makitzo_install);   end
    def uninstall;    exec(:makitzo_uninstall); end
    
    # Execute an aribtrary helper method on all target systems
    def exec(*command)
      config.store.open do
        multi_session(target_hosts) { |session, host| session.send(*command) }
      end
    end
    
    # Migrate all target systems
    def migrate
      config.store.open do
        migrator = Migrations::Migrator.new(self)
        migrator.migrate(target_hosts)
      end
    end
    
    def create_migration(name)
      generator = Migrations::Generator.new(self)
      generator.create_migration(name)
    end
    
    # List the hosts which would be affected, taking into account
    # any query parameters.
    def list
      target_hosts.map { |h| h.name }.sort.each { |h| puts h }
    end
    
    # Run a shell command on hosts
    def shell(*command)
      multi_session(target_hosts) { |session, host| session.exec(command.join(' ')) }
    end
    
    # read from IO and send commands to target hosts
    # this is intended to be used non-interactively (e.g. with a pipe)
    # TODO: other system operations should be rewritten to use the "shell" service as
    # it remembers state such as working directory etc
    # TODO: how to we specify which shell to open?!
    # TODO: this should probably be extracted
    def stream(io)
      reader = MultiplexedReader.new(io)
      multi_ssh(target_hosts) do |host, conn, error|
        logger.with_host(host) do
          if error
            logger.error("could not connect to host: #{error.message} (#{error.class})")
          else
            conn.open_channel do |ch|
              ch.send_channel_request("shell") do |ch, success|
                if success
                  logger.info "shell opened"
                  
                  ch.on_data { |ch, data| }
                  ch.on_close { logger.info "shell closed" }
                  
                  while line = reader.gets
                    line.strip!
                    logger.log_command_line(line)
                    line += "\n"
                    ch.send_data(line)
                  end
                  ch.send_data("exit\n")
                else
                  logger.error "shell could not be opened"
                end
              end
            end
            
            conn.loop
          end
        end
      end
    end
    
    # Run a shell command on hosts using sudo
    def sudo(*command)
      multi_session(target_hosts) { |session, host| session.sudo { session.exec(command.join(' ')) } }
    end
    
    # Run a shell command on hosts and compare output
    def compare(*command)
      command = command.join(' ')
      sessions = nil
      results, mutex = Hash.new { |h,k| h[k] = [] }, Mutex.new
      
      logger.silence do
        sessions = multi_session(target_hosts) do |session, host|
          result = session.exec(command)
          mutex.synchronize { results[result] << host }
        end
      end
      
      logger.log_command_line(command)
      
      sessions.each do |s|
        if s.connection_error
          logger.error "connection to #{s.host.name} failed: #{s.connection_error.class} (#{s.connection_error.message})"
        end
      end
      
      logger.info("#{results.length} unique response(s)")
      
      results.each do |result, hosts|
        hosts.each do |h|
          logger.info(h.name + ":")
        end
        logger.log_command_status(result)
      end
    end
  end
end