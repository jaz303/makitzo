class Module
  def bangify(*methods)
    exception_class = 'RuntimeError'
    exception_class = methods.pop if (methods.last.is_a?(Class) || methods.last =~ /^[A-Z]/)
    methods.each do |method|
      class_eval <<-CODE
        def #{method}!(*args, &block)
          result = #{method}(*args, &block)
          raise #{exception_class} unless result
          result
        end
      CODE
    end
  end
end
