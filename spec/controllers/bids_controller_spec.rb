# frozen_string_literal: true

require "rails_helper"
include ActionController::RespondWith

RSpec.describe BidsController, type: :controller do

  #
  describe "POST /bids" do
    login(:user)
    # subject { post :create, params: @bid }
    # subject { post :create, params:  attributes_for(:bid) }
    before(:each) do
      @lot = create(:lot)
      # @bid = attributes_for(:bid, lot_id: @lot.id, proposed_price: @lot.current_price + 1)
    end
    context "create bid valid" do

      it "response for create should be success" do
        # subject
        request = post :create, params: attributes_for(:bid, lot_id: @lot.id, proposed_price: @lot.current_price + 1)
        # lot_after = Lot.find(id: @lot.id)
        lot_after = Lot.where(id: @lot.id)
        expect(json_parse_response_body[:resource][:id]).to eq 1
        expect { } .to change { @lot.current_price } .to(json_parse(lot_after.to_s))
      end
    end

    context "create bid should be errors " do
      # before(:each) do
      #   @bid.proposed_price = nil
      # end

      it "proposed_price can't be blank" do
        post :create, params: attributes_for(:bid, lot_id: @lot.id, proposed_price: "")
        expect(json_parse_response_body[:errors][:proposed_price].to_s).to match /can't be blank/
      end
    end

    context "create bid with not correct proposed_price" do
      # before(:each) do
      #   bid1 = create(:bid, proposed_price: @lot.current_price + 1)
      #   qwe = 0
      #   bid2 = build(:bid, proposed_price: @lot.current_price - 5)
      # end
      # subject { post :create, params: {
      #     proposed_price: @bid2.proposed_price,
      #     lot_id: @bid2.lot_id,
      #   }
      # }

      it "proposed_price can't be blank" do
        post :create, params: attributes_for(:bid, proposed_price: @lot.current_price + 1)
        post :create, params: attributes_for(:bid, proposed_price:  @lot.current_price - 1)
        # subject
        expect(json_parse_response_body[:errors][:proposed_price].to_s).to match /proposed_price can't be less than lot.current_price/
      end
    end
  end
end
