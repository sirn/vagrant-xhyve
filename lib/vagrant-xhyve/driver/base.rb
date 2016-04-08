require 'pathname'

module VagrantPlugins
  module Xhyve
    module Driver
      class Base
        DHCPD_LEASES = '/var/db/dhcpd_leases'.freeze

        def initialize(id, data_dir)
          @id = id
          @data_dir = Pathname.new(data_dir)
        end

        def self.detect!
          raise NotImplementedError
        end

        def boot(params)
          raise NotImplementedError
        end

        def cleanup
          File.delete(pid_file)
        rescue Errno::ENOENT
          nil
        end

        def poweroff
          raise NotImplementedError
        end

        def ip_address
          @ip_address ||= if File.exists?(ip_address_file)
            File.read(ip_address_file).chomp.to_s
          end
        end

        def import(source)
          FileUtils.cp_r(source.to_s, image_dir)
        end

        def state
          if pid
            IO.popen("ps -p #{pid}").tap { |f| f.read }.close
            if $?.success?
              return :running
            end
          end
          :not_running
        end

        private

        def image_dir
          @image_dir ||= @data_dir.join(@id)
        end

        def ip_address_file
          @ip_address_file ||= @data_dir.join('ip_address')
        end

        def mac_address
          @mac_address ||= if File.exists?(mac_address_file)
            File.read(mac_address_file).chomp.to_s
          end
        end

        def mac_address_file
          @mac_address_file ||= @data_dir.join('mac_address')
        end

        def pid
          if File.exists?(pid_file)
            File.read(pid_file).chomp.to_i
          end
        end

        def pid_file
          @pid_file ||= @data_dir.join('pid')
        end
      end
    end
  end
end
