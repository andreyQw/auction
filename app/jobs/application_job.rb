# frozen_string_literal: true

class ApplicationJob < ActiveJob::Base
  def get_value(string)
    string.split(":").last
  end
end
