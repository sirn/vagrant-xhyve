require 'pathname'
require 'timeout'

module VagrantPlugins
  module Xhyve
    module Driver
      class Base
        DHCPD_LEASES = '/var/db/dhcpd_leases'.freeze
        WAIT_TIMEOUT = 120

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

        def destroy
          FileUtils.rm_rf(image_dir)
          File.delete(mac_address_file) rescue nil
        end

        def poweroff
          raise NotImplementedError
        end

        def ip_address
          host_ip = nil
          Timeout.timeout(WAIT_TIMEOUT) do
            begin
              host_ip = read_ip_address
              sleep(10) unless host_ip
            end until host_ip
          end
          host_ip
        rescue Timeout::Error
          raise Errors::IpAddressNotAvailable
        end

        def import(source)
          FileUtils.cp_r(source.to_s, image_dir)
        end

        def mac_address
          @mac_address ||= if File.exists?(mac_address_file)
            File.read(mac_address_file).chomp.to_s
          end
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

        def read_ip_address
          if mac_address
            leases_data = File.read(DHCPD_LEASES)
            parser = Support::DhcpdLeases.new
            leases = parser.parse(leases_data)

            matched_lease = leases.select do |lease|
              lease['hw_address'].split(",")[1] == mac_address
            end.first

            if matched_lease
              matched_lease['ip_address']
            end
          end
        rescue Racc::ParseError
          nil
        end
      end
    end
  end
end
