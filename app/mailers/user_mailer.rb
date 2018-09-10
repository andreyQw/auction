# frozen_string_literal: true

class UserMailer < ApplicationMailer
  def email_for_lot_winner(lot)
    @lot = lot.reload
    bid = Bid.find(lot.bid_win)
    @customer = bid.user
    mail(to: @customer.email, subject: "email_for_lot_winner")
  end

  def email_for_seller_lot_closed(lot)
    @lot = lot
    @seller = lot.user
    mail(to: @seller.email, subject: "email_for_seller_lot_closed")
  end

  def email_for_seller_lot_not_sold(lot)
    @lot = lot
    @seller = lot.user
    mail(to: @seller.email, subject: "email_for_seller_lot_not_sold")
  end

  def email_for_seller_order_was_created(order)
    @lot = order.lot
    @seller = order.lot.user
    mail(to: @seller.email, subject: "email_for_seller_order_was_created")
  end

  def email_for_customer_lot_was_sent(order)
    @lot = order.lot
    @customer = User.find(@lot.user_win_id)
    mail(to: @customer.email, subject: "email_for_customer_lot_was_sent")
  end

  def email_after_delivered_to_seller(order)
    @lot = order.lot
    @seller = order.lot.user
    mail(to: @seller.email, subject: "email_after_delivered", template_name: "email_after_delivered")
  end

  def email_after_delivered_to_customer(order)
    @lot = order.lot
    @customer = @lot.winner
    mail(to: @customer.email, subject: "email_after_delivered", template_name: "email_after_delivered")
  end
end
