module VagrantPlugins
  module Xhyve
    module Action
      class Cleanup
        def initialize(app, env)
          @app = app
        end

        def call(env)
          cleanup(env[:machine])
          @app.call(env)
        end

        private

        def cleanup(machine)
          machine.provider.driver.cleanup
        end
      end
    end
  end
end
