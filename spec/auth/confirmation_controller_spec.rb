
# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Passwords", type: :request do
  before(:each) do
    @user = create(:user, confirmed_at: nil)
  end
  subject do
    get "/auth/confirmation", params: {
        config:             "default",
        confirmation_token: @user.confirmation_token,
        redirect_url:       "http://example.com/",
    }
  end
  describe "GET auth/confirmation" do
    it "should respond with success" do
      subject
      expect(response).to be_redirect
      expect(@user.reload.confirmed_at.nil?).to be_falsey
    end
  end
end
