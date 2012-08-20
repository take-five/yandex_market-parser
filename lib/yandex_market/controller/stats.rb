module YandexMarket
  module Controller
    # Stats controller groups incoming objects by their XML-node and counts entries for each group
    #
    # == Example
    #   h = Stats.new
    #   p = Parser.new(h)
    #   p.parse_stream(File.open('/tmp/yandex.xml'))
    #   p.stats # => {'yml_catalog' => 1, 'shop' => 1, 'offer' => 2345}
    class Stats < Base
      attr_reader :stats

      def initialize
        @stats = Hash.new do |h, k|
          h[k] = 0
        end
      end

      def << o
        @stats[o.class.node_name] += 1
      end

      def inspect
        @stats.map { |k, v| "#{k}: #{v}" }.join("\n")
      end
    end
  end
end