require "yandex_market"

module YandexMarket::Parser
  autoload :Base,          "yandex_market/parser/base"
  autoload :Configurable,  "yandex_market/parser/configurable"
  autoload :Configuration, "yandex_market/parser/configuration"
  autoload :Minimal,       "yandex_market/parser/minimal"
end