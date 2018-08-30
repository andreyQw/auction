# frozen_string_literal: true

class UserMailer < ApplicationMailer
  def email_for_lot_winner(lot)
    @lot = lot
    bid = Bid.find(lot.bid_win)
    @customer = bid.user
    mail(to: @customer.email, subject: "email_for_lot_winner")
  end

  def email_for_seller_lot_closed(lot)
    @lot = lot
    @seller = lot.user
    mail(to: @seller.email, subject: "email_for_seller_lot_closed")
  end
end
