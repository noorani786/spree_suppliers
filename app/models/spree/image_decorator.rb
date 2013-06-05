module Spree
  Spree::Image.class_eval do
    belongs_to :supplier
  end
end