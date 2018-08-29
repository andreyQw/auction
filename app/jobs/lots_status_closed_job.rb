# frozen_string_literal: true

class LotsStatusClosedJob < ApplicationJob
  queue_as :default

  def perform(lot_id)
    lot = Lot.find(get_value(lot_id))
    max_bid = Bid.last

    puts "LotsStatusClosedJob: lot_id= #{lot.id} status BEFORE updated = #{ lot.status }"
    lot.update(status: :closed, bid_win: max_bid)
    puts "LotsStatusClosedJob: lot_id= #{lot.id} status AFTER updated = #{lot.status}"
  end

  def get_value(string)
    val = string.split(":").last
  end
end
