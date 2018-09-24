# frozen_string_literal: true

require "rails_helper"

RSpec.describe BidsChannel, type: :channel do
  before do
    # initialize connection with identifiers
    # stub_connection user_id: user.id

    @user = create :user
    @lot = create :lot, current_price: 15.00, status: :in_process, user: @user
  end

  it "rejects when no lot_id id" do
    subscribe
    expect(subscription).to be_rejected
  end

  it "subscribes to a stream when lot id is provided" do
    subscribe(lot_id: @lot.id)

    expect(subscription).to be_confirmed
    expect(streams).to include("bids_for_lot_#{@lot.id}")
  end
end
