
require "rails_helper"

RSpec.describe Order, type: :model do

  let(:user_seller) { create(:user) }
  let(:user_customer) { create(:user) }
  let(:lot) { create(:lot, status: "closed", user_id: user_seller.id, bid_win: 1, user_win_id: user_customer.id) }

  context "create order" do
    it "should be valid" do
      order = create(:order, lot_id: lot.id)
      expect(order).to be_valid
    end

    it "should not valid: " do
      # order = build(:order, lot_id: lot.id).set_current_user_role(user_seller.id)
      # expect(order).to be_valid
    end
  end

  context "update order" do
    before :each do
    end

    it "should be not valid if" do

    end
  end
end
