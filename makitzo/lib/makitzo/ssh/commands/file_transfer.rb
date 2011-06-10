module Makitzo; module SSH; module Commands
  module FileTransfer
    def scp_upload(local_path, remote_path)
      logger.info "scp: '#{local_path}' -> '#{remote_path}'"
      scp = Net::SCP.new(connection)
      scp.upload!(local_path, remote_path)
    end
  end
end; end; end