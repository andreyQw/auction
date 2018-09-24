# frozen_string_literal: true

require "rails_helper"
require "sidekiq/testing"

RSpec.describe BidsController, type: :controller do

  #
  describe "POST /bids" do

    context "Not authorized user" do
      let!(:seller) { create(:user) }
      let!(:lot) { create(:lot_in_process, user_id: seller.id, current_price: 10.0, estimated_price: 20.0) }

      it "should not create bid" do
        post :create, params: attributes_for(:bid, lot_id: lot.id, proposed_price: lot.current_price + 1)
        expect(json_parse_response_body[:errors]).to include("You need to sign in or sign up before continuing.")
      end
    end

    context "Authorized user" do
      login(:user)
      let(:customer) { create(:user) }

      let(:lot1) { create(:lot_in_process, user_id: @user.id, current_price: 10.0, estimated_price: 20.0) }
      let(:lot2) { create(:lot_in_process, user_id: customer.id, current_price: 10.0, estimated_price: 20.0) }

      subject do
        # not win bid
        post :create, params: attributes_for(:bid, lot_id: lot1.id, proposed_price: lot1.current_price + 1)
      end

      context "owner stack" do
        it "should not create" do
          subject
          expect(json_parse_response_body[:errors][:user]).to include("Lot owner can't create bid for his lot")
        end
      end

      context "customer stack" do
        before(:each) do
          login_by_user(customer)
        end
        context "create not bid_win" do

          it "should create bid, end not add lot1.bid_win" do
            subject
            expect(response).to be_successful
            expect(lot1.reload.bid_win).to eq(nil)
          end

          it "should change lot.current_price" do
            subject
            expect(response).to be_successful
            expect(json_parse_response_body[:resource][:proposed_price]).to eq(lot1.reload.current_price)
          end
        end

        context "create bid_win" do

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
        end

      end
    end
  end
end
