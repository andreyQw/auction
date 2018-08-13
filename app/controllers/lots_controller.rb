# frozen_string_literal: true

class LotsController < ApplicationController
  before_action :authenticate_user!

  def index
    lots = Lot.select(:id, :title, :current_price).where(status: [:pending, :in_progress]).limit(2)
    # lots = Lot.where(status: [:pending, :in_progress]).limit(2)
    render json: { status: "success", message: "all available lots", data: lots }
  end

  def create
    lot = Lot.new(lot_params)
    if lot.save
      render json: {status: "success", message: "lot was created", data:lot}
    else
      render json: {status: "error", message: "lot was't create", data:lot.errors}
    end
  end
  #
  # def show
  #   # GET | /api/users/:id | api/users#show | api_article_path(:id)
  #   user = User.find(params[:id])
  #   render json: {status: 'success', message: 'UsersController::show', data:user}
  # end
  #
  # def edit
  #   # GET | /api/users/:id/edit | api/users#edit | edit_api_article_path(:id)
  # end
  #
  # def update
  #   # PATCH/PUT | /api/users/:id | api/users#update | api_article_path(:id)
  #   user = User.find(params[:id])
  #   if user.update_attributes(user_params)
  #     render json: {status: 'success', message: 'updated user', data:user}
  #   else
  #     render json: {status: 'error', message: 'user not update', data:user.errors}
  #
  #   end
  # end
  #
  # def destroy
  #   # DELETE | /api/users/:id | api/users#destroy | api_article_path(:id)
  #   user = User.find(params[:id])
  #   user.destroy
  #   render json: {status: 'success', message: 'deleted user', data:user}
  # end
  #
  def lot_params
    params.permit(:title, :image, :description, :status, :current_price, :estimated_price, :lot_start_time, :lot_end_time)
  end
end
