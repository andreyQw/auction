# frozen_string_literal: true

require "rails_helper"
include ActionController::RespondWith

RSpec.describe BidsController, type: :controller do

  #
  describe "POST /bids" do
    login(:user)

    before(:each) do
      @user2 = create(:user)
      @lot = create(:lot, user_id: @user.id, status: :in_process)
      @proposed_price = @lot.current_price + 1
    end

    subject do
      post :create, params: attributes_for(:bid, user_id: @user2.id, lot_id: @lot.id, proposed_price: @proposed_price)
    end

    context "create bid valid" do
      it "response for create should be success and change lot.current_price" do
        expect { subject }.to change { @lot.reload.current_price }.from(@lot.current_price).to(@proposed_price)
      end
    end

    context "create bid should be errors " do
      it "proposed_price can't be blank" do
        post :create, params: attributes_for(:bid, lot_id: @lot.id, proposed_price: "")
        expect(json_parse_response_body[:errors][:proposed_price].to_s).to match /can't be blank/
      end
    end

  end
end
