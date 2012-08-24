module YandexMarket
  module Controller
    autoload :CategoryCollector, "yandex_market/controller/category_collector"
    autoload :CurrencyCollector, "yandex_market/controller/currency_collector"
    autoload :Dispatchable,      "yandex_market/controller/dispatchable"
    autoload :Naive,             "yandex_market/controller/naive"
    autoload :Stats,             "yandex_market/controller/stats"

    # Abstract controller, dispatches objects to proper methods, defines callback-methods
    class Base
      extend YandexMarket::Controller::Dispatchable

      define_hooks :before_parse, :after_parse

      # Declare default dispatch property
      dispatcher.property :node_name

      # Dispatches +object+ to proper method
      def <<(object)
        dispatch(object)
      end
    end # class Base
  end # module Controller
end # module YandexMarket