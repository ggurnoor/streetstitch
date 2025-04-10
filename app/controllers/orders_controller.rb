class OrdersController < ApplicationController
  before_action :authenticate_user!

  def new
    @cart_items = current_user.cart.cart_items.includes(:product)

    if @cart_items.empty?
      redirect_to cart_path, alert: "Cart is empty"
    else
      @address = current_user.address || Address.new
    end
  end

  def create
    Rails.logger.debug "👉 ORDERS CREATE PARAMS: #{params.inspect}"

    @cart_items = current_user.cart.cart_items.includes(:product)
    return redirect_to cart_path, alert: "Cart is empty" if @cart_items.empty?

    # Save or update address
    address = current_user.address || current_user.build_address
    if address.update(address_params)
      # Tax calculations
      subtotal = @cart_items.sum { |item| item.product.price * item.quantity }
      pst = current_user.province&.pst || 0
      gst = current_user.province&.gst || 0
      hst = current_user.province&.hst || 0

      order = current_user.orders.create!(
        subtotal: subtotal.round(2),
        pst: (subtotal * pst).round(2),
        gst: (subtotal * gst).round(2),
        hst: (subtotal * hst).round(2),
        total: (subtotal * (1 + pst + gst + hst)).round(2)
      )

      # Add order items
      @cart_items.each do |item|
        order.order_items.create!(
          product: item.product,
          quantity: item.quantity,
          unit_price: item.product.price
        )
      end

      # Empty cart
      current_user.cart.cart_items.destroy_all

      redirect_to order_path(order), notice: "Order placed successfully!"
    else
      redirect_to checkout_path, alert: "Please check your address details."
    end
  end

  def show
    @order = current_user.orders.find(params[:id])
  end

  private

  def address_params
    if params[:address].present?
      params.require(:address).permit(:street, :city, :postal_code, :province_id)
    else
      {}
    end
  end
end
