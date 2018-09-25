# frozen_string_literal: true

require "rails_helper"
require "sidekiq/testing"

RSpec.describe OrdersStatusController, type: :controller do
  Sidekiq::Testing.fake!

  describe "PUT /order_status/:id" do
    login(:user)

    let(:customer) { create(:user) }
    let(:lot_closed) { create(:lot, user_id: @user.id, status: :closed, user_win_id: customer.id) }
    let(:order_pending) { create(:order, lot_id: lot_closed.id, status: :pending) }
    let(:order_sent) { create(:order, lot_id: lot_closed.id, status: :sent) }
    let(:order_delivered) { create(:order, lot_id: lot_closed.id, status: :delivered) }

    context "Seller" do

      context "order_pending" do
        before(:each) do
          order_pending
        end
        context "update status: (:pending -> :sent)" do
          it "should update" do
            put :update, params: { id: order_pending.id, status: :sent }
            expect(response).to be_successful
            expect(json_parse_response_body[:resource][:status]).to eq("sent")
          end
        end

        context "update status: (:pending -> :delivered)" do
          it "should not update" do
            put :update, params: { id: order_pending.id, status: :delivered }
            expect(response.status).to eq(401)
            expect(json_parse_response_body[:error]).to eq("You are not authorized for this action")
          end
        end
      end

      context "order_sent" do
        before(:each) do
          order_sent
        end
        context "update status: (:sent -> :pending)" do
          it "should not update" do
            put :update, params: { id: order_sent.id, status: :pending }
            expect(response.status).to eq(400)
          end
        end

        context "update status: (:sent -> :delivered)" do
          it "should not update" do
            put :update, params: { id: order_sent.id, status: :delivered }
            expect(response.status).to eq(401)
          end
        end
      end

      context "order_delivered" do
        before(:each) do
          order_delivered
        end
        context "update status: (:delivered -> :pending)" do
          it "should not update" do
            put :update, params: { id: order_delivered.id, status: :pending }
            expect(response.status).to eq(400)
          end
        end

        context "update status: (:delivered -> :sent)" do
          it "should not update" do
            put :update, params: { id: order_delivered.id, status: :sent }
            expect(response.status).to eq(401)
          end
        end
      end
    end

    context "Customer" do
      before(:each) do
        login_by_user(customer)
      end

      context "order_pending" do
        before(:each) do
          order_pending
        end

        context "update status: (:pending -> :delivered)" do
          it "should not update" do
            put :update, params: { id: order_pending.id, status: :delivered }
            expect(response.status).to eq(401)
          end
        end

        context "update status: (:pending -> :sent)" do
          it "should not update" do
            put :update, params: { id: order_pending.id, status: :sent }
            expect(response.status).to eq(401)
          end
        end
      end

      context "order_sent" do
        before(:each) do
          order_sent
        end

        context "update status: (:sent -> :delivered)" do
          it "should update" do
            put :update, params: { id: order_sent.id, status: :delivered }
            expect(response).to be_successful
            expect(json_parse_response_body[:resource][:status]).to eq("delivered")
          end
        end

        context "update status: (:sent -> :pending)" do
          it "should not update" do
            put :update, params: { id: order_sent.id, status: :pending }
            expect(response.status).to eq(400)
          end
        end
      end

      context "order_delivered" do
        before(:each) do
          order_delivered
        end

        context "update status: (:delivered -> :pending)" do
          it "should not update" do
            put :update, params: { id: order_delivered.id, status: :pending }
            expect(response.status).to eq(400)
          end
        end

        context "update status: (:delivered -> :sent)" do
          it "should not update" do
            put :update, params: { id: order_delivered.id, status: :sent }
            expect(response.status).to eq(401)
          end
        end
      end
    end
  end
end
