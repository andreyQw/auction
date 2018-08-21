# frozen_string_literal: true

require "rails_helper"
include ActionController::RespondWith

RSpec.describe LotsController, type: :controller do

  #
  describe "GET /lots" do

    it "error - You need to sign_in/sign_up" do
      get :index
      expect(response.status).to eq(401)
    end

    context "context: path with login, " do
      login(:user)

      before(:each) do
        create_list :lot, 3, user: @user
      end

      it "gives you a status 200 after sign_in " do
        get :index
        expect(response.status).to eq(200)
      end

      context "should return all lots" do
        # config.default_per_page = 10
        before(:each) do
          create_list :lot, 10, user: @user
          create_list :lot, 10, user: @user, status: :in_process
          create_list :lot, 2, user: @user, status: :closed

          @user2 = create :user
          create :lot, user: @user2
          create :lot, user: @user2, status: :in_process
          create :lot, user: @user2, status: :closed
        end

        it "should return 10 lots without params" do
          get :index
          expect(json_parse_response_body[:resources].count).to eq(10)
        end

        it "should return 1 lots with page 2, and meta(pagination)" do
          get :index, params: { page: 2 }
          expect(json_parse_response_body[:resources].count).to eq(1)
          expect(json_parse_response_body[:meta].count).to be
        end

        it "should return 10 lots belongs_to user" do
          # get :index, params: { page: 2, user_id: @user2.id }
          get :index, params: { user_id: @user.id }
          expect(json_parse_response_body[:resources].count).to eq(10)
        end

        it "should return 3 lots not belongs_to user" do
          get :index, params: { user_id: @user2.id }
          expect(json_parse_response_body[:resources].count).to eq(3)
        end

        it "should return correct fields" do
          get :index,  params: { user_id: @user.id }

          lot_attributes = [
              :id, :user_id, :title, :image, :description, :status, :current_price,
              :estimated_price, :lot_start_time, :lot_end_time, :user
          ]

          expect(json_parse_response_body[:resources][0].keys).to eq(lot_attributes)
        end
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
    context "create lot valid" do
      before(:each) do
        @lot = build(:lot)
      end

      it "response for create should be success" do
        subject
        expect(response).to be_successful
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
        expect(response).to be_successful
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
        expect(json_parse_response_body).to eq(message: "Not found")
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

    context "update with valid user and :pending status" do
      it "should update" do
        expect { subject } .to change { @lot.reload.title } .to("New title")
      end
    end

    context "update with valid user and not valid status" do

      subject { put :update, params: { id: @lot.id, title: "New title" } }
      context ":in_process" do
        before(:each) do
          @lot = create :lot, user: @user, status: :in_process
        end

        it "update with creator user and :in_process status" do
          subject
          expect(json_parse_response_body[:error]).to eq("You are not authorized for this action")
        end
      end

      context ":closed" do
        before(:each) do
          @lot = create :lot, user: @user, status: :closed
        end

        it "update with creator user and :closed status" do
          subject
          expect(json_parse_response_body[:error]).to eq("You are not authorized for this action")
        end
      end
    end

    context "update with not valid user" do
      before(:each) do
        @user2 = create :user
        login_by_user @user2
      end

      it "update with not creator - error" do
        subject
        expect(json_parse_response_body[:error]).to eq("You are not authorized for this action")
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
      it "should delete" do
        subject
        expect(response.status).to eq 200
      end
    end

    context "delete with valid user and not :pending status" do

      context ":in_process" do
        before(:each) do
          @lot = create :lot, user: @user, status: :in_process
        end

        it "should not delete (status: :in_process)" do
          subject
          expect(Lot.where(id: @lot.id).present?).to be
        end
      end

      context ":closed" do
        before(:each) do
          @lot = create :lot, user: @user, status: :closed
        end
        it "should not delete (status: :closed)" do
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

      it "should not delete (user no owner)" do
        subject
        expect(Lot.where(id: @lot.id).present?).to be
        expect(json_parse_response_body[:error]).to eq("You are not authorized for this action")
      end
    end
  end

end
