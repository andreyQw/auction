# frozen_string_literal: true

require "rails_helper"

RSpec.describe UserMailer, type: :mailer do

  # let(:mail) { described_class.instructions(user).deliver_now }
  let(:mail_for_seller) { UserMailer.email_for_seller_lot_closed @lot }
  let(:mail_for_customer) { UserMailer.email_for_lot_winner @lot }

  before :each do
    @user_seller = create :user
    @lot = create :lot, user: @user_seller, status: "in_process", current_price: 10.00, estimated_price: 20.00
  end

  context "lot mails" do
    context "email_for_lot_winner" do
      before :each do
        @user_customer = create :user
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
        expect(mail_for_seller.body).to match /Current price: #{@lot.current_price}/
      end
    end
  end
end
