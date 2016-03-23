class UploadPolicy < ApplicationPolicy

	def index?
    @user.has_role? :content_admin or @user.has_role? :sys_admin
  end

  def create?
    @user.has_role? :content_admin or @user.has_role? :sys_admin
  end

end