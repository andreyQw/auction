# frozen_string_literal: true

class OrdersController < ApplicationController
  before_action :authenticate_user!

  def create
    order = Order.create(order_params)
    render_resource_or_errors(order)
  end

  def show

  end

  def order_params
    params.permit(:lot_id, :arrival_location, :arrival_type, :status)
  end
end
