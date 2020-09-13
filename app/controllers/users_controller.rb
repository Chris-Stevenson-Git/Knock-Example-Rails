class UsersController < ApplicationController
  before_action :authenticate_user,  only: [:index, :current, :update]

  def current
    # render json: current_user
    render json: current_user
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password)
  end


end
