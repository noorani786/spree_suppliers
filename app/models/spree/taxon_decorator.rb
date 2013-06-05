module Spree
  Spree::Taxon.class_eval do
    has_and_belongs_to_many :suppliers, join_table: :spree_suppliers_taxons
  end
end
