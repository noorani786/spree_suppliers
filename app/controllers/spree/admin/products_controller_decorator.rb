module Spree
  Spree::Admin::ProductsController.class_eval do
    before_filter :load
    before_filter :load_index, :only => [:index]
    before_filter :edit_before, :only => [:edit]
    create.before :create_before
    create.fails :reset
    update.before :update_taxons
    new_action.before :new_action_before

    def load
      @suppliers = Supplier.find(:all, :order => "name")
      @options = Taxon.all
    end

    def load_index
      if try_spree_current_user.has_spree_role? "vendor"
        @collection.select! {|c| c.supplier_id == spree_current_user.supplier.id}
      end
    end

    #indicate that we want to create a new product
    def new_action_before
      @status = true
      @suppliers = Supplier.all
    end

    def edit_before
      @suppliers = Supplier.all
      @status = false
    end

    def taxon_push object
      object.taxons = []
      Taxon.all.map {|m| object.taxons.push(Taxon.find_by_id(params[m.name])) if params.member?(m.name)}
      return object
    end

    def reset
      @status = true
    end

    def update_taxons
      @object = taxon_push(@object)
    end

    def create_before
      if spree_current_user.has_spree_role?("vendor")
        @object = current_user.supplier.products.build(params[:product])
      else
        @object = Product.new(params[:product])
      end
      @object = taxon_push(@object)
    end

    def publish
      p = Product.find_by_name(params[:id])
      p.available_on = Date.today
      p.save
      redirect_to edit_admin_product_path(p)
    end

    def unpublish
      p = Product.find_by_name(params[:id])
      p.available_on = nil
      p.save
      redirect_to edit_admin_product_path(p)
    end
  end
end