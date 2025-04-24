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

    preview_data = session[:preview_address]
    Rails.logger.debug "Session preview address: #{preview_data.inspect}"

    if preview_data.nil?
      return redirect_to checkout_path, alert: "Missing address data. Please try again."
    end

    cleaned_data = preview_data.except("id", "created_at", "updated_at")

    address = user_signed_in? ? (current_user.address || current_user.build_address) : Address.new
    address.assign_attributes(cleaned_data)
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
        province_id: address.province_id,
        status: ''
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
      session[:preview_address] = nil

      redirect_to order_path(order), notice: "Order created! Now proceed to payment."
    else
      flash[:alert] = "Failed to save address: #{address.errors.full_messages.join(', ')}"
      redirect_to checkout_path
    end
  end

  def stripe_checkout
    order = Order.find(params[:id])

    session = Stripe::Checkout::Session.create(
      payment_method_types: ['card'],
      line_items: order.order_items.map do |item|
        {
          price_data: {
            currency: 'cad',
            product_data: {
              name: item.product.name
            },
            unit_amount: (item.price * 100).to_i
          },
          quantity: item.quantity
        }
      end,
      mode: 'payment',
      success_url: "#{root_url}orders/#{order.id}?payment=success",
      cancel_url: "#{root_url}orders/#{order.id}?payment=cancelled"
    )

    order.update(stripe_session_id: session.id)
    redirect_to session.url, allow_other_host: true
  end

  def show
    @order = user_signed_in? ? current_user.orders.find(params[:id]) : Order.find(params[:id])
  end

  def index
    if user_signed_in?
      @orders = current_user.orders.includes(order_items: :product).order(created_at: :desc).page(params[:page]).per(5)
    else
      redirect_to new_user_session_path, alert: "Please log in to view your orders."
    end
  end

  def stripe_checkout
    @order = user_signed_in? ? current_user.orders.find(params[:id]) : Order.find(params[:id])

    if @order.status != "pending"
      redirect_to order_path(@order), alert: "Order is already paid or invalid." and return
    end

    session = Stripe::Checkout::Session.create({
      payment_method_types: ['card'],
      line_items: @order.order_items.map do |item|
        {
          price_data: {
            currency: 'cad',
            product_data: {
              name: item.product.name
            },
            unit_amount: (item.price * 100).to_i
          },
          quantity: item.quantity
        }
      end,
      mode: 'payment',
      success_url: order_url(@order),
      cancel_url: order_url(@order),
      metadata: {
        order_id: @order.id
      }
    })

    @order.update!(stripe_session_id: session.id)
    redirect_to session.url, allow_other_host: true
  end


  def preview
    @cart_items = session_cart_items
    return redirect_to cart_path, alert: "Cart is empty" if @cart_items.empty?

    @address = Address.new(address_params)
    @address.user = current_user if user_signed_in?

    unless @address.valid?
      flash.now[:alert] = "Please fill in all required fields."
      return render :new, status: :unprocessable_entity
    end

    province = Province.find_by(id: @address.province_id)
    subtotal = @cart_items.sum { |item| item.product.price * item.quantity }

    @invoice = OpenStruct.new(
      address: "#{@address.street}, #{@address.city}, #{@address.postal_code}",
      province_id: @address.province_id,
      province: province&.name,
      subtotal: subtotal.round(2),
      pst: (subtotal * province&.pst.to_f).round(2),
      gst: (subtotal * province&.gst.to_f).round(2),
      hst: (subtotal * province&.hst.to_f).round(2),
      total: (subtotal * (1 + province&.pst.to_f + province&.gst.to_f + province&.hst.to_f)).round(2)
    )

    session[:preview_address] = @address.attributes
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
    params.fetch(:address, {}).permit(:street, :city, :postal_code, :province_id)
  end
end
