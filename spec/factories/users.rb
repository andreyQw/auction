# frozen_string_literal: true

FactoryBot.define do
  factory :user do |f|
    f.email "qwe@mail.com"
    f.password "password"
    f.phone "112"
    f.first_name "Bob"
    f.last_name "Qwe"
    f.birthday Time.now.strftime("%m/%d/%Y")
    f.created_at Time.now
    f.updated_at Time.now
  end
end
