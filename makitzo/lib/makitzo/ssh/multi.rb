module Makitzo
  module SSH
    # mixing providing ability to run multiple SSH connections in parallel.
    # clients mixing in this module should also include ApplicationAware,
    # or provide +config+ and +logger+ methods.
    module Multi
      # connect to an array of hosts, returning an array of arrays.
      # each array has the form [host, connection, error]
      # only one of connection and error will be non-nil
      def multi_connect(hosts, &block)
        connection_threads = hosts.map { |h|
          Thread.new do
            begin
              ssh_options = {}
            
              password = h.read_merged(:ssh_password)
              ssh_options[:password] = password if password

              timeout = h.read_merged(:ssh_timeout)
              ssh_options[:timeout] = timeout if timeout
            
              [h, Net::SSH.start(h.name, h.read_merged(:ssh_username), ssh_options), nil]
            rescue => e
              [h, nil, e]
            end
          end
        }
        connection_threads.map(&:value)
      end
      
      # execute a block on each host, in parallel
      # block receives host, connection object and error object
      # only one of connection, error will be non-nil
      # returns after block has finished executing on all hosts
      # returns array of block return values for each host
      def multi_ssh(hosts, &block)
        result = []
        groups = config.concurrency.nil? ? [hosts] : (hosts.in_groups_of(config.concurrency))
        groups.each do |hosts|
          group_result = multi_connect(hosts).map { |host, conn, error|
            conn[:logger] = logger if conn # ick?
            Thread.new { block.call(host, conn, error) }
          }.map(&:value)
          group_result.each { |gr| result << gr }
        end
        result
      end
      
      def multi_session(hosts, &block)
        context_klass = ssh_context_class
        
        multi_ssh(hosts) do |host, conn, error|
          context = context_klass.new(host, conn)
          logger.with_host(host) do
            if error
              logger.error("could not connect to host: #{error.class}")
              context.connection_error = error
            else
              begin
                block.call(context, host)
              rescue => e
                logger.error("unhandled exception: #{e.class} (#{e.message})")
              ensure
                conn.close unless conn.closed?
              end
            end
          end
          context
        end
      end
      
      def ssh_context_class
        session_klass = Class.new(Makitzo::SSH::Context)
        session_klass.send(:include, config.helpers)
        session_klass
      end
    end
  end
end