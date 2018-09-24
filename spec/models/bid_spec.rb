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

  context "Validation" do
    context "proposed_price more_than_last_proposed_price" do
      it "should be valid" do
        bid = build(:bid, lot_id: lot_in_process.id, user_id: customer.id, proposed_price: lot_in_process.current_price + 1)
        expect(bid).to be_valid
      end

      it "should not be valid, proposed_price < current_price" do
        bid = build(:bid, lot_id: lot_in_process.id, user_id: customer.id, proposed_price: lot_in_process.current_price - 1)
        expect(bid).to_not be_valid
        expect(bid.errors.messages).to eq proposed_price: ["proposed_price can't be less than lot.current_price"]
      end

      it "should not be valid, proposed_price = nil" do
        bid = build(:bid, lot_id: lot_in_process.id, user_id: customer.id, proposed_price: "")
        expect(bid).to_not be_valid
        expect(bid.errors.messages[:proposed_price]).to include("proposed_price can't be less than lot.current_price")
      end
    end

    context "Lot status_must_be_in_process" do
      let(:lot_pending) { create(:lot, user_id: seller.id) }
      let(:lot_closed) { create(:lot_closed, user_id: seller.id) }

      it "should be valid, status :in_process" do
        bid = build(:bid, lot_id: lot_in_process.id, user_id: customer.id, proposed_price: lot_in_process.current_price + 1)
        expect(bid).to be_valid
      end

      it "should be not valid, status :pending" do
        bid = build(:bid, lot_id: lot_pending.id, user: customer, proposed_price: lot_pending.current_price + 1)
        expect(bid).to_not be_valid
        expect(bid.errors.messages[:base]).to eq (["Lot status must be in_process"])
      end

      it "should be not valid, status :closed" do
        bid = build(:bid, lot_id: lot_closed.id, user: customer, proposed_price: lot_pending.current_price + 1)
        expect(bid).to_not be_valid
        expect(bid.errors.messages[:base]).to eq (["Lot status must be in_process"])
      end
    end

    context "user_must_be_not_owner" do

      it "should be valid" do
        bid = build(:bid, lot_id: lot_in_process.id, user_id: customer.id, proposed_price: lot_in_process.current_price + 1)
        expect(bid).to be_valid
      end

      it "should not be valid" do
        bid = build(:bid, lot_id: lot_in_process.id, user_id: seller.id, proposed_price: lot_in_process.current_price + 1)
        expect(bid).to_not be_valid
        expect(bid.errors.messages).to eq user: ["Lot owner can't create bid for his lot"]
      end
    end
  end

  context "Bid methods" do
    context "change_lot_current_price" do
      it "should change_lot_current_price" do
        proposed_price = lot_in_process.current_price + 1
        bid = create(:bid, lot_id: lot_in_process.id, user_id: customer.id, proposed_price: proposed_price)
        expect(bid.lot.reload.current_price).to eq(proposed_price)
      end
    end

    context "lot_closed" do
      context "not close Lot" do
        before do
          @bid_not_win = create(:bid, lot_id: lot_in_process.id, user_id: customer.id, proposed_price: lot_in_process.current_price + 1)
        end
        it "should not close Lot" do
          expect(@bid_not_win.lot.reload.status).to eq("in_process")
        end
        it "should not close Lot and not set lot.bid_win, lot.user_win" do
          expect(@bid_not_win.lot.reload.user_win_id).to eq(nil)
        end
        it "should not close Lot and not set lot.bid_win, lot.user_win" do
          expect(@bid_not_win.lot.reload.bid_win).to eq(nil)
        end
      end

      context "close Lot" do
        before do
          @bid_win = create(:bid, lot_id: lot_in_process.id, user_id: customer.id, proposed_price: lot_in_process.estimated_price + 1)
        end

        it "should close Lot" do
          expect(@bid_win.lot.reload.status).to eq("closed")
        end

        it "should set lot.bid_win" do
          expect(@bid_win.lot.reload.user_win_id).to eq(customer.id)
        end

        it "should set lot.user_win" do
          expect(@bid_win.lot.reload.bid_win).to eq(@bid_win.id)
        end
      end
    end

    context "broadcast_bid" do
      it "should send bid to bids_for_lot_* chanel" do
        bid = create(:bid, lot_id: lot_in_process.id, user_id: customer.id, proposed_price: lot_in_process.current_price + 1)

        expect {
          ActionCable.server.broadcast(
            "bids_for_lot_#{lot_in_process.id}", BidSerializer.new(bid)
          )
        }.to have_broadcasted_to("bids_for_lot_#{lot_in_process.id}").with(json_parse(obj_serialization(bid, serializer: BidSerializer))[:bid])
      end
    end
  end
end
