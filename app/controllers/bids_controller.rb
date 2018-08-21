# frozen_string_literal: true

class BidsController < ApiController
  before_action :authenticate_user!

  def index
    # render_resources Bid.where(lot_id: params[:lot_id])
    render_resources Bid.all
  end

  def create
    bid = Bid.create(bid_params)
    render_resource_or_errors(bid)
  end

  def bid_params
    params.permit(:proposed_price, :lot_id, :user_id)
  end
end
