class IsoPolicy
  
  C_CLASS_NAME = "IsoPolicy"
  
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    sys_admin?
  end

  def show?
    sys_admin?
  end

  def create?
    sys_admin?
  end

  def new?
    sys_admin?
  end

  def update?
    sys_admin?
  end

  def edit?
    sys_admin?
  end

  def destroy?
    sys_admin?
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

  def sys_admin?
    @user.has_role? :sys_admin
  end

end
