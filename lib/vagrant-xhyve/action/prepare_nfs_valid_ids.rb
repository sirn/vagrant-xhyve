module VagrantPlugins
  module Xhyve
    module Action
      class PrepareNFSValidIds
        def initialize(app, env)
          @app = app
        end

        def call(env)
          prepare_nfs_valid_ids(env[:machine], env)
          @app.call(env)
        end

        private

        # TODO: Retrieve global state of running Xhyve?
        def prepare_nfs_valid_ids(machine, env)
          env[:nfs_valid_ids] = [machine.id]
        end
      end
    end
  end
end
