# frozen_string_literal: true

# == Schema Information
#
# Table name: orders
#
#  id               :integer          not null, primary key
#  arrival_location :text
#  arrival_type     :string
#  status           :integer          default("pending")
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  lot_id           :integer
#
# Indexes
#
#  index_orders_on_lot_id  (lot_id)
#  index_orders_on_status  (status)
#

class Order < ApplicationRecord
  belongs_to :lot

  attr_accessor :current_user

  enum status: [ :pending, :sent, :delivered ]

  validates :arrival_location, :arrival_type, :status, presence: true

  validate :lot_status_must_be_closed, :creator_must_be_winner

  def lot_status_must_be_closed
    errors.add(:base, "Lot status must be in_process") unless lot.closed?
  end

  def set_current_user(current_user)
    @current_user = current_user
  end
end
