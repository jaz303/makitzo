module Makitzo; module SSH; module Commands
  module Ruby
    def ruby_version
      ruby_version_check = exec("#{host.read_merged(:ruby_command) || 'ruby'} -v")
      if ruby_version_check.error?
        logger.warn "Ruby executable '#{host.ruby_command}' not found"
        false
      else
        logger.success "Ruby executable located"
        true
      end
    end
    
    def require_ruby!
      raise CommandFailed unless ruby_version
    end
  end
end; end; end