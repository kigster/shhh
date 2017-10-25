module Sym
  module Extensions
    module WithTimeout

      def with_timeout(timeout = 3)
        Timeout::timeout(timeout) {
          yield if block_given?
        }
      end

    end
  end
end

