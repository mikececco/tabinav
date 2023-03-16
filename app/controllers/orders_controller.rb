class OrdersController < ApplicationController

  def show
    @order = current_user.orders.find(params[:id])
  end

  def create
    bookmark = Bookmark.find(params[:bookmark_id])
    order = Order.create!(bookmark_id: bookmark.id, amount: bookmark.route.total_price, state: 'pending', user: current_user)

    session = Stripe::Checkout::Session.create(
      payment_method_types: ['card'],
      line_items: [
        quantity: 1,
        price_data: {
          unit_amount: bookmark.route.total_price.to_i,
          currency: 'eur',
          product_data: {
            name: bookmark.route.destination
          }
        }
      ],
      mode: "payment",
      success_url: "http://localhost:3000/hack?bookmark_id=#{bookmark.id}",#hackhack_path(bookmark_id: bookmark),
      cancel_url: "http://localhost:3000/hack"
    )
    order.update(checkout_session_id: session.id)
    redirect_to new_order_payment_path(order)
  end
end
