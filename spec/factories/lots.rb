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

FactoryBot.define do
  factory :lot do
    user_id 1
    title { Faker::Device.model_name }
    image "img"
    description { Faker::Device.manufacturer }
    status :pending
    current_price { rand(100..1000).to_f }
    estimated_price  { rand(1001..2000).to_f }
    lot_start_time DateTime.now + 1.hour
    lot_end_time DateTime.now + 5.hour
    created_at DateTime.now
    updated_at DateTime.now
  end
end
