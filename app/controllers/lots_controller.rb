# frozen_string_literal: true

class LotsController < ActionApiController
  before_action :authenticate_user!

  def index
    # lots = Lot.select(:id, :title, :current_price).where(status: [:pending, :in_progress]).limit(2)
    lots = Lot.where(status: [:pending, :in_progress]).page(1).per(2)
    pagination = {
      current_page: lots.current_page,
      next_page: lots.next_page,
      prev_page: lots.prev_page,
      total_pages: lots.total_pages,
      total_count: lots.total_count
    }
    render json: { status: "success", message: "all available lots", data: { lots: lots, pagination: pagination } }
  end

  def create
    lot = Lot.new(lot_params.merge(user: current_user))
    lot.save
    render_resource_or_errors(lot)

    # if lot.save
    #   render json: { status: "success", message: "lot was created", data: lot }
    # else
    #   render json: { status: "error", message: "lot was't create", data: lot.errors }
    # end
  end

  def show
    lot = Lot.find(params[:id])
    render_resource(lot)
    # render json: { status: "success", message: "show lot details", data: lot }
  end

  def update
    lot = Lot.find(params[:id])
    user_can_update_lot?(lot)
    lot.update_attributes(lot_params)
    render_resource_or_errors(lot)
    # if current_user.id == lot.user_id && lot.status == "pending"
    #   lot.update_attributes(lot_params)
    #   render json: { status: "success", message: "updated lot", data: lot }
    # else
    #   render json: { status: "error", message: "user or status is not valid", data: lot.errors }
    # end
  end

  def destroy
    lot = Lot.find(params[:id])
    lot.destroy
    render_resource(lot)

    # if current_user.id == lot.user_id && lot.status == "pending"
    #   lot.destroy
    #   render json: { status: "success", message: "lot was deleted", data: lot }
    # else
    #   render json: { status: "error", message: "user or status is not valid", data: lot.errors }
    # end
  end

  def lot_params
    params.permit(:title, :image, :description, :status, :current_price, :estimated_price, :lot_start_time, :lot_end_time)
  end
end
