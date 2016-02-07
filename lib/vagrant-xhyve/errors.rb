module VagrantPlugins
  module Xhyve
    module Errors
      class VagrantXhyveError < Vagrant::Errors::VagrantError
        error_namespace('vagrant_xhyve.errors')
      end

      class VmnetNotAvailable < VagrantXhyveError
        error_key(:vmnet_not_available)
      end

      class XhyveBootedWithoutIpAddress < VagrantXhyveError
        error_key(:xhyve_booted_without_ip_address)
      end

      class XhyveNotDetected < VagrantXhyveError
        error_key(:xhyve_not_detected)
      end
    end
  end
end
