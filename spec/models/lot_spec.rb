# frozen_string_literal: true

# == Schema Information
#
# Table name: lots
#
#  id                :integer          not null, primary key
#  bid_win           :integer
#  current_price     :float            not null
#  description       :string
#  estimated_price   :float            not null
#  image             :string
#  job_id_closed     :string
#  job_id_in_process :string
#  lot_end_time      :datetime         not null
#  lot_start_time    :datetime         not null
#  status            :integer          default("pending")
#  title             :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  user_id           :integer
#  user_win_id       :integer
#
# Indexes
#
#  index_lots_on_status   (status)
#  index_lots_on_user_id  (user_id)
#

require "rails_helper"
require "sidekiq/testing"

RSpec.describe Lot, type: :model do

  let(:seller) { create(:user) }
  let(:lot_pending) { create(:lot, user_id: seller.id) }

  it "+ should be valid 1)if lot_start_time_must_be_more_than_now 2)lot_end_time_must_be_more_lot_start_time" do
    time_more_now = Time.zone.now + 1.hour
    lot = build(:lot, user_id: seller.id, lot_start_time: time_more_now, lot_end_time: time_more_now + 1.hour)
    expect(lot).to be_valid
  end

  it "- should be not valid 1)if lot_start_time less than current time" do
    time_less_now = Time.zone.now - 1.hour
    lot = build(:lot, user_id: seller.id, lot_start_time: time_less_now, lot_end_time: time_less_now + 2.hour)
    expect(lot).to_not be_valid
    expect(lot.errors.messages).to eq lot_start_time: ["Lot START time can't be less than current time"]
  end

  it "- should be not valid 2)if lot_end_time less than lot_start_time" do
    time_more_now = Time.zone.now + 1.hour
    lot = build(:lot, user_id: seller.id, lot_start_time: time_more_now, lot_end_time: time_more_now - 1.hour)
    expect(lot).to_not be_valid
    expect(lot.errors.messages).to eq lot_end_time: ["Lot END time can't be less than lot START time"]
  end

  it "should save image" do
    lot = lot_pending
    expect(lot.image.to_s).to eq("/uploads/test/lot/image/#{lot.id}/no_image.gif")
    expect(File.file?("#{Rails.root}/public" + lot.image.to_s)).to be true
  end

  it "should add_lot_jobs" do
    Sidekiq::Testing.disable!
    # Sidekiq::Testing.fake!
    lot = lot_pending
    expect(Sidekiq::ScheduledSet.new.size).to eq 2
    expect(Sidekiq::ScheduledSet.new.find_job(lot.job_id_in_process)).to be_truthy
    expect(Sidekiq::ScheduledSet.new.find_job(lot.job_id_closed)).to be_truthy
    Sidekiq::ScheduledSet.new.clear
  end

  it "should push_job_id_to_lot" do
    lot = build(:lot, user_id: seller.id)
    expect(lot.add_lot_jobs).to include(:job_id_in_process, :job_id_closed)
  end

  it "should delete_jobs" do
    Sidekiq::Testing.disable!
    lot = create(:lot, user_id: seller.id)
    lot.delete_jobs
    expect(Sidekiq::ScheduledSet.new.size).to eq 0
  end

end
