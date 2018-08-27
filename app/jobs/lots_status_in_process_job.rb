class LotsStatusInProcessJob < ApplicationJob

  queue_as :default

  def perform(lot_id)
    lot = Lot.find(lot_id)

    puts "LotsStatusInProcessJob: lot_id= #{lot.id} status BEFORE updated = #{lot.status}"
    lot.update(status: :in_process)
    puts "LotsStatusInProcessJob: lot_id= #{lot.id} status AFTER updated = #{lot.status}"
  end
end
