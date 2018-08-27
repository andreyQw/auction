# frozen_string_literal: true

class LotsController < ApiController
  before_action :authenticate_user!

  def index
    filter = params[:filter]
    if filter == "all" || filter == nil
      return render_resources Lot.where(status: :in_process)
    elsif filter == "created"
      return render_resources Lot.where(user_id: current_user.id)
    elsif filter == "participation"
      lots = Lot.joins(:bids).where("bids.user_id = #{current_user.id}").distinct
      return render_resources lots
    end
  end

  def create
    lot = Lot.create(lot_params.merge(user: current_user))
    LotsStatusInProcessJob.set(wait_until: lot.lot_start_time).perform_later(lot.id)
    LotsStatusClosedJob.set(wait_until: lot.lot_end_time).perform_later(lot.id)
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
