module Spree
  class Supplier < ActiveRecord::Base
    
    attr_accessible :title, :notes, :phone, :fax, :email, :facebook, :twitter, :website, :name, :images_attributes
    
    validates :title, presence: true
    validates :phone, presence: true
    validates :email, presence: true
    validates :name, presence: true
    
    has_many :images, :as => :viewable, :order => :position, :dependent => :destroy
    accepts_nested_attributes_for :images
    belongs_to :user
    has_many :supplier_invoices
    has_and_belongs_to_many :taxons, join_table: :spree_suppliers_taxons
    has_many :products
  end
end
