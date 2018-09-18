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

  attr_accessor :current_user_role

  enum status: [ :pending, :sent, :delivered ]
  enum arrival_type: [ :royal_mail, :united_states_postal_service, :dhl_express ]

  validates :arrival_location, :arrival_type, :status, presence: true

  validate :lot_status_must_be_closed,  on: :create

  validate :check_status_change_for_seller, on: :update, if: :seller?
  validate :customer_can_update_pending_order,  on: :update, if: :customer?
  validate :check_status_change_for_customer, on: :update, if: :customer?

  after_create :send_email_for_seller

  after_update :send_email_for_customer_lot_sent, if: :sent?
  after_update :send_email_after_delivered, if: :delivered?

  def lot_status_must_be_closed
    errors.add(:base, "Lot status must be closed") unless lot.closed?
  end

  def seller?
    current_user_role == "seller"
  end

  def customer?
    current_user_role == "customer"
  end

  def check_status_change_for_seller
    unless changed == ["status"] && status_change == ["pending", "sent"]
      errors.add(:base, "seller can update only status field and it must be from :pending to :sent")
    end
  end

  def check_status_change_for_customer
    if changed == ["status"] && status_change != ["sent", "delivered"]
      errors.add(:status, "customer can update status only from :sent to :delivered")
    end
  end

  def customer_can_update_pending_order
    if case_for_pending_status? || case_for_not_pending_status?
      errors.add(:status, "customer can update pending order except :status")
    end
  end

  def case_for_pending_status?
    status == "pending" && changed.include?("status")
  end

  def case_for_not_pending_status?
    status != "pending" && (changed.include?("arrival_type") || changed.include?("arrival_location"))
  end

  def set_current_user_role(current_user_id)
    if lot.user_win_id == current_user_id
      "customer"
    elsif lot.user_id == current_user_id
      "seller"
    end
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
