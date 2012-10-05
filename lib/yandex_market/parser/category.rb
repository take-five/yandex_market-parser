module YandexMarket
  module Parser
    # Category parser.
    class Category < Base

      configure.categories do |c|
        c.collect :id, :parent_id, :title
      end
    end
  end
end