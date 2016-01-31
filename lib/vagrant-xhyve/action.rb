require 'pathname'
require 'vagrant/action/builder'

module VagrantPlugins
  module Xhyve
    module Action
      include Vagrant::Action::Builtin

      action_root = Pathname.new(File.expand_path('../action', __FILE__))
      autoload :Boot, action_root.join('boot')
      autoload :Cleanup, action_root.join('cleanup')
      autoload :Import, action_root.join('import')
      autoload :ReadState, action_root.join('read_state')
      autoload :Warn, action_root.join('warn')

      def self.action_boot
        Vagrant::Action::Builder.new.tap do |b|
          b.use Boot
        end
      end

      def self.action_read_state
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use ReadState
        end
      end

      def self.action_start
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use Call, IsState, :running do |env, b1|
            if env[:result]
              b1.use Message, I18n.t('vagrant_xhyve.commands.common.vm_already_running')
              next
            end

            b1.use Call, IsState, :unclean_shutdown do |env2, b2|
              if env2[:result]
                b2.use Warn, I18n.t('vagrant_xhyve.warnings.unclean_shutdown')
                b2.use Cleanup
              end
            end

            b1.use action_boot
          end
        end
      end

      def self.action_up
        Vagrant::Action::Builder.new.tap do |b|
          b.use Call, IsState, Vagrant::MachineState::NOT_CREATED_ID do |env, b2|
            if env[:result]
              b2.use HandleBox
            end
          end

          b.use ConfigValidate
          b.use Call, IsState, Vagrant::MachineState::NOT_CREATED_ID do |env, b2|
            if env[:result]
              b2.use Import
            end
          end

          b.use action_start
        end
      end
    end
  end
end
