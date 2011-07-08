module Makitzo; module Migrations
  class Migration < Makitzo::SSH::Context
    class << self
      def timestamp;      @timestamp;       end
      def timestamp=(ts); @timestamp = ts;  end
      
      def directory;      @directory;       end
      def directory=(d);  @directory = d;   end
      
      def roles(*roles)
        @roles ||= []
        @roles.concat([roles].flatten) unless roles.empty?
        @roles
      end
      
      def hosts(*hosts)
        @hosts ||= []
        @hosts.concat([hosts].flatten) unless hosts.empty?
        @hosts
      end
      
      def query
        unless @query
          @query = World::Query.new
          roles.each { |r| @query.roles << r }
          hosts.each { |h| @query.hosts << h }
        end
        @query
      end
      
      alias_method :role, :roles
      alias_method :host, :hosts
      
      # Returns an array of methods which are required by migrations.
      # Used to prevent helpers from defining conflicting methods.
      def protected_context_methods
        %w(up down local_directory local_migration_file remote_directory remote_migration_file)
      end
    end
    
    def local_directory
      self.class.directory
    end
    
    def local_migration_file(file)
      File.join(local_directory, file)
    end
    
    def remote_directory
      File.join(host.migration_history_dir, self.class.timestamp.to_s)
    end
    
    def remote_migration_file(file)
      File.join(remote_directory, file)
    end
    
    def up
      raise UnsupportedMigrationError, "up direction is not defined!"
    end
    
    def down
      raise UnsupportedMigrationError, "down direction is not defined!"
    end
    
    def to_i
      self.class.timestamp
    end
  end
end; end