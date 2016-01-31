module VagrantPlugins
  module Xhyve
    module Action
      class Boot
        def initialize(app, env)
          @app = app
        end

        def call(env)
          boot(env[:machine], env[:ui])
          @app.call(env)
        end

        private

        def boot(machine, ui)
          ui.info I18n.t('vagrant.actions.vm.boot.booting')
          ui.detail I18n.t('vagrant_xhyve.actions.vm.boot.booting_sudo')

          machine.provider.driver.boot({
            cpus: machine.provider_config.cpus.to_i,
            memory: machine.provider_config.memory,
            firmware: machine.provider_config.firmware,
            pcis: machine.provider_config.pcis,
            acpi: machine.provider_config.acpi,
            lpc: machine.provider_config.lpc,
          })
        end
      end
    end
  end
end
