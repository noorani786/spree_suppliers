module Spree
  class SupplierInvoice < ActiveRecord::Base
    belongs_to :supplier
    has_many :invoice_items
    attr_accessible :order_id, :supplier_id, :item_count, :invoice_total
    
    def item_total
      invoice_items.map { |i| i.line_item.price * i.quantity }.sum
    end
    
    def additional_fees?
      supplier.title == 'Benco Dental'
    end
    
    def shipping_fees?
      supplier.title == 'Ultradent Products, Inc.' && item_total < 250.00
    end
    
    def shipping_fees
      shipping_fees? ? 8.50 : 0.00
    end
    
    def additional_fees
      benco_desc_html = "Standard Freight/Haz <i class='hint'>(fuel surcharge)</i>"
      benco_desc = "Standard Freight/Haz (fuel surcharge)"
      additional_fees? ? additional_fees_hash(benco_desc, benco_desc_html, 1.32) : additional_fees_hash("", "", 0.0)
    end
    
    private
     
    def additional_fees_hash(desc, desc_html, amount)
      { description: desc_html.html_safe, description_nomarkup: desc, amount: amount }
    end
  end
end