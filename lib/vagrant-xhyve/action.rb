require 'pathname'
require 'vagrant/action/builder'

module VagrantPlugins
  module Xhyve
    module Action
      include Vagrant::Action::Builtin

      action_root = Pathname.new(File.expand_path('../action', __FILE__))
      autoload :Boot, action_root.join('boot')
      autoload :Cleanup, action_root.join('cleanup')
      autoload :ForcedHalt, action_root.join('forced_halt')
      autoload :Import, action_root.join('import')
      autoload :ReadSSHInfo, action_root.join('read_ssh_info')
      autoload :ReadState, action_root.join('read_state')
      autoload :Warn, action_root.join('warn')

      def self.action_boot
        Vagrant::Action::Builder.new.tap do |b|
          b.use Boot
        end
      end

      def self.action_halt
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use Call, IsState, :running do |env, b1|
            if !env[:result]
              b1.use Message, I18n.t('vagrant_xhyve.commands.common.vm_not_running')
              next
            end

            b1.use Call, GracefulHalt, :not_running, :running do |env2, b2|
              if !env2[:result]
                b2.use ForcedHalt
              end
            end

            b1.use Cleanup
          end
        end
      end

      def self.action_read_ssh_info
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use ReadSSHInfo
        end
      end

      def self.action_read_state
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use ReadState
        end
      end

      def self.action_resume
        Vagrant::Action::Builder.new.tap do |b|
          b.use Warn, I18n.t('vagrant_xhyve.actions.vm.resume.not_supported')
        end
      end

      def self.action_ssh
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use Call, IsState, :running do |env, b1|
            if !env[:result]
              b1.use Message, I18n.t('vagrant_xhyve.commands.common.vm_not_running')
              next
            end

            b1.use SSHExec
          end
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

            b1.use action_boot
          end
        end
      end

      def self.action_suspend
        Vagrant::Action::Builder.new.tap do |b|
          b.use Warn, I18n.t('vagrant_xhyve.actions.vm.suspend.not_supported')
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
