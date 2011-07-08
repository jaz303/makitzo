module Makitzo; module Logging
  class Blackhole
    def with_host(host, &block); yield; end
    def log_command(status); end
    def overall_success!; end
    def overall_error!; end
    def error(msg); end
    def success(msg); end
    def notice(msg); end
    def warn(msg); end
    def info(msg); end
    def debug(msg); end
    def collector?; false; end
    def result; ""; end
  end
end; end