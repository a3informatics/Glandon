class BackgroundPolicy < ApplicationPolicy

	def index?
    @user.has_role? :content_admin or @user.has_role? :sys_admin
  end

	def running?
    @user.has_role? :content_admin or @user.has_role? :sys_admin
  end

  def clear?
    @user.has_role? :content_admin or @user.has_role? :sys_admin
  end

end