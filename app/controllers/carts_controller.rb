class CartsController < ApplicationController
  before_action :authenticate_user!

  def show
    @cart = current_user.cart || current_user.create_cart
    @cart_items = @cart.cart_items.includes(:product)

    @subtotal = @cart_items.sum { |item| item.product.price * item.quantity }

    if current_user.province
      pst = current_user.province.pst || 0
      gst = current_user.province.gst || 0
      hst = current_user.province.hst || 0
    else
      pst = gst = hst = 0
    end

    @taxes = {
      pst: (@subtotal * pst).round(2),
      gst: (@subtotal * gst).round(2),
      hst: (@subtotal * hst).round(2)
    }

    @total = @subtotal + @taxes.values.sum
  end
end
