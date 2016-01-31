require 'securerandom'

module VagrantPlugins
  module Xhyve
    module Action
      class Import
        def initialize(app, env)
          @app = app
        end

        def call(env)
          import(env[:machine], env[:ui])
          @app.call(env)
        end

        private

        def import(machine, ui)
          ui.info I18n.t("vagrant.actions.vm.clone.creating")
          machine.id = SecureRandom.uuid
          machine.provider.machine_id_changed
          machine.provider.driver.import(machine.box.directory)
        end
      end
    end
  end
end
