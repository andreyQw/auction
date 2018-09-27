# frozen_string_literal: true

class BidsController < ApiController
  def create
    bid = current_user.bids.build(bid_params)
    bid.save

    send_on_broadcast bid
    render_resource_or_errors(bid, serializer: BidSerializer)
  end

  def bid_params
    params.permit(:proposed_price, :lot_id)
  end

  def send_on_broadcast(bid)
    ActionCable.server.broadcast("bids_for_lot_#{bid.lot.id}", BidSerializer.new(bid, scope: current_user, scope_name: :current_user))
  end
end
