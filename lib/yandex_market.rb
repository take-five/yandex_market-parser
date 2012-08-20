require "yandex_market/version"

# The way to customize processing of Yandex.Market XML files
# is to define Parser and Controller.
#
# Parser is responsible for reading file, recognizing its structure and map XML-nodes to Ruby objects.
# Controller is responsible for the rest part of work - it processes objects received from Parser.
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
# To create a controller you should create a new class - successor of YandexMarket::Controller::Base. You should define
# dispatch rules for main YML-objects: catalog, shop, currency, category, offer. Optionally you can add hooks for every
# handler. E.g. if you set up your dispatch rules to route <tt>offer</tt> nodes to <tt>handle_offer</tt>, you can declare
# <tt>before_handle_offer</tt> and <tt>after_handle_offer</tt> hooks.
#   class MyCoolController < YandexMarket::Controller::Base
#     dispatch do |d|
#       d.route 'yml_catalog' => :catalog,
#               'shop' => :shop,
#               'currency' => :currency,
#               'category' => :category,
#               'offer' => :offer
#     end
#
#     before_offer :before_offer_hook
#
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
#
#     private
#     def before_offer_hook(offer)
#     end
#   end
#
# There is already few predefined controllers, they are designed mainly for testing purposes:
# 1. YandexMarket::Controller::Naive - it just stores all objects to array, and it is accessible by method +objects+
# 2. YandexMarket::Controller::Stats - counts nodes by node type, statistics is accessible by method +stats+
#
# And now you can parse YML-files:
#   controller = MyCoolController.new
#   parser  = MyCoolParser.new(controller)
#   parser.parse_stream(File.open('/tmp/yandex.xml'))
module YandexMarket
  autoload :Controller, "yandex_market/controller"
  autoload :Model,      "yandex_market/model"
  autoload :Parser,     "yandex_market/parser"
end