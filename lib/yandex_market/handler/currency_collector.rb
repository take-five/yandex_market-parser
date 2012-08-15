require "active_support/concern"

module YandexMarket
  module Handler
    # Mixin for handlers, stores currencies in inner hash, and maps a currency for each offer
    module CurrencyCollector
      extend ActiveSupport::Concern

      included do
        attr_reader :currencies
        after_currency :collect_currency
        before_offer   :assign_currency
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
  end # module Handler
end # module YandexMarket