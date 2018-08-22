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

      context "should return all lots" do
        # config.default_per_page = 10
        before(:each) do
          create_list :lot, 10, user: @user
          @lots_in_process = create_list :lot, 10, user: @user, status: :in_process
          create_list :lot, 2, user: @user, status: :closed

          @user2 = create :user
          create :lot, user: @user2
          @lots_in_process_page_2 = create :lot, user: @user2, status: :in_process
          create :lot, user: @user2, status: :closed
        end

        it "should return 10 lots without params" do
          get :index
          expect(json_parse_response_body[:resources].count).to eq(10)
          expect(response.body).to include(collection_serialize(@lots_in_process, "LotSerializer"))
        end

        it "should return: filter == 'created'" do
          get :index,  params: { filter: "created", page: 3 }
          expect(json_parse_response_body[:resources].count).to eq(2)
        end

        it "should return 1 lots with page 2, and meta(pagination)" do
          get :index, params: { page: 2 }
          expect(json_parse_response_body[:resources].count).to eq(1)
          expect(json_parse_response_body[:meta].count).to be
          serialization = ActiveModelSerializers::SerializableResource.new(@lots_in_process_page_2, serializer: LotSerializer).to_json
          expect(json_parse_response_body[:resources][0]).to eq(json_parse(serialization)[:lot])
        end


        it "should return 10 lots belongs_to user" do
          # get :index, params: { page: 2, user_id: @user2.id }
          get :index, params: { user_id: @user.id }
          expect(json_parse_response_body[:resources].count).to eq(10)
        end

        it "should return correct fields" do
          get :index,  params: { user_id: @user.id }

          lot_attributes = [
              :id, :user_id, :title, :image, :description, :status, :current_price,
              :estimated_price, :lot_start_time, :lot_end_time, :user
          ]

          expect(json_parse_response_body[:resources].first.keys).to eq(lot_attributes)
        end

        it "should return: filter == 'all'" do
          get :index,  params: { filter: "all" }
          expect(json_parse_response_body[:resources].count).to eq(10)
        end

        context "filter with bid" do
          before(:each) do
            # @user - login
            # @user2
            @user3 = create :user
            lot1 = create :lot, current_price: 10.00, status: :in_process, user: @user
            bid1 = create :bid, proposed_price: 11.00, lot_id: lot1.id, user_id: @user2.id

            @lot2 = create :lot, current_price: 15.00, status: :in_process, user: @user2
            bid2  = create :bid, proposed_price: 16.00, lot_id: @lot2.id, user_id: @user.id
            bid23 = create :bid, proposed_price: 17.00, lot_id: @lot2.id, user_id: @user3.id
            bid24 = create :bid, proposed_price: 18.00, lot_id: @lot2.id, user_id: @user.id
            @lot2.update(status: :closed)

            @lot3 = create :lot, current_price: 20.00, status: :in_process, user: @user3
            bid3  = create :bid, proposed_price: 21.00, lot_id: @lot3.id, user_id: @user.id
            bid32 = create :bid, proposed_price: 22.00, lot_id: @lot3.id, user_id: @user2.id
          end

          it "should return lots with: filter == 'participation'" do
            get :index,  params: { filter: "participation" }
            # json_parse_response_body[:resources][0][:bids]
            expect(json_parse_response_body[:resources].count).to eq(2)
            expect(json_parse_response_body[:resources][0][:id]).to eq(@lot2.id)
            expect(json_parse_response_body[:resources][1][:id]).to eq(@lot3.id)
          end
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
