module Makitzo; module Migrations
  module Commands
    def upload_migration_file(name)
      target = remote_migration_file(name)
      scp_upload(local_migration_file(name), target)
      target
    end
    
    bangify :upload_migration_file
  end
end; end