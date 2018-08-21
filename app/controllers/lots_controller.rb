# frozen_string_literal: true

class LotsController < ApiController
  before_action :authenticate_user!

  def index
    if params[:user_id]
      return render_resources Lot.where(user_id: params[:user_id])
      # return render_resources Lot.where( status: :closed, user_id: current_user.id )
    end
    # lots = Lot.where(status: [:pending, :in_process])
    render_resources Lot.where(status: :in_process)
  end

  def create
    lot = Lot.new(lot_params.merge(user: current_user))
    lot.save
    render_resource_or_errors(lot)
  end

  def show
    lot = Lot.find(params[:id])
    authorize lot
    render_resource(lot)
  end

  def update
    lot = Lot.find(params[:id])
    authorize lot

    lot.update_attributes(lot_params)
    render_resource_or_errors lot
  end

  def destroy
    lot = Lot.find(params[:id])
    authorize lot
    lot.destroy
    render_resource(lot)
  end

  def lot_params
    params.permit(:title, :image, :description, :status, :current_price, :estimated_price, :lot_start_time, :lot_end_time)
  end
end
