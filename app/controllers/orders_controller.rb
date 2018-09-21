# frozen_string_literal: true

class OrdersController < ApiController
  before_action :authenticate_user!

  def create
    order = Order.new(order_params)
    authorize order
    order.save
    render_resource_or_errors(order)
  end

  def show
    order = Order.find(params[:id])
    authorize order
    render_resource(order)
  end

  def update
    order = Order.find(params[:id])
    order.assign_attributes(order_params)

    authorize order
    order.save
    render_resource_or_errors order
  end

  def order_params
    params.permit(:lot_id, :arrival_location, :arrival_type, :status)
  end
end
