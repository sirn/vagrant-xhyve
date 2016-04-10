require 'ipaddr'

module VagrantPlugins
  module Xhyve
    module Action
      class PrepareNFSSettings
        include Vagrant::Action::Builtin::MixinSyncedFolders

        def initialize(app, env)
          @app = app
        end

        def call(env)
          prepare_nfs_settings(env[:machine], env)
          @app.call(env)
        end

        private

        def get_host_ip(guest_ip)
          host_ip = nil

          # TODO: Find a better way to get host IP.
          IO.popen('ifconfig') do |cmd|
            cmd.readlines.each do |line|
              match = line.match(/inet (\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}) netmask (\w+)/)
              if match
                ipaddr = match[1]
                mask = match[2].to_i(16)
                mask = "%d.%d.%d.%d" % [(mask>>24)&0xff, (mask>>16)&0xff, (mask>>8)&0xff, mask&0xff]
                network = IPAddr.new("#{ipaddr}/#{mask}")
                if network.include?(guest_ip)
                  host_ip = ipaddr
                  break
                end
              end
            end
          end

          host_ip
        end

        def prepare_nfs_settings(machine, env)
          if machine.config.vm.synced_folders.any? { |_, opts| opts[:type] == :nfs }
            guest_ip = machine.provider.driver.ip_address
            host_ip = get_host_ip(guest_ip)

            raise Vagrant::Errors::NFSNoHostIP unless host_ip
            raise Vagrant::Errors::NFSNoGuestIP unless guest_ip

            env[:nfs_host_ip] = host_ip
            env[:nfs_machine_ip] = guest_ip
          end
        end
      end
    end
  end
end
