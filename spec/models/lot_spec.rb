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
  after(:all) do
    Sidekiq::ScheduledSet.new.clear
  end

  let(:seller) { create(:user) }
  let(:customer) { create(:user) }
  let(:lot_pending) { create(:lot, user_id: seller.id) }

  context "Validation" do
    time_more_now = Time.zone.now + 1.hour
    time_less_now = Time.zone.now - 1.hour

    context "lot_start_time_must_be_more_than_now" do
      it "should be valid" do
        lot = build(:lot, user_id: seller.id, lot_start_time: time_more_now, lot_end_time: time_more_now + 1.hour)
        expect(lot).to be_valid
      end

      it "should not be valid, lot_start_time less than current time" do
        lot = build(:lot, user_id: seller.id, lot_start_time: time_less_now, lot_end_time: time_less_now + 1.hour)
        expect(lot).to_not be_valid
        expect(lot.errors.messages).to eq lot_start_time: ["Lot START time can't be less than current time"]
      end
    end

    context "lot_end_time_must_be_more_lot_start_time" do
      it "should be valid: lot_end_time > lot_start_time" do
        lot = build(:lot, user_id: seller.id, lot_start_time: time_more_now, lot_end_time: time_more_now + 1.hour)
        expect(lot).to be_valid
      end

      it "should not be valid: lot_end_time < lot_start_time" do
        lot = build(:lot, user_id: seller.id, lot_start_time: time_more_now, lot_end_time: time_more_now - 1.hour)
        expect(lot).to_not be_valid
        expect(lot.errors.messages).to eq lot_end_time: ["Lot END time can't be less than lot START time"]
      end
    end
  end


  context "Lot methods" do

    context "push_job_id_to_lot" do
      it "should push_job_id_to_lot" do
        lot = create(:lot, user_id: seller.id)

        expect(lot.job_id_in_process).to_not be_nil
        expect(lot.job_id_closed).to_not be_nil
      end
    end

    context "add_lot_jobs" do
      before(:each) do
        Sidekiq::ScheduledSet.new.clear
      end
      it "should add jobs" do
        Sidekiq::Testing.disable!

        lot = build(:lot, user_id: seller.id)
        jobs_id = lot.add_lot_jobs
        expect(Sidekiq::ScheduledSet.new.size).to eq 2
        expect(Sidekiq::ScheduledSet.new.find_job(jobs_id[:job_id_in_process])).to be_truthy
        expect(Sidekiq::ScheduledSet.new.find_job(jobs_id[:job_id_closed])).to be_truthy
        Sidekiq::ScheduledSet.new.clear
      end

      it "should return jobs hash" do
        lot = build(:lot, user_id: seller.id)

        jobs_id = lot.add_lot_jobs
        expect(jobs_id).to include(:job_id_in_process, :job_id_closed)
        expect(jobs_id[:job_id_in_process]).to_not be_nil
        expect(jobs_id[:job_id_closed]).to_not be_nil
      end
    end

    context "Save lot.image" do
      it "should save image" do
        expect(lot_pending.image.to_s).to eq("/uploads/test/lot/image/#{lot_pending.id}/no_image.gif")
        expect(File.file?("#{Rails.root}/public" + lot_pending.image.to_s)).to be true
      end
    end
  end
end
