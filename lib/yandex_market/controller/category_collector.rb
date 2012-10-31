module YandexMarket
  module Controller
    # Mixin for controllers, stores categories in inner hash, and maps a category for each offer
    module CategoryCollector
      def self.included(base)
        base.class_eval do
          attr_reader :categories

          after_category :collect_category
          before_offer   :assign_category
        end
      end

      def collect_category category
        @categories ||= {}
        @categories[category.id] = category
      end

      def assign_category offer
        finalize_categories unless @categories_finalized

        if offer.category_id && @categories.key?(offer.category_id)
          offer.category = @categories[offer.category_id]
        end
      end

      private
      def finalize_categories
        @categories.each do |id, category|
          category.parent = @categories[category.parent_id] if
              category.parent_id && category.parent_id > 0 && @categories.has_key?(category.parent_id)
        end
        @categories_finalized = true
      end
    end # module CurrencyCollector
  end # module Controller
end # module YandexMarket