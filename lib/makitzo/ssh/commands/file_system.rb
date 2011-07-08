module Makitzo; module SSH; module Commands
  module FileSystem
    
    #
    # Predicates... these never log extra info
    
    def which?(executable)
      exec("which #{executable}").success?
    end
    
    def dir_exists?(dir)
      exec("test -d #{dir}").success?
    end
    
    
    def cd(dir)
      exec("cd #{x(dir)}")
    end
    
    def mv(source, destination)
      exec("mv #{x(source)} #{x(destination)}").success?
    end
    
    # Ensure a directory exists.
    # Log and raise CommandFailed otherwise
    def require_dir!(dir, friendly_name = nil)
      friendly_name ||= dir
      unless dir_exists?(dir)
        logger.error "#{friendly_name} (#{dir}) is not a directory"
        raise CommandFailed
      end
    end
    
    # Check that a directory exists and attempt to create it if missing
    # Log and raise CommandFailed if can't create dir
    def find_or_create_dir!(directory, friendly_name = nil)
      friendly_name ||= directory
      if !dir_exists?(directory)
        mkdir = exec("mkdir -p #{directory}")
        if mkdir.error?
          logger.error "Failed to create #{friendly_name} (#{directory})"
          raise CommandFailed
        else
          logger.success "#{friendly_name} directory created"
        end
      else
        logger.success "#{friendly_name} directory located"
      end
    end
    
    def rm_rf!(directory, friendly_name = nil)
      friendly_name ||= directory
      if exec("rm -rf #{directory}").error?
        logger.error "could not delete #{friendly_name} (#{directory})"
        raise CommandFailed
      end
    end
  end
end; end; end