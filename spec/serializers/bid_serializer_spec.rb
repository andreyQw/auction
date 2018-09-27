# frozen_string_literal: true

require "rails_helper"
require "sidekiq/testing"

RSpec.describe BidSerializer, type: :serializer do
  after(:all) do
    Sidekiq::ScheduledSet.new.clear
  end


  let!(:seller)  { create(:user) }
  let!(:customer) { create(:user) }

  let(:lot_in_process) { create(:lot_in_process, user_id: seller.id) }

  describe "attributes" do
    it "user_name_alias: :You" do
      bid = build(:bid, lot_id: lot_in_process.id, user_id: customer.id, proposed_price: lot_in_process.current_price + 1)

      bid_serialized = obj_serialization(bid, serializer: BidSerializer, scope: customer, scope_name: :current_user)

      expected_keys = [:id, :proposed_price, :created_at, :lot_id, :user_name_alias]

      expect(json_parse(bid_serialized)[:bid].keys).to eq(expected_keys)
      expect(json_parse(bid_serialized)[:bid][:user_name_alias]).to eq("You")
    end

    it "user_name_alias: 'Customer *****'" do
      bid = build(:bid, lot_id: lot_in_process.id, user_id: customer.id, proposed_price: lot_in_process.current_price + 1)

      bid_serialized = obj_serialization(bid, serializer: BidSerializer, scope: seller, scope_name: :current_user)

      expect(json_parse(bid_serialized)[:bid][:user_name_alias]).to include("Customer")
    end
  end
end
