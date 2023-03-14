class OrdersController < ApplicationController

  def show
    @order = current_user.orders.find(params[:id])
  end

  def create
    route = Route.find(params[:route_id])
    order = Order.create!(route: route, amount: 300, state: 'pending', user: current_user)

    session = Stripe::Checkout::Session.create(
      payment_method_types: ['card'],
      line_items: [
        quantity: 1,
        price_data: {
          unit_amount: 300,
          currency: 'eur',
          product_data: {
            name: route.id
          }
        }
      ],
      mode: "payment",
      success_url: "https://2cf1-92-108-209-229.eu.ngrok.io/orders/#{order.id}",
      cancel_url: order_url(order)
    )

    order.update(checkout_session_id: session.id)
    redirect_to new_order_payment_path(order)
  end
end
