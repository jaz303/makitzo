module Makitzo
  class Config
    include ApplicationAware
    include Settings
    
    def initialize(app)
      @app = app
      @options_stack = []
      @terminal = HighLine.new
      @store = nil
      @concurrency = nil
      
      @helpers = Module.new do
        def self.method_added(method_name)
          if SSH::Context.protected_context_methods.include?(method_name.to_s)
            raise "The method name '#{method_name}' is used internally by SSH sessions. Please rename your helper."
          end
        end
      end
      
      @mutex = Mutex.new
      initialize_roles
      initialize_hosts
    end
    
    #
    #
    
    def concurrency=(concurrency)
      @concurrency = concurrency
    end
    
    def concurrency
      @concurrency
    end
    
    #
    # Store
    
    def store=(store)
      @store = store
    end
    
    def store
      raise Store::MissingStoreError if @store.nil?
      @store
    end
    
    #
    # Helpers
    
    def helpers(&block)
      @helpers.class_eval(&block) if block_given?
      @helpers
    end
    
    #
    #
    
    def memoize(&block)
      MemoizedProc.new(&block)
    end
    
    def synchronize(&block)
      @mutex.synchronize(&block)
    end
    
    #
    # Prompting
    
    extend Forwardable
    def_delegators :@terminal, :agree, :ask, :choose, :say
    
    def password_prompt(prompt = 'Enter password: ')
      ask(prompt) { |q| q.echo = false }
    end
    
    #
    # Options
    
    def with_options(options)
      begin
        @options_stack.push(options)
        yield if block_given?
      ensure
        @options_stack.pop
      end
    end
    
    MERGER = lambda do |k,o,n|
      if o.is_a?(Array)
        n.is_a?(Array) ? (o + n) : (o.dup << n)
      else
        n
      end
    end
    
    def merged_options(extra_options = {})
      opts = @options_stack.inject({}) { |m,hsh| m.update(hsh, &MERGER) }
      opts.update(extra_options, &MERGER)
    end
    
    #
    # Hosts & Roles
      
    { 'role' => '::Makitzo::World::Role',
      'host' => '::Makitzo::World::Host' }.each do |entity, klass|
      class_eval <<-CODE
        public
          def #{entity}(name, options = {})
            thing = #{klass}.new(@app, name, merged_options(options))
            raise "Duplicate #{entity} name '\#{name}'" if @#{entity}s.include?(thing)
            @#{entity}s << thing
            @#{entity}_index[thing.name.to_s] = thing
            yield thing if block_given?
            thing
          end
          
          def #{entity}_for_name(name)
            @#{entity}_index[name.to_s]
          end
          
          def #{entity}_for_name!(name)
            #{entity}_for_name(name) or raise "Unknown #{entity} '#{name}'!"
          end
          
          def #{entity}s
            @#{entity}s.to_a
          end
          
        private
          def initialize_#{entity}s
            @#{entity}s = Set.new
            @#{entity}_index = {}
          end
      CODE
    end
    
    def resolve_role(thing)
      if thing.is_a?(::Makitzo::World::Role)
        thing
      else
        role_for_name!(thing.to_s)
      end
    end

  end
end