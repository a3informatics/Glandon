class UsersController < ApplicationController

  before_action :authenticate_user!
  before_action :set_user, only: [:show, :edit, :update, :update_name]

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

  def update_name
    authorize User
    if @user.update(user_params)
      flash[:success] = "User display name sucessfully updated."
    else
      flash[:error] = "Failed to update user display name. " + (@user.errors.full_messages.to_sentence if !@user.errors.empty?)
    end
    redirect_to user_settings_path
  end

  def update
    authorize User
    current_roles = @user.role_list
    if @user.removing_last_admin?(user_params)
      render json: { errors: [ "You cannot remove the last system administrator." ] }, status: 422 
    else
      if @user.update(user_params)
        AuditTrail.update_event(current_user, "User #{@user.email} roles updated from #{current_roles} to #{@user.role_list}")
        render json: { data: { redirect_url: users_path }}, status: 200
        flash[:success] = "User role for #{@user.email} successfully updated to: #{@user.role_list_stripped}."
      else
        render json: { errors: [ "Failed to update roles for #{@user.email}." ] }, status: 422 
      end
    end
  end

  def destroy
    authorize User
    # Note, no check on deleting the last admin user as cannot delete yourself and
    # you need to be admin to delete.
    user = User.find(params[:id])
    delete_email = user.email
    if current_user.id == user.id
      flash[:error] = "You cannot delete your own user!"
    elsif user.logged_in?
      flash[:error] = "You cannot delete #{delete_email}. User has logged in!"
    else
      user.destroy
      AuditTrail.delete_event(current_user, "User #{delete_email} deleted.")
      flash[:success] = "User #{delete_email} was successfully deleted."
    end
    render :json => { }, status: 200
  end

  def lock
    authorize User, :edit?
    user = User.find(params[:id])
    user.lock
    flash[:success] = "User was successfully deactivated."
    redirect_to users_path
  end

  def unlock
    authorize User, :edit?
    user = User.find(params[:id])
    user.unlock
    flash[:success] = "User was successfully activated."
    redirect_to users_path
  end

  def stats_by_domain
    authorize User, :show?
    render json: {data: User.all.users_by_domain}
  end

private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, {role_ids: []})
  end

end
