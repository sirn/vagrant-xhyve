module VagrantPlugins
  module Xhyve
    module Errors
      class VagrantXhyveError < Vagrant::Errors::VagrantError
        error_namespace('vagrant_xhyve.errors')
      end

      class IpAddressNotAvailable < VagrantXhyveError
        error_key(:ip_address_not_available)
      end

      class VmnetNotAvailable < VagrantXhyveError
        error_key(:vmnet_not_available)
      end

      class XhyveNotDetected < VagrantXhyveError
        error_key(:xhyve_not_detected)
      end
    end
  end
end
