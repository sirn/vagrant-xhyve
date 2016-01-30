module VagrantPlugins
  module Xhyve
    module Errors
      class VagrantXhyveError < Vagrant::Errors::VagrantError
        error_namespace('vagrant_xhyve.errors')
      end

      class XhyveNotDetected < VagrantXhyveError
        error_key(:xhyve_not_detected)
      end
    end
  end
end
