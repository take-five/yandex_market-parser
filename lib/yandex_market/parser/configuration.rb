require "set"
require "active_support/core_ext/array/wrap"
require "active_support/core_ext/hash/keys"
require "active_support/core_ext/hash/deep_merge"
require "active_support/core_ext/object/duplicable"

module YandexMarket
  # Parser configuration
  # == Example
  #   cnf = Parser::Configuration.new
  #   cnf.shop do |s|
  #     s.xpath '@id' => :id
  #   end
  #
  #   cnf.shop # => Parser::Configuration::Section instance
  class Parser::Configuration
    # A concrete section configuration
    class Section
      attr_reader :map,        # attributes map (xpath => attr)
                  :attributes, # which attributes shall be collected within section
                  :converters  # map of converters

      attr_accessor :node # XML node name for section
      alias_method :node_name, :node=

      def initialize
        reset
      end

      def initialize_copy(other)
        super

        reset

        instance_variables.each do |ivar|
          was = other.instance_variable_get(ivar)
          was = was.duplicable? && !was.is_a?(Class) ? was.clone : was

          instance_variable_set ivar, was
        end

        # flush @klass anyway
        @klass = nil
      end

      # Specify base class for instantiated classes
      def base_class(klass = nil)
        if klass
          raise TypeError, "Class(YandexMarket::Model) expected" unless
              klass.is_a?(Class) && klass < YandexMarket::Model

          @base_class = klass
        else
          @base_class
        end
      end

      # Specify a concrete class for mapped objects
      # Warning: using of +instantiate+ and inheritance causes unknown problems
      def instantiate(klass)
        raise TypeError, 'Class(YandexMarket::Model) expected' unless
            klass.is_a?(Class) && klass < YandexMarket::Model

        @instantiate = klass
      end

      # Define an xpath mapping
      # == Example
      #   xpath '@id' => :id, 'company' => :company
      def xpath(map)
        raise ArgumentError, 'Hash expected' unless map.is_a?(Hash)

        # stringify keys and values
        map = Hash[map.collect { |k, v| [k.to_s, v.to_s] }]

        @map.deep_merge!(map)
      end

      # Define an +attributes+ that should be collected within section
      def collect(*attributes)
        Array.wrap(attributes).flatten.each do |attr|
          assert_valid_attribute! attr

          @attributes << attr.to_s
        end
      end

      # Returns true when all of +attributes+ are collected within section
      def collect?(*attributes)
        Array.wrap(attributes).flatten.all? do |attr|
          @attributes.include?(attr.to_s)
        end
      end

      # Define list of +attributes+ that should not be collected within section
      def skip(*attributes)
        attributes = Array.wrap(attributes).flatten.map(&:to_s)
        @attributes.subtract(attributes)
      end

      # Define a converter (transformer) for certain +attributes+
      # == Example
      #   convert   :date, :with => DateTime
      #   treat     :date, :as => DateTime
      #   transform :date, :to => DateTime
      def convert(*attributes, converter)
        converter = converter.values_at(:with, :as, :to).compact.first if converter.is_a?(Hash)

        Array.wrap(attributes).flatten.each do |attr|
          assert_valid_attribute! attr

          @converters[attr.to_s] = converter
        end
      end
      alias_method :treat, :convert
      alias_method :transform, :convert

      # Extend sections with +extension+ or +block+
      def extend(extension=nil, &block)
        extension ||= block

        @extensions << extension
      end

      # Define a relation to another section
      #
      # == Example
      #   relate :currencies, :to => 'currencies/currency', :as => configuration.currencies
      def relate(name, options)
        to, as = options.values_at(:to, :as)

        raise TypeError, 'Section class expected' unless as.is_a?(self.class)

        @relations[name.to_s] = [to, as]
      end

      # Reset xpath mapping and collected attributes
      def reset
        @node = ''
        @map = {}
        @converters = {}
        @attributes = Set.new
        @extensions = []
        @relations  = {}
        @base_class = YandexMarket::Model
        @instantiate = nil
      end

      # Build or retrieve SAX Node class
      def klass
        @klass ||= instantiate_class
      end

      private
      def assert_valid_attribute!(attr) #:nodoc:
        raise ArgumentError,
              "Unknown attribute #{attr}, define it with +xpath+ method" unless @map.values.include?(attr.to_s)
      end

      def instantiate_class #:nodoc:
        klass = @instantiate || Class.new(@base_class)
        klass.node @node

        # apply mappings
        @map.each_pair do |xpath, attribute|
          if collect?(attribute)
            klass.map attribute.to_sym, :to => xpath, :as => @converters[attribute]
          end
        end
        klass.generate_attribute_methods *@attributes

        # apply relations
        @relations.each_pair do |attribute, relation|
          to, as = relation
          klass.relate attribute.to_sym, :to => to, :as => as.klass
        end

        # apply extensions
        @extensions.each do |ext|
          ext.is_a?(Module) ?
            klass.send(:include, ext) :
            klass.class_eval(&ext)
        end

        klass
      end
    end

    attr_reader :sections

    def initialize
      reset
    end

    def initialize_copy(other)
      super

      reset

      other.sections.each_pair do |key, value|
        @sections[key] = value.clone
      end
      @handler = other.handler.clone if other.handler.duplicable?
    end

    # generate accessor methods for common sections
    %w(catalog shop categories currencies offers).each do |section|
      class_eval <<-CODE, __FILE__, __LINE__ + 1
        def #{section}                            # def shop
          @sections[:#{section}].tap do |section| #   @sections[:shop].tap do |section|
            yield(section) if block_given?        #     yield(section) if block_given?
          end                                     #   end
        end                                       # end
      CODE
    end

    # Get or set object handler (must be successor of YandexMarket::Handler::Base)
    # == Example
    #   configuration.handler YandexMarket::Handler::Base
    def handler(handler = nil)
      if handler
        raise TypeError, "YandexMarket::Handler::Base expected, #{handler.class} given instead" unless
            handler.is_a?(Class) && handler <= YandexMarket::Handler::Base

        @handler = handler
      else
        @handler
      end
    end

    private
    def reset
      @sections = Hash.new { |hash, key| hash[key] = Section.new }
    end
  end
end