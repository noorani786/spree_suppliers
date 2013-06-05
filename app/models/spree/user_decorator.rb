module Spree
  Spree::User.class_eval do
    has_one :supplier
  end
end