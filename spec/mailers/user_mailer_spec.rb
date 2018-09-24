# frozen_string_literal: true

require "rails_helper"

RSpec.describe UserMailer, type: :mailer do

  let(:mail_for_seller_lot_not_sold) { UserMailer.email_for_seller_lot_not_sold lot_in_process }
  let(:mail_for_seller) { UserMailer.email_for_seller_lot_closed lot_in_process }
  let(:mail_for_customer) { UserMailer.email_for_lot_winner lot_in_process }

  let(:email_for_seller_order_was_created) { UserMailer.email_for_seller_order_was_created order }
  let(:email_for_customer_lot_was_sent) { UserMailer.email_for_customer_lot_was_sent order }

  let(:email_after_delivered_to_seller) { UserMailer.email_after_delivered_to_seller order }
  let(:email_after_delivered_to_customer) { UserMailer.email_after_delivered_to_customer order }

  let(:seller) { create(:user) }
  let(:customer) { create(:user) }
  let(:lot_in_process) { create(:lot_in_process, user_id: seller.id, current_price: 10.0) }

  context "lot mails" do
    context "email_for_lot_winner" do
      let!(:bid_win) { create :bid, user: customer, lot: lot_in_process, proposed_price: lot_in_process.estimated_price + 1 }

      it "check mail for customer won" do
        expect(mail_for_customer.to).to eq([customer.email])
        expect(mail_for_customer.from).to eq(["from@example.com"])
        expect(mail_for_customer.body).to match /Follow this link: http:\/\/example.com\/lots\/#{lot_in_process.id}/
      end

      it "check mail for seller" do
        expect(mail_for_seller.to).to eq([seller.email])
        expect(mail_for_seller.from).to eq(["from@example.com"])
        expect(mail_for_seller.body).to match /Your lot - #{lot_in_process.title}, was closed./
      end
    end
  end

  context "check mail for seller lot not sold" do
    it "should not sold" do
      expect(mail_for_seller_lot_not_sold.to).to eq([seller.email])
      expect(mail_for_seller_lot_not_sold.from).to eq(["from@example.com"])
      expect(mail_for_seller_lot_not_sold.body).to match /Your lot - #{lot_in_process.title}, was closed but not sold./
    end
  end

  context "Order" do
    let(:lot_closed) { create :lot, user_id: seller.id, status: :closed, user_win_id: customer.id }

    let!(:order) { create :order, lot_id: lot_closed.id }

    context "Order create" do
      it "should sent mail to seller order was created" do
        expect(email_for_seller_order_was_created.to).to eq([seller.email])
        expect(email_for_seller_order_was_created.from).to eq(["from@example.com"])
        expect(email_for_seller_order_was_created.body).to match /Order was created./
      end
    end

    context "Order update status on :sent" do
      before(:each) do
        order.update(status: "sent")
      end

      it "should sent mail for customer" do
        expect(email_for_customer_lot_was_sent.to).to eq([customer.email])
        expect(email_for_customer_lot_was_sent.from).to eq(["from@example.com"])
        expect(email_for_customer_lot_was_sent.body).to match /Lot was sent./
      end
    end

    context "Order update status on :delivered" do
      before(:each) do
        order.update(status: "delivered")
      end

      it "should sent mail for seller and customer" do
        expect(email_after_delivered_to_seller.to).to eq([seller.email])
        expect(email_after_delivered_to_customer.to).to eq([customer.email])
        expect(email_after_delivered_to_seller.from).to eq(["from@example.com"])
        expect(email_after_delivered_to_seller.body).to match /Lot was delivered./
      end
    end
  end
end
