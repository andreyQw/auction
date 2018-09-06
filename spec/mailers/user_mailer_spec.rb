# frozen_string_literal: true

require "rails_helper"

RSpec.describe UserMailer, type: :mailer do

  # let(:mail) { described_class.instructions(user).deliver_now }
  let(:mail_for_seller_lot_not_sold) { UserMailer.email_for_seller_lot_not_sold @lot }
  let(:mail_for_seller) { UserMailer.email_for_seller_lot_closed @lot }
  let(:mail_for_customer) { UserMailer.email_for_lot_winner @lot }

  let(:email_for_seller_order_was_created) { UserMailer.email_for_seller_order_was_created @order }
  let(:email_for_customer_lot_was_sent) { UserMailer.email_for_customer_lot_was_sent @order }

  let(:email_after_delivered_to_seller) { UserMailer.email_after_delivered_to_seller @order }
  let(:email_after_delivered_to_customer) { UserMailer.email_after_delivered_to_customer @order }

  before :each do
    @user_seller = create :user
    @user_customer = create :user
    @lot = create :lot, user: @user_seller, status: "in_process", current_price: 10.00, estimated_price: 20.00
  end

  context "lot mails" do
    context "email_for_lot_winner" do
      before :each do
        @bid = create :bid, user: @user_customer, lot: @lot, proposed_price: 30.00
      end

      it "check mail for customer won" do
        expect(mail_for_customer.to).to eq([@user_customer.email])
        expect(mail_for_customer.from).to eq(["from@example.com"])
        expect(mail_for_customer.body).to match /Follow this link: http:\/\/example.com\/lots\/#{@lot.id}/
      end

      it "check mail for seller" do
        expect(mail_for_seller.to).to eq([@user_seller.email])
        expect(mail_for_seller.from).to eq(["from@example.com"])
        expect(mail_for_seller.body).to match /Your lot - #{@lot.title}, was closed./
      end
    end

  end

  context "check mail for seller lot not sold" do
    it "should not sold" do
      expect(mail_for_seller_lot_not_sold.to).to eq([@user_seller.email])
      expect(mail_for_seller_lot_not_sold.from).to eq(["from@example.com"])
      expect(mail_for_seller_lot_not_sold.body).to match /Your lot - #{@lot.title}, was closed but not sold./
    end
  end

  context "Order" do
    let(:lot_closed) { create :lot, user_id: @user_seller.id, status: "closed", current_price: 10.00,
                              estimated_price: 20.00, bid_win: 1, user_win_id: @user_customer.id }

    before(:each) do
      @order = create :order, lot_id: lot_closed.id
    end

    context "Order create" do
      it "should sent mail to seller order was created" do
        expect(email_for_seller_order_was_created.to).to eq([@user_seller.email])
        expect(email_for_seller_order_was_created.from).to eq(["from@example.com"])
        expect(email_for_seller_order_was_created.body).to match /Order was created./
      end
    end

    context "Order update status on :sent" do
      before(:each) do
        @order.instance_variable_set "@current_user_role", @order.set_current_user_role(@user_seller.id)
        @order.update(status: "sent")
      end

      it "should sent mail for customer" do
        expect(email_for_customer_lot_was_sent.to).to eq([@user_customer.email])
        expect(email_for_customer_lot_was_sent.from).to eq(["from@example.com"])
        expect(email_for_customer_lot_was_sent.body).to match /Lot was sent./
      end
    end

    context "Order update status on :delivered" do
      before(:each) do
        @order.instance_variable_set "@current_user_role", @order.set_current_user_role(@user_customer.id)
        @order.update(status: "delivered")
      end

      it "should sent mail for seller and customer" do
        expect(email_after_delivered_to_seller.to).to eq([@user_seller.email])
        expect(email_after_delivered_to_customer.to).to eq([@user_customer.email])
        expect(email_after_delivered_to_seller.from).to eq(["from@example.com"])
        expect(email_after_delivered_to_seller.body).to match /Lot was delivered./
      end
    end
  end
end
