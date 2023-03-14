class OrdersController < ApplicationController
  
  def show
    @order = current_user.orders.find(params[:id])
  end

  def create
    teddy = Teddy.find(params[:route_id])
    order = Order.create!(route: route, route_sku: route.sku, amount: route.price, state: 'pending', user: current_user)

    session = Stripe::Checkout::Session.create(
      payment_method_types: ['card'],
      line_items: [{
        name: route.sku,
        # We can't do .photo_url in our app, using unsplash, need to change later
        images: [route.photo_url],
        amount: route.price_cents,
        currency: 'eur',
        quantity: 1
      }],
      success_url: order_url(order),
      cancel_url: order_url(order)
    )

    order.update(checkout_session_id: session.id)
    redirect_to new_order_payment_path(order)
  end
end
