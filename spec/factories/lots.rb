
FactoryBot.define do
  factory :lot do
    user_id 1
    title { Faker::Device.model_name }
    image  'img'
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