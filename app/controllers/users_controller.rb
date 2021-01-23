class UsersController < ApplicationController

  before_action :authenticate_and_authorize
  before_action :set_user, only: [:show, :edit, :update, :update_name]

  read_access :stats_by_domain
  update_access :lock, :unlock, :update_name
  associated_klasses authorization: User::Access, model: User

  def new
  end

  def create
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
    @current_user = current_user
    @users = User.all
  end

  def show
  end

  def edit
  end

  def update_name
    if @user.update(user_params)
      flash[:success] = "User display name sucessfully updated."
    else
      flash[:error] = "Failed to update user display name. " + (@user.errors.full_messages.to_sentence if !@user.errors.empty?)
    end
    redirect_to user_settings_path
  end

  def update
    ua = @user.my_access
    current_roles = @user.role_list
    if @user.removing_last_admin?(user_params)
      flash[:error] = "You cannot remove the last system administrator."
      redirect_to users_path
    else
      ua.has_role = ids_to_uris(user_params, [:role_ids])[:role_ids]
      if ua.save
        AuditTrail.update_event(current_user, "User #{@user.email} roles updated from #{current_roles} to #{@user.role_list}")
        redirect_to users_path, success: "User roles for #{@user.email} successfully updated."
      else
        flash[:error] = "Failed to update roles for #{@user.email}."
        redirect_to users_path
      end
    end
  end

  def destroy
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
    user = User.find(params[:id])
    user.lock
    flash[:success] = "User was successfully deactivated."
    redirect_to users_path
  end

  def unlock
    user = User.find(params[:id])
    user.unlock
    flash[:success] = "User was successfully activated."
    redirect_to users_path
  end

  def stats_by_domain
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
