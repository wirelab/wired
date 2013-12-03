class UsersController < ApplicationController
  respond_to :json

  def create
    @user = User.create_or_update_by_access_token user_params[:access_token]

    if @user.save
      session[:fbid] = @user.fbid
      render json: {user: @user, redirect: root_url}, status: :ok
    else
      render json: {}, status: :unprocessable_entity
    end
  end

  def user_params
    params.require(:user).permit(:access_token)
  end
end
