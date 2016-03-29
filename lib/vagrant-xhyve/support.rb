require 'pathname'

module VagrantPlugins
  module Xhyve
    module Support
      support_root = Pathname.new(File.expand_path('../support', __FILE__))
      autoload :DhcpdLeases, support_root.join('dhcpd_leases')
      autoload :VmnetMac, support_root.join('vmnet_mac')
    end
  end
end
