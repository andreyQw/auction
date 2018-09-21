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

    it "response not authorized" do
      subject
      expect(json_parse_response_body[:error]).to eq("You are not authorized for this action")
    end

    context "when user winner" do
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
    let!(:order_pending) { create(:order, lot_id: lot_closed.id, status: :pending) }

    context "seller" do

      context "update order status: (:pending -> :sent)" do
        it "should update" do
          put :update, params: { id: lot_closed.id, status: :sent }
          expect(json_parse_response_body[:resource][:status]).to eq("sent")
        end
      end

      context "update order status (:pending -> :delivered)" do
        it "should not update" do
          put :update, params: { id: lot_closed.id, status: :delivered }
          expect(json_parse_response_body[:error]).to eq("You are not authorized for this action")
        end
      end

      context "update order params: (status -> :sent, :arrival_type, :arrival_location)" do
        it "should not update: with arrival_type, arrival_location field" do
          put :update, params: { id: lot_closed.id, status: "sent", arrival_type: "dhl_express", arrival_location: "Kiev" }
          expect(json_parse_response_body[:error]).to eq("You are not authorized for this action")
        end
      end

      context "update order params: (:arrival_type, :arrival_location)" do
        it "should not update: with arrival_type, arrival_location field" do
          put :update, params: { id: lot_closed.id, arrival_type: "dhl_express", arrival_location: "Kiev" }
          expect(json_parse_response_body[:error]).to eq("You are not authorized for this action")
        end
      end
    end


    context "Customer stack/" do
      before(:each) do
        login_by_user(customer)
      end

      context "pending_order" do
        context "update status in pending_order (:pending -> :sent)" do
          it "should not update" do
            put :update, params: { id: order_pending.id, status: "sent" }

            expect(json_parse_response_body[:error]).to eq("You are not authorized for this action")
          end
        end

        context "update status in pending_order (:pending -> :delivered)" do
          it "should not update" do
            put :update, params: { id: order_pending.id, status: "delivered" }

            expect(json_parse_response_body[:error]).to eq("You are not authorized for this action")
          end
        end

        context "update pending_order with :arrival_type" do
          it "should update" do
            put :update, params: { id: order_pending.id, arrival_type: "dhl_express" }

            expect(response).to be_successful
            expect(json_parse_response_body[:resource][:arrival_type]).to eq("dhl_express")
          end
        end
      end

      context "update order_sent" do

        let!(:order_sent) { create(:order, lot_id: lot_closed.id, status: "sent") }

        context "update order_sent (:sent -> :delivered)" do
          it "should update" do
            put :update, params: { id: order_sent.id, status: :delivered }
            expect(json_parse_response_body[:resource][:status]).to eq("delivered")
          end
        end

        context "update order_sent (:sent -> :pending)" do
          it "should not update" do
            put :update, params: { id: order_sent.id, status: :pending }
            expect(json_parse_response_body[:error]).to eq("You are not authorized for this action")
          end
        end

        context "update order_sent with :arrival_type" do
          it "should not update" do
            put :update, params: { id: order_sent.id, arrival_type: "dhl_express" }
            expect(json_parse_response_body[:error]).to eq("You are not authorized for this action")
          end
        end
      end

      context "update order_delivered" do
        let!(:order_delivered) { create(:order, lot_id: lot_closed.id, status: "delivered") }

        it "should not update arrival_type" do
          put :update, params: { id: order_delivered.id, arrival_type: "dhl_express" }
          expect(json_parse_response_body[:error]).to eq("You are not authorized for this action")
        end

        it "should not update status" do
          put :update, params: { id: order_delivered.id, status: :pending }
          expect(json_parse_response_body[:error]).to eq("You are not authorized for this action")
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
