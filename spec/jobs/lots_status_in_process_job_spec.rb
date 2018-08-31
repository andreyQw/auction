# frozen_string_literal: true

require "rails_helper"

RSpec.describe LotsStatusInProcessJob, type: :job do
  include ActiveJob::TestHelper
  ActiveJob::Base.queue_adapter = :test

  subject(:job) { described_class.perform_later(@lot.id) }
  before(:each) do
    @user = create :user
    @lot = create :lot, user: @user, status: :in_process
  end

  it "queues the job" do
    expect { job }
        .to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end

  it "is run job in correct time" do
    time = Time.now
    jid = LotsStatusInProcessJob.set(wait_until: time + 10.second).perform_later(@lot.id)
    expect(jid.scheduled_at).to eq((time + 10.second).to_f)
  end
end
