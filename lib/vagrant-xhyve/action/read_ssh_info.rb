module VagrantPlugins
  module Xhyve
    module Action
      class ReadSSHInfo
        def initialize(app, env)
          @app = app
        end

        def call(env)
          env[:machine_ssh_info] = ssh_info(env[:machine])
          @app.call(env)
        end

        private

        def ssh_info(machine)
          {
            host: machine.provider.driver.ip_address,
            port: 22,
          }
        end
      end
    end
  end
end
