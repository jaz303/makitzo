module Makitzo
  module ApplicationAware
    def app
      @app
    end
    
    def config
      @app.config
    end
    
    def logger
      @app.logger
    end
    
    def store
      config.store
    end
  end
end