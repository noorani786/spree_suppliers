module Spree
  class InvoiceItem < ActiveRecord::Base
    attr_accessible :product_id, :quantity, :line_item_id
    
    belongs_to :supplier_invoice
    belongs_to :line_item
  end
end
