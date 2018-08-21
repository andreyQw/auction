# frozen_string_literal: true
# == Schema Information
#
# Table name: lots
#
#  id              :integer          not null, primary key
#  current_price   :float            not null
#  description     :string
#  estimated_price :float            not null
#  image           :string
#  lot_end_time    :datetime         not null
#  lot_start_time  :datetime         not null
#  status          :integer          default("pending")
#  title           :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  user_id         :integer
#
# Indexes
#
#  index_lots_on_status   (status)
#  index_lots_on_user_id  (user_id)
#

class Lot < ApplicationRecord
  belongs_to :user
  has_many :bids
  has_one :order

  enum status: [ :pending, :in_process, :closed ]

  validates :title, :current_price, :estimated_price, :lot_start_time, :lot_end_time,  presence: true

  validates :current_price, :estimated_price, numericality: { greater_than: 0 }

  validate :lot_start_time_must_be_more_then_now
  validate :lot_end_time_must_be_more_lot_start_time

  def lot_start_time_must_be_more_then_now
    if lot_start_time < DateTime.now
      errors.add(:lot_start_time, "Lot START time can't be less than current time")
    end
  end

  def lot_end_time_must_be_more_lot_start_time
    if lot_end_time <= lot_start_time
      errors.add(:lot_end_time, "Lot END time can't be less than lot START time")
    end
  end
end
