# frozen_string_literal: true

require "rails_helper"

RSpec.describe OrdersController, type: :controller do

  describe "POST /orders" do
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

  describe "PUT /orders" do
    login(:user)

    before(:each) do
      @user_customer = create(:user)
      @lot = create(:lot, user_id: @user.id, status: :in_process, current_price: 10.00, estimated_price: 15.00)
      @bid = create(:bid, proposed_price: 20.00, lot_id: @lot.id, user_id: @user_customer.id)
      @order = create(:order, lot_id: @lot.id, status: "pending")
    end

    context "seller try update order status from :pending to :sent" do
      subject { put :update, params: { id: @lot.id, status: "sent" } }
      it "should update" do
        subject
        keys = [:id, :lot_id, :status, :arrival_type, :arrival_location]
        expect(json_parse_response_body[:resource].keys).to eq(keys)
      end
    end

    context "seller try update order with :sent status and arrival_type, arrival_location params" do
      subject { put :update, params: { id: @lot.id, status: "sent", arrival_type: "dhl_express", arrival_location: "kiev" } }
      it "should not update with arrival_type, arrival_location field" do
        subject
        expect(json_parse_response_body[:errors][:base]).to eq(["seller can update only status field and it must be from :pending to :sent"])
      end
    end

    context "seller try update order status from :pending to :delivered" do
      subject { put :update, params: { id: @lot.id, status: "delivered" } }
      it "should update with from :pending to :sent" do
        subject
        expect(json_parse_response_body[:errors][:base]).to eq(["seller can update only status field and it must be from :pending to :sent"])
      end
    end


    context "customer try update with :sent status" do
      before(:each) do
        login_by_user(@user_customer)
      end
      subject { put :update, params: { id: @lot.id, status: "sent" } }
      it "should update" do
        subject
        expect(json_parse_response_body[:errors][:status]).to include("customer can update status field only from :sent to :delivered")
        # expect { subject } .to change { @lot.reload.title } .to("New title")
      end
    end

    context "customer try update with :sent status" do
      before(:each) do
        login_by_user(@user_customer)
        @order.status
      end
      subject { put :update, params: { id: @lot.id, status: "sent" } }
      it "should update" do
        subject
        expect(json_parse_response_body[:errors][:status]).to include("customer can update status field only from :sent to :delivered")
        # expect { subject } .to change { @lot.reload.title } .to("New title")
      end
    end

  end


end
