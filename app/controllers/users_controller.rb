class UsersController < ApplicationController

  before_action :authenticate_user!
  before_action :set_user, only: [:show, :edit, :update]

  C_CLASS_NAME = "UsersController"
  
  def index
    authorize User
    @users = User.all
  end

  def show
    authorize User
  end

  def edit
    authorize User
  end

  def update
    authorize User
    if @user.update(user_params)
      # TODO: Move hardcode flash message into language file
      redirect_to @user, notice: 'User was successfully updated.'
    else
      render :edit
    end
  end

private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:username, :email, {role_ids: []})
  end

end