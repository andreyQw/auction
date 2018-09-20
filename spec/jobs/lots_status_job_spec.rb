# frozen_string_literal: true

require "rails_helper"

RSpec.describe LotsStatusInProcessJob, type: :job do
  include ActiveJob::TestHelper

  subject(:job) { described_class.perform_later(@lot.id) }
  before(:each) do
    @user = create :user
    @lot = create :lot, user: @user, status: :in_process
  end

  it "queues the job" do
    expect { job }
        .to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end

end
