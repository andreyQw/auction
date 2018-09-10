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

RSpec.describe Order, type: :model do

  let(:user_seller) { create(:user) }
  let(:user_customer) { create(:user) }
  let(:lot) { create(:lot, status: "closed", user_id: user_seller.id, bid_win: 1, user_win_id: user_customer.id) }
  before(:each) do
    @order_pending_status = create(:order, lot_id: lot.id)
    @order_sent_status = create(:order, lot_id: lot.id, status: :sent)
  end

  context "create order" do
    it "should be valid" do
      expect(@order_pending_status).to be_valid
    end

    it "should set current_user_role: seller" do
      @order_pending_status.instance_variable_set "@current_user_role", @order_pending_status.set_current_user_role(user_seller.id)
      expect(@order_pending_status.current_user_role).to eq("seller")
    end

    it "should set current_user_role: customer" do
      @order_pending_status.instance_variable_set "@current_user_role", @order_pending_status.set_current_user_role(user_customer.id)
      expect(@order_pending_status.current_user_role).to eq("customer")
    end
  end

  context "update order" do
    context "Seller stack" do

      it "seller can update" do
        @order_pending_status.instance_variable_set "@current_user_role", @order_pending_status.set_current_user_role(user_seller.id)
        @order_pending_status.update(status: "sent")
        expect(@order_pending_status.reload.status).to eq("sent")
      end

      it "seller can update only status field" do
        @order_pending_status.instance_variable_set "@current_user_role", @order_pending_status.set_current_user_role(user_seller.id)
        @order_pending_status.update(status: "sent", arrival_type: "dhl_express")
        expect(@order_pending_status.errors[:base]).to eq (["seller can update only status field and it must be from :pending to :sent"])
      end

      it "seller can't update status on: delivered" do
        @order_pending_status.instance_variable_set "@current_user_role", @order_pending_status.set_current_user_role(user_seller.id)
        @order_pending_status.update(status: "delivered")
        expect(@order_pending_status.errors[:base]).to eq (["seller can update only status field and it must be from :pending to :sent"])
      end
    end

    context "Customer stack" do
      context "for order with :pending status" do

        it "customer can update :arrival_type" do
          @order_pending_status.instance_variable_set "@current_user_role", @order_pending_status.set_current_user_role(user_customer.id)
          @order_pending_status.update(arrival_type: "dhl_express")
          expect(@order_pending_status.reload.arrival_type).to eq("dhl_express")
        end

        it "customer can't update status from :pending to :sent" do
          @order_pending_status.instance_variable_set "@current_user_role", @order_pending_status.set_current_user_role(user_customer.id)
          @order_pending_status.update(status: "sent")
          expect(@order_pending_status.errors[:status]).to include("customer can update status only from :sent to :delivered")
        end

        it "customer can't update status from :pending to :delivered" do
          @order_pending_status.instance_variable_set "@current_user_role", @order_pending_status.set_current_user_role(user_customer.id)
          @order_pending_status.update(status: "delivered")
          expect(@order_pending_status.errors[:status]).to include("customer can update status only from :sent to :delivered")
        end

        it "customer can update :arrival_type" do
          @order_pending_status.instance_variable_set "@current_user_role", @order_pending_status.set_current_user_role(user_customer.id)
          @order_pending_status.update(arrival_type: "dhl_express")
          expect(@order_pending_status.reload.arrival_type).to eq("dhl_express")
        end
      end

      context "for order with :sent status" do
        it "customer can update status from :sent to :delivered" do
          @order_sent_status.instance_variable_set "@current_user_role", @order_sent_status.set_current_user_role(user_customer.id)
          @order_sent_status.update(status: "delivered")
          expect(@order_sent_status).to be_valid
        end

        it "customer can't update status from :pending to :delivered" do
          @order_sent_status.instance_variable_set "@current_user_role", @order_pending_status.set_current_user_role(user_customer.id)
          @order_sent_status.update(status: "pending")
          expect(@order_sent_status.errors[:status]).to include("customer can update status only from :sent to :delivered")
        end

        it "customer can't update :arrival_type" do
          @order_sent_status.instance_variable_set "@current_user_role", @order_sent_status.set_current_user_role(user_customer.id)
          @order_sent_status.update(arrival_type: "dhl_express")
          expect(@order_sent_status.errors[:status]).to include("customer can update pending order except :status")
        end
      end
    end

  end
end
