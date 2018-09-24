# frozen_string_literal: true

class BidsController < ApiController
  before_action :authenticate_user!

  def create
    bid = Bid.create(bid_params.merge(user: current_user))
    render_resource_or_errors(bid, serializer: BidSerializer, current_user_id: current_user.id)
  end

  def bid_params
    params.permit(:proposed_price, :lot_id)
  end
end
