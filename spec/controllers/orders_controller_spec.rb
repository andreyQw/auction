# frozen_string_literal: true

require "rails_helper"

RSpec.describe OrdersController, type: :controller do

  login(:user)
  let(:user2) { create(:user) }
  let(:lot) { create(:lot, user_id: @user.id, status: :in_process, current_price: 10.00, estimated_price: 15.00) }
  before(:each) do
    @bid = create(:bid, proposed_price: 20.00, lot_id: lot.id, user_id: user2.id)
  end

  subject { post :create, params: attributes_for(:order, lot_id: lot.id) }

  it "response not authorized" do
    subject
    expect(json_parse_response_body[:error]).to eq("You are not authorized for this action")
  end

  context "when user winner" do
    before(:each) do
      login_by_user(user2)
    end
    it "should create order" do
      subject
      expect(json_parse_response_body[:resource][:lot_id]).to eq(lot.id)
    end
  end
end
