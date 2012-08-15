require "yandex_market/version"
require "active_support/dependencies/autoload"

# The way to customize processing of Yandex.Market XML files
# is to define Parser and Handler.
#
# Parser is responsible for reading file, recognizing its structure and map XML-nodes to Ruby objects.
# Handler is responsible for the rest part of work - it processes objects, received from Parser.
#
# To create a parser you should create a new class - successor of YandexMarket::Parser::Base, and
# configure YML-specific sections. In each section you should define of which attributes you are interested.
# Some attributes are already mapped to standard XML-nodes. Anyway, you can map some specific attributes by yourself.
#   class MyCoolParser < YandexMarket::Parser::Base
#     configure.catalog do |c|
#       c.collect :date
#     end
#     configure.offers do |c|
#       c.xpath 'oferta/@id' => :oferta_id # custom mapping
#       c.collect :id, :price, :oferta_id
#       # you can specify a base class for generated classes (it should be successor of YandexMarket::Model)
#       c.base_class MyCoolOffer
#       # alternatively you can specify a concrete class for section
#       c.instantiate MyCoolOffer # no additional classes shall be generated
#     end
#   end
#
# To create a handler you should create a new class - successor of YandexMarket::Handler::Base. You should implement
# main methods: catalog, shop, currency, category, offer
#   class MyCoolHandler < YandexMarket::Handler::Base
#     def catalog(o)
#     end
#
#     def shop(o)
#     end
#
#     def currency(o)
#     end
#
#     def category(o)
#     end
#
#     def offer(o)
#     end
#   end
#
# There is already few predefined handlers, they are mainly for testing purposes:
# 1. YandexMarket::Handlers::Naive - it just stores all objects to array, and it is accessible by method +objects+
# 2. YandexMarket::Handlers::Stats - counts nodes by node type, statistics is accessible by method +stats+
#
# And now you can parse YML-files:
#   handler = MyCoolHandler.new
#   parser  = MyCoolParser.new(handler)
#   parser.parse_stream(File.open('/tmp/yandex.xml'))
module YandexMarket
  extend ActiveSupport::Autoload

  autoload :Handler
  autoload :Model
  autoload :Parser
end