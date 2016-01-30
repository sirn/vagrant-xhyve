require 'vagrant'

module VagrantPlugins
  module Xhyve
    class Plugin < Vagrant.plugin('2')
      name 'Xhyve'
      description <<-DESC
        This plugin installs a provider that allows Vagrant to manage
        machines with Xhyve on Mac OS X 10.11 and above.
      DESC

      provider(:xhyve) do
        require_relative 'provider'
        Provider
      end
    end
  end
end
