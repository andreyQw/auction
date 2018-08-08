# frozen_string_literal: true

require "rails_helper"

RSpec.describe User, type: :model do
  it "if User.count changed by 1" do
    expect { create(:user) }.to change(User, :count).by(1)
  end
end
