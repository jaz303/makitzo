module Makitzo; module World
  # NamedEntity is a base class for categories of objects uniquely identified
  # by name. Equality is defined based on name and class.
  class NamedEntity
    include ApplicationAware
    include Settings
    
    def self.setting_accessor(*syms)
      syms.each do |sym|
        class_eval <<-CODE
          def #{sym};         read(:#{sym});        end
          def #{sym}=(value); set(:#{sym}, value);  end
        CODE
      end
    end
    
    attr_reader :name
    
    setting_accessor :makitzo_root
    setting_accessor :ssh_username, :ssh_port, :ssh_timeout
    
    def initialize(app, name, options = {})
      @app, @name = app, name.to_s
      options.each do |k,v|
        send(:"#{k}=", v)
      end
    end
    
    def <=>(other);   name <=> other.name;                            end
    def hash;         name.hash;                                      end
    def eql?(other);  other.is_a?(self.class) && other.name == name;  end
    
    def to_s; name; end
    
    def read!(key)
      val = read(key)
      raise MissingPropertyError if val.nil?
      val
    end
  end
end; end