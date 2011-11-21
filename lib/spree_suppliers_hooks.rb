class SuppliersHooks < Spree::ThemeSupport::HookListener
  insert_after :admin_tabs do
    %(<%= tab(:suppliers) %>)
  end

  # insert_after :admin_order_tabs do
  #   %(<%= tab(:order_line_items) %>)
  # end

  # insert_after :admin_product_tabs do
  #   %(<%= tab(:selected_admin_productor_vendors_url) %>)
  # end
  insert_after :admin_product_form_right ,"admin/products/suppliers_form"
  
  insert_after :admin_configuration_menu do
    %(<tr><td><%= link_to t("Suppliers"), admin_suppliers_url %><td><td><%= t("Suppliers_description") %></td></tr>)
  end

  # Add on_hand field to admin/products listing
  insert_after :admin_products_index_headers do
    %(<th><%= sort_link @search, :count_on_hand, t("count_on_hand") %></th>)
  end

  insert_after :admin_tabs do
    %(<%= tab(:pickups) %>)
  end

  insert_after :admin_products_index_rows do
    %(<td><%= product.count_on_hand %></td>)
  end

end