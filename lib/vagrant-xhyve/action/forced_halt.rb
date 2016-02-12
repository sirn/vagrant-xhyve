module VagrantPlugins
  module Xhyve
    module Action
      class ForcedHalt
        def initialize(app, env)
          @app = app
        end

        def call(env)
          halt(env[:machine], env[:ui])
          @app.call(env)
        end

        private

        def halt(machine, ui)
          current_state = machine.state.id
          if current_state == :running
            ui.info I18n.t('vagrant_xhyve.actions.vm.halt.force')
            machine.provider.driver.poweroff
          end
        end
      end
    end
  end
end
