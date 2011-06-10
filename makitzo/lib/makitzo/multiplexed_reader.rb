module Makitzo
  # relays IO from a single source to multiple threads
  # each thread will see the same input.
  # necessarily has to store all data as set of reader threads is not known.
  # possible solution: associate reader with ThreadGroup so we can access
  # list of threads. can then keep track of threads that have read least/most
  # data and discard anything that's no longer needed.
  class MultiplexedReader
    def initialize(io)
      @io, @mutex, @state, @lines = io, Mutex.new, Hash.new { |h,k| h[k] = 0 }, []
    end
    
    def gets
      @mutex.synchronize do
        lines_read_by_thread = @state[Thread.current]
        if lines_read_by_thread >= @lines.count
          @lines << @io.gets
        end
        @state[Thread.current] = lines_read_by_thread + 1
        
        line = @lines[lines_read_by_thread]
        line ? line.dup : line
      end
    end
  end
end