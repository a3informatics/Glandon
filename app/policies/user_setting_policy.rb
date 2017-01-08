class UserSettingPolicy < ApplicationPolicy

	def update?
    reader? or system_admin?
  end

end