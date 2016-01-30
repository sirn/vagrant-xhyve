module VagrantPlugins
  module Xhyve
    class Driver
      attr_reader :version

      def initialize
        fd = IO.popen("xhyve -v 2>&1")
        body = fd.read
        fd.close

        unless $?.success?
          raise Errors::XhyveNotDetected
        end

        @version = body[/(?<=xhyve: )\d+\.\d+\.\d+/].split('.')
      end
    end
  end
end
