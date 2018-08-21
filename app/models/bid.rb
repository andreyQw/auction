# frozen_string_literal: true
# == Schema Information
#
# Table name: bids
#
#  id             :integer          not null, primary key
#  nickname       :string
#  proposed_price :float
#  created_at     :datetime
#  lot_id         :integer
#  user_id        :integer
#
# Indexes
#
#  index_bids_on_lot_id   (lot_id)
#  index_bids_on_user_id  (user_id)
#

class Bid < ApplicationRecord
  belongs_to :user
  belongs_to :lot
  after_create :change_lot_current_price

  validates :proposed_price, :lot_id,  presence: true

  validates :proposed_price, numericality: { greater_than: 0 }

  validate :more_than_last_proposed_price

  def more_than_last_proposed_price
    if proposed_price == nil || lot.current_price > proposed_price
      errors.add(:proposed_price, "proposed_price can't be less than lot.current_price")
    end
  end


  def change_lot_current_price
    lot.update(current_price: proposed_price)
  end
end
