# frozen_string_literal: true

class LotsStatusClosedJob < ApplicationJob
  queue_as :default

  def perform(lot_id)
    lot = Lot.find(get_value(lot_id))
    max_bid = lot.bids.last

    puts "LotsStatusClosedJob: lot_id= #{lot.id} status BEFORE updated = #{ lot.status }"
    if max_bid
      lot.update(status: :closed, bid_win: max_bid.id, user_win_id: max_bid.user_id)
    else
      lot.update(status: :closed)
      UserMailer.email_for_seller_lot_not_sold lot
    end
    puts "LotsStatusClosedJob: lot_id= #{lot.id} status AFTER updated = #{lot.status}"
  end

  def get_value(string)
    string.split(":").last
  end
end
