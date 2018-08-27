require 'rails_helper'

RSpec.describe LotsStatusJob, type: :job do
  ActiveJob::Base.queue_adapter = :test
  # before(:each) do
  #
  # end

  it "matches with enqueued job" do
    ActiveJob::Base.queue_adapter = :test
    expect {
      LotsStatusJob.set(:wait_until => Date.tomorrow.noon).perform_later
    }.to have_enqueued_job.at(Date.tomorrow.noon)
  end
  # pending "add some examples to (or delete) #{__FILE__}"
end
