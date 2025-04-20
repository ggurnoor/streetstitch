require 'ostruct'

class OrdersController < ApplicationController
  skip_before_action :verify_authenticity_token

  def new
    @cart_items = session_cart_items
    if @cart_items.empty?
      redirect_to cart_path, alert: "Cart is empty" and return
    end

    @address = Address.new
  end

  def create
    @cart_items = session_cart_items
    return redirect_to cart_path, alert: "Cart is empty" if @cart_items.empty?

    address = user_signed_in? ? (current_user.address || current_user.build_address) : Address.new
    address.assign_attributes(address_params)
    address.user = current_user if user_signed_in?

    if address.save
      province = Province.find_by(id: address.province_id)
      pst = province&.pst || 0
      gst = province&.gst || 0
      hst = province&.hst || 0

      subtotal = @cart_items.sum { |item| item.product.price * item.quantity }

      order_attrs = {
        subtotal: subtotal.round(2),
        pst: (subtotal * pst).round(2),
        gst: (subtotal * gst).round(2),
        hst: (subtotal * hst).round(2),
        total: (subtotal * (1 + pst + gst + hst)).round(2),
        address: "#{address.street}, #{address.city}, #{address.postal_code}",
        province_id: address.province_id
      }

      order = user_signed_in? ? current_user.orders.create!(order_attrs) : Order.create!(order_attrs)

      @cart_items.each do |item|
        order.order_items.create!(
          product: item.product,
          quantity: item.quantity,
          price: item.product.price
        )
      end

      session[:cart] = {}
      redirect_to order_path(order), notice: "Order placed successfully!"
    else
      flash[:alert] = "Failed to save address: #{address.errors.full_messages.join(', ')}"
      redirect_to checkout_path
    end
  end

  def show
    @order = user_signed_in? ? current_user.orders.find(params[:id]) : Order.find(params[:id])
  end

  def index
    if user_signed_in?
      @orders = current_user.orders.includes(order_items: :product)
    else
      redirect_to new_user_session_path, alert: "Please log in to view your orders."
    end
  end

  private

  def session_cart_items
    session[:cart] ||= {}
    session[:cart].map do |product_id, quantity|
      product = Product.find_by(id: product_id)
      OpenStruct.new(product: product, quantity: quantity.to_i) if product
    end.compact
  end

  def address_params
    params.require(:address).permit(:street, :city, :postal_code, :province_id)
  end
end
