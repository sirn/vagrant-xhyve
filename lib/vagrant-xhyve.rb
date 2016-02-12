require 'pathname'
require 'vagrant-xhyve/plugin'

module VagrantPlugins
  module Xhyve
    lib_path = Pathname.new(File.expand_path('../vagrant-xhyve', __FILE__))
    autoload :Action, lib_path.join('action')
    autoload :Driver, lib_path.join('driver')
    autoload :Errors, lib_path.join('errors')
    autoload :Support, lib_path.join('support')

    def self.source_root
      @source_root ||= Pathname.new(File.expand_path('../../', __FILE__))
    end
  end
end
