require 'pathname'
require 'vagrant/action/builder'

module VagrantPlugins
  module Xhyve
    module Action
      include Vagrant::Action::Builtin

      action_root = Pathname.new(File.expand_path('../action', __FILE__))

      def self.action_up
        Vagrant::Action::Builder.new.tap do |b|
        end
      end
    end
  end
end
