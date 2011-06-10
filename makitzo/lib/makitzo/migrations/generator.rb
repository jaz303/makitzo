module Makitzo; module Migrations
  class Generator
    include ApplicationAware
    include Paths
    
    def initialize(app)
      @app = app
    end
    
    def create_migration(name)
      @migration_name = name
      @migration_timestamp = Time.now.to_i
      @migration_directory = File.join(local_migration_path, "#{@migration_timestamp}_#{@migration_name}")
      @migration_class_name = @migration_name.camelize
      
      template = ERB.new(File.read(File.join(Makitzo::ROOT, 'templates', 'migration.erb')))
      
      FileUtils.mkdir_p(@migration_directory)
      
      migration_source = template.result(binding)
      File.open(File.join(@migration_directory, 'migration.rb'), 'w') { |f| f.write(migration_source) }
    end
  end
end; end