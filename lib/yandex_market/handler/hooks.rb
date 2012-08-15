module YandexMarket
  module Handler
    # Almost like ActiveSupport::Callbacks but 76,6% less complex.
    #
    # Example:
    #
    #   class CatWidget < Apotomo::Widget
    #     define_hooks :before_dinner, :after_dinner
    #
    # Now you can add callbacks to your hook declaratively in your class.
    #
    #     before_dinner :wash_paws
    #     after_dinner { puts "Ice cream!" }
    #     after_dinner :have_a_desert   # => refers to CatWidget#have_a_desert
    #
    # Running the callbacks happens on instances. It will run the block and #have_a_desert from above.
    #
    #   cat.run_hook :after_dinner
    module Hooks
      def self.included(base)
        base.extend ClassMethods

        base.singleton_class.send :attr_accessor, :_hooks
      end

      module ClassMethods
        def define_hooks(*names)
          names.each do |name|
            setup_hook(name)
          end
        end
        alias_method :define_hook, :define_hooks

        def run_hook_for(name, scope, *args)
          callbacks_for_hook(name).each do |callback|
            if callback.kind_of? Symbol
              scope.send(callback, *args)
            else
              scope.instance_exec(*args, &callback)
            end
          end
        end

        # Returns the callbacks for +name+. Handy if you want to run the callbacks yourself, say when
        # they should be executed in another context.
        #
        # Example:
        #
        #   def initialize
        #     self.class.callbacks_for_hook(:after_eight).each do |callback|
        #       instance_exec(self, &callback)
        #     end
        #
        # would run callbacks in the object _instance_ context, passing +self+ as block parameter.
        def callbacks_for_hook(name)
          (_hooks || {})[name.to_s] || []
        end

        private

        def setup_hook(name)
          define_singleton_method name do |method=nil, &block|
            self._hooks ||= {}
            _hooks[name.to_s] ||= []
            _hooks[name.to_s] << (block || method)
          end

          #instance_eval <<-RUBY_EVAL, __FILE__, __LINE__ + 1
          #  def #{name}(method=nil, &block)
          #    self._hooks ||= {}
          #    _hooks[#{name.to_s.inspect}] ||= []
          #    _hooks[#{name.to_s.inspect}] << (block || method)
          #  end
          #RUBY_EVAL
        end
      end

      # Runs the callbacks (method/block) for the specified hook +name+. Additional arguments will
      # be passed to the callback.
      #
      # Example:
      #
      #   cat.run_hook :after_dinner, "i want ice cream!"
      #
      # will invoke the callbacks like
      #
      #   desert("i want ice cream!")
      #   block.call("i want ice cream!")
      def run_hook(name, *args)
        self.class.run_hook_for(name, self, *args)
      end

      def run_hooks(name, *args)
        run_hook "before_#{name}", *args
        result = yield
        run_hook "after_#{name}", *args

        result
      end
    end
  end
end