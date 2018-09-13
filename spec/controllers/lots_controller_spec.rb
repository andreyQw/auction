# frozen_string_literal: true

require "rails_helper"
require "sidekiq/testing"

RSpec.describe LotsController, type: :controller do

  describe "GET /lots" do
    include ActiveJob::TestHelper
    after { clear_enqueued_jobs }

    context "not authenticated" do
      it "error for index - You need to sign_in/sign_up" do
        get :index
        expect(response.status).to eq(401)
        expect(json_parse_response_body[:errors]).to include("You need to sign in or sign up before continuing.")
      end

      it "error for create - You need to sign_in/sign_up" do
        post :create, params: attributes_for(:lot)
        expect(response.status).to eq(401)
      end

      it "error for show" do
        get :show, params: { id: 1 }
        expect(response.status).to eq(401)
      end

      it "error for update" do
        put :update, params: { id: 1, title: "New title" }
        expect(response.status).to eq(401)
      end

      it "error for destroy" do
        delete :destroy, params: { id: 1 }
        expect(response.status).to eq(401)
      end
    end

    context "context: path with login" do
      login(:user)
      let(:user2) { create(:user) }

      # lots for @user
      let(:lots_pending) { create_list(:lot, 10, user_id: @user.id) }
      let(:lots_in_process) { create_list(:lot_in_process, 10, user_id: @user.id) }
      let(:lots_closed) { create_list(:lot_closed, 10, user_id: @user.id) }

      let(:lot_for_bid) { create(:lot_in_process, user_id: @user.id) }

      # lots for user2
      let(:user2_lot_pending)   { create(:lot, user_id: user2.id) }
      let(:user2_lot_in_process) { create(:lot_in_process, user_id: user2.id) }
      let(:user2_lot_closed)    { create(:lot_closed, user_id: user2.id) }

      # bis with :lot_for_bid and :user2
      let(:bid_not_win) { create(:bid, lot_id: lot_for_bid.id, user_id: user2.id, proposed_price: 15) }
      let(:bid_win)     { create(:bid, lot_id: lot_for_bid.id, user_id: user2.id, proposed_price: 25) }


      context "Pagination and lot without filter" do
        before(:each) do
          lots_pending # owner @user, quantity 10
          lots_in_process # owner @user, quantity 10
          lots_closed # owner @user, quantity 10

          user2_lot_pending # owner user2, quantity 1
          user2_lot_in_process # owner user2, quantity 1
          user2_lot_closed # owner user2, quantity 1
        end

        it "should return first 10 lots, without params (lots with status: :in_process)" do
          get :index
          expect(json_parse_response_body[:resources].count).to eq(10)
          expect(response.body).to include(collection_serialize(lots_in_process, "LotSerializer"))
          expect(json_parse_response_body[:resources]).to all(include(status: "in_process"))
        end

        it "should return 1 lot with status in_process, with page 2, and meta(pagination)" do
          current_page = 2
          get :index, params: { page: current_page }
          expect(json_parse_response_body[:resources].count).to eq(1)
          expect(json_parse_response_body[:meta][:current_page]).to eq(current_page)
          expect(json_parse_response_body[:resources]).to eq([json_parse(obj_serialization(user2_lot_in_process, serializer: LotSerializer))[:lot]])
        end

        it "serializer: should return correct fields" do
          get :index
          lot_attributes = [:id, :user_id, :title, :image, :description, :status, :current_price,
                            :estimated_price, :lot_start_time, :lot_end_time, :bid_win, :user_win_id, :job_id_in_process, :job_id_closed, :bids]
          expect(json_parse_response_body[:resources].first.keys).to eq(lot_attributes)
        end
      end

      context "Check filter lots" do
        before(:each) do
          login_by_user(user2)

          user2_lot_pending # owner user2, quantity 1
          user2_lot_in_process # owner user2, quantity 1
          user2_lot_closed # owner user2, quantity 1

          lot_for_bid # owner @user - seller
          bid_not_win # user2 - customer
        end

        it "should return lots with: filter == 'all' (all his lot and lots where he take path)" do
          get :index,  params: { filter: "all" }
          lots = json_parse_response_body[:resources]
          expect(lots.count).to eq(4) # user2 has: 3 own lots and 1 he take path
        end

        it "should return: filter == 'created' (all his lot with any statuses)" do
          get :index,  params: { filter: "created" } # user2 has 3 lots with different statuses
          lots = json_parse_response_body[:resources]
          expect(lots.count).to eq(3)
          expect(lots).to all(include(user_id: user2.id))
        end

        it "should return lots with: filter == 'participation' (all lots where @user2 take path)" do
          get :index,  params: { filter: "participation" }
          lots = json_parse_response_body[:resources]
          expect(lots.count).to eq(1)  # user2 take path in 1 lot
        end

      end
    end
  end

  describe "POST /lots" do

    include ActiveJob::TestHelper

    login(:user)

    time = Time.zone.now

    context "create lot valid" do
      it "response for create should be success" do
        post :create, params: attributes_for(:lot)
        expect(response).to be_successful
      end
    end

    context "create lot not valid" do
      it "response for create should be success" do
        post :create, params: attributes_for(:lot, lot_start_time: time - 60.second, lot_end_time: time - 120.second, status: :pending)
        expect(json_parse_response_body[:errors]).to be_truthy
      end
    end
  end

  describe "GET /lots/:id" do

    include ActiveJob::TestHelper

    login(:user)
    let(:user2) { create(:user) }

    let(:lot_pending)   { create(:lot, user_id: @user.id) }
    let(:lot_in_process) { create(:lot_in_process, user_id: @user.id) }
    let(:lot_closed)    { create(:lot_closed, user_id: @user.id) }

    context "should show for owner" do
      # subject { get :show, params: { id: lot_pending.id } } # owner - @user, status - in_process
      before(:each) do
        # login - @user
        lot_pending # owner - @user, status - pending
        lot_in_process # owner - @user, status - lot_in_process
        lot_closed # owner - @user, status - lot_closed
      end

      it "should show :pending" do
        get :show, params: { id: lot_pending.id }
        lot = json_parse_response_body[:resource]
        expect(response).to be_successful
        expect(lot[:id]).to eq(lot_pending.id)
      end

      it "should show :lot_in_process" do
        get :show, params: { id: lot_in_process.id }
        lot = json_parse_response_body[:resource]
        expect(lot[:id]).to eq(lot_in_process.id)
      end

      it "should show :lot_closed" do
        get :show, params: { id: lot_closed.id }
        lot = json_parse_response_body[:resource]
        expect(lot[:id]).to eq(lot_closed.id)
      end
    end

    context "show for not owner(must see only :in_process lot)" do
      before(:each) do
        login_by_user(user2)
      end

      it "should show :in_process" do
        get :show, params: { id: lot_in_process.id }
        lot = json_parse_response_body[:resource]
        expect(response).to be_successful
        expect(lot[:id]).to eq(lot_in_process.id)
      end

      it "should not show :pending" do
        get :show, params: { id: lot_pending.id }
        expect(response.status).to eq(401)
        expect(json_parse_response_body[:error]).to include("You are not authorized for this action")
      end

      it "should not show :closed" do
        get :show, params: { id: lot_closed.id }
        expect(response.status).to eq(401)
        expect(json_parse_response_body[:error]).to include("You are not authorized for this action")
      end
    end

    context "lot not found" do
      it "try get not exist lot" do
        no_exist_lot_id = 1
        get :show, params: { id: no_exist_lot_id }
        expect(response.status).to eq 404
        expect(json_parse_response_body).to eq(message: "Not found")
      end
    end
  end

  describe "PUT /lots/:id" do

    include ActiveJob::TestHelper

    login(:user)
    let(:user2) { create(:user) }

    let(:lot_pending)   { create(:lot, user_id: @user.id) }
    let(:lot_in_process) { create(:lot_in_process, user_id: @user.id) }
    let(:lot_closed)    { create(:lot_closed, user_id: @user.id) }

    context "update with valid user" do
      it "should update lot, with :pending status" do
        expect { put :update, params: { id: lot_pending.id, title: "New title" } }.to change{ lot_pending.reload.title }.to("New title")
      end

      it "should not update lot, with :in_process status" do
        put :update, params: { id: lot_in_process.id, title: "New title" }
        expect(response.status).to eq 401
        expect(json_parse_response_body).to eq(error: "You are not authorized for this action")
      end

      it "should not update lot, with :closed status" do
        put :update, params: { id: lot_closed.id, title: "New title" }

        expect(json_parse_response_body).to eq(error: "You are not authorized for this action")
      end
    end

    context "update with not valid user" do
      before(:each) do
        login_by_user(user2)
      end

      it "should not update" do
        put :update, params: { id: lot_pending.id, title: "New title" }
        expect(response.status).to eq 401
        expect(json_parse_response_body).to eq(error: "You are not authorized for this action")
      end
    end


  end

  describe "DELETE /lots/:id" do

    let(:user2) { create(:user) }

    let(:lot_pending)   { create(:lot, user_id: @user.id) } # lot with status: :pending
    let(:lot_in_process) { create(:lot_in_process, user_id: @user.id) } # lot with status: :in_process
    let(:lot_closed)    { create(:lot_closed, user_id: @user.id) } # lot with status: :closed

    context "not authenticated" do
      it "error for index - You need to sign_in/sign_up" do
        delete :destroy, params: { id: 1 }
        expect(response.status).to eq(401)
        expect(json_parse_response_body[:errors]).to include("You need to sign in or sign up before continuing.")
      end
    end

    context "delete with valid user" do
      login(:user)

      it "should delete lot with :pending status and jobs" do
        Sidekiq::Testing.disable!
        delete :destroy, params: { id: lot_pending.id }
        expect(response.status).to eq 200
        expect(@user.lots.count).to eq 0
        expect(Sidekiq::ScheduledSet.new.size).to eq 0
      end

      it "should not delete (status: :in_process)" do
        Sidekiq::Testing.fake!
        delete :destroy, params: { id: lot_in_process.id }
        expect(@user.lots.count).to eq 1
        expect(json_parse_response_body[:error]).to eq("You are not authorized for this action")
      end

      it "should not delete (status: :closed)" do
        Sidekiq::Testing.fake!
        delete :destroy, params: { id: lot_closed.id }
        expect(@user.lots.count).to eq 1
        expect(json_parse_response_body[:error]).to eq("You are not authorized for this action")
      end
    end

    context "delete with not valid user" do
      include ActiveJob::TestHelper
      login(:user)
      before(:each) do
        lot_pending # lot with @user owner
        login_by_user(user2)
      end

      it "should not delete" do
        delete :destroy, params: { id: lot_pending.id }
        expect(@user.lots.count).to eq 1
        expect(json_parse_response_body[:error]).to eq("You are not authorized for this action")
      end
    end

  end
end
