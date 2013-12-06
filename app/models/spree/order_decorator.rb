module Spree
  Spree::Order.class_eval do
    has_many :supplier_invoices
    
    def suppliers
      @suppliers ||= line_items.collect { |li| li.product.supplier }.uniq
    end
    
    def supplier_invoice(supplier_id)
      return supplier_invoices.select { |si| si.supplier_id == supplier_id }.first unless supplier_invoices.empty?  
      invoice = SupplierInvoice.new(order_id: self.id, supplier_id: supplier_id)
      supplier_items = line_items.select { |li| li.product.supplier_id == supplier_id }
      supplier_items.each do |item|
        invoice.invoice_items.new(product_id: item.product.id, quantity: item.quantity, line_item_id: item.id)
      end
      invoice.invoice_total = invoice.item_total + invoice.additional_fees[:amount] + invoice.shipping_fees
      invoice
    end
    
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
        invoice.update_attributes(:invoice_total => item_total + invoice.additional_fees[:amount] + invoice.shipping_fees)
        @invoice = invoice
        #SupplierMailer.invoice_email(@invoice).deliver
      end
    end
    
    def invoice_total
      supplier_invoices.reduce(0) { |sum, i| sum + i.invoice_total }
    end
    
    alias_method :orig_finalize, :finalize!
    def finalize!
      orig_finalize

      # generate the invoices for each supplier
      generate_invoices(self)
    end
    
    def additional_fees
      supplier_invoices.reduce(0) { |sum, i| sum + i.additional_fees[:amount] }
    end
  end
end