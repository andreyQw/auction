# frozen_string_literal: true

require "rails_helper"

RSpec.describe UserSerializer, type: :serializer do

  describe "attributes" do
    it "should include size as an attribute" do
      user = build(:user)

      user_serialized = obj_serialization(user, serializer: UserSerializer)

      expected_keys = [:id, :email, :phone, :first_name, :last_name, :birthday]

      expect(json_parse(user_serialized)[:user].keys).to eq(expected_keys)
    end
  end
end
