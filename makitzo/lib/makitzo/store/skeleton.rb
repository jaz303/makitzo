module Makitzo; module Store
  # Stores record persistent host state data including applied migrations and
  # arbitrary key-value pairs.
  #
  # This is an interface definition for a store backend. It is not necessary to
  # extend this class, but all methods must be implemented.
  # 
  # All operations must raise ::Makitzo::Store::OperationFailedError on failure.
  class Skeleton
    def open(&block)
      raise
    end
    
    def read(host, key)
      raise
    end
    
    def write(host, key, value)
      raise
    end
    
    def read_all(host, *keys)
      raise
    end
    
    def write_all(host, hash)
      raise
    end
    
    def mark_migration_as_applied(host, migration)
      raise
    end
    
    def unmark_migration_as_applied(host, migration)
      raise
    end
    
    def applied_migrations_for_all_hosts
      raise
    end
    
    def applied_migrations_for_host(host)
      raise
    end
  end
end; end