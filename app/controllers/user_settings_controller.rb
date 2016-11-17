class UserSettingsController < ApplicationController

  before_action :authenticate_user!
  before_action :set_settings, only: [:index, :show, :edit, :update]

  C_CLASS_NAME = "UsersController"
  
  def index
    authorize UserSetting
    @settings_metadata = @user.settings_metadata
  end

  def update
    authorize UserSetting
    name = user_params[:name]
    value = user_params[:value]
    @user.write_setting(name, value)
    redirect_to user_settings_path
  end

private

  def set_settings
    @user = current_user
    @settings = @user.settings
  end

  def user_params
    params.require(:user_settings).permit(:name, :value)
  end

end