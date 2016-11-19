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
      AuditTrail.create_event(current_user, "User #{user_params[:email]} created.")
      flash[:success] = "User was successfully created."
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
    current_roles = @user.role_list
    if @user.update(user_params)
      AuditTrail.update_event(current_user, "User #{@user.email} roles updated from #{current_roles} to #{@user.role_list}")
      redirect_to users_path, success: "User roles for #{@user.email} successfully updated."
    else
      flash[:error] = "Failed to update roles for #{@user.email}."
      redirect_to users_path
    end
  end

  def destroy
    authorize User
    delete_user = User.find(params[:id])
    delete_email = delete_user.email
    if current_user.id != delete_user.id 
      if delete_user.destroy
        AuditTrail.delete_event(current_user, "User #{delete_email} deleted.")
        flash[:success] = "User #{delete_email} was successfully deleted."
        redirect_to users_path
      else
        flash[:error] = "Failed to delete user #{delete_email}."
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