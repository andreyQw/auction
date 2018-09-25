# frozen_string_literal: true

class ApiController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken
  include RenderMethods
  include Pundit

  rescue_from ActiveRecord::RecordNotFound do
    render json: { message: "Not found" }, status: :not_found
  end

  rescue_from Pundit::NotAuthorizedError do
    render json: { error: "You are not authorized for this action" }, status: :unauthorized
  end

  rescue_from ActionController::BadRequest do |exception|
    render json: { error: exception.message }, status: :bad_request
  end
end
