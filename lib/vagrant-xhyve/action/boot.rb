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
        end
      end
    end
  end
end
