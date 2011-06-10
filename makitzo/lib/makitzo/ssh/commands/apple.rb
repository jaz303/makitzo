module Makitzo; module SSH; module Commands
  module Apple
    def mount_dmg(path)
      mount_status = exec("hdiutil attach -puppetstrings #{x(path)}")
      if mount_status.error?
        logger.warn("unable to mount #{path}")
        false
      else
        mount_status.stdout.split("\n").reverse.each do |line|
          chunks = line.split(/\t+/)
          if chunks.length == 3
            mount_point = chunks[2].strip
            unless mount_point.empty?
              logger.success("#{path} mounted at #{mount_point}")
              return mount_point
            end
          end
        end
        true
      end
    end
    
    def unmount_dmg(path)
      unmount_status = exec("hdiutil detach #{x(path)}")
      if unmount_status.error?
        logger.warn("unable to unmount #{path}")
        false
      else
        logger.success("#{path} unmounted")
        true
      end
    end
    
    def install_app(app, target = '/Applications', backup_file = nil)
      target_dir = File.join(target, File.basename(app))
      exec("test -d #{x(target_dir)} && rm -rf #{x(target_dir)}")
      if exec("cp -R #{x(app)} #{x(target)}").success?
        logger.success("app #{app} installed to #{target}")
        true
      else
        logger.warn("failed to install #{app} to #{target}")
        false
      end
    end
    
    def install_pkg(pkg)
      if exec("installer -pkg #{x(pkg)} -target /").success?
        logger.success("package #{pkg} installed to /")
        true
      else
        logger.warn("failed to install package #{pkg}")
        false
      end
    end
    
    def shutdown_at(time)
      sudo do
        unless exec("pmset schedule shutdown \"#{time}\"").success?
          logger.error("couldn't set poweroff time")
          return false
        end
      end
      true
    end
    
    # format of restart_time is mm/dd/yy HH:MM:ss
    def shutdown(restart_time = nil)
      sudo do
        if restart_time
          res = exec("pmset schedule poweron \"#{restart_time}\"")
          unless res.success?
            logger.error("couldn't set restart time")
            return false
          end
        end
        res = exec("shutdown -h now")
        res.success?
      end
    end
    
    def daily_shutdown
      tomorrow = Time.now + 86400
      shutdown(time.strftime("%m/%d/%y 08:45:00"))
    end
    
    def reboot
      sudo { exec('reboot') }
    end
    
    def serial_number
      res = exec("system_profiler SPHardwareDataType | grep 'Serial Number' | awk '{ print $4; }'")
      res.success? ? res.stdout.strip : nil
    end
    
    def use_network_time_server(address)
      sudo do
        exec!("systemsetup -setnetworktimeserver \"#{x(address)}\"")
        exec!("systemsetup -setusingnetworktime on")
      end
    end
    
    bangify :mount_dmg, :unmount_dmg, :install_app, 'Makitzo::SSH::CommandFailed'
  end
end; end; end