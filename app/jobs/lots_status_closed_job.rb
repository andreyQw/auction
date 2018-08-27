class LotsStatusClosedJob < ApplicationJob

  queue_as :default

  def perform(lot_id)
    lot = Lot.find(lot_id)

    puts "LotsStatusClosedJob: lot_id= #{lot.id} status BEFORE updated = #{lot.status}"
    lot.update(status: :closed)
    puts "LotsStatusClosedJob: lot_id= #{lot.id} status AFTER updated = #{lot.status}"
  end
end
