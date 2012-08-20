module YandexMarket
  module Controller
    # Simple controller. Just holds objects in memory.
    class Naive < Base
      attr_reader :objects

      dispatch do |d|
        d.route 'yml_catalog' => :catalog,
                'shop'        => :shop,
                'currency'    => :currency,
                'category'    => :category,
                'offer'       => :offer
      end

      def initialize
        @objects = []
      end

      def accept o
        @objects << o
      end
      alias_method :catalog, :accept
      alias_method :shop, :accept
      alias_method :currency, :accept
      alias_method :category, :accept
      alias_method :offer, :accept
    end
  end
end