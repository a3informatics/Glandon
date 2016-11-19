class UploadPolicy < ApplicationPolicy

	def index?
    content_admin? or system_admin?
  end

  def create?
    content_admin? or system_admin?
  end

end