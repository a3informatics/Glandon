class DashboardPolicy < ApplicationPolicy

	def index?
    reader? || system_admin?
  end

end