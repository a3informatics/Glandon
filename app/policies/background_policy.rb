class BackgroundPolicy < ApplicationPolicy

	def index?
    content_admin? or system_admin?
  end

	def running?
    content_admin? or system_admin?
  end

  def clear?
    content_admin? or system_admin?
  end

  def clear_completed?
    content_admin? or system_admin?
  end

end