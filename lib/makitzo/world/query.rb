module Makitzo; module World
  # Query enables selection of a subset of hosts based on name/role
  class Query
    class StringArray < Array
      def <<(item);       super(item.to_s); end
      def push(item);     super(item.to_s); end
      def unshift(item);  super(item.to_s); end
    end
    
    # Returns a Query which will match all hosts
    def self.all
      new
    end
    
    attr_reader :roles, :hosts
    
    def initialize
      @roles, @hosts = StringArray.new, StringArray.new
    end
    
    def empty?
      @roles.empty? && @hosts.empty?
    end
    
    def merge!(query)
      @roles |= query.roles
      @hosts |= query.hosts
      self
    end
    
    def includes?(host)
      empty? || @hosts.include?(host.to_s) || (host.roles.any? { |r| @roles.include?(r.to_s) })
    end
    
    def exec(config)
      if !empty?
        hosts, all_hosts = [], config.hosts
        
        if @roles.length > 0
          hosts |= all_hosts.select { |host| (@roles & (host.roles.map { |r| r.name })).any? }
        end
        
        if @hosts.length > 0
          host_patterns = @hosts.map { |h| Regexp.new('^' + h.gsub('.', '\\.').gsub('*', '.*?') + '$') }
          hosts |= all_hosts.select { |host| host_patterns.any? { |hp| host.name =~ hp } }
        end
      else
        hosts = config.hosts
      end
      
      hosts
    end
  end
end; end