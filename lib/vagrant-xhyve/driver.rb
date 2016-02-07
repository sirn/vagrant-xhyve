require 'pathname'

module VagrantPlugins
  module Xhyve
    class Driver
      def initialize(id, data_dir)
        @id = id
        @data_dir = Pathname.new(data_dir)
      end

      def self.detect!
        IO.popen('xhyve -v 2>&1').tap { |f| f.read }.close
        unless $?.success?
          raise Errors::XhyveNotDetected
        end
      end

      def boot(params)
        command = ['xhyve']
        command << '-A' if params[:acpi]
        command += ['-m', params[:memory]] if params[:memory]
        command += ['-c', params[:cpus]] if params[:cpus]

        params[:pcis].each do |pci|
          command += ['-s', pci]
        end

        command += ['-l', params[:lpc]] if params[:lpc]
        command += ['-U', @id]
        command += ['-f', params[:firmware]]

        # Need to be run before actually booting up Xhyve, since vmnet.framework
        # forbids multiple processes accessing the same interface at once.
        # (i.e. we can't resolve UUID to MAC address while Xhyve is running.)
        store_mac_address!
        unless mac_address
          raise Errors::VmnetNotAvailable
        end

        # Big hack ahead. sudo -b will run the process in background but that
        # will make IO.popen return pid of sudo. We need actual pid of xhyve
        # to interact with it.
        Dir.chdir(image_dir) do
          IO.popen(
            "sudo -b sh -c \"echo \\$\\$ >#{Shellwords.escape(pid_file)}; " +
            "exec #{Shellwords.join(command)} " +
            '</dev/null ' +
            '>/dev/null ' +
            '2>&1"'
          )
        end
      end

      def cleanup
        File.delete(pid_file)
      rescue Errno::ENOENT
        nil
      end

      def import(source)
        FileUtils.cp_r(source.to_s, image_dir)
      end

      def state
        if pid
          IO.popen("ps -p #{pid}").tap { |f| f.read }.close
          if $?.success?
            :running
          else
            :unclean_shutdown
          end
        else
          :not_running
        end
      end

      private

      def image_dir
        @image_dir ||= @data_dir.join(@id)
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

      def store_mac_address!
        unless mac_address
          lib_dir = VagrantPlugins::Xhyve.source_root.join('lib')
          uid = Shellwords.escape(@id)

          fd = IO.popen(
            "sudo #{Shellwords.escape(RbConfig.ruby)} " +
            "-I#{Shellwords.escape(lib_dir)} " +
            "-e \"require 'vagrant-xhyve/vmnet_mac'; " +
            "puts VagrantPlugins::Xhyve::VmnetMac.from_uuid('#{uid}')\""
          )

          addr = fd.read.chomp
          fd.close

          if addr.match(/^\w{,2}:\w{,2}:\w{,2}:\w{,2}:\w{,2}:\w{,2}$/)
            @mac_address = addr
            File.open(mac_address_file, 'wb') do |file|
              file.write(addr)
            end
          end
        end
      end
    end
  end
end
