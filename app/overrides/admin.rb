Deface::Override.new(:virtual_path => "spree/layouts/admin",
                     :name => "suppliers_tabs",
                     :insert_bottom => "[data-hook='admin_tabs'], #admin_tabs[data-hook]",
                     :text => "<%= tab(:suppliers) %>")

Deface::Override.new(:virtual_path => "spree/admin/products/_form",
                     :name => "add_suppliers_to_admin_products_edit",
                     :insert_bottom => "[data-hook='admin_product_form_left']",
                     :text => "
                      <%= f.field_container :supplier do %>
                        <%= f.label :supplier_id, Spree.t(:suppliers) %>
                        <%= f.collection_select(:supplier_id, @suppliers, :id, :title, { :include_blank => true }, { :class => 'select2' }) %>
                        <%= f.error_message_on :supplier %>
                      <% end %>")

Deface::Override.new(:virtual_path => "spree/products/show",
  :name => "add_supplier_products_show",
  :insert_before => "code[erb-loud]:contains(\"render :partial => 'taxons'\")",
  :partial => "spree/products/supplier"
)
