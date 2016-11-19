class UserPolicy < ApplicationPolicy

	def index?
    system_admin?
  end

  def show?
    system_admin?
  end

  def new?
    system_admin?
  end

  def update?
    system_admin?
  end

  def create?
    system_admin?
  end

  def edit?
    system_admin?
  end

  def destroy?
    system_admin?
  end

end