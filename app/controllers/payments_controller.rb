class PaymentsController < ApplicationController
  def fake_confirm
    order = Order.find(params[:order_id])
    order.update(status: 'paid') # ✅ mark as paid

    redirect_to order_path(order), notice: "Payment successful! Order marked as paid."
  end
end
