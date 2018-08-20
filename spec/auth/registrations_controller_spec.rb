# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Registration", type: :request do
  describe "POST create" do
    context "user regisration" do
      let(:data) do
        {
          email:                 "user@mail.co",
          phone:                 "1234567890",
          first_name:            "first name",
          last_name:             "last name",
          password:              "password",
          password_confirmation: "password",
          birthday:               22.years.ago
        }
      end

      subject { post "/auth", params: data }

      it "response should be success" do
        subject
        expect(response).to be_successful
      end

      it "creates new user" do
        expect {
          subject
        }.to change { User.count }.from(0).to(1)
      end

      it "sends a confirmation email" do
        expect { subject }.to change(Devise.mailer.deliveries, :count).by(1)
      end

      it "send a email confirmation with custom text" do
        subject
        confirmation_email = Devise.mailer.deliveries.last
        expect(data[:email]).to eq confirmation_email.to[0]
        expect(confirmation_email.body.to_s).to match /Welcome #{data[:email]}!/
      end

      it "email confirmation link" do
        subject
        confirmation_email = Devise.mailer.deliveries.last
        /href="(?<confirmation_link>.+)"/ =~ confirmation_email.body.to_s
        get confirmation_link
        expect(response.status).to eq 302
      end
    end
  end
end
