ActiveAdmin.register Order do
  includes :user, :order_items, :province

  # ✅ Fix: Allow mass assignment of these fields
  permit_params :user_id, :province_id, :subtotal, :gst, :pst, :hst, :total,
                :address, :status, :stripe_payment_id, :stripe_session_id

  index do
    selectable_column
    id_column
    column("Customer") { |order| order.user&.email || "Guest" }
    column :address
    column("Province") { |order| order.province&.name }
    column("PST") { |order| number_to_currency(order.pst) }
    column("GST") { |order| number_to_currency(order.gst) }
    column("HST") { |order| number_to_currency(order.hst) }
    column("Total") { |order| number_to_currency(order.total) }
    column("Ordered Items") do |order|
      ul do
        order.order_items.each do |item|
          li "#{item.product.name} × #{item.quantity} @ #{number_to_currency(item.price)}"
        end
      end
    end
    actions
  end

  show do
    attributes_table do
      row("Customer") { |order| order.user&.email || "Guest" }
      row :address
      row :province
      row("PST") { number_to_currency(order.pst) }
      row("GST") { number_to_currency(order.gst) }
      row("HST") { number_to_currency(order.hst) }
      row("Total") { number_to_currency(order.total) }
      row("Status") { status_tag(order.status) }
      row("Stripe Payment ID") { order.stripe_payment_id }
    end

    panel "Ordered Products" do
      table_for order.order_items do
        column("Product") { |item| item.product.name }
        column("Quantity") { |item| item.quantity }
        column("Unit Price") { |item| number_to_currency(item.price) }
        column("Line Total") { |item| number_to_currency(item.price * item.quantity) }
      end
    end
  end

  form do |f|
    f.semantic_errors
    f.inputs "Order Details" do
      f.input :user
      f.input :province
      f.input :address
      f.input :subtotal
      f.input :pst
      f.input :gst
      f.input :hst
      f.input :total
      f.input :status, as: :select, collection: Order.statuses.keys
      f.input :stripe_payment_id
      f.input :stripe_session_id
    end
    f.actions
  end
end
