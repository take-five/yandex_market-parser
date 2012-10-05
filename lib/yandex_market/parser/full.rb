module YandexMarket
  module Parser
    # Full parser. Collects categories and all offers attributes
    class Full < Base

      configure.currencies do |c|
        c.collect :id
      end

      configure.categories do |c|
        c.collect :id, :parent_id
      end

      configure.offers do |c|
        c.collect :id, :price, :available, :currency_id, :picture, :type,
                  :url, :category_id, :type_prefix, :vendor, :model, :name,
                  :description, :delivery, :store, :pickup, :vendor_code, :local_delivery_cost,
                  :sales_notes, :manufacturer_warranty, :country_of_origin, :downloadable, :adult,
                  :barcode
      end
    end
  end
end