# frozen_string_literal: true

require "rails_helper"
include ActionController::RespondWith

RSpec.describe LotsController, type: :controller do

  describe "GET /lots" do

    it "doesn't give you anything if you don't log in" do
      get :index
      expect(response.status).to eq(401)
    end


    context "context: general authentication via API, " do
      login(:user)
      before(:each) do
        create_list :lot, 3, user: @user
      end

      it 'gives you a status 200 on signing in ' do
        get :index
        expect(response.status).to eq(200)
      end

      it "should return paginate with 2 lots" do
        get :index
        expect(JSON.parse(response.body, symbolize_names: true)[:data].count).to eq(2)
      end
    end
  end

  describe "Create lot" do
    login(:user)
    # subject { post :create, params: { lot: attributes_for(:lot, title: @lot.title) } }
    subject { post :create, params: { lot: attributes_for(:lot, @lot) } }

    before(:each) do
      @lot = build(:lot)
      @lot.user_id = @user.id
    end

    # subject { post :create }

    it "response for create should be success" do
      subject
      expect(response).to be_success
    end
  end
end
