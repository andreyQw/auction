# frozen_string_literal: true

class OrdersStatusController < ApiController
  def status_update
    order = Order.find(params[:id])
    # order.assign_attributes(order_params)

    authorize order, "update_status_to_" + order_params[:status].to_s + "?"
    order.update(order_params)
    render_resource_or_errors order
  end

  def order_params
    if params[:status] == "sent" || params[:status] == "delivered"
      params.permit(:status)
    else
      {status: "unacceptable"}
    end
  end
end
