# class ActionApiController < ActionController::Base
class ActionApiController < ActionController::API
  include Pundit
  protect_from_forgery
end