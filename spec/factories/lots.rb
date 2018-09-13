# frozen_string_literal: true

# == Schema Information
#
# Table name: lots
#
#  id                :integer          not null, primary key
#  bid_win           :integer
#  current_price     :float            not null
#  description       :string
#  estimated_price   :float            not null
#  image             :string
#  job_id_closed     :string
#  job_id_in_process :string
#  lot_end_time      :datetime         not null
#  lot_start_time    :datetime         not null
#  status            :integer          default("pending")
#  title             :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  user_id           :integer
#  user_win_id       :integer
#
# Indexes
#
#  index_lots_on_status   (status)
#  index_lots_on_user_id  (user_id)
#

FactoryBot.define do
  time_now = Time.zone.now
  factory :lot do
    user
    title { Faker::Device.model_name }
    image { Rack::Test::UploadedFile.new(Rails.root.join("spec/support/no_image.gif")) }
    description { Faker::Device.manufacturer }
    status "pending"
    current_price 10.00
    estimated_price 20.00
    lot_start_time time_now + 1.hour
    lot_end_time time_now + 2.hour
    created_at time_now
    updated_at time_now
  end

  factory :lot_in_process, class: Lot do
    user
    title { Faker::Device.model_name }
    image { Rack::Test::UploadedFile.new(Rails.root.join("spec/support/no_image.gif")) }
    description { Faker::Device.manufacturer }
    status "in_process"
    current_price 10.00
    estimated_price 20.00
    lot_start_time time_now + 1.hour
    lot_end_time time_now + 2.hour
    created_at time_now
    updated_at time_now
  end

  factory :lot_closed, class: Lot do
    user
    title { Faker::Device.model_name }
    image { Rack::Test::UploadedFile.new(Rails.root.join("spec/support/no_image.gif")) }
    description { Faker::Device.manufacturer }
    status "closed"
    current_price 10.00
    estimated_price 20.00
    lot_start_time time_now + 1.hour
    lot_end_time time_now + 2.hour
    created_at time_now
    updated_at time_now
  end
end
