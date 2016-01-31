require 'pathname'

module VagrantPlugins
  module Xhyve
    class Driver
      def initialize(id, data_dir)
        @id = id
        @data_dir = Pathname.new(data_dir)
      end

      def self.detect!
        IO.popen("xhyve -v 2>&1").tap { |f| f.read }.close
        unless $?.success?
          raise Errors::XhyveNotDetected
        end
      end

      def cleanup
        File.delete(pid_file)
      rescue Errno::ENOENT
        nil
      end

      def import(source)
        FileUtils.cp_r(source.to_s, image_dir)
      end

      def state
        if pid
          begin
            Process.kill(0, pid)
            :running
          rescue Errno::ESRCH
            :unclean_shutdown
          end
        else
          :not_running
        end
      end

      private

      def image_dir
        @image_dir ||= @data_dir.join(@id)
      end

      def pid
        if File.exists?(pid_file)
          File.read(pid_file).chomp.to_i
        end
      end

      def pid_file
        @pid_file ||= @data_dir.join("#{@id}.pid")
      end
    end
  end
end
