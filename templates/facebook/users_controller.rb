class UsersController < ApplicationController
  respond_to :json

  def create 
    @user = User.create_or_update_by_access_token user_params[:access_token] 

    #todo catch koala error if access_token invalid
    @user.entry = Entry.new if @user.entry.nil?
    if @user.save 
      session[:id] = @user.id 
      render json: {redirect: edit_vote_path(@user.entry)}, status: :ok
    else
      render json: {}, status: :unprocessable_entity
    end
  end

  def user_params
    params.require(:user).permit(:access_token)
  end
end
