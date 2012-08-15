module YandexMarket
  module Parser
    # Minimal parser. Collects only offers: id, availability and price
    class Minimal < Base
      configure.catalog do |c|
        c.collect :date
      end

      configure.currencies do |c|
        c.collect :id
      end

      configure.offers do |c|
        c.collect :id, :price, :available, :currency_id
      end
    end
  end
end