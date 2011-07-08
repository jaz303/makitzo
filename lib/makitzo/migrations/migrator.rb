module Makitzo; module Migrations
  class Migrator
    include ApplicationAware
    include SSH::Multi
    include Paths
    
    def initialize(app)
      @app = app
    end
    
    def migrate(target_hosts)
      all_migrations = migrations
      return if all_migrations.empty?
      
      # start with a query matching all hosts and reduce to set of hosts
      # affected by existing migrations
      migration_hosts_query = World::Query.all
      all_migrations.each { |m| migration_hosts_query.merge!(m.query) }
      
      # get list of hosts and intersect with hosts specified on command-line
      migration_hosts = migration_hosts_query.exec(config)
      migration_hosts &= target_hosts
      
      # finally, remove any hosts with no pending migrations
      applied_migrations = store.applied_migrations_for_all_hosts
      migration_hosts.delete_if { |host|
        all_migrations.all? { |m|
          (applied_migrations[host.to_s] || []).include?(m.timestamp) || !m.query.includes?(host)
        }
      }
      
      multi_ssh(migration_hosts) do |host, conn, error|
        logger.with_host(host) do
          if error
            # log connection error
          else
            begin
              overseer_session = ssh_context_class.new(host, conn)
              overseer_session.makitzo_install_check!
          
              # then select the appropriate migrations, create session classes and run
              all_migrations.each do |migration_klass|
                next if (applied_migrations[host.to_s] || []).include?(migration_klass.timestamp)
                next unless migration_klass.query.includes?(host)
                migration = migration_klass.new(host, conn)
                migration.exec!("mkdir -p #{migration.x(migration.remote_directory)}")
                migration.up
                host.mark_migration_as_applied(migration)
                logger.success "Migration #{migration_klass.timestamp} applied"
              end
            rescue SSH::CommandFailed => e
              logger.error "Migration failed"
            end
          end
        end
      end
    end
    
  private
  
    def migrations
      unless @migrations
        @migrations = Dir["#{local_migration_path}/*"].map do |candidate|
          next unless File.directory?(candidate)
          timestamp, *rest = File.basename(candidate).split('_')
          class_name = rest.join('_').camelize
          begin
            require File.join(candidate, 'migration.rb')
            klass = class_name.constantize
          rescue LoadError => e
            raise MigrationNotFound, "migration file not found: #{candidate}"
          rescue NameError => e
            raise MigrationNotFound, "expected #{candidate} to define #{class_name}"
          end
          klass.timestamp = timestamp.to_i
          klass.directory = File.expand_path(candidate)
          klass.send(:include, config.helpers)
          klass
        end
        @migrations.compact!
        @migrations.sort { |m1,m2| m1.timestamp <=> m2.timestamp }
      end
      @migrations
    end
    
  end
end; end