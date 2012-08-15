require "active_model"
require "sax_stream/mapper"

module YandexMarket
  # An abstract YandexMarket model
  class Model
    include SaxStream::Mapper
    include ActiveModel::Validations

    class << self
      # For each attribute of +attributes+ generate three methods (for example, shop):
      #   shop - getter
      #   shop= - setter
      #   shop? - predicate
      def generate_attribute_methods(*attributes)
        Array.wrap(attributes).each do |attribute|
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
      attr_accessor :currency
    end
  end
end