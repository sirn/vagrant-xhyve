module VagrantPlugins
  module Xhyve
    module Action
      class Destroy
        def initialize(app, env)
          @app = app
        end

        def call(env)
          destroy(env[:machine], env[:ui])
          @app.call(env)
        end

        private

        def destroy(machine, ui)
          ui.info I18n.t('vagrant.actions.vm.destroy.destroying')
          machine.provider.driver.destroy
          machine.id = nil
        end
      end
    end
  end
end
