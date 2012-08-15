module YandexMarket
  module Handler
    # Simple handler. Just holds objects in memory.
    class Naive < Base
      attr_reader :objects

      def initialize
        @objects = []
      end

      def << o
        run_hooks o.class.node_name, o do
          @objects << o
        end
      end
    end
  end
end