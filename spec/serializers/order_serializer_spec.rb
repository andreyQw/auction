# frozen_string_literal: true

require "rails_helper"
require "sidekiq/testing"

RSpec.describe OrderSerializer, type: :serializer do
  after(:all) do
    Sidekiq::ScheduledSet.new.clear
  end

  let(:seller)  { create(:user) }
  let(:customer) { create(:user) }

  let(:lot_closed) { create(:lot_closed, user_id: seller.id, user_win_id: customer.id) }

  describe "attributes" do
    it "should include size as an attribute" do
      order = build(:order, lot_id: lot_closed.id)

      order_serialized = obj_serialization(order, serializer: OrderSerializer)

      expected_keys = [:id, :lot_id, :status, :arrival_type, :arrival_location]

      expect(json_parse(order_serialized)[:order].keys).to eq(expected_keys)
    end
  end
end
