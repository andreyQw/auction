# frozen_string_literal: true

require "rails_helper"

RSpec.describe LotsStatusInProcessJob, type: :job do
  ActiveJob::Base.queue_adapter = :test
  # before(:each) do
  #
  # end

  it "matches with enqueued job" do

  end

end
