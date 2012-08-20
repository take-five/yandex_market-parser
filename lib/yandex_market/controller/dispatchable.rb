require "hooks"

module YandexMarket
  module Controller
    class DispatchError < StandardError; end

    # Add dispatch ability to base class
    #
    # == Usage
    #   class MyController
    #     extend Dispatchable
    #
    #     dispatch do |d|
    #       d.property 'node_name.to_s'
    #       d.property :node_name
    #       d.property proc { |o| o.node_name }
    #
    #       d.route 'yml_catalog' => :catalog,
    #               'shop' => :shop
    #     end
    #   end
    module Dispatchable
      # Inheritance hook
      def inherited(subclass) #:nodoc:
        super

        subclass.instance_variable_set :@dispatcher, @dispatcher.clone
      end

      def self.extended(base)
        base.class_eval do
          include Hooks
          include InstanceMethods
        end
      end

      # Retrieve dispatcher instance and optionally execute block with it
      def dispatcher
        @dispatcher ||= Dispatcher.new

        if block_given?
          yield @dispatcher

          @dispatcher.inject(self)
        end

        @dispatcher
      end
      alias dispatch dispatcher

      module InstanceMethods #:nodoc:all:
        def run_hooks(name, *args)
          run_hook "before_#{name}", *args
          result = yield
          run_hook "after_#{name}", *args

          result
        end
      end

      # Method dispatcher
      class Dispatcher #:nodoc:all:
        attr_reader :routes

        def initialize
          @routes = {}
          @property = proc { }
        end

        def initialize_copy(other)
          super

          other.instance_variables.each do |ivar|
            other_value = other.instance_variable_get(ivar)
            instance_variable_set(ivar, (other_value.clone rescue other_value))
          end
        end

        def property(value = nil)
          if value
            @property = value
          else
            @property
          end
        end

        def route(hash)
          @routes.merge! hash
        end

        def inject(klass)
          klass.send(:remove_method, :dispatch) rescue nil

          klass.class_eval <<-CODE, __FILE__, __LINE__ + 1
            # create hooks like +before_shop+, +after_shop+
            %w(before after).product(#{@routes.values.inspect}).map { |*a| a.join('_').to_sym }.each do |name|
              define_hook name unless respond_to?("_\#{name}_callbacks")
            end

            def dispatch(object)
              property  = #{compile_property}
              method_id = self.class.dispatcher.routes[property]
              case property
                #{@routes.map { |k, v| "when #{k.inspect} then run_hooks(:#{v}, object) { #{v}(object) }" }.join("\n")}
                else raise YandexMarket::Controller::DispatchError, "Cannot dispatch object \#{object}" unless method_id
              end
            end
          CODE
        end

        private
        def compile_property
          case @property
            when String then "object.instance_eval{ #@property }"
            when Symbol then "object.#@property"
            when Proc   then "self.class.dispatcher.property[object]"
            else raise TypeError, 'Property must be String, Symbol or Proc'
          end
        end
      end # class Dispatcher
    end # module Dispatchable
  end # module Controller
end # module YandexMarket