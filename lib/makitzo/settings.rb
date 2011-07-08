module Makitzo
  # mixin providing classes with a settings hash
  module Settings
    def settings
      @settings ||= {}
    end

    def [](key)
      read(key)
    end
  
    def []=(key, value)
      set(key, value)
    end
    
    def read(key, default = nil)
      val = settings[key.to_sym]
      val = val.call if val.respond_to?(:call)
      val.nil? ? default : val
    end

    def set(key, value = nil, &block)
      settings[key.to_sym] = block_given? ? block : value
    end
  
    def memo(key, &block)
      set(key, MemoizedProc.new(&block))
    end
  end
end