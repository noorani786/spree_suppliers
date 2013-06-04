require 'spree_core'
require 'spree_suppliers/engine'

module SpreeSuppliers
  class Engine < Rails::Engine
    config.autoload_paths += %W(#{config.root}/lib)
    def self.activate

      Spree::LineItem.class_eval do
        has_many :invoice_items
      end

      Spree::Image.class_eval do
        belongs_to :supplier
      end

      Spree::Admin::OrdersController.class_eval do
        def show
          load_order
          # optional fee that admin can charge to sell suppliers products for them
          @fee = 0.10
          if current_user.has_role?("vendor")
            @invoices = @order.supplier_invoices
            @invoices.select! {|s| s.supplier_id == current_user.supplier.id}
          else
            @invoices = @order.supplier_invoices
          end
          respond_with(@order)
        end

        def index
          params[:search] ||= {}
          params[:search][:completed_at_is_not_null] ||= '1' if Spree::Config[:show_only_complete_orders_by_default]
          @show_only_completed = params[:search][:completed_at_is_not_null].present?
          params[:search][:meta_sort] ||= @show_only_completed ? 'completed_at.desc' : 'created_at.desc'

          @search = Order.metasearch(params[:search])

          if !params[:search][:created_at_greater_than].blank?
            params[:search][:created_at_greater_than] = Time.zone.parse(params[:search][:created_at_greater_than]).beginning_of_day rescue ""
          end

          if !params[:search][:created_at_less_than].blank?
            params[:search][:created_at_less_than] = Time.zone.parse(params[:search][:created_at_less_than]).end_of_day rescue ""
          end

          if @show_only_completed
            params[:search][:completed_at_greater_than] = params[:search].delete(:created_at_greater_than)
            params[:search][:completed_at_less_than] = params[:search].delete(:created_at_less_than)
          end

          @orders = Order.metasearch(params[:search]).includes([:user, :shipments, :payments]).page(params[:page]).per(Spree::Config[:orders_per_page])

          if current_user.has_role?("vendor")
            @orders.select! {|o| o.supplier_invoices.select {|s| s.supplier_id == current_user.supplier.id}.size > 0}
          end
          respond_with(@orders)
        end
      end

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

        def finalize!
          update_attribute(:completed_at, Time.now)
          InventoryUnit.assign_opening_inventory(self)
          # lock any optional adjustments (coupon promotions, etc.)
          adjustments.optional.each { |adjustment| adjustment.update_attribute('locked', true) }
          # generate the invoices for each supplier
          generate_invoices(self)
          #OrderMailer.confirm_email(self).deliver

          self.state_events.create({
            :previous_state => 'cart',
            :next_state => 'complete',
            :name => 'order' ,
            :user_id => (User.respond_to?(:current) && User.current.try(:id)) || self.user_id
          })
        end
      end

      Spree::Product.class_eval do
        belongs_to :supplier
      end

      Spree::Taxon.class_eval do
        has_and_belongs_to_many :suppliers
      end

      Spree::User.class_eval do
        has_one :supplier
      end

    end
    config.to_prepare &method(:activate).to_proc
  end
end

