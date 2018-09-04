# frozen_string_literal: true

FactoryBot.define do
  factory :order do
    lot_id 1
    arrival_location { Faker::Address.full_address }
    arrival_type ["Royal Mail", "United States Postal Service", "DHL Express"].sample
    created_at DateTime.now
  end
end
