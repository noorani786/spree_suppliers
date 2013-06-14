module Spree
  class SupplierInvoice < ActiveRecord::Base
    attr_accessible :order_id, :supplier_id, :item_count
    
    belongs_to :supplier
    has_many :invoice_items
  end
end