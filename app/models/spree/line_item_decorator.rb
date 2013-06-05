module Spree
  Spree::LineItem.class_eval do
    has_many :invoice_items
  end
end