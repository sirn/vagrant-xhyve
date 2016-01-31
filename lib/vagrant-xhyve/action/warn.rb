module VagrantPlugins
  module Xhyve
    module Action
      class Warn
        def initialize(app, env, message)
          @app = app
          @message = message
        end

        def call(env)
          env[:ui].warn(@message)
          @app.call(env)
        end
      end
    end
  end
end
