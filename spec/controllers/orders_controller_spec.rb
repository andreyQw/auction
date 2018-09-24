# frozen_string_literal: true

require "rails_helper"
require "sidekiq/testing"

RSpec.describe OrdersController, type: :controller do
  Sidekiq::Testing.fake!

  describe "POST /orders" do
    login(:user)
    let(:user_customer) { create(:user) }
    let(:lot_closed) { create(:lot, user_id: @user.id, status: :closed, user_win_id: user_customer.id) }

    subject { post :create, params: attributes_for(:order, lot_id: lot_closed.id) }

    context "User not winner" do
      it "response not authorized" do
        subject
        expect(response.status).to eq(401)
        expect(json_parse_response_body[:error]).to eq("You are not authorized for this action")
      end
    end

    context "User winner" do
      before(:each) do
        login_by_user(user_customer)
      end
      it "should create order" do
        subject
        keys = [:id, :lot_id, :status, :arrival_type, :arrival_location]
        expect(response).to be_successful
        expect(json_parse_response_body[:resource].keys).to eq(keys)
      end
    end
  end

  describe "PUT /orders/:id" do
    login(:user)

    let(:customer) { create(:user) }
    let(:lot_closed) { create(:lot, user_id: @user.id, status: :closed, user_win_id: customer.id) }

    let(:order_pending) { create(:order, lot_id: lot_closed.id, status: :pending) }
    let(:order_sent) { create(:order, lot_id: lot_closed.id, status: :sent) }
    let(:order_delivered) { create(:order, lot_id: lot_closed.id, status: :delivered) }

    subject { put :update, params: { id: lot_closed.id, arrival_type: "dhl_express", arrival_location: "Kiev" } }
    context "Seller update order params: (:arrival_type, :arrival_location)" do
      context "order_pending" do
        before do
          order_pending
        end
        it "should not update" do
          subject
          expect(response.status).to eq(401)
          expect(json_parse_response_body[:error]).to eq("You are not authorized for this action")
        end
      end

      context "order_sent" do
        before do
          order_sent
        end
        it "should not update" do
          subject
          expect(response.status).to eq(401)
        end
      end

      context "order_delivered" do
        before do
          order_delivered
        end
        it "should not update" do
          subject
          expect(response.status).to eq(401)
        end
      end
    end


    context "Customer" do
      before(:each) do
        login_by_user(customer)
      end
      context "order_pending" do
        before do
          order_pending
        end
        it "should update" do
          subject
          expect(response).to be_successful
          expect(json_parse_response_body[:resource][:arrival_type]).to eq("dhl_express")
          expect(json_parse_response_body[:resource][:arrival_location]).to eq("Kiev")
        end
      end

      context "order_sent" do
        before do
          order_sent
        end
        it "should not update" do
          subject
          expect(response.status).to eq(401)
        end
      end

      context "order_delivered" do
        before do
          order_delivered
        end
        it "should not update" do
          subject
          expect(response.status).to eq(401)
        end
      end
    end
  end

  describe "GET /orders/:id" do
    let(:seller) { create(:user) }
    let(:customer) { create(:user) }
    let(:user3) { create(:user) }

    let(:lot_closed) { create(:lot, user_id: seller.id, status: :closed, user_win_id: customer.id) }

    let!(:order_pending) { create(:order, lot_id: lot_closed.id, status: :pending) }

    subject { get :show, params: { id: order_pending.id } }

    context "not login" do
      it "response need to sign_in" do
        subject
        expect(json_parse_response_body[:errors]).to include("You need to sign in or sign up before continuing.")
      end
    end

    context "login" do

      context "login like seller" do
        before do
          login_by_user(seller)
        end

        it "should return order for seller" do
          subject
          expect(response).to be_successful
          expect(json_parse_response_body[:resource][:id]).to eq(order_pending.id)
        end
      end

      context "login like customer" do
        before do
          login_by_user(customer)
        end

        it "should return order for customer" do
          subject
          expect(response).to be_successful
          expect(json_parse_response_body[:resource][:id]).to eq(order_pending.id)
        end
      end

      context "login like not customer and seller" do
        before do
          login_by_user(user3)
        end

        it "should return not authorized" do
          subject
          expect(response).to_not be_successful
          expect(json_parse_response_body[:error]).to eq("You are not authorized for this action")
        end
      end
    end
  end
end
