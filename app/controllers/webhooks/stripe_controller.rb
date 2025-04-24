module Webhooks
  class StripeController < ApplicationController
    skip_before_action :verify_authenticity_token

    def receive
      payload = request.body.read
      sig_header = request.env['HTTP_STRIPE_SIGNATURE']
      endpoint_secret = ENV['STRIPE_WEBHOOK_SECRET']

      begin
        event = Stripe::Webhook.construct_event(payload, sig_header, endpoint_secret)
      rescue JSON::ParserError => e
        render json: { error: 'Invalid payload' }, status: 400 and return
      rescue Stripe::SignatureVerificationError => e
        render json: { error: 'Invalid signature' }, status: 400 and return
      end

      if event['type'] == 'checkout.session.completed'
        session = event['data']['object']
        order_id = session['metadata']['order_id']
        order = Order.find_by(id: order_id)

        if order && order.pending?
          order.update!(
            status: :paid,
            stripe_payment_id: session['payment_intent']
          )
        end
      end

      render json: { message: 'success' }, status: 200
    end
  end
end