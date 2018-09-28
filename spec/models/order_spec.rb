# frozen_string_literal: true

# == Schema Information
#
# Table name: orders
#
#  id               :integer          not null, primary key
#  arrival_location :text
#  arrival_type     :integer          default("royal_mail")
#  status           :integer          default("pending")
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  lot_id           :integer
#
# Indexes
#
#  index_orders_on_lot_id  (lot_id)
#  index_orders_on_status  (status)
#


require "rails_helper"
require "sidekiq/testing"

RSpec.describe Order, type: :model do
  after(:all) do
    Sidekiq::ScheduledSet.new.clear
  end

  let(:seller) { create(:user) }

  let(:lot_pending) { create(:lot, user_id: seller.id) }
  let(:lot_in_process) { create(:lot_in_process, user_id: seller.id, current_price: 10.0) }
  let(:lot_closed) { create(:lot_closed, user_id: seller.id) }

  let(:order_pending) { create(:order, lot_id: lot_closed.id) }

  context "Validation" do
    context "lot_status_must_be_closed" do

      it "should be valid" do
        order = build(:order, lot_id: lot_closed.id)
        expect(order).to be_valid
      end

      it "should not be valid: lot.status = in_process" do
        order = build(:order, lot_id: lot_in_process.id)
        expect(order).to_not be_valid
        expect(order.errors.messages[:base]).to eq(["Lot status must be closed"])
      end

      it "should not be valid: lot.status = pending" do
        order = build(:order, lot_id: lot_pending.id)
        expect(order).to_not be_valid
      end
    end
  end
end
