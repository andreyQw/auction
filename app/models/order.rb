# frozen_string_literal: true

# == Schema Information
#
# Table name: orders
#
#  id               :integer          not null, primary key
#  arrival_location :text
#  arrival_type     :integer          default("royal_mail")
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

  enum status: [ :pending, :sent, :delivered ]
  enum arrival_type: [ :royal_mail, :united_states_postal_service, :dhl_express ]

  validates :arrival_location, :arrival_type, :status, presence: true

  validate :lot_status_must_be_closed,  on: :create

  after_create :send_email_for_seller

  after_update :send_email_for_customer_lot_sent, if: :sent?
  after_update :send_email_after_delivered, if: :delivered?

  def lot_status_must_be_closed
    errors.add(:base, "Lot status must be closed") unless lot.closed?
  end

  def send_email_for_seller
    UserMailer.email_for_seller_order_was_created self
  end

  def send_email_for_customer_lot_sent
    UserMailer.email_for_customer_lot_was_sent self
  end

  def send_email_after_delivered
    UserMailer.email_after_delivered_to_seller self
    UserMailer.email_after_delivered_to_customer self
  end
end
