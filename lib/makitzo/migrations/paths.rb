module Makitzo; module Migrations
  module Paths
    def local_migration_path
      File.join(app.root_directory, 'migrations')
    end
  end
end; end