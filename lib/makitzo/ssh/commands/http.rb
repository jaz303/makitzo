module Makitzo; module SSH; module Commands
  module HTTP
    
    # downloads a url -> path, using either curl or wget
    # logs a warning if neither is present
    # TODO: hosts/roles should be able to specify their preferred d/l mechanism
    def download(url, path)
      if which?("curl")
        download_with_curl(url, path)
      elsif which?("wget")
        download_with_wget(url, path)
      else
        logger.warn("failed: download #{url} -> #{path} (curl/wget not found)")
        false
      end
    end
    
    # downloads url and saves in path, using either curl or wget
    # raises CommandFailed if download fails
    def download!(url, path)
      raise CommandFailed unless download(url, path)
    end
    
    # downloads url and saves to path, using curl
    # logs success/failure message
    def download_with_curl(url, path)
      result = exec("curl -o #{path} -f #{url}")
      if result.success?
        logger.success("download #{url} -> #{path} (curl)")
        true
      else
        logger.warn("failed: download #{url} -> #{path} (curl)")
        false
      end
    end
    
    def download_with_wget(url, path)
      result = exec("wget -o #{path} -- #{url}")
      if result.success?
        logger.success("download #{url} -> #{path} (wget)")
        true
      else
        logger.warn("failed: download #{url} -> #{path} (wget)")
        false
      end
    end
    
    bangify :download_with_curl, :download_with_wget
    
  end
end; end; end