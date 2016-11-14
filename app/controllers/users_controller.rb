class UsersController < ApplicationController

  before_action :authenticate_user!
  before_action :set_user, only: [:show, :edit, :update]

  C_CLASS_NAME = "UsersController"
  
  def new
    authorize User
  end

  def create
    authorize User
    new_user = User.create(user_params)
    if new_user.errors.blank?
      flash[:success] = 'User was successfully created.'
      redirect_to users_path
    else
      flash[:error] = "User was not created. #{new_user.errors.full_messages.to_sentence}."
      redirect_to users_path
    end
  end  

  def index
    authorize User
    @current_user = current_user
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
      redirect_to users_path, success: 'User was successfully updated.'
    else
      flash[:error] = "Failed to update settings for #{@user.email}."
      redirect_to users_path
    end
  end

  def destroy
    authorize User
    delete_user = User.find(params[:id])
    if current_user.id != delete_user.id 
      if delete_user.destroy
        flash[:success] = 'User was successfully deleted.'
        redirect_to users_path
      else
        flash[:error] = "Failed to delete user #{delete_user.email}."
        redirect_to users_path
      end
    else
      flash[:error] = "Cannot delete your own user!"
      redirect_to users_path
    end
  end

private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:username, :email, :password, :password_confirmation, {role_ids: []})
  end

end