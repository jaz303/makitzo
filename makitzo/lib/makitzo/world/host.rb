module Makitzo; module World
  class Host < NamedEntity
    include Makitzo::FileSystem
    
    def roles
      @roles ||= []
    end
    
    def roles=(roles)
      resolved_roles = [roles].flatten.map { |r| config.resolve_role(r) }
      @roles = resolved_roles
    end
    
    def address
      address  = name
      
      if username = read_merged(:ssh_username)
        address = "#{username}@#{address}"
      end
      
      if port = read_merged(:ssh_port)
        address << ":#{port}"
      end
      
      address
    end
    
    def root;   read_merged(:makitzo_root);   end
    def root!;  read_merged!(:makitzo_root);  end
    
    # read a setting from this host, or from its roles
    # if the setting is not present on this host, all roles supplying
    # a non-nil value must be in consensus or else a ConflictingPropertyError
    # will be raised.
    def read_merged(key, default = nil)
      config.synchronize do
        val = read(key)
        if val.nil?
          role_values = roles.map { |r| r.read(key) }.compact.uniq
          raise ConflictingPropertyError if role_values.length > 1
          val = role_values.first
        end
        val.nil? ? default : val
      end
    end
    
    def read_merged!(key)
      val = read_merged(key)
      raise MissingPropertyError, "missing property: #{key}" if val.nil?
      val
    end
    
    #
    # Store delegators
    
    def read_from_store(key, default = nil)
      store.read(self, key) || default
    end
    
    def write_to_store(key, value)
      store.write(self, key, value)
    end
    
    def read_all_from_store(*keys)
      store.read_all(self, *keys)
    end
    
    def write_all_to_store(hash)
      store.write_all(self, hash)
    end
    
    def applied_migrations
      store.applied_migrations_for_host(self)
    end
    
    def mark_migration_as_applied(migration)
      store.mark_migration_as_applied(self, migration)
    end
    
    def unmark_migration_as_applied(migration)
      store.unmark_migration_as_applied(self, migration)
    end
  end
end; end