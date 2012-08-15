require "active_support/core_ext/object/duplicable"

module YandexMarket
  module Parser
    module Configurable
      def configuration
        @configuration ||= Configuration.new
      end
      alias_method :configure, :configuration

      def inherited(subclass)
        subclass.instance_variable_set :@configuration, @configuration.clone if @configuration.duplicable?
      end

      module InstanceMethods
        def configuration
          self.class.configuration
        end
      end # module InstanceMethods
    end # module Configurable
  end # module Parser
end # module YandexMarket