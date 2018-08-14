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

      it "gives you a status 200 on signing in " do
        get :index
        expect(response.status).to eq(200)
      end

      it "should return paginate with 2 lots" do
        get :index
        expect(JSON.parse(response.body, symbolize_names: true)[:data].count).to eq(2)
      end
    end
  end

  describe "POST /lots" do
    login(:user)
    subject { post :create, params: {
        title: @lot.title,
        current_price: @lot.current_price,
        estimated_price: @lot.estimated_price,
        lot_start_time: @lot.lot_start_time,
        lot_end_time: @lot.lot_end_time,
      }
    }
    context "valid title" do
      before(:each) do
        @lot = build(:lot)
      end

      it "response for create should be success" do
        subject
        expect(response).to be_success
      end

    end

    context "not valid title" do
      before(:each) do
        @lot = build(:lot)
        @lot.title = nil
      end
      it "not valid " do
        subject
        # expect(parse_json_string(response.body)[:errors][:title]).to eq(["can't be blank"])
        expect(JSON.parse(response.body, symbolize_names: true)[:data][:title]).to eq(["can't be blank"])
      end
    end
  end

  describe "GET /lots/:id" do
    login(:user)
    subject { get :show, params: { id: @lot.id }}
    context "show lot details " do
      before(:each) do
        @lot = create(:lot, user: @user, status: :pending)
      end

      it "response lot" do
        subject
        expect(response).to be_success
      end
    end

    context "lot not found" do
      subject { get :show, params: { id: 2 }}
      before(:each) do
        @lot = create(:lot, user: @user, status: :pending)
      end
      it "lot.id = 2 not found " do
        subject
        # expect(parse_json_string(response.body)[:errors][:title]).to eq(["can't be blank"])
        expect(JSON.parse(response.body, symbolize_names: true)[:data][:title]).to eq(["can't be blank"])
      end
    end
  end

end
