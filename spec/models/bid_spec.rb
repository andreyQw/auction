# frozen_string_literal: true

# == Schema Information
#
# Table name: bids
#
#  id             :integer          not null, primary key
#  proposed_price :float
#  created_at     :datetime
#  lot_id         :integer
#  user_id        :integer
#
# Indexes
#
#  index_bids_on_lot_id   (lot_id)
#  index_bids_on_user_id  (user_id)
#


require "rails_helper"

RSpec.describe Bid, type: :model do
  before(:each) do
    @user1 = create(:user)
    @user2 = create(:user)
    @lot1 = create(:lot, user_id: @user1.id, status: :in_process, current_price: 10.0)
  end

  it "should be valid 1)if proposed_price more than lot_current_price 2)lot_status = in_process 3) user not owner" do
    bid = create(:bid, lot_id: @lot1.id, user_id: @user2.id, proposed_price: 11.0)
    expect(bid).to be_valid
  end

  it "should be not valid if proposed_price less than lot_current_price" do
    bid = build(:bid, lot_id: @lot1.id, user_id: @user2.id, proposed_price: 9.0)
    expect(bid).to_not be_valid
    expect(bid.errors.messages).to eq proposed_price: ["proposed_price can't be less than lot.current_price"]
  end

  it "should be not valid if owner try create bid for his lot" do
    bid = build(:bid, lot_id: @lot1.id, user_id: @user1.id, proposed_price: 11.0)
    expect(bid).to_not be_valid
    expect(bid.errors.messages).to eq user: ["Lot owner can't create bid for his lot"]
  end

  context "check lot status" do
    before :each do
      @lot2 = create(:lot, user_id: @user1.id, status: :pending, current_price: 10.00)
      @lot3 = create(:lot, user_id: @user1.id, status: :closed, current_price: 10.00)
    end

    it "should be not valid if lot status :pending" do
      bid = build(:bid, lot_id: @lot2.id, user: @user2, proposed_price: 11.00)
      expect(bid).to_not be_valid
      expect(bid.errors.messages[:base]).to eq (["Lot status must be in_process"])
    end

    it "should be not valid if lot status :closed" do
      bid = build(:bid, lot_id: @lot3.id, user: @user2, proposed_price: 11.00)
      expect(bid).to_not be_valid
      expect(bid.errors.messages[:base]).to eq (["Lot status must be in_process"])
    end
  end
end
