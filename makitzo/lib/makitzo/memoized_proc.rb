module Makitzo
  class MemoizedProc
    def initialize(&block)
      @proc = block
    end
    
    def call(*args)
      if defined?(@value)
        @value
      else
        @value = @proc.call(*args)
      end
    end
  end
end