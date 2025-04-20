require 'ostruct'

class CartItemsController < ApplicationController
  def create
    session[:cart] ||= {}
    product_id = params[:product_id].to_s
    session[:cart][product_id] ||= 0
    session[:cart][product_id] += 1

    redirect_to cart_path, notice: "Added to cart"
  end

  def update
    session[:cart] ||= {}
    product_id = params[:id].to_s
    quantity = params[:cart_item][:quantity].to_i
    session[:cart][product_id] = quantity if quantity > 0

    redirect_to cart_path, notice: "Quantity updated"
  end

  def destroy
    session[:cart] ||= {}
    session[:cart].delete(params[:id].to_s)

    redirect_to cart_path, notice: "Item removed from cart"
  end
end
