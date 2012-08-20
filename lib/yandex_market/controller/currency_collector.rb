module YandexMarket
  module Controller
    # Mixin for controllers, stores currencies in inner hash, and maps a currency for each offer
    module CurrencyCollector
      def self.included(base)
        base.class_eval do
          attr_reader :currencies

          after_currency :collect_currency
          before_offer   :assign_currency
        end
      end

      def collect_currency currency
        @currencies ||= {}
        @currencies[currency.id] = currency
      end

      def assign_currency offer
        if offer.currency_id && @currencies.key?(offer.currency_id)
          offer.currency = @currencies[offer.currency_id]
        end
      end
    end # moduel CurrencyCollector
  end # module Controller
end # module YandexMarket