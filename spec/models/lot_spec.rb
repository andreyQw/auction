# frozen_string_literal: true

require "rails_helper"

RSpec.describe Lot, type: :model do
  before(:each) do
    @user1 = create(:user)
  end

  it "+ should be valid 1)if lot_start_time_must_be_more_than_now 2)lot_end_time_must_be_more_lot_start_time" do
    time_more_now = DateTime.now + 1.hour
    lot = build(:lot, user_id: @user1.id, lot_start_time: time_more_now, lot_end_time: time_more_now + 1.hour)
    expect(lot).to be_valid
  end

  it "- should be not valid 1)if lot_start_time less than current time" do
    time_less_now = DateTime.now - 1.hour
    lot = build(:lot, user_id: @user1.id, lot_start_time: time_less_now, lot_end_time: time_less_now + 2.hour)
    expect(lot).to_not be_valid
    expect(lot.errors.messages).to eq lot_start_time: ["Lot START time can't be less than current time"]
  end

  it "- should be not valid 2)if lot_end_time less than lot_start_time" do
    time_more_now = DateTime.now + 1.hour
    lot = build(:lot, user_id: @user1.id, lot_start_time: time_more_now, lot_end_time: time_more_now - 1.hour)
    expect(lot).to_not be_valid
    expect(lot.errors.messages).to eq lot_end_time: ["Lot END time can't be less than lot START time"]
  end

end
