require "rails_helper"
# frozen_string_literal: true

RSpec.describe "Login", type: :request do
  describe "POST login" do

    let(:data) do
      {
          email: Faker::Internet.free_email,
          password: "password"
      }
    end

    before(:each) do
      @user = create :user, data
    end

    context "when user was logged successful" do
      subject { post "/auth/sign_in", params: data }

      it "response should be success" do
        subject
        expect(response).to be_successful
      end
    end

    context "when user was logout successful" do
      before(:each) do
        @logged_user_headers = create(:user).create_new_auth_token
      end

      it "response should be success" do
        delete "/auth/sign_out", headers: @logged_user_headers
        expect(response).to be_successful
      end
    end

    context "when user try login with wrong parameters" do
      it "response should be 401 status with wrong password" do
        post "/auth/sign_in", params: { email: data[:email], password: "wrong_password" }
        expect(response.status).to eq 401
      end

      it "response should be 401 status with wrong email" do
        post "/auth/sign_in", params: { email: "some_prefix_" + data[:email], password: data[:password] }
        expect(response.status).to eq 401
      end
    end
  end
end
