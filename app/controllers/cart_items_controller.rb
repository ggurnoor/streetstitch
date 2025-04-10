class CartItemsController < ApplicationController
  before_action :authenticate_user!

  def create
    product = Product.find(params[:product_id])
    cart = current_user.cart || current_user.create_cart

    cart_item = cart.cart_items.find_or_initialize_by(product_id: product.id)
    cart_item.quantity = (cart_item.quantity || 0) + 1
    cart_item.save

    redirect_to cart_path, notice: "Added to cart"
  end

  def update
    cart_item = current_user.cart.cart_items.find(params[:id])
    cart_item.update(quantity: params[:cart_item][:quantity])
    redirect_to cart_path, notice: "Quantity updated"
  end

  def destroy
    cart_item = current_user.cart.cart_items.find(params[:id])
    cart_item.destroy
    redirect_to cart_path, notice: "Item removed from cart"
  end
end
