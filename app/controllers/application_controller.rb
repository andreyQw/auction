# frozen_string_literal: true

# class ApplicationController < ActionController::API
class ApplicationController < ActionController::Base
  include DeviseTokenAuth::Concerns::SetUserByToken
  protect_from_forgery with: :null_session
  before_action :configure_permitted_parameters, if: :devise_controller?

  rescue_from ActiveRecord::RecordNotFound do
    render json: { message: "Not found" }, status: :not_found
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :email, :phone, :first_name, :last_name, :birthday ])
  end
end
