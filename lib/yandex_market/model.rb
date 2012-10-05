require "weakref"
require "sax_stream/mapper"

module YandexMarket
  # An abstract YandexMarket model
  class Model
    include SaxStream::Mapper

    class << self
      # For each attribute of +attributes+ generate three methods (for example, shop):
      #   shop - getter
      #   shop= - setter
      #   shop? - predicate
      def generate_attribute_methods(*attributes)
        attributes.flatten.each do |attribute|
          class_eval <<-CODE, __FILE__, __LINE__ + 1
            def #{attribute}
              self[#{attribute.to_s.inspect}]
            end

            def #{attribute}=(value)
              self[#{attribute.to_s.inspect}] = value
            end

            def #{attribute}?
              !!#{attribute}
            end
          CODE
        end
      end # def generate_attribute_methods
    end

    # Base class for offers
    class Offer < Model
      attr_accessor :currency, :category, :params
    end

    # Base class for categories
    class Category < Model
      attr_reader :parent

      def children
        @children ||= []
      end

      def parent=(category)
        category.children << self

        @parent = category
      end
    end
  end
end