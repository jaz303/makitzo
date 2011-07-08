module Makitzo; module SSH; module Commands
  module Makitzo
    def makitzo_install
      root = host.root!
      if makitzo_install_check
        logger.success("Makitzo already installed")
      else
        find_or_create_dir!(root, 'Makitzo root')
        find_or_create_dir!(host.migration_history_dir, 'migration history directory')
        exec!("echo COMPLETE > #{host.install_file}")
        logger.success("Install successful")
      end
      logger.overall_success!
    rescue CommandFailed => e
      logger.error "installation aborted"
    end
    
    def makitzo_uninstall
      root = host.root!
      if root.length <= 1
        logger.error "failsafe! I won't remove this directory: #{root}"
        next
      end
      require_dir!(root, 'Makitzo root')
      rm_rf!(root, 'Makitzo root')
      logger.success("uninstall successful")
      logger.overall_success!
    rescue CommandFailed => e
      logger.error "uninstallation aborted"
    end
    
    def makitzo_install_check
      result = exec("cat #{host.install_file}")
      return result.success? && result.stdout.strip == 'COMPLETE'
    end
    
    def makitzo_install_check!
      unless makitzo_install_check
        logger.error "Makitzo is not installed on this system"
        raise CommandFailed
      else
        true
      end
    end
  end
end; end; end