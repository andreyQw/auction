# frozen_string_literal: true

class LotsStatusInProcessJob < ApplicationJob
  queue_as :default

  def perform(lot_id)
    lot = Lot.find(get_value(lot_id))
    if lot
      puts "LotsStatusInProcessJob: lot_id= #{lot.id} status BEFORE updated = #{lot.status}"
      lot.update(status: :in_process)
      puts "LotsStatusInProcessJob: lot_id= #{lot.id} status AFTER updated = #{lot.status}"
    end
  end

  def get_value(string)
    string.split(":").last
  end
end
