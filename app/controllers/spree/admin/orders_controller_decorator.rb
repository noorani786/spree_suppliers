module Spree
  Spree::Admin::OrdersController.class_eval do
    
    def show
      load_order
      # optional fee that admin can charge to sell suppliers products for them
      @fee = 0.10
      if spree_current_user.has_spree_role?("vendor")
        @invoices = @order.supplier_invoices
        @invoices.select! {|s| s.supplier_id == current_user.supplier.id}
      else
        @invoices = @order.supplier_invoices
      end
      respond_with(@order)
    end
    
    alias_method :orig_index, :index
    def index
      orig_index
      if spree_current_user.has_spree_role?("vendor")
        @orders.select! {|o| o.supplier_invoices.select {|s| s.supplier_id == current_user.supplier.id}.size > 0}
      end
      respond_with(@orders)
    end
  end
end