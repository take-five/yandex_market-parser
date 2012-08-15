module YandexMarket
  module Handler
    extend ActiveSupport::Autoload

    autoload :CurrencyCollector
    autoload :Hooks
    autoload :Naive
    autoload :Stats

    # Abstract handler, dispatches objects to proper methods, defines callback-methods
    class Base
      include YandexMarket::Handler::Hooks

      NODE_TYPES = :catalog, :shop, :currency, :category, :offer

      define_hooks :before_parse, :after_parse
      # create hooks like before_shop, after_shop, before_offer, after_offer
      define_hooks *%w(before after).product(NODE_TYPES).map { |*a| a.join('_').to_sym }

      # Dispatches +object+ to proper method
      def <<(object)
        dispatcher[object.class].call(object)
      end

      protected
      def catalog o
        raise NotImplementedError
      end

      def shop o
        raise NotImplementedError
      end

      def currency o
        raise NotImplementedError
      end

      def category o
        raise NotImplementedError
      end

      def offer o
        raise NotImplementedError
      end

      private
      # syntax sugar :)
      def process_yml_catalog(o) #:nodoc:
        process_catalog(o)
      end

      # generate process methods
      NODE_TYPES.each do |type|
        class_eval <<-CODE, __FILE__, __LINE__ + 1
          def process_#{type}(o)        # def process_shop(o)
            run_hooks :#{type}, o do    #   run_hooks :shop, o do
              #{type}(o)                #     shop(o)
            end                         #   end
          end                           # end
        CODE
      end

      def dispatcher #:nodoc:
        @dispatcher ||= Hash.new do |hash, klass|
          hash[klass] = method("process_#{klass.node_name}".intern)
        end
      end # def dispatcher
    end # class Base
  end # module Handler
end # module YandexMarket