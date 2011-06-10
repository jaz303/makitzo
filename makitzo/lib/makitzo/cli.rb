module Makitzo
  class CLI
    def run(args)
      
      # TODO: locate this automatically or allow it from a configuration file
      worldfile = 'Worldfile'
      root_directory = File.dirname(worldfile)
      
      app = Application.new
      app.root_directory = root_directory
      
      query = World::Query.new
      config = app.config
      
      trace = false
      opts = OptionParser.new do |opts|
        opts.banner = "Usage: makitzo [options] command"
        
        opts.on("--trace", "Show backtrace on error") do
          trace = true
        end
        
        opts.on("--role [ROLE]", "Restrict command to role (may appear multiple times)") do |r|
          query.roles << r
        end
        
        opts.on("--host [HOST]", "Restrict command to host (may appear multiple times)") do |h|
          query.hosts << h
        end
        
        opts.on("-c", "--concurrency [NUM]", "Maximum number of connections to open in parallel") do |c|
          config.concurrency = c.to_i
        end
        
        opts.on_tail("-h", "--help", "Show this message") do
          puts opts
          exit
        end
      end
      
      opts.parse!(args)
      
      app.query = query
      
      config.instance_eval(File.read(worldfile))
      
      if $stdin.isatty
        command = ARGV
      else
        command = ['stream', $stdin]
      end
      
      if command.empty?
        $stderr.puts "Error: no command specified"
        $stderr.puts "  Valid commands: #{app.valid_commands.join(', ')}"
        exit 1
      end
      
      result = app.invoke(*command)
    
    rescue => e
      $stderr.puts "#{e.message} (#{e.class})"
      if trace
        $stderr.puts e.backtrace.join("\n")
      else
        $stderr.puts "(run with --trace for detailed error information)"
      end
      exit 1
    end
  end
end