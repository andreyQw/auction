# frozen_string_literal: true

class BidsController < ApiController
  def index
    # render_resources Bid.where(lot_id: params[:lot_id])
    render_resources Bid.all
  end

  def create
    bid = Bid.create(bid_params.merge(user: current_user, nickname: "Customer #{current_user.id}"))
    render_resource_or_errors(bid)
  end

  def bid_params
    params.permit(:proposed_price, :lot_id)
  end
end
