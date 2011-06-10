module Makitzo
  # classes including this module must define a #root method that returns
  # the path of the makitzo control directory (e.g. /home/foo/makitzo)
  module FileSystem
    INSTALL_FILE            = 'INSTALL'
    HISTORY_DIR             = 'migrations-history'
    
    def self.install_file(root)
      File.join(root, INSTALL_FILE)
    end
    
    def self.migration_history_dir(root)
      File.join(root, HISTORY_DIR)
    end
    
    def install_file
      ::Makitzo::FileSystem.install_file(root)
    end
    
    def migration_history_dir
      ::Makitzo::FileSystem.migration_history_dir(root)
    end
  end
end