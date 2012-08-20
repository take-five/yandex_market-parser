module YandexMarket
  module Parser
    module Configurable
      def configuration
        @configuration ||= Configuration.new
      end
      alias_method :configure, :configuration

      def inherited(subclass)
        subclass.instance_variable_set :@configuration, @configuration.clone
      rescue TypeError
        # ignore error "can't clone NilClass"
      end

      module InstanceMethods
        def configuration
          self.class.configuration
        end
      end # module InstanceMethods
    end # module Configurable
  end # module Parser
end # module YandexMarket