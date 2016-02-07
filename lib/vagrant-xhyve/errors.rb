module VagrantPlugins
  module Xhyve
    module Errors
      class VagrantXhyveError < Vagrant::Errors::VagrantError
        error_namespace('vagrant_xhyve.errors')
      end

      class XhyveNotDetected < VagrantXhyveError
        error_key(:xhyve_not_detected)
      end

      class VmnetNotAvailable < VagrantXhyveError
        error_key(:vmnet_not_available)
      end
    end
  end
end
