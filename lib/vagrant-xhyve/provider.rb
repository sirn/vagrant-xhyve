module VagrantPlugins
  module Xhyve
    class Provider < Vagrant.plugin('2', :provider)
      attr_reader :driver

      def initialize(machine)
        @machine = machine
        machine_id_changed
      end

      def self.installed?
        Driver::SudoXhyve.detect!
        true
      rescue Errors::XhyveNotDetected
        false
      end

      def self.usable?(raise_error=false)
        Driver::SudoXhyve.detect!
        true
      rescue Errors::XhyveNotDetected
        raise if raise_error
        false
      end

      def action(name)
        action_method = "action_#{name}"
        if Action.respond_to?(action_method)
          Action.send(action_method)
        end
      end

      def machine_id_changed
        @driver = Driver::SudoXhyve.new(@machine.id, @machine.data_dir)
      end

      def ssh_info
        env = @machine.action('read_ssh_info')
        env[:machine_ssh_info]
      end

      def state
        env = @machine.action('read_state')
        state_id = env[:machine_state_id]

        short = I18n.t("vagrant_xhyve.states.short_#{state_id}")
        long = I18n.t("vagrant_xhyve.states.long_#{state_id}")

        if state_id == :not_created
          state_id = Vagrant::MachineState::NOT_CREATED_ID
        end

        Vagrant::MachineState.new(state_id, short, long)
      end
    end
  end
end
