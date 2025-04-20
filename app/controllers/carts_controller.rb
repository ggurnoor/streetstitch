require 'ostruct'

class CartsController < ApplicationController
  def show
    session[:cart] ||= {}

    @cart_items = session[:cart].map do |product_id, quantity|
      product = Product.find_by(id: product_id)
      OpenStruct.new(product: product, quantity: quantity.to_i) if product
    end.compact

    @subtotal = @cart_items.sum { |item| item.product.price * item.quantity }

    if user_signed_in? && current_user.province
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
