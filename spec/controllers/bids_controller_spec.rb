# frozen_string_literal: true

require "rails_helper"

RSpec.describe BidsController, type: :controller do

  #
  describe "POST /bids" do
    login(:user)

    time = Time.zone.now
    let(:customer) { create(:user) }
    let(:customer2) { create(:user) }
    let(:lot1) { create(:lot_in_process, user_id: @user.id, current_price: 10.0, estimated_price: 20.0) }
    let(:lot2) { create(:lot_in_process, user_id: customer.id, current_price: 10.0, estimated_price: 20.0) }

    # before(:each) do
    #   time = Time.zone.now
    #   @user2 = create(:user)
    #   @lot = create(:lot, user_id: @user.id, status: :in_process, lot_start_time: time + 60.second, lot_end_time: time + 120.second, current_price: 10.00, estimated_price: 15.00)
    #   @lot2 = create(:lot, user_id: @user2.id, status: :in_process, lot_start_time: time + 60.second, lot_end_time: time + 120.second, current_price: 10.00, estimated_price: 15.00)
    #   @proposed_price = @lot.current_price + 10
    # end

    subject do
      # not win bid
      post :create, params: attributes_for(:bid, lot_id: lot1.id, proposed_price: lot1.current_price + 1)
    end

    context "create not bid_win" do
      before(:each) do
        login_by_user(customer)
      end

      it "should create bid, end not add lot1.bid_win" do
        subject
        expect(response).to be_successful
        expect(lot1.reload.bid_win).to eq(nil)
      end

      it "should create and change lot.current_price" do
        subject
        expect(response).to be_successful
        expect(json_parse_response_body[:resource][:proposed_price]).to eq(lot1.reload.current_price)
      end
    end

    context "create bid_win" do
      before(:each) do
        login_by_user(customer)
      end

      it "should broadcast bid send to lot chanel" do
        expect { subject }
            .to have_broadcasted_to("bids_for_lot_#{lot1.id}")
                    .with(a_hash_including(user_name_alias: user_name_alias(customer.id, lot1.id)))
      end

      it "response should be with set lot.bid_win" do
        post :create, params: attributes_for(:bid, lot_id: lot1.id, proposed_price: lot1.estimated_price + 1)
        bid = json_parse_response_body[:resource]
        expect(bid[:id]).to eq(lot1.reload.bid_win)
      end

      it "response with :user_name_alias 'You'" do
        subject
        expect(json_parse_response_body[:resource][:user_name_alias]).to eq("You")
      end

      it "proposed_price can't be blank" do
        post :create, params: attributes_for(:bid, lot_id: lot1.id, proposed_price: "")
        expect(json_parse_response_body[:errors][:proposed_price].to_s).to match /can't be blank/
      end

    end

  end
end
