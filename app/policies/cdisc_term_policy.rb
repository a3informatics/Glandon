class CdiscTermPolicy < ApplicationPolicy

  def load?
    @user.has_role? :sys_admin
  end

end