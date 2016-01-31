module VagrantPlugins
  module Xhyve
    module Action
      class ReadState
        def initialize(app, env)
          @app = app
        end

        def call(env)
          env[:machine_state_id] = read_state(env[:machine])
          @app.call(env)
        end

        private

        def read_state(machine)
          if machine.id
            state_id = machine.provider.driver.state
            state_id = :unknown if state_id.nil?
            state_id
          else
            :not_created
          end
        end
      end
    end
  end
end
