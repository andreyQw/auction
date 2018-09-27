# frozen_string_literal: true

require "rails_helper"

RSpec.describe LotSerializer, type: :serializer do

  let(:seller) { create(:user) }

  describe "attributes" do
    it "should include size as an attribute" do
      lot = build(:lot, user_id: seller.id)

      lot_serialized = obj_serialization(lot, serializer: LotSerializer)

      expected_keys = [:id, :user_id, :title, :image, :description, :status, :current_price, :estimated_price,
                       :lot_start_time, :lot_end_time, :bid_win, :user_win_id, :bids]

      expect(json_parse(lot_serialized)[:lot].keys).to eq(expected_keys)
    end
  end
end
