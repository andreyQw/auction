# frozen_string_literal: true

require "rails_helper"
include ActionController::RespondWith

RSpec.describe LotsController, type: :controller do

  #
  describe "GET /lots" do

    it "redirected on auth/sign_in" do
      get :index
      expect(response.status).to eq(302)
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
        expect(json_parse[:data][:lots].count).to eq(2)
      end
    end
  end

  #
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
        expect(json_parse[:data][:title]).to eq(["can't be blank"])
      end
    end
  end

  #
  describe "GET /lots/:id" do
    login(:user)

    subject { get :show, params: { id: @lot.id } }

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
      subject { get :show, params: { id: 2 } }

      before(:each) do
        @lot = create(:lot, user: @user, status: :pending)
      end

      it "lot.id = 2 not found " do
        subject
        expect(response.status).to eq 404
        expect(json_parse).to eq(message: "Not found")
      end
    end
  end

  #
  describe "PUT /lots/:id" do
    login(:user)
    before(:each) do
      @lot = create :lot, user: @user, status: :pending
    end

    subject { put :update, params: { id: @lot.id, title: "New title" } }

    context "update with valid user and pending status" do
      it "update with creator user" do
        expect { subject } .to change { @lot.reload.title } .to("New title")
      end
    end

    context "update with valid user and not :pending status" do

      subject { put :update, params: { id: @lot.id, title: "New title" } }
      context ":inProgress" do
        before(:each) do
          @lot = create :lot, user: @user, status: :inProcess
        end

        it "update with creator user and :inProgress status" do
          subject
          expect(json_parse[:message]).to eq("user or status is not valid")
        end
      end

      context ":closed" do
        before(:each) do
          @lot = create :lot, user: @user, status: :closed
        end

        it "update with creator user" do
          subject
          expect(json_parse[:message]).to eq("user or status is not valid")
        end
      end
    end

    context "update with not valid user" do
      before(:each) do
        @user2 = create :user
        login_by_user @user2
      end

      it "update with not creator user reject" do
        subject
        expect(json_parse[:message]).to eq("user or status is not valid")
      end
    end
  end

  #
  describe "DELETE /lots/:id" do
    login(:user)

    before(:each) do
      @lot = create :lot, user: @user, status: :pending
    end

    subject { delete :destroy, params: { id: @lot.id } }

    context "delete with valid user and pending status" do
      it "delete with creator user" do
        subject
        expect(response.status).to eq 200
      end
    end

    context "delete with valid user and not :pending status" do

      context ":in_progress" do
        before(:each) do
          @lot = create :lot, user: @user, status: :inProcess
        end

        it "delete with creator user and :in_progress status" do
          subject
          expect(Lot.where(id: @lot.id).present?).to be
        end
      end

      context ":closed" do
        before(:each) do
          @lot = create :lot, user: @user, status: :closed
        end
        it "delete with creator user" do
          subject
          expect(Lot.where(id: @lot.id).present?).to be
        end
      end
    end

    context "delete with not valid user" do
      before(:each) do
        @user2 = create :user
        login_by_user @user2
      end

      it "delete with not creator user reject" do
        subject
        expect(Lot.where(id: @lot.id).present?).to be
        expect(json_parse[:message]).to eq("user or status is not valid")
      end
    end
  end

end
