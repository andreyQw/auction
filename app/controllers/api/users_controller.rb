class Api::UsersController < ApplicationController
  def index
    # GET | /api/users | api/users#index | api_article_path
    users = User.all
    render json: {status: 'success', message: 'UsersController::index', data:users}
  end

  def new
    # GET | /api/users/new | api/users#new | new_api_article_path
  end

  def create
    # POST | /api/users | api/users#create | api_article_path
    user = User.new(user_params)
    if user.save
      render json: {status: 'success', message: 'UsersController::create', data:user}
    else
      render json: {status: 'error', message: 'UsersController::create', data:user.errors}
    end
  end

  def show
    # GET | /api/users/:id | api/users#show | api_article_path(:id)
    user = User.find(params[:id])
    render json: {status: 'success', message: 'UsersController::show', data:user}
  end

  def edit
    # GET | /api/users/:id/edit | api/users#edit | edit_api_article_path(:id)
  end

  def update
    # PATCH/PUT | /api/users/:id | api/users#update | api_article_path(:id)
    user = User.find(params[:id])
    if user.update_attributes(user_params)
      render json: {status: 'success', message: 'updated user', data:user}
    else
      render json: {status: 'error', message: 'user not update', data:user.errors}

    end
  end

  def destroy
    # DELETE | /api/users/:id | api/users#destroy | api_article_path(:id)
    user = User.find(params[:id])
    user.destroy
    render json: {status: 'success', message: 'deleted user', data:user}
  end

  def user_params
    params.permit(:email, :password, :phone, :fname, :lname, :birthday)
  end
end
