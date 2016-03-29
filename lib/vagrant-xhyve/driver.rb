require 'pathname'

module VagrantPlugins
  module Xhyve
    module Driver
      driver_root = Pathname.new(File.expand_path('../driver', __FILE__))
      autoload :Base, driver_root.join('base')
      autoload :SudoXhyve, driver_root.join('sudo_xhyve')
    end
  end
end
