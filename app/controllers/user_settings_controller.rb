class UserSettingsController < ApplicationController

  before_action :authenticate_user!
  before_action :set_settings, only: [:index, :show, :edit, :update]

  C_CLASS_NAME = "UsersController"
  
  def index
    authorize UserSetting
    @settings_metadata = @user.settings_metadata
  end

  #def edit
  #  authorize User
  #end

  def update
    authorize UserSetting
    name = params[:id]
    value = params[:value]
    @user.write_setting(name, value)
  #  if @user.update(user_params)
  #    # TODO: Move hardcode flash message into language file
  #    redirect_to @user, notice: 'User was successfully updated.'
  #  else
  #    render :edit
  #  end
    redirect_to user_settings_path
  end

private

  def set_settings
    @user = current_user
    @settings = @user.settings
  end

  def user_params
    params.require(:user_settings).permit(:id, :value)
  end

end