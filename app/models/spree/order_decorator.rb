module Spree
  Spree::Order.class_eval do
    has_many :supplier_invoices
    def generate_invoices(order)
      @order = order
      @order_products = @order.line_items
      @suppliers = @order_products.collect{|item| item.product.supplier_id}.uniq
      @invoices = @suppliers.count

      for i in 0..@invoices - 1
        @supplier_products = @order_products.select{|x| x.product.supplier_id == @suppliers[i]}
        @product_count = @supplier_products.count
        invoice = SupplierInvoice.create(:order_id => @order.id, :supplier_id => @suppliers[i], :item_count => @product_count)

        @supplier_products.each do |item|
          invoice.invoice_items.create(:product_id => item.product.id, :quantity => item.quantity, :line_item_id => item.id)
        end

        item_total = "0.00".to_d
        invoice.invoice_items.each do |i|
          item_total = (i.line_item.variant.price * i.quantity) + item_total
        end
        invoice.update_attributes(:invoice_total => item_total)
        @invoice = invoice
        #SupplierMailer.invoice_email(@invoice).deliver
      end
    end
    
    alias_method :orig_finalize, :finalize!
    def finalize!
      orig_finalize

      # generate the invoices for each supplier
      generate_invoices(self)
    end
  end
end