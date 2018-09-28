# frozen_string_literal: true

class LotsController < ApiController
  def index
    filter = params[:filter]
    if filter == "all"
      lots = Lot.my_lots_all(current_user.id)
      return render_resources lots
    elsif filter == "created"
      return render_resources Lot.my_lots_created(current_user.id)
    elsif filter == "participation"
      return render_resources Lot.my_lots_participation(current_user.id)
    end
    render_resources Lot.in_process
  end

  def create
    lot = current_user.lots.build(lot_params)
    authorize lot
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
