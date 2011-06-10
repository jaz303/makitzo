module Makitzo; module Logging
  THREAD_HOST_KEY = 'makitzo.logging.host'
  
  # A logger which collects all log messages and displays a summary by host
  class Collector
    include Colorize
    
    attr_accessor :use_color
    def use_color?; !!@use_color; end

    def initialize
      @use_color = true
      @host = nil
      @messages = []
      @hosts = Hash.new { |h,k| h[k] = {:error => false, :messages => []} }
      @lock = Mutex.new
      @silenced = false
    end
    
    # This method is not threadsafe. So call it before spawning threads.
    def silence(&block)
      begin
        was_silenced = @silenced
        @silenced = true
        yield if block_given?
      ensure
        @silenced = was_silenced
      end
    end
    
    def with_host(host, &block)
      return unless block_given?
      
      begin
        set_current_host(host)
        info("host is #{host.address}")
        yield
      ensure
        set_current_host(nil)
      end
      
      nil
    end

    # logs a command
    # options[:command] - override command line to be logged. useful for masking passwords.
    def log_command(status, options = {})
      command = options[:command] || status.command
      
      log_command_line(command, status.success?)
      log_command_status(status)
      
      overall_error! if current_host && !status.success?
    end
    
    def log_command_line(command, success = true)
      if command.is_a?(Net::SSH::Connection::Session::ExecStatus)
        success = command.success?
        command = command.command
      end
      if success
        append green("$", true), " ", green(sanitize(command))
      else
        append red("$", true), " ", red(sanitize(command))
      end
    end
    
    def log_command_status(result, success = true)
      if result.is_a?(Net::SSH::Connection::Session::ExecStatus)
        success = result.success?
        result  = (success ? result.stdout : result.stderr).last_line.strip
      end
      unless result.empty?
        if success
          append green("-", true), " ", green(sanitize(result))
        else
          append red("!", true), " ", red(sanitize(result))
        end
      end
    end
    
    def overall_success!
      raise "Cannot log host success when no host is set" unless current_host
      @hosts[current_host.to_s][:error] = false
    end
    
    def overall_error!
      raise "Cannot log host error when no host is set" unless current_host
      @hosts[current_host.to_s][:error] = true
    end
    
    def error(message)
      append red("[ERROR]", true), ' ', red(sanitize(message))
      overall_error! if current_host
    end
    
    def success(message)
      append green("[OK]", true), ' ', sanitize(message)
    end
    
    def notice(message)
      append cyan("[NOTICE]", true), ' ', sanitize(message)
    end
    
    def warn(message)
      append yellow("[WARNING]", true), ' ', sanitize(message)
    end
    
    def info(message)
      append '[INFO]', ' ', sanitize(message)
    end
    
    def debug(message)
      append blue('[DEBUG]', true), ' ', sanitize(message)
    end
    
    def collector?
      true
    end
    
    def result
      out = ""
      
      @hosts.keys.sort.each do |host_name|
        host_status = @hosts[host_name]
        next if host_status[:messages].empty?
        out << magenta('* ' + host_name, true) << " " << (host_status[:error] ? red('[ERROR]', true) : green('[OK]', true)) << "\n"
        host_status[:messages].each { |m| out << m.indent(2) << "\n" }
        out << "\n"
      end
      
      unless @messages.empty?
        out << magenta("* Global Messages", true) << "\n"
        @messages.each { |m| out << m.indent(2) << "\n" }
        out << "\n"
      end
      
      out
    end
    
    def append(*chunks)
      unless @silenced
        @lock.synchronize do
          active_log << chunks.join('').strip
        end
      end
    end
    
  private
  
    def sanitize(message)
      message.to_s
    end
  
    def active_log
      current_host ? @hosts[current_host.to_s][:messages] : @messages
    end
    
    def current_host
      Thread.current[THREAD_HOST_KEY]
    end
    
    def set_current_host(host)
      raise "Cannot set host; host already set" if host && current_host
      Thread.current[THREAD_HOST_KEY] = host
    end
  
  end

end; end