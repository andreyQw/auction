# frozen_string_literal: true

require "rails_helper"

describe LotPolicy do

  let(:seller) { create(:user) }
  let(:customer) { create(:user) }

  let(:lot_pending)   { build(:lot, user_id: seller.id) }
  let(:lot_in_process) { build(:lot_in_process, user_id: seller.id) }
  let(:lot_closed)    { build(:lot_closed, user_id: seller.id) }

  context "lot_pending" do
    context "seller" do
      subject { LotPolicy.new(seller, lot_pending) }
      it "create?" do
        expect(subject.create?).to be_truthy
      end
      it "update?" do
        expect(subject.update?).to be_truthy
      end
      it "destroy?" do
        expect(subject.destroy?).to be_truthy
      end
      it "show?" do
        expect(subject.show?).to be_truthy
      end
    end

    context "customer" do
      subject { LotPolicy.new(customer, lot_pending) }
      it "update?" do
        expect(subject.update?).to be_falsey
      end
      it "destroy?" do
        expect(subject.destroy?).to be_falsey
      end
      it "show?" do
        expect(subject.show?).to be_falsey
      end
    end
  end

  context "lot_in_process" do
    context "seller" do
      subject { LotPolicy.new(seller, lot_in_process) }
      it "update?" do
        expect(subject.update?).to be_falsey
      end
      it "destroy?" do
        expect(subject.destroy?).to be_falsey
      end
      it "show?" do
        expect(subject.show?).to be_truthy
      end
    end

    context "customer" do
      subject { LotPolicy.new(customer, lot_in_process) }
      it "update?" do
        expect(subject.update?).to be_falsey
      end
      it "destroy?" do
        expect(subject.destroy?).to be_falsey
      end
      it "show?" do
        expect(subject.show?).to be_truthy
      end
    end
  end

  context "lot_closed" do
    context "seller" do
      subject { LotPolicy.new(seller, lot_closed) }
      it "update?" do
        expect(subject.update?).to be_falsey
      end
      it "destroy?" do
        expect(subject.destroy?).to be_falsey
      end
      it "show?" do
        expect(subject.show?).to be_truthy
      end
    end

    context "customer" do
      subject { LotPolicy.new(customer, lot_closed) }
      it "update?" do
        expect(subject.update?).to be_falsey
      end
      it "destroy?" do
        expect(subject.destroy?).to be_falsey
      end
      it "show?" do
        expect(subject.show?).to be_falsey
      end
    end
  end

end
