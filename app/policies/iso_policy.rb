class IsoPolicy
  
  C_CLASS_NAME = "IsoPolicy"
  
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    system_admin?
  end

  def show?
    system_admin?
  end

  def create?
    system_admin?
  end

  def new?
    system_admin?
  end

  def update?
    system_admin?
  end

  def edit?
    system_admin?
  end

  def destroy?
    system_admin?
  end

  def scope
    Pundit.policy_scope!(user, record.class)
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope
    end
  end

private

  def reader?
    @user.has_role? Role::C_READER or @user.has_role? Role::C_CURATOR or @user.has_role? Role::C_CONTENT_ADMIN
  end

  def curator?
    @user.has_role? Role::C_CURATOR or @user.has_role? Role::C_CONTENT_ADMIN
  end

  def content_admin?
    @user.has_role? @user.has_role? Role::C_CONTENT_ADMIN
  end

  def system_admin?
    @user.has_role? Role::C_SYS_ADMIN
  end

end
