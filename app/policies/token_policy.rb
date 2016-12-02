class TokenPolicy < ApplicationPolicy

	def index?
    system_admin?
  end

	def release?
    system_admin?
  end

end