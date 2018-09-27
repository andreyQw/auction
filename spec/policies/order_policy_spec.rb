# frozen_string_literal: true

require "rails_helper"
require "sidekiq/testing"

describe OrderPolicy do
  after(:all) do
    Sidekiq::ScheduledSet.new.clear
  end

  let(:seller)  { create(:user) }
  let(:customer) { create(:user) }

  let(:lot_closed) { create(:lot_closed, user_id: seller.id, user_win_id: customer.id) }

  let(:order_pending)   { build(:order, lot_id: lot_closed.id, status: :pending) }
  let(:order_sent)      { build(:order, lot_id: lot_closed.id, status: :sent) }
  let(:order_delivered) { build(:order, lot_id: lot_closed.id, status: :delivered) }

  context "order_pending" do
    context "seller" do
      subject { OrderPolicy.new(seller, order_pending) }
      it "create?" do
        expect(subject.create?).to be_falsey
      end
      it "show?" do
        expect(subject.show?).to be_truthy
      end
      it "update?" do
        expect(subject.update?).to be_falsey
      end
      it "destroy?" do
        expect(subject.destroy?).to be_falsey
      end

      it "update_status_to_sent?" do
        expect(subject.update_status_to_sent?).to be_truthy
      end
      it "update_status_to_delivered?" do
        expect(subject.update_status_to_delivered?).to be_falsey
      end
    end

    context "customer" do
      subject { OrderPolicy.new(customer, order_pending) }
      it "create?" do
        expect(subject.create?).to be_truthy
      end
      it "update?" do
        expect(subject.update?).to be_truthy
      end
      it "destroy?" do
        expect(subject.destroy?).to be_falsey
      end
      it "show?" do
        expect(subject.show?).to be_truthy
      end

      it "update_status_to_sent?" do
        expect(subject.update_status_to_sent?).to be_falsey
      end
      it "update_status_to_delivered?" do
        expect(subject.update_status_to_delivered?).to be_falsey
      end
    end
  end
end
