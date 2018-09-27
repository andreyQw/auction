# frozen_string_literal: true

class LotsStatusInProcessJob < ApplicationJob
  queue_as :default

  def perform(lot_id)
    lot = Lot.find(lot_id)
    if lot
      lot.update(status: :in_process)
      puts "LotsStatusInProcessJob: lot_id= #{lot.id} status AFTER updated = #{lot.status}"
    end
  end
end
