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
require "sidekiq/testing"

RSpec.describe Bid, type: :model do

  let(:seller) { create(:user) }
  let(:customer) { create(:user) }
  let(:lot_in_process) { create(:lot_in_process, user_id: seller.id, current_price: 10.0) }

  it "should be valid 1)if proposed_price more than lot_current_price 2)lot_status = in_process 3) user not owner" do
    bid = create(:bid, lot_id: lot_in_process.id, user_id: customer.id, proposed_price: lot_in_process.current_price + 1)
    expect(bid).to be_valid
  end

  it "should close Lot and set lot.bid_win, lot.user_win" do
    bid = create(:bid, lot_id: lot_in_process.id, user_id: customer.id, proposed_price: lot_in_process.estimated_price + 1)
    expect(bid.lot.reload.user_win_id).to eq(customer.id)
    expect(bid.lot.reload.bid_win).to eq(bid.id)
  end

  it "should be not valid if proposed_price less than lot_current_price" do
    bid = build(:bid, lot_id: lot_in_process.id, user_id: customer.id, proposed_price: lot_in_process.current_price - 1)
    expect(bid).to_not be_valid
    expect(bid.errors.messages).to eq proposed_price: ["proposed_price can't be less than lot.current_price"]
  end

  it "should be not valid if owner try create bid for his lot" do
    bid = build(:bid, lot_id: lot_in_process.id, user_id: seller.id, proposed_price: lot_in_process.current_price + 1)
    expect(bid).to_not be_valid
    expect(bid.errors.messages).to eq user: ["Lot owner can't create bid for his lot"]
  end

  context "check lot status" do
    let(:lot_pending) { create(:lot, user_id: seller.id) }
    let(:lot_closed) { create(:lot_closed, user_id: seller.id) }

    it "should be not valid if lot status :pending" do
      bid = build(:bid, lot_id: lot_pending.id, user: customer, proposed_price: lot_pending.current_price + 1)
      expect(bid).to_not be_valid
      expect(bid.errors.messages[:base]).to eq (["Lot status must be in_process"])
    end

    it "should be not valid if lot status :closed" do
      bid = build(:bid, lot_id: lot_closed.id, user: customer, proposed_price: lot_pending.current_price + 1)
      expect(bid).to_not be_valid
      expect(bid.errors.messages[:base]).to eq (["Lot status must be in_process"])
    end
  end
end
