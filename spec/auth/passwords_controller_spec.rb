# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Passwords", type: :request do

  let!(:user) { create(:user) }

  describe "POST create" do
    subject { post "/auth/password", params: { email: user.email, redirect_url: "http://example.com/" } }

    it "should respond with success" do
      subject
      expect(response).to be_successful
    end
  end

  describe "GET edit" do
    before do
      raw, enc = Devise.token_generator.generate(User, :reset_password_token)
      @user = create(:user, reset_password_token: enc, reset_password_sent_at: Time.now.utc)
      @token = raw
    end

    subject do
      get "/auth/password/edit", params: {
        reset_password_token: @token,
        redirect_url: "http://example.com/"
      }
    end

    it "should respond with redirect" do
      expect { subject }.to change { @user.reload.allow_password_change }.from(false).to(true)
      expect(response).to be_redirect
    end

    it "should change user's reset token" do
      subject
      expect(@user.reload.reset_password_token).to eq @token
    end
  end

  describe "PUT create" do
    context "when password_changed" do
      subject { put "/auth/password", params: {
          encrypted_password:    "password",
          password:              "new_password",
          password_confirmation: "new_password"
      }, headers: user.create_new_auth_token }

      it "should respond with success" do
        subject
        expect(response).to be_successful
        expect(JSON.parse(response.body, symbolize_names: true)[:message]).to eq("Your password has been successfully updated.")
      end
    end

    context "when password restored" do
      before do
        @user = create(:user, reset_password_sent_at: Time.now.utc, allow_password_change: true)
      end

      subject { put "/auth/password", params: {
          password:              "new_password",
          password_confirmation: "new_password"
      }, headers: @user.create_new_auth_token }

      it "should respond with success" do
        expect { subject }.to change { @user.reload.allow_password_change }.from(true).to(false)
        expect(response).to be_successful
        expect(JSON.parse(response.body, symbolize_names: true)[:message]).to eq("Your password has been successfully updated.")
      end
    end
  end
end
