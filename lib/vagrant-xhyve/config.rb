module VagrantPlugins
  module Xhyve
    class Config < Vagrant.plugin('2', :config)
      attr_accessor :cpus
      attr_accessor :memory
      attr_accessor :firmware
      attr_accessor :pcis
      attr_accessor :acpi
      attr_accessor :lpc

      def initialize
        @cpus = UNSET_VALUE
        @memory = UNSET_VALUE
        @firmware = UNSET_VALUE
        @pcis = []
        @acpi = UNSET_VALUE
        @lpc = UNSET_VALUE
      end

      def to_s
        'Xhyve'
      end
    end
  end
end
