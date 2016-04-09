module VagrantPlugins
  module Xhyve
    module Driver
      class SudoXhyve < Base
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
            ) do |fd|
              # We need some way to make IO.popen waits for sudo prompt.
              # Apparently give it a block does the trick.
              nil
            end
          end
        end

        def poweroff
          if pid
            IO.popen("sudo kill #{pid}")
            loop do
              break if state != :running
              sleep 1
            end
          end
        end

        private

        def store_mac_address!
          unless mac_address
            lib_dir = Xhyve.source_root.join('lib')
            uid = Shellwords.escape(@id)

            fd = IO.popen(
              "sudo #{Shellwords.escape(RbConfig.ruby)} " +
              "-I#{Shellwords.escape(lib_dir)} " +
              "-e \"require 'vagrant-xhyve/support/vmnet_mac'; " +
              "puts VagrantPlugins::Xhyve::Support::VmnetMac.from_uuid('#{uid}')\""
            )

            addr = fd.read.chomp
            fd.close

            if addr.match(/^\w{,2}:\w{,2}:\w{,2}:\w{,2}:\w{,2}:\w{,2}$/)
              @mac_address = addr
              @ip_address = nil
              File.open(mac_address_file, 'wb') do |file|
                file.write(addr)
              end
            end
          end
        end
      end
    end
  end
end
