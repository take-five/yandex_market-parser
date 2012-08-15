require "sax_stream/parser"
require "sax_stream/types/boolean"
require "sax_stream/types/decimal"
require "active_support/core_ext/object/with_options"

module YandexMarket
  # Base parser class
  #
  # == Example
  #   class MyParser < YandexMarket::Parser::Base
  #     configure.shop do |s|
  #       s.collect :company, :version
  #       s.xpath '@attr' => :attr
  #     end
  #
  #     configure.categories do |c|
  #       #
  #     end
  #
  #     configure.currencies do |c|
  #       #
  #     end
  #
  #     configure.offers do |o|
  #       #
  #     end
  #
  #     # set handler
  #     configure.handler MyHandler
  #   end
  module Parser
    class Base
      extend Configurable
      include Configurable::InstanceMethods

      class << self
        def configure_relations #:nodoc:
          configure.catalog do |c|
            c.relate :shop, :to => 'shop', :as => configuration.shop
          end
          configure.shop do |c|
            c.relate :currencies, :to => 'currencies/currency', :as => configuration.currencies
            c.relate :categories, :to => 'categories/category', :as => configuration.categories
            c.relate :offers,     :to => 'offers/offer',        :as => configuration.offers
          end
        end

        # Inheritance hook - reconfigure relations
        def inherited(subclass)
          super
          subclass.configure_relations
        end
      end

      # configure default xpath maps
      configure.catalog do |c|
        c.node_name 'yml_catalog'

        c.xpath '@date' => :date
        c.transform :date, :to => DateTime
      end

      configure.shop do |c|
        c.node_name 'shop'

        %w(name company url platform version agency email local_delivery_cost).each { |attr| c.xpath attr => attr }
      end

      configure.currencies do |c|
        c.node_name 'currency'

        c.xpath '@id' => :id, '@rate' => :rate
      end

      configure.categories do |c|
        c.node_name 'category'

        c.xpath '@id' => :id, '@parentId' => :parent_id
      end

      configure.offers do |c|
        c.base_class YandexMarket::Model::Offer
        c.node_name 'offer'

        c.xpath '@id' => :id,
                '@available' => :available,
                '@type' => :type,
                :url => :url,
                :price => :price,
                :currencyId => :currency_id,
                :categoryId => :category_id,
                :picture => :picture,
                :typePrefix => :type_prefix,
                :vendor => :vendor,
                :model => :model,
                :name => :name,
                :description => :description,
                :delivery => :delivery,
                :store => :store,
                :pickup => :pickup,
                :vendorCode => :vendor_code,
                :local_delivery_cost => :local_delivery_cost,
                :sales_notes => :sales_notes,
                :manufacturer_warranty => :manufacturer_warranty,
                :country_of_origin => :country_of_origin,
                :downloadable => :downloadable,
                :adult => :adult,
                :barcode => :barcode

        c.with_options :as => SaxStream::Types::Boolean do |bool|
          bool.transform :available
          bool.transform :store
          bool.transform :pickup
          bool.transform :delivery
          bool.transform :manufacturer_warranty
          bool.transform :downloadable
          bool.transform :adult
        end

        c.transform :price, :to => SaxStream::Types::Decimal
      end

      # set default (abstract handler)
      configure.handler YandexMarket::Handler::Base
      configure_relations

      attr_reader :handler
      def initialize(handler = nil)
        @handler = handler || configuration.handler.new
        @parser = SaxStream::Parser.new(@handler, [configuration.catalog.klass, configuration.shop.klass])
      end

      def parse_stream(io_stream, encoding = 'UTF-8')
        handler.run_hooks :parse do
          @parser.parse_stream(io_stream, encoding)
        end
      end
    end # class Base
  end # module Parser
end # module YandexMarket