# frozen_string_literal: true

# class ActionApiController < ActionController::Base
class ActionApiController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken
  include RenderMethods
  include Pundit

  rescue_from ActiveRecord::RecordNotFound do
    render json: { message: "Not found" }, status: :not_found
  end

  rescue_from Pundit::NotAuthorizedError do
    render json: { error: "You are not authorized for this action" }, status: :unprocessable_entity
    # render json: { error: "You are not authorized for this action" }, with: :user_not_authorized
  end
end
