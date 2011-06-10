module Makitzo; module Logging
  module Colorize
    def bold(text)
      if use_color?
        "\033[1m#{text}\033[0m"
      else
        text
      end
    end
    
    def colorize(text, ansi, bold = false)
      if use_color?
        code = "\033["
        code << "1;" if bold
        code << "#{ansi}m"
        code + text + "\033[0m"
      else
        text
      end
    end
    
    { :black      => 30,
      :red        => 31,
      :green      => 32,
      :yellow     => 33,
      :blue       => 34,
      :magenta    => 35,
      :cyan       => 36,
      :white      => 37
    }.each do |color, ansi|
      class_eval <<-CODE
        def #{color}(text, bold = false)
          colorize(text, #{ansi}, bold)
        end
      CODE
    end
  end
end; end
