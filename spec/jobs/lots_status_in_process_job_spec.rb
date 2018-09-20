# frozen_string_literal: true

require "rails_helper"

RSpec.describe LotsStatusInProcessJob, type: :job do
  include ActiveJob::TestHelper

  let(:seller) { create(:user) }
  let(:lot) { create(:lot, user_id: seller.id) }

  it "should add 2 jobs in queues" do
    expect { lot }
        .to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(2)
    expect(ActiveJob::Base.queue_adapter.enqueued_jobs.first[:job].to_s).to eq("LotsStatusInProcessJob")
    expect(ActiveJob::Base.queue_adapter.enqueued_jobs.last[:job].to_s).to eq("LotsStatusClosedJob")
  end

  it "should run job in correct time" do
    time = Time.now
    job = LotsStatusInProcessJob.set(wait_until: time + 10.second).perform_later(lot.id)
    expect(job.scheduled_at).to eq((time + 10.second).to_f)
  end
end
