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

FactoryBot.define do
  factory :order do
    lot_id 1
    arrival_location { Faker::Address.full_address }
    arrival_type "royal_mail"
    status "pending"
    created_at DateTime.now
  end
end
