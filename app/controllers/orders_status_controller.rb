# frozen_string_literal: true

class OrdersStatusController < ApiController
  def update
    order = Order.find(params[:id])

    authorize order, "update_status_to_" + order_params[:status].to_s + "?"
    order.update(order_params)
    render_resource_or_errors order
  end

  def order_params
    if ["sent", "delivered"].include?(params[:status])
      params.permit(:status)
    else
      raise ActionController::BadRequest.new("Bad request, wrong params")
    end
  end
end
