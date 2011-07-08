module Makitzo; module SSH; module Commands
  module Unix
    def killall(process_name)
      exec("killall #{x(process_name)}")
    end
  end
end; end; end