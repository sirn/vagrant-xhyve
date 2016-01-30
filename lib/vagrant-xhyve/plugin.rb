require 'vagrant'

module VagrantPlugins
  module Xhyve
    class Plugin < Vagrant.plugin('2')
      name 'Xhyve'
      description <<-DESC
        This plugin installs a provider that allows Vagrant to manage
        machines with Xhyve on Mac OS X 10.11 and above.
      DESC

      config(:xhyve, :provider) do
        require_relative 'config'
        Config
      end

      provider(:xhyve) do
        setup_i18n
        require_relative 'provider'
        Provider
      end

      def self.setup_i18n
        I18n.load_path << File.expand_path('locales/en.yml', Xhyve.source_root)
        I18n.reload!
      end
    end
  end
end
