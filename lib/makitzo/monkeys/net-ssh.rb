class Net::SSH::Connection::Session
  class ExecStatus
    attr_accessor :command, :stdout, :stderr, :exit_code, :exit_signal
    
    def initialize
      @command, @stdout, @stderr, @exit_code, @exit_signal = "", "", "", 0, 0, nil
    end
    
    def success?
      @exit_code == 0
    end
    
    def error?
      !success?
    end
    
    def to_i
      @exit_code
    end
    
    def to_s
      @stdout
    end
    
    def inspect
      "<ExecStatus command=#{@command.inspect} stdout=#{@stdout.inspect} status=#{@exit_code}>"
    end
    
    def hash
      "#{command}\n#{exit_code}\n#{stdout}".hash
    end
    
    def eql?(other)
      other.is_a?(ExecStatus) && (command == other.command && exit_code == other.exit_code && stdout == other.stdout)
    end
  end
  
  # Adapted from:
  # http://stackoverflow.com/questions/3386233/how-to-get-exit-status-with-rubys-netssh-library
  #
  # FIXME: we're currently opening a channel per command which strikes me
  # as inefficient and prevents, for example, working directory from
  # persisting across requests.
  def exec2!(command, options = {})
    options = {:log => true}.update(options)
    
    status = ExecStatus.new
    status.command = command
    
    ch = open_channel do |channel|
      channel.exec(command) do |ch, success|
        raise "could not execute command: #{command.inspect}" unless success
        
        channel.on_data { |ch, data| status.stdout << data }
        channel.on_extended_data { |ch, type, data| status.stderr << data }
        channel.on_request("exit-status") { |ch,data| status.exit_code = data.read_long }
        channel.on_request("exit-signal") { |ch,data| status.exit_signal = data.read_long }
      end
    end
    
    self.loop
    
    if options[:log] && self[:logger]
      if options[:log].is_a?(String)
        self[:logger].log_command(status, :command => options[:log])
      else
        self[:logger].log_command(status)
      end
    end
    
    status
  end
end