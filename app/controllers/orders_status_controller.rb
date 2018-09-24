# frozen_string_literal: true

class OrdersStatusController < ApiController
  def status_update
    order = Order.find(params[:id])
    order.assign_attributes(order_params)

    authorize order
    order.save
    render_resource_or_errors order
  end

  def order_params
    params.permit(:status)
  end
end
